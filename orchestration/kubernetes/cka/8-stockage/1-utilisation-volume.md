# Utilisation des volumes k8s
Le système de fichiers du conteneur est éphémère. Les fichiers sur le système de fichiers du conteneur n'existent que tant que le conteneur existe. Si un conteneur est supprimé ou recréé dans K8s, les données stockées sur le système de fichiers du conteneur sont perdues.<br>
De nombreuses applications ont besoin d'une méthode de stockage de données plus persistante.
Les volumes vous permettent de stocker des données en dehors du système de fichiers du conteneur tout en permettant au conteneur d'accéder aux données lors de l'exécution. Cela peut permettre aux données d'être persistées au-delà de la durée de vie du conteneur.<br>
Nous présentons à présent deux exemples d'utilisation de volume.

## Volume de type hostPath
Nous créons un pod qui utilise un volume de type hostPath pour stocker des données sur un noeud worker :
```
vi volume-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'echo Success! > /output/success.txt']
    volumeMounts:
    - name: test-volume
      mountPath: /output
  volumes:
  - name: test-volume
    hostPath:
      path: /var/data
```

```
kubectl create -f volume-pod.yml
```

L'on peut vérifier sur quel noeud worker le pod a été déploié :
```
kubectl get pod volume-pod -o wide
```

L'on peut se connecter sur ce noeud et vérifier le contenu du fichier  *success.txt*:
```
cat /var/data/success.txt
```

Le volume de type hostPath stocke les données dans un répertoire spécifié sur un nœud worker K8s.

## Volume de type emptyDir
Nous créons un pod multi-conteneurs qui utilise un volume de type emptyDir partagé entre ces conteneurs :
```
vi shared-volume-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: shared-volume-pod
spec:
  containers:
  - name: busybox1
    image: busybox
    command: ['sh', '-c', 'while true; do echo Success! > /output/output.txt; sleep 5; done']
    volumeMounts:
    - name: test-volume
      mountPath: /output
  - name: busybox2
    image: busybox
    command: ['sh', '-c', 'while true; do cat /input/output.txt; sleep 5; done']
    volumeMounts:
    - name: test-volume
      mountPath: /input
  volumes:
  - name: test-volume
    emptyDir: {}
```

```
kubectl create -f shared-volume-pod.yml
```

L'on peut vérifier le log du conteneur pour busybox2 et on pourra voir les données générées par busybox1.

```
kubectl logs shared-volume-pod -c busybox2
```

Le volume de type emptyDir stocke les données dans un emplacement créé dynamiquement sur un nœud. Ce répertoire n'existe que tant que le pod existe sur le nœud. Le répertoire et les données sont supprimés lorsque le pod est supprimé. Ce type de volume est très utile pour partager simplement des données entre conteneurs d'un même Pod.