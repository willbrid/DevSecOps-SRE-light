# Gestion des mises à jour continues avec les déploiements
Dans ce tutoriel, nous présenterons la gestion des mises à jours continues des applications via les déploiements.<br>

Nous supposons un déploiement créé avec cette définition :
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: test-deployment
  template:
    metadata:
      labels:
        app: test-deployment
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.1
        ports:
        - containerPort: 80
```

Nous éditons en mode éxécution les spec de ce déploiement en changeant la version de l'image à 1.19.2 :
```
kubectl edit deployment test-deployment
```

```
...
spec:
  containers:
  - name: nginx
    image: nginx:1.19.2
    ...
```

Nous vérifions le statut de la mise à jour, le statut du déploiement et les pods :
```
kubectl rollout status deployment.v1.apps/test-deployment
kubectl get deployment test-deployment
kubectl get pods
``` 

Nous effectuons une autre mise à jour de ce déploiement, cette fois en utilisant la méthode *kubectl set image*. Nous utilisons intentionnellement une mauvaise version d'image.
```
kubectl set image deployment/test-deployment nginx=nginx:broken --record
```

Nous vérifions à nouveau le statut de la mise à jour et nous constatons que la mise à jour échoue en raison d'un échec de téléchargement de l'image *nginx=nginx:broken*.

```
kubectl rollout status deployment.v1.apps/test-deployment
kubectl get pods
```

Nous affichons l'historique des mises à jour de ce déploiement :
```
kubectl rollout history deployment.v1.apps/test-deployment
```

Nous faisons un rollback à un version antérieure du déploiement qui fonctionne correctement :
```
kubectl rollout undo deployment.v1.apps/test-deployment
```

ou en utilisant un numéro spécifique de version :
```
kubectl rollout undo deployment.v1.apps/test-deployment --to-revision=<revisionNum>
``` 

où *revisionNum* est le numéro de la dernière bonne version.