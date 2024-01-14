# Implémentation des probes et bilan de santé
Les liveness probes vérifient si un conteneur est sain afin qu'il puisse être redémarré s'il ne l'est pas.
Les Readiness probes vérifient si un conteneur est entièrement démarré et prêt à être utilisé.
Les probes peuvent exécuter une commande à l'intérieur du conteneur, effectuer une requête HTTP ou tenter une connexion socket TCP pour déterminer l'état du conteneur.

## Liveness probe
Nous créons un pod avec un liveness probe qui vérifie l'état du conteneur en vérifiant que la ligne de commande répond.

```
vi liveness-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: liveness-pod
spec:
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'while true; do sleep 10; done']
    livenessProbe:
      exec:
        command: ['echo', 'health check!']
      initialDelaySeconds: 5
      periodSeconds: 5
```

```
kubectl apply -f liveness-pod.yml
```

Nous pouvons vérifier le statut du pod et afficher ses détails :
```
kubectl get pod liveness-pod
```

```
kubectl describe pod liveness-pod
```

## Readiness probe
Nous créons un pod avec une liveness probe et une readiness probe, qui utilisent toutes deux une vérification http.

```
vi readiness-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: readiness-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.20.1
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 15
      periodSeconds: 5
```

```
kubectl apply -f readiness-pod.yml
```

Nous pouvons vérifier l'état du pod. Initialement, le statut sera *Running* mais le conteneur ne sera pas prêt. Attendez un peu et vérifiez à nouveau l'état du pod. Une fois que le readiness probe s'exécute avec succès, le conteneur doit être prêt.

```
kubectl get pod readiness-pod
```