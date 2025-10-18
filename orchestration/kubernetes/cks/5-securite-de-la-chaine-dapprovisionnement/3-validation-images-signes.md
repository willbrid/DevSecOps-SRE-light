# Validation des images signées

- **Signatures d'images** : les images de conteneur peuvent être signées à l'aide d'un hachage généré à partir du contenu unique de l'image. Les signatures peuvent être utilisées pour vérifier que le contenu de l'image n'a pas été falsifié.
- Nous pouvons fournir un hachage SHA-256 pour valider une image.
- Ainsi pour valider l'image, nous pouvons ajouter le hachage à la référence de l'image dans la spécification de notre conteneur avec image : **imageName:tag@sha256:hash**.
- Si l'image échoue à la validation, le pod sera créé, mais le nœud ne parviendra pas à télécharger l'image.

- Créons un pod qui utilise un hachage sha256 pour valider l'image :

```
vi signed-image-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: signed-image-pod
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: busybox:1.33.1@sha256:9687821b96b24fa15fac11d936c3a633ce1506d5471ebef02c349d85bebb11b5
    command: ['sh', '-c', 'echo "Hello, world!"']
```

```
kubectl create -f signed-image-pod.yml
```

- Essayons de créer un pod dont la signature d'image est incorrecte

```
vi bad-signature-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: bad-signature-pod
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: busybox:1.33.1@sha256:9687821b96b24fa15fac11d936c3a633ce1506d5471ebef02c349d85bebb11b6
    command: ['sh', '-c', 'echo "Hello, world!"']
```

```
kubectl create -f bad-signature-pod.yml
```

Le pod ne devrait pas réussir à récupérer l'image.