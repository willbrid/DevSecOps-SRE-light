# Déploiement avec les stratégies blue/green et canary
Nous pouvons utiliser plusieurs déploiements pour configurer des environnements blue/green dans Kubernetes.<br>
Nous pouvons utiliser des libellés et des sélecteurs sur les services pour diriger le trafic utilisateur vers différents pods.<br>
Un moyen simple de configurer un environnement Canary dans Kubernetes consiste à utiliser un service qui sélectionne les pods à partir de 2 déploiements différents. Variez le nombre de répliques pour diriger moins d'utilisateurs vers l'environnement Canary.

## Stratégie de déploiement blue/green
- Nous créons un déploiement blue :
```
vi blue-deployment.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blue-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bluegreen-test
      color: blue
  template:
    metadata:
      labels:
        app: bluegreen-test
        color: blue
    spec:
      containers:
      - name: nginx
        image: linuxacademycontent/ckad-nginx:blue
        ports:
        - containerPort: 80
```

```
kubectl apply -f blue-deployment.yml
```

Nous créons un service qui permet de router le traffic vers le déploiement bleu :
```
vi bluegreen-test-svc.yml
```

```
apiVersion: v1
kind: Service
metadata:
  name: bluegreen-test-svc
spec:
  selector:
    app: bluegreen-test
    color: blue
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

```
kubectl apply -f bluegreen-test-svc.yml
```

Nous affichons l'adresse IP du service de type clusterIP *bluegreen-test-svc* et faisons un test d'accès au service :
```
kubectl get service bluegreen-test-svc
```

```
curl <bluegreen-test-svc cluster IP address>
```

- Nous créons un déploiement green :
```
vi green-deployment.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: green-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bluegreen-test
      color: green
  template:
    metadata:
      labels:
        app: bluegreen-test
        color: green
    spec:
      containers:
      - name: nginx
        image: linuxacademycontent/ckad-nginx:green
        ports:
        - containerPort: 80
```

```
kubectl apply -f green-deployment.yml
```

Nous vérifions le statut de ce déploiement green :
```
kubectl get deployment green-deployment
```

Nous testons de manière directe le déploiement green en obtenant l'adresse IP de son pod, puis en utilisant la ligne de commande curl :
```
kubectl get pods -o wide
```

```
curl <green-deployment Pod IP address>
```

Si la commande s'exécute en succès, nous éditons les sélecteurs du service *bluegreen-test-svc* pour diriger le trafic vers le déploiement green :
```
kubectl edit service bluegreen-test-svc
```

```
...
spec:
  selector:
    app: bluegreen-test
    color: green
...    
```

Nous testons à nouveau le service. La réponse à la commande curl doit indiquer que nous communiquons avec la version green du pod de déploiement green.
```
kubectl get service bluegreen-test-svc
```

```
curl <bluegreen-test-svc cluster IP address>
```

## Stratégie de déploiement canary
- Nous créons un déploiement principal :
```
vi main-deployment.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: main-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: canary-test
      environment: main
  template:
    metadata:
      labels:
        app: canary-test
        environment: main
    spec:
      containers:
      - name: nginx
        image: linuxacademycontent/ckad-nginx:1.0.0
        ports:
        - containerPort: 80
```

```
kubectl apply -f main-deployment.yml
```

Nous créons un service permettant d'exposer ce déploiement principal :
```
vi canary-test-svc.yml
```

```
apiVersion: v1
kind: Service
metadata:
  name: canary-test-svc
spec:
  selector:
    app: canary-test
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

```
kubectl apply -f canary-test-svc.yml
```

Nous affichons l'adresse IP du service *canary-test-svc* de type clusterIP et faisons un test d'accès au service :
```
kubectl get service canary-test-svc
```

```
curl <canary-test-svc cluster IP address>
```

- Nous créons un déploiement canary
```
vi canary-deployment.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: canary-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: canary-test
      environment: canary
  template:
    metadata:
      labels:
        app: canary-test
        environment: canary
    spec:
      containers:
      - name: nginx
        image: linuxacademycontent/ckad-nginx:canary
        ports:
        - containerPort: 80
```

```
kubectl apply -f canary-deployment.yml
```

Nous restestons le service via la commande :
```
curl <canary-test-svc cluster IP address>
```