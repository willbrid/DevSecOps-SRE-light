# Volume
Le champ *volumes* dans la spécification du pod définit les détails des volumes utilisés dans le pod.<br>
Le champ *volumeMounts* dans la spécification de conteneur monte un volume sur un conteneur spécifique à un emplacement spécifique.<br>
Les volumes *hostPath* montent les données à partir d'un emplacement spécifique sur l'hôte (nœud k8s).<br>
Les types de volume *hostPath* :
- Directory – Monte un répertoire existant sur l'hôte.
- DirectoryOrCreate - Monte un répertoire sur l'hôte et le crée s'il n'existe pas.
- File – Monte un fichier unique existant sur l'hôte.
- FileOrCreate - Monte un fichier sur l'hôte et le crée s'il n'existe pas.<br>
Les volumes *emptyDir* fournissent un stockage temporaire qui utilise le système de fichiers hôte et sont supprimés si le pod est supprimé.

## Volume hostpath de type Directory
- Nous nous loguons sur le noeud worker1
Nous créons un répertoire et un fichier avec des données sur le noeud worker1.
```
sudo mkdir /etc/hostPath
```

```
echo "This is worker 1!" | sudo tee /etc/hostPath/data.txt
```

- Nous nous loguons sur le noeud worker2
Nous créons un répertoire et un fichier avec des données sur le noeud worker2.
```
sudo mkdir /etc/hostPath
```

```
echo "This is worker 2!" | sudo tee /etc/hostPath/data.txt
```

- Nous nous loguons sur le noeud plan de contrôle
Nous créons un pod qui utilise un volume hostPath pour monter les données à partir de l'hôte.
```
vi hostpath-volume-test.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-volume-test
spec:
  restartPolicy: OnFailure
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'cat /data/data.txt']
    volumeMounts:
    - name: host-data
      mountPath: /data
  volumes:
  - name: host-data
    hostPath:
      path: /etc/hostPath
      type: Directory
```

```
kubectl apply -f hostpath-volume-test.yml
```

Nous pouvons vérifier l'état du pod.
```
kubectl get pod hostpath-volume-test
```

Nous pouvons vérifier les journaux du pod pour voir la sortie des données de l'hôte indiquant sur quel nœud de travail le pod s'exécute.
```
kubectl logs hostpath-volume-test
```

## Volume hostpath de type EmptyDir
Nous créons un pod qui utilise un volume emptyDir.
```
vi emptydir-volume-test.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-volume-test
spec:
  restartPolicy: OnFailure
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'echo "Writing to the empty dir..." > /data/data.txt; cat /data/data.txt']
    volumeMounts:
    - name: emptydir-vol
      mountPath: /data
  volumes:
  - name: emptydir-vol
    emptyDir: {}
```

```
kubectl apply -f emptydir-volume-test.yml
```

Nous pouvons vérifier les journaux du pod :
```
kubectl logs emptydir-volume-test
```