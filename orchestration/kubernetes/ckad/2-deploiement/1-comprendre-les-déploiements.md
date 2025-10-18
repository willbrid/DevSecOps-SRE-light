# Comprendre les déploiements
Un déploiement gère activement un état souhaité pour un ensemble de répliques de pods.<br>
Le modèle de pod fournit la configuration de pod que le déploiement utilisera pour créer de nouveaux pods.<br>
Le champ *replicas* définit le nombre de répliques. Vous pouvez augmenter ou diminuer l'échelle en modifiant cette valeur.<br>

- créons un déploiement
```
vi nginx-deployment.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports: 
        - containerPort: 80
```

```
kubectl apply -f nginx-deployment.yml
```

Nous pouvons checker le status du déploiement :
```
kubectl get deployments
```

Nous pouvons aussi checker les pods de ce déploiement
```
kubectl get pods
```

- Augmentons le nombre de répliques de pod de ce déploiement<br>
Nous pouvons augmenter ce nombre de répliques via la ligne de commande :
```
kubectl scale deployment/nginx-deployment --replicas=4
```

Nous pouvons vérifier l'état du déploiement et les répliques de pods.
```
kubectl get deployment nginx-deployment
kubectl get pods
```

Nous pouvons augmenter ce nombre de répliques en éditant les spécificaitions du déploiement :
```
kubectl edit deployment nginx-deployment
```

```
...
spec:
  ...
  replicas: 2
```

Nous pouvons vérifier l'état du déploiement et les répliques de pods.
```
kubectl get deployment nginx-deployment
kubectl get pods
```

En copiant le nom complet de l'un des pods de déploiement actifs, nous pouvons Supprimer ce pod.
```
kubectl delete pod <Pod name> --force
```

Le déploiement maintiendra l'état souhaité en créant une nouvelle réplique pour remplacer le pod supprimé. Nous pouvons le vérifier en listant les pods de ce déploiement :
```
kubectl get pods
```