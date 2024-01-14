# Gestion des ressources d'un conteneur de l'objet pod sur k8s
Dans ce tutoriel, nous présenterons la gestion des ressources cpu et mémoire d'un conteneur dans un pod.<br>

## attribut *spec.containers.resources.requests*
Nous créons un pod *request-pod* en définissant sa demande en ressource :
```
vi request-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: request-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'while true; do sleep 3600; done']
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
```

```
kubectl create -f request-pod.yml
```

Cela permettra de créer un pod avec sa demande en ressource cpu et mémoire. Ainsi k8s va checker tous les noeuds worker pour vérifier si l'un des noeuds worker possède assez de ressource cpu et mémoire satisfaisant cette demande. Dans le cas contraire, il va laisser le pod à l'état *pending*. Cependant cela n'exclut pas le fait qu'une fois déploié sur un noeud ayant la capacité, le conteneur du pod pourra dépasser cette demande et/ou saturer le noeud.


## attribut *spec.containers.resources.limits*
Nous créons un pod *request-limits-pod* en définissant sa demande en ressource :
```
vi request-limits-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: request-limits-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'while true; do sleep 3600; done']
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "256Mi"
```

```
kubectl create -f request-limits-pod.yml
```

Grâce à l'attribut *spec.containers.resources.limits*, le conteneur du pod sera effectivement limité à la ressource cpu et mémoire qui lui a été définie.