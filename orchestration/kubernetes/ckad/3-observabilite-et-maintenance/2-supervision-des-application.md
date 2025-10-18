# Supervision des applications
L'API de métriques Kubernetes fournit des données de métriques sur les performances des conteneurs. Nous pouvons afficher les métriques de pod à l'aide de *kubectl top pod* .<br>

- Installation de metrics-server
```
kubectl apply -f https://raw.githubusercontent.com/ACloudGuru-Resources/content-ckaresources/master/metrics-server-components.yaml
```

NB : Cela peut prendre quelques minutes pour que metrics-server rassemble les métriques initiales et soit disponible.<br>

- utilisation de la commande *kubectl top* <br>
Nous créons un pod qui utilise une quantité détectable de CPU.
```
vi resource-consumer-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: resource-consumer-pod
spec:
  containers:
  - name: resource-consumer
    image: gcr.io/kubernetes-e2e-test-images/resource-consumer:1.5
  - name: busybox-sidecar
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'until curl localhost:8080/ConsumeCPU -d "millicores=100&durationSec=3600"; do sleep 5; done && while true; do sleep 10; done']
```

```
kubectl apply -f resource-consumer-pod.yml
```

Nous pouvons utiliser la commande *kubectl top* pour afficher les métriques des pods.
```
kubectl top pod
kubectl top pod -n default
```

Nous pouvons aussi afficher les métriques d'un noeud :
```
kubectl top node
```