# Accès aux journaux de conteneur
La sortie standard/erreur des conteneurs est stockée dans le journal du conteneur.<br>
Nous pouvons afficher le journal du conteneur à l'aide de *kubectl logs* .<br>
Pour les pods multi-conteneurs, nous pouvons utiliser l'option *-c* pour spécifier les journaux du conteneur que nous souhaitons afficher.<br>

Nous créons un pod qui génère les logs :
```
vi logging-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: logging-pod
spec:
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'while true; do echo "Writing to the log!"; sleep 5; done']
```

```
kubectl apply -f logging-pod.yml
```

Nous pouvons afficher les logs :
```
kubectl logs logging-pod
```

ou alors en précisant le conteneur :
```
kubectl logs logging-pod -c busybox
```