# Utilisation des services k8s
Les services Kubernetes permettent d'exposer une application s'exécutant en tant qu'ensemble de pods. Ils fournissent aux clients un moyen abstrait d'accéder aux applications sans avoir à connaître les pods de l'application. <br>
Nous présentons à présent trois exemples d'utilisation de l'objet *service*.<br>

## service de type *ClusterIP*
Nous créons un déploiement :
```
vi deployment-svc.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-svc
spec:
  replicas: 3
  selector:
    matchLabels:
      app: svc
  template:
    metadata:
      labels:
        app: svc
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.1
        ports:
        - containerPort: 80
```

```
kubectl create -f deployment-svc.yml
```

Nous créons un service de type *clusterIP* :
```
vi svc-clusterip.yml
```

```
apiVersion: v1
kind: Service
metadata:
  name: svc-clusterip
spec:
  type: ClusterIP
  selector:
    app: svc
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

```
kubectl create -f svc-clusterip.yml
```

L'on peut lister les services
```
kubectl get svc
```

L'on peut afficher le détail d'un service
```
kubectl describe svc svc-clusterip
```

L'on peut lister les endpoints d'un service :
```
kubectl get endpoints svc-clusterip
```

Nous créons un pod de test pour notre service :
```
vi pod-svc-test.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-svc-test
spec:
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'while true; do sleep 10; done']
```

```
kubectl create -f pod-svc-test.yml
```

Nous exécutons une commande dans le conteneur *busybox* du pod *pod-svc-test* afin de faire une requête sur le service :
```
kubectl exec pod-svc-test -- curl svc-clusterip:80
```

Vous devriez voir la page d'accueil Nginx, qui est servie par l'un des pods backend créés précédemment à l'aide d'un déploiement.<br>

## service de type *NodePort*
Nous créons un service de type *nodePort* permettant d'exposer directement notre déploiement précédent à l'extérieur du cluster :
```
vi svc-nodeport.yml
``` 

```
apiVersion: v1
kind: Service
metadata:
  name: svc-nodeport
spec:
  type: NodePort
  selector:
    app: svc
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
``` 

```
kubectl create -f svc-nodeport.yml
```

L'on pourra tester le service depuis notre navigateur en saisissant l'adresse : *http://< @IP noeud master>:30080* et l'on pourra voir la page d'accueil Nginx.<br>

## service de type *ClusterIP* avec l'objet Ingress
Nous gérons l'accès à l'application depuis l'extérieur avec l'objet Ingress. Il s'agit d'exposer notre service de type *ClusterIP* à l'extérieur du cluster.<br>
Nous créons notre objet Ingress :
```
vi test-ingress.yml
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - http:
      paths:
      - path: /somepath
        pathType: Prefix
        backend:
          service:
            name: svc-clusterip
            port:
              number: 80
```

```
kubectl create -f test-ingress.yml
```

L'on peut décrire notre objet Ingress :
```
kubectl describe ingress test-ingress
```

Nous pouvons mettre à jour le service ci-dessus pour fournir un nom au port de service :
```
vi svc-clusterip.yml
```

```
apiVersion: v1
kind: Service
metadata:
  name: svc-clusterip
spec:
  type: ClusterIP
  selector:
    app: svc
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
```

```
kubectl apply -f svc-clusterip.yml
```

Ainsi l'on pourra mentionner ce nom au niveau de l'ingress. Au lieu d'utiliser l'attribut *spec.rules.http.paths.backend.service.port.number* , nous utilisons l'attribut *spec.rules.http.paths.backend.service.port.name* :
```
vi test-ingress.yml
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - http:
      paths:
      - path: /somepath
        pathType: Prefix
        backend:
          service:
            name: svc-clusterip
            port:
              name: http
```

```
kubectl apply -f test-ingress.yml
```