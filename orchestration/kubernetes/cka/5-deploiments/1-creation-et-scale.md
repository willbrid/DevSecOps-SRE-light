# Création et scale d'un objet deployment de k8s
Dans ce tutoriel, nous présenterons la création et le scale d'un objet déployment de k8s.<br>

## création d'un déploiement
Nous créons un deploiement :
```
vi test-deployment.yml
```

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

```
kubectl create -f test-deployment.yml
```

L'on peut lister les déploiements :
```
kubectl get deployments
```

L'on peut lister les pods de ce déploiement :
```
kubectl get pods
```

L'on peut afficher le détail de ce déploiement :
```
kubectl describe deployment test-deployment
```

## scale d'un déploiement
Nous faisons un scale du déploiement *test-deployment* en changeant l'attribut *spec.replicas* dans son fichier manifeste :
```
vi test-deployment.yml
```

```
...
spec:
  replicas: 5
...
```

L'on peut aussi effectuer ce changement via la commande *kubectl* :
```
kubectl edit test-deployment
```

L'on peut aussi appliquer directement ce changement via la commande *kubectl* :
```
kubectl scale deployment.v1.apps/test-deployment --replicas=5
```

L'on peut vérifier ce déploiement et le nombre de ses pods :
```
kubectl get deployments
kubectl get pods
```