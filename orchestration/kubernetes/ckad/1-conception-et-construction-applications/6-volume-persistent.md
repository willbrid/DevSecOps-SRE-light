# Volume persistent
Un *PersistentVolume* définit une ressource de stockage.<br>
Un *PersistentVolumeClaim* définit une requête pour consommer une ressource de stockage.<br>
*PersistentVolumeClaims* se lie automatiquement à un *PersistentVolume* qui répond à leurs critères.<br>
On monte un *PersistentVolumeClaim* sur un conteneur comme un volume normal.<br>
Nous supposerons qu'un fichier /etc/hostPath existe déjà sur chaque noeud worker (voir 5-volume.md).

- Nous créons un *PersistentVolume* qui monte les données à partir de l'hôte.
```
vi hostpath-pv.yml
```

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: hostpath-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  storageClassName: slow
  hostPath:
    path: /etc/hostPath
    type: Directory
```

```
kubectl apply -f hostpath-pv.yml
```

Nous pouvons vérifier le statut du *PersistentVolume*
```
kubectl get pv
```

- Nous créons un *PersistentVolumeClaim* qui se liera au *PersistentVolume*.
```
vi hostpath-pvc.yml
```

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: hostpath-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 200Mi
  storageClassName: slow
```

```
kubectl apply -f hostpath-pvc.yml
```

Nous pouvons vérifier l'état du *PersistentVolumeClaim* pour vérifier qu'il s'est lié au *PersistentVolume*. Le statut doit être
*Bound*, et le volume doit afficher le nom du *PersistentVolume*.
```
kubectl get pvc hostpath-pvc
```

- Nous créons un pod qui monte ce *PersistentVolumeClaim*
```
vi pv-pod-test.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: pv-pod-test
spec:
  restartPolicy: OnFailure
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'cat /data/data.txt']
    volumeMounts:
    - name: pv-host-data
      mountPath: /data
  volumes:
  - name: pv-host-data
    persistentVolumeClaim:
      claimName: hostpath-pvc
```

```
kubectl apply -f pv-pod-test.yml
```

Nous pouvons vérifier le statut du pod :
```
kubectl get pod pv-pod-test
```

Nous pouvons vérifier les journaux du pod et voir la sortie des données *PersistentVolume* indiquant sur quel nœud de travail le pod s'exécute.
```
kubectl logs pv-pod-test
```