# Attribution des pods aux nœuds
Dans ce tutoriel, nous présenterons deux façons d'attribuer un pod à un noeud : via l'attribut *spec.nodeSelector* et via l'attribut *spec.nodeName*.<br>

## attribution via *nodeSelector*
Nous listons l'ensemble de nos noeuds du cluster :

```
kubectl get nodes
``` 

Nous affectons un label à un noeud worker par exemple : *k8s-worker1* .
```
kubectl label nodes k8s-worker1 special=true
```

Nous créons un pod en utilisant l'attribut *spec.nodeSelector* :
```
vi nodeselector-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: nodeselector-pod
spec:
  nodeSelector:
    special: "true"
  containers:
  - name: nginx
    image: nginx:1.19.1
```

```
kubectl create -f nodeselector-pod.yml
```

Pour vérifier si effectivement ce pod a été déploié sur le noeud *k8s-worker1*, nous éxécutons la commande :
```
kubectl get pod nodeselector-pod -o wide
```

## attribution via *nodeName*
Nous listons l'ensemble de nos noeuds du cluster :

```
kubectl get nodes
```

Nous choisissons un noeud worker par exemple : *k8s-worker2* .<br>
Nous créons un pod en utilisant l'attribut *spec.nodeName* :
```
vi nodename-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: nodename-pod
spec:
  nodeName: k8s-worker2
  containers:
  - name: nginx
    image: nginx:1.19.1
```

```
kubectl create -f nodename-pod.yml
```

Pour vérifier si effectivement ce pod a été déploié sur le noeud *k8s-worker2*, nous éxécutons la commande :
```
kubectl get pod nodename-pod -o wide
```