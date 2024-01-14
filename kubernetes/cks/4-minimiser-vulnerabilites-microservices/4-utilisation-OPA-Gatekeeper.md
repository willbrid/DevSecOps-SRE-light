# Utilisation de OPA Gatekeeper

Qu'est-ce qu'OPA Gatekeeper ? <br>
Open Policy Agent (OPA) Gatekeeper nous permet d'appliquer des politiques hautement personnalisables sur tout type d'objet k8s au moment de sa création. Les politiques sont définies à l'aide de l'**OPA Constraint Framework**.<br>

Avec OPA Gatekeeper, nous pouvons contrôler des choses comme :
- référentiel d'image : Les images doivent provenir uniquement de certains référentiels pré-approuvés.
- labels: Tous les déploiements doivent inclure certains libellés informatifs.
- limites de ressources : Tous les pods doivent spécifier des limites de ressources.<br>

Un modèle de contrainte définit un schéma pour une contrainte et la logique Rego qui appliquera la contrainte.<br>
Les modèles de contrainte définissent une logique de contrainte réutilisable et tous les paramètres pouvant être transmis.<br>
Les modèles utilisent un langage appelé Rego ("ray-go") pour définir la logique de contrainte.<br>
Une contrainte attache la logique dans un modèle de contrainte aux objets k8s entrants avec tous les paramètres définis dans le modèle de contrainte.<br>
Un modèle de contrainte crée un nouveau type d'objet k8s que nous pouvons utiliser pour créer des objets de contrainte.<br>
Les objets de contrainte appliquent un modèle de contrainte à un groupe spécifique d'objets entrants potentiels, ainsi que des paramètres spécifiques.<br>

**match** détermine à quel(s) nouvel(s) objet(s) la contrainte s'appliquera. <br>
**parameters** est transmis au modèle de contrainte.

## Installer OPA Gatekeeper sur le cluster

```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
```

Vérifions l'état des pods OPA Gatekeeper et attendons qu'ils soient tous complètement activés.

```
kubectl get pods -n gatekeeper-system -w
```

## Modèle de contrainte

Créons un objet ConstraintTemplate qui peut être utilisé pour appliquer les exigences relatives aux étiquettes (labels) sur les objets.

```
vi k8srequiredlabels.yml
```

```
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        # Schema for the `parameters` field
        openAPIV3Schema:
          properties:
            labels:
              type: array
              items: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels

        violation[{"msg": msg, "details": {"missing_labels": missing}}] {
          provided := {label | input.review.object.metadata.labels[label]}
          required := {label | label := input.parameters.labels[_]}
          missing := required - provided
          count(missing) > 0
          msg := sprintf("you must provide labels: %v", [missing])
        }
```

```
kubectl create -f k8srequiredlabels.yml
```

## Contrainte

Créons une contrainte à partir du modèle de contrainte qui exige que les déploiements aient une étiquette appelée *contact* .

```
vi dep-must-have-contact.yml
```

```
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: dep-must-have-contact
spec:
  match:
    kinds:
    - apiGroups: ["apps"]
      kinds: ["Deployment"]
  parameters:
    labels: ["contact"]
```

```
kubectl create -f dep-must-have-contact.yml
```

## Testons la contrainte

créons un déploiement sans l'étiquette : *contact*.

```
vi opa-test-deployment.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opa-test-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: opa-test
  template:
    metadata:
      labels:
        app: opa-test
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

```
kubectl create -f opa-test-deployment.yml
```

Cela devrait échouer, car le déploiement n'a pas l'étiquette requise.<br>
Modifions le manifeste de ce déploiement et ajoutons l'étiquette

```
vi opa-test-deployment.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opa-test-deployment
  labels:
    contact: william_bridge
spec:
  replicas: 1
  selector:
    matchLabels:
      app: opa-test
  template:
    metadata:
      labels:
        app: opa-test
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

```
kubectl apply -f opa-test-deployment.yml
```

Cela devrait réussir, car le déploiement a l'étiquette requise.