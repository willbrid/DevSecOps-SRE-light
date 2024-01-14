# Utilisation de l'objet daemonSet de k8s
Dans ce tutoriel, nous présenterons la création d'un objet daemonSet qui permet d'éxécuter automatiquement une copie d'un pod sur chaque nœud.<br>

Nous créons un objet daemonSet :
```
vi test-daemonset.yml
```

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: test-daemonset
spec:
  selector:
    matchLabels:
      app: test-daemonset
  template:
    metadata:
      labels:
        app: test-daemonset
    spec:
      containers:
      - name: nginx
        image: nginx:1.19.1
```

```
kubectl create -f test-daemonset.yml
```

Nous listons les pods et vérifions qu'un pod daemonset s'éxécute sur chaque noeud :
```
kubectl get pods -o wide
```