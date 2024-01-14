# Effectuer des mises à jour continues
Une mise à jour progressive déploie progressivement les modifications apportées au modèle de pod de déploiement en remplaçant progressivement les répliques par de nouvelles.<br>
Utilisez *kubectl rollout status* pour vérifier l'état d'une mise à jour progressive.<br>
Annulez la dernière mise à jour continue avec : *kubectl rollout undo* .<br>

- créons un déploiement
```
vi rolling-deployment.yml
```

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-deployment
spec:
  replicas: 5
  selector:
    matchLabels:
      app: rolling
  template:
    metadata:
      labels:
        app: rolling
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

```
kubectl apply -f rolling-deployment.yml
```

Nous pouvons vérifier l'état du déploiement et attendre que toutes les répliques démarrent complètement.

- mettons à jour l'image du déploiement<br>

Nous pouvons mettre l'image du déploiement via la ligne de commande :
```
kubectl set image deployment.v1.apps/rolling-deployment nginx=nginx:1.16.1
```

Nous pouvons consulter la liste des pods. Les pods du déploiement seront progressivement remplacés par de nouveaux pods exécutant la nouvelle version de l'image.
```
kubectl get pods
```

Nous pouvons afficher l'état de la mise à jour du déploiement.
```
kubectl rollout status deployment/rolling-deployment
```

Nous pouvons mettre l'image du déploiement en éditant la manifest du déploiement :
```
kubectl edit deployment rolling-deployment
```

```
...
spec
...
  containers:
  - name: nginx
    image: nginx:1.20.1
...    
```

Nous pouvons afficher l'état de la mise à jour du déploiement.
```
kubectl rollout status deployment/rolling-deployment
```

Nous pouvons annuler la dernière mise à jour :
```
kubectl rollout undo deployment/rolling-deployment
```

Nous pouvons afficher l'état de la mise à jour du déploiement et ses pod.
```
kubectl rollout status deployment/rolling-deployment
kubectl get pods
```

Copions l'un des noms de pod. Utilisons-le pour vérifier l'un des pods pour voir s'il utilise la version d'image 1.16.1.
```
kubectl describe pod <Pod name>
```