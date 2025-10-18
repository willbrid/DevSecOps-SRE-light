# Débogage dans Kubernetes
Nous pouvons utiliser *kubectl get pods* pour vérifier l'état de tous les pods dans un espace de noms. Nous pouvons utiliser l'option *--all-namespaces* si nous ne savons pas dans quel espace de noms rechercher.<br>
Nous pouvons utiliser *kubectl describe* pour obtenir des informations détaillées sur les objets Kubernetes.<br>
Nous pouvons utiliser *kubectl logs* pour récupérer les journaux de conteneur.<br>
Nous pouvons vérifier les journaux au niveau du cluster si nous ne trouvons toujours aucune information pertinente.<br>

créons un pod avec erreur
```
vi broken-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: broken-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.20.q
    livenessProbe:
      httpGet:
        path: /
        port: 81
      initialDelaySeconds: 3
      periodSeconds: 3
```

```
kubectl apply -f broken-pod.yml
```

Nous pouvons obtenir une liste de pods dans l'espace de noms par défaut :

```
kubectl get pods
kubectl get pods -n default
```

Nous pouvons obtenir une liste de pods dans tous les espaces de noms :

```
kubectl get pods --all-namespaces
```

Nous pouvons obtenir plus de détails sur le Pod :

```
kubectl describe pod broken-pod
```

Une fois le problème d'image détecté, nous pouvons modifiez le yaml pour corriger la version de l'image du pod :
```
vi broken-pod.yml
```

```
...
spec
  containers:
  - image: nginx:1.20.1
...
```

Nous supprimons et recréons le pod :

```
kubectl delete pod broken-pod --force
kubectl apply -f broken-pod.yml
```

Nous pouvons vérifier à nouveau l'état du pod. Nous pouvons remarquer qu'il commence à redémarrer à plusieurs reprises. C'est parce que le liveness probe n'est pas configuré correctement.

```
kubectl get pod broken-pod
```

Nous pouvons vérifier les logs du conteneur :

```
kubectl logs broken-pod
```

Nous pouvons vérifier et editer le manifeste YAML du pod :
```
kubectl get pod broken-pod -o yaml
```

```
vi broken-pod.yml
```

```
...
spec
  containers:
  - ...
    livenessProbe:
      httpGet:
        path: /
        port: 80
...
```

Nous supprimons et recréons le pod :

```
kubectl delete pod broken-pod --force
kubectl apply -f broken-pod.yml
```

Nous pouvons vérifier à nouveau le statut du pod :

```
kubectl get pod broken-pod
```

Le pod devrait maintenant fonctionner correctement.<br>

Nous pouvons vérifier les journaux *kube-apiserver*. Notons que le nom du fichier journal contient un hachage aléatoire. Nous devrons parcourir le système de fichiers dans */var/log/containers/* pour trouver le fichier.

```
sudo cat /var/log/containers/kube-apiserver-k8s-control_kube-system_kube-apiserver-<hash>.log
```

Nous pouvons vérifier les journaux du *kubelet* :
```
sudo journalctl -u kubelet
```