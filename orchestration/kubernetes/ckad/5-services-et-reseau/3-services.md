# Explorer les services
Les services vous permettent d'exposer une application s'exécutant dans plusieurs pods.<br>
Les services ClusterIP exposent les pods à d'autres applications au sein du cluster.<br>
Les services NodePort exposent les pods en externe à l'aide d'un port qui écoute sur chaque nœud du cluster.<br>

- créons un pod serveur
```
vi service-server-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: service-server-pod
  labels:
    app: service-server
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
    - containerPort: 80
```

```
kubectl apply -f service-server-pod.yml
```

- Créons un service de type ClusterIP
```
vi clusterip-service.yml
```

```
apiVersion: v1
kind: Service
metadata:
  name: clusterip-service
spec:
  type: ClusterIP
  selector:
    app: service-server
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
```

```
kubectl apply -f clusterip-service.yml
```

Nous pouvons obtenir l'adresse IP du cluster pour le service.
```
kubectl get svc clusterip-service
```

Utilisez l'adresse IP du cluster pour tester le service.
```
curl <service cluster IP address>:8080
```

- Créons un service de type NodePort
```
vi nodeport-service.yml
```

```
apiVersion: v1
kind: Service
metadata:
  name: nodeport-service
spec:
  type: NodePort
  selector:
    app: service-server
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
    nodePort: 30080
```

```
kubectl apply -f nodeport-service.yml
```

Testons le service NodePort. Le port du nœud externe écoute directement sur l'hôte, nous pouvons donc y accéder en utilisant localhost .
```
curl localhost:30080
```

Nous pouvons également utiliser l'adresse IP publique de n'importe lequel de nos nœuds Kubernetes pour accéder au service à l'adresse http://<Node Public IP address>:30080 .