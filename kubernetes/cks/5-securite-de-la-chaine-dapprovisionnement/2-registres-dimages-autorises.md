# Registres d'images autorisés

- **Registres d'images** : c'est un service qui stocke des images de conteneurs et les propose en téléchargement. Lorsque nous exécutons un conteneur dans Kubernetes, le nœud télécharge automatiquement l'image à partir d'un registre.

- **Restreindre les registres autorisés** : une façon d'empêcher les téléchargements à partir de registres non approuvés consiste à restreindre les registres pouvant être utilisés dans le cluster. Ce qui permettra de limiter les utilisateurs aux seuls registres d'images fiables afin de les empêcher d'exécuter des images provenant de sources non fiables dans le cluster. Une façon de le faire est d'utiliser **OPA Gatekeeper**.

- Créons un objet **ConstraintTemplate** qui nous permet de mettre en liste blanche les registres autorisés :

```
vi k8sallowedrepos.yml
```

```
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sallowedrepos
spec:
  crd:
    spec:
      names:
        kind: K8sAllowedRepos
      validation:
        # Schema for the `parameters` field
        openAPIV3Schema:
          properties:
            repos:
              type: array
              items:
                type: string
  targets:
  - target: admission.k8s.gatekeeper.sh
    rego: |
      package k8sallowedrepos
      violation[{"msg": msg}] {
        container := input.review.object.spec.containers[_]
        satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]
        not any(satisfied)
        msg := sprintf("container <%v> has an invalid image repo <%v>, allowed repos are %v", [container.name, container.image, input.parameters.repos])
      }
      violation[{"msg": msg}] {
        container := input.review.object.spec.initContainers[_]
        satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]
        not any(satisfied)
        msg := sprintf("container <%v> has an invalid image repo <%v>, allowed repos are %v", [container.name, container.image, input.parameters.repos])
      }      
```

```
kubectl create -f k8sallowedrepos.yml
```

- Créons une contrainte qui n'autorise que les images de Docker Hub :

```
vi whitelist-dockerhub.yml
```

```
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sAllowedRepos
metadata:
  name: whitelist-dockerhub
spec:
  match:
    kinds:
    - apiGroups: [""]
      kinds: ["Pod"]
  parameters:
    repos:
    - "docker.io"
```

```
kubectl create -f whitelist-dockerhub.yml
```

- Créons un pod qui utilise une image de Docker Hub

```
vi dh-busybox.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: dh-busybox
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: docker.io/library/busybox
    command: ['sh', '-c', 'sleep 3600']
```

```
kubectl create -f dh-busybox.yml
```

- Essayons de créer un pod qui utilise une image d'un registre bloqué

```
vi gcr-busybox.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: gcr-busybox
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: gcr.io/google-containers/busybox
    command: ['sh', '-c', 'sleep 3600']
```

```
kubectl create -f gcr-busybox.yml
```

Cela devrait échouer car il n'utilise pas de registre approuvé.
<br>
Nous pouvons aussi supprimer la contrainte pour la désactiver

```
kubectl delete K8sAllowedRepos whitelist-dockerhub
```