# Inspection de l'utilisation des ressources de pod
Dans ce tutoriel, nous installerons l'outil **metrics server** afin d'inspecter l'utilisation des ressources cpu et mémoire des pods.

## Installation de metrics server dans le cluster
Sur le noeud master, nous exécutons la commande :
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
Lien: [metrics server github](https://github.com/kubernetes-sigs/metrics-server) <br>
Nous patientons quelques minutes, puis nous exécutons la commande de vérification du bon fonctionnement de metrics server :
```
kubectl get --raw /apis/metrics.k8s.io/
```

## Création et supervision des pods
Nous définissons un objet pod metrics-test-pod :
```
vi metrics-test-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: metrics-test-pod
  labels:
    app: metrics-test
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do sleep 3600; done']
```

```
kubectl create -f metrics-test-pod.yml
```

Pour visualiser l'utilisation des ressources des pods :
```
kubectl top pod
```

L'on peut trier cet affichage via l'option **--sort-by** :
```
kubectl top pod --sort-by cpu
```
Cela permettra d'afficher l'utilisation des ressources de pods en appliquant un tri par ordre décroissant du cpu.<br>
L'on peut filtrer cet affichage avec l'option **--selector** :
```
kubectl top pod --selector app=metrics-test
``` 
Cela permettra d'afficher l'utilisation des ressources de pods pour tous les pods ayant le label *app=metrics-test*.