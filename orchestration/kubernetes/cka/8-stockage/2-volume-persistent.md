# Utilisation de volume persistent k8s
Les volumes persistants sont une forme légèrement plus avancée de volume. Ils vous permettent de traiter le stockage comme une ressource abstraite et de le consommer à l'aide de vos pods.<br>
Les volumes et les volumes persistants ont chacun un type de volume. Le type de volume détermine la manière dont le stockage est réellement géré. Différents types de volumes prennent en charge des méthodes de stockage telles que :
- NFS
- mécanismes de stockage cloud (AWS, Azure, GCP)
- les objets ConfigMaps et Secrets
- un répertoire simple sur un nœud worker

## StorageClass
Les objets StorageClass permettent aux administrateurs de k8s de spécifier les types de services de stockage qu'ils proposent sur leur plateforme.<br>
Nous créons un objet StorageClass qui prend en charge l'extension de volume.
```
vi localdisk-sc.yml
```

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: localdisk
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: true
```

```
kubectl create -f localdisk-sc.yml
```

L'attribut *allowVolumeExpansion* permettra d'étendre une requête de volume de persistent (PersistentVolumeClaim).

## volume persistent
Un volume persistent utilise un ensemble d'attributs pour décrire la ressource de stockage sous-jacente (telle qu'un disque ou un emplacement de stockage dans le cloud) qui sera utilisée pour stocker les données.<br>
Nous créons un volume persistent qui utilise notre objet StorageClass :
```
vi test-pv.yml
```

```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: test-pv
spec:
  storageClassName: localdisk
  persistentVolumeReclaimPolicy: Recycle
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /var/output
```

```
kubectl create -f test-pv.yml
```

L'attribut *spec.persistentVolumeReclaimPolicy* détermine comment les ressources de stockage peuvent être réutilisées lorsque les objets *PersistentVolumeClaims* associés à un objet *PersistentVolume* sont supprimés :
- Retain : valeur permettant de conserver toutes les données. Cela nécessite qu'un administrateur nettoie manuellement les données et prépare la ressource de stockage pour la réutilisation.
- Delete : valeur permettant de supprimer automatiquement la ressource de stockage sous-jacente (ne fonctionne que pour les ressources de stockage cloud).
- Recycle : valeur permettant de supprimer automatiquement toutes les données de la ressource de stockage sous-jacente, ce qui permet de réutiliser l'objet PersistentVolume.

L'attribut *spec.capacity.storage* permet de définir la valeur de la capacité de stockage (en Gi, en Mi).

L'attribut *spec.accessModes* permet de définir le mode d'accès :
- ReadWriteOnce : le volume peut être monté en lecture-écriture par un seul nœud
- ReadOnlyMany : le volume peut être monté en lecture seule par plusieurs nœuds
- ReadWriteMany : le volume peut être monté en lecture-écriture par plusieurs nœuds

L'on peut afficher la liste des volumes persistents :
```
kubectl get pv
```

## requête de volume persistent
Nous créons un objet *PersistentVolumeClaim* qui sera lié à l'objet PersistentVolume :
```
vi test-pvc.yml
```

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  storageClassName: localdisk
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
```

```
kubectl create -f test-pvc.yml
```

Les objets PersistentVolume et PersistentVolumeClaim doivent avoir les mêmes valeurs de l'objet storageClass et du mode d'accès.<br>
L'attribut *spec.resources.requests.storage* permet de définir la valeur de la requête de stockage au près du volume persistent.<br>

L'on peut vérifier l'état des objets PersistentVolume et PersistentVolumeClaim pour vérifier qu'ils ont été liés :
```
kubectl get pv
kubectl get pvc
```

Nous créons un pod qui utilisera l'objet *PersistentVolumeClaim* :
```
vi pvc-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'echo Success! > /output/success.txt']
    volumeMounts:
    - name: pvc-storage
      mountPath: /output
  volumes:
  - name: pvc-storage
    persistentVolumeClaim:
      claimName: test-pvc
```

```
kubectl create -f pvc-pod.yml
```

Nous pouvons étendre la capacité de l'objet *PersistentVolumeClaim* :
```
kubectl edit pvc test-pvc --record
```

```
...
spec:
  ...
  resources:
    requests:
      storage: 200Mi
```

Nous pouvons supprimer le pod et notre objet *PersistentVolumeClaim* :
```
kubectl delete pod pvc-pod
kubectl delete pvc test-pvc
```

Nous vérifions l'état de l'objet PersistentVolume pour vérifier qu'il a été recyclé avec succès et qu'il est à nouveau disponible.