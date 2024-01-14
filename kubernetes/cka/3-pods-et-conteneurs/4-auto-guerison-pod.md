# Auto-guérison des pods sur k8s avec les stratégies de redémarrage
Dans ce tutoriel, nous présenterons les différentes stratégies de redémarrage des pods dans un cluster.<br>

## La stratégie de redémarrage : Always
Nous créons un pod avec la stratégie *Always* qui se termine après quelques secondes.

```
vi always-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: always-pod
spec:
  restartPolicy: Always
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'sleep 10']
```

```
kubectl create -f always-pod.yml
```

Ce pod sera créé et redémarré toutes les 10 secondes.<br>

La stratégie *Always* est la politique de redémarrage par défaut dans K8s. Avec cette stratégie, les conteneurs seront toujours redémarrés s'ils s'arrêtent, même s'ils se sont terminés avec succès. Utilisez cette stratégie pour les applications qui doivent toujours être en cours d'exécution.<br>

## La stratégie de redémarrage : OnFailure
Nous créons deux pods *onfailure-pod1* et *onfailure-pod2* avec la stratégie *OnFailure*.

```
vi onfailure-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: onfailure-pod1
spec:
  restartPolicy: OnFailure
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'sleep 10']
---
apiVersion: v1
kind: Pod
metadata:
  name: onfailure-pod2
spec:
  restartPolicy: OnFailure
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'sleep 10; this is a bad command that will fail']
```

```
kubectl create -f onfailure-pod.yml
```

Le pod *onfailure-pod1* est créé et après 10 secondes, il est en état arrêté. Ce pod ne redémarre pas car il s'est terminé avec succès.<br>
Le pod *onfailure-pod2* est créé et après 10 secondes, il est en état arrêté avec un code d'erreur. Ce pod redémarre car il s'est arrêté avec un code d'erreur.<br>

La stratégie *OnFailure* redémarrera les conteneurs uniquement si le processus de conteneur se termine avec un code d'erreur ou si le conteneur est déterminé comme étant défectueux par un *liveness probe*. Utilisez cette stratégie pour les applications qui doivent s'exécuter correctement, puis s'arrêter.<br>

## La stratégie de redémarrage : Never
Nous créons un pod avec la stratégie *Never*.
```
vi never-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: never-pod
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'sleep 10; this is a bad command that will fail']
```

```
kubectl create -f never-pod.yml
```

Même en cas d'erreur, ce pod ne va jamais se redemarrer.<br>

La stratégie *Never* cela empêchera le redémarrage des conteneurs du pod, même si le conteneur se ferme ou si un *liveness probe* échoue. Utilisez ceci pour les applications qui doivent s'exécuter une fois et ne jamais être redémarrées automatiquement.