# Gestion de l'utilisation des ressources
Une demande de ressources informe le cluster de l'utilisation prévue des ressources pour un conteneur. Il est utilisé pour sélectionner un nœud disposant de suffisamment de ressources disponibles pour exécuter le pod.<br>
Une limite de ressources définit une limite supérieure sur le nombre de ressources qu'un conteneur peut utiliser. Si le processus de conteneur tente de dépasser cette limite, le processus de conteneur sera arrêté.<br>
Un *ResourceQuota* limite la quantité de ressources pouvant être utilisées dans un espace de noms spécifique. Si un utilisateur tente de créer ou de modifier des objets dans cet espace de noms de sorte que le quota soit dépassé, la demande sera refusée.

## Demande et limite de ressource
créons un espace de nom
```
kubectl create namespace resources-test
```

créons un pod avec la définition de la demande et de la limite de ressource
```
vi resources-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: resources-pod
  namespace: resources-test
spec:
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'while true; do echo Running...; sleep 5; done']
    resources:
      requests:
        memory: 64Mi
        cpu: 250m
      limits:
        memory: 128Mi
        cpu: 500m
```

```
kubectl apply -f resources-pod.yml
```

Nous vérifions l'état du nouveau pod.
```
kubectl get pods -n resources-test
```

## ResourceQuota
Nous activons le contrôleur d'admission *ResourceQuota*.
```
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

Localisons l'indicateur *--enable-admission-plugins* et ajoutons *ResourceQuota* à la liste.
```
- --enable-admission-plugins=NodeRestriction,ResourceQuota
```

Nous créons un objet *ResourceQuota*
```
vi resources-test-quota.yml
```

```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: resources-test-quota
  namespace: resources-test
spec:
  hard:
    requests.memory: 128Mi
    requests.cpu: 500m
    limits.memory: 256Mi
    limits.cpu: "1"
```

```
kubectl apply -f resources-test-quota.yml
```

Essayons de créer un pod qui dépasserait le quota de limite de mémoire pour l'espace de noms.
```
vi too-many-resources-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: too-many-resources-pod
  namespace: resources-test
spec:
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'while true; do echo Running...; sleep 5; done']
    resources:
      requests:
        memory: 64Mi
        cpu: 250m
      limits:
        memory: 200Mi
        cpu: 500m
```

```
kubectl apply -f too-many-resources-pod.yml
```

Cela devrait échouer, car ce pod, aux côtés du pod existant, dépasserait le quota de limite de mémoire pour l'espace de noms.