# Pod multi-conteneur et pod avec conteneur init
Dans ce tutoriel, nous présenterons comment créer un pod avec plusieurs conteneurs : pod multi-conteneur et pod avec conteneur init.<br>

## pod multi-conteneur
Nous créons un pod multi-conteneur qui utilise un stockage partagé.

```
vi sidecar-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
spec:
  containers:
  - name: busybox1
    image: busybox
    command: ['sh', '-c', 'while true; do echo logs data > /output/output.log; sleep 5; done']
    volumeMounts:
    - name: sharedvol
      mountPath: /output
  - name: sidecar
    image: busybox
    command: ['sh', '-c', 'tail -f /input/output.log']
    volumeMounts:
    - name: sharedvol
      mountPath: /input
  volumes:
  - name: sharedvol
    emptyDir: {}
```

```
kubectl create -f sidecar-pod.yml
```

Le conteneur *busybox1* écrit ses logs dans un fichier */output/output.log* monté depuis le volume *sharedvol* et le conteneur *sidecar* lit ces logs dans un fichier */input/output.log* monté depuis ce même volume.<br>
L'on pourra visualiser les logs de conteneur sidecar :
```
kubectl logs sidecar-pod -c sidecar
```

## pod avec un conteneur init
Nous créons un pod avec un conteneur init qui retarde le démarrage de 30 secondes.

```
vi init-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.19.1
  initContainers:
  - name: delay
    image: busybox
    command: ['sleep', '30']
```

```
kubectl create -f init-pod.yml
```