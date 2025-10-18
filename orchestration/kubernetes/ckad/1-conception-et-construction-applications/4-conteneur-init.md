# Conteneur init
Les conteneurs d'initialisation s'exécutent jusqu'à la fin avant le démarrage du conteneur principal.<br>
Ajoutez des conteneurs init en utilisant le champ *initContainers* du PodSpec.<br>

- Nous créons un pod avec un conteneur Init qui retarde le démarrage de 60 secondes.
```
vi init-test.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: init-test
spec:
  containers:
  - name: nginx
    image: nginx:stable
  initContainers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'sleep 60']
```

```
kubectl apply -f init-test.yml
```

- Nous pouvons vérifier l'état du pod.
```
kubectl get pod init-test
```

- Nous attendons environ 60 secondes que le conteneur d'initialisation se termine, puis nous vérifions à nouveau l'état.
```
kubectl get pod init-test
```