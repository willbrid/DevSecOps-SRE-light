# Troubleshooter une application
Il s'agira de troubleshooter les pods d'une application.<br>

- Nous pouvons consulter le statut des pods
```
kubectl get pods
```

- Nous pouvons afficher le détail d'un pod
```
kubectl describe pod podname
```

- Nous pouvons éxécuter une commande à l'intérieur du pod
```
kubectl exec podname -c containername -- command
```

- Nous pouvons accéder au conteneur du pod en mode interactif shell
```
kubectl exec podname -c containername --stdin --tty -- /bin/sh
```

- Nous pouvons consulter les journaux du conteneur d'un pod
```
kubectl logs podname -c containername
```