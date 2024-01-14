# Gestion des configurations sur k8s
Dans ce tutoriel, nous présenterons la gestion des objets configmap et secret de k8s.

## Gestion des objets configmap
**- créer un objet configmap**<br>
Nous créons un objet configmap *test-configmap* :
```
vi test-configmap.yml
```

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-configmap
data:
  key1: Hello, world!
  key2: |
    Test
    multiple lines
    more lines
```

```
kubectl create -f test-configmap.yml
```

**- lister et afficher les objets configmap**<br>
Par exemple, l'on peut lister les objets configmap :
```
kubectl get configmap
```

L'on peut afficher le détail d'un objet configmap :
```
kubectl describe configmap test-configmap
```

**- utiliser un objet configmap comme variable d'environnement**<br>
Nous créons un objet pod et fournissons les données de configuration à l'aide de variables d'environnement.<br>
```
vi env-configmap-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: env-configmap-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'echo "configmap: $CONFIGMAPVAR"']
    env:
    - name: CONFIGMAPVAR
      valueFrom:
        configMapKeyRef:
          name: test-configmap
          key: key1
```

```
kubectl create -f env-configmap-pod.yml
```

En inspectant les logs du pod, l'on pourra voir la valeur de la variable d'environnement **CONFIGMAPVAR** s'afficher.
```
kubectl logs env-configmap-pod
```

**- monter un objet configmap comme volume**<br>
Nous créons un objet pod et fournissons des données de configuration à l'aide de volumes.
```
vi volume-configmap-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: volume-configmap-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'while true; do sleep 3600; done']
    volumeMounts:
    - name: configmap-volume
      mountPath: /etc/config/configmap
  volumes:
  - name: configmap-volume
    configMap:
      name: test-configmap
```

```
kubectl create -f volume-configmap-pod.yml
```

Dans ce montage, chaque clé de l'objet configmap sera un fichier. Ainsi la définition ci-dessus permettra de créer deux fichiers dans le conteneur *busybox* au niveau du répertoire de montage **/etc/config/configmap** . L'on pourra vérifier cela en exécutant les commandes ci-dessous :<br>
```
kubectl exec volume-configmap-pod -- ls /etc/config/configmap
kubectl exec volume-configmap-pod -- cat /etc/config/configmap/key1
kubectl exec volume-configmap-pod -- cat /etc/config/configmap/key2
```

## Gestion des objets secret
**- création un objet secret**<br>
Nous supposerons que nous avons deux mots de passe : *motDePasseSolide1* et *motDePasseSolide2* à définir dans un objet secret.<br>

Nous générons deux valeurs encodées en base64 via ces mots de passe.
```
echo -n 'motDePasseSolide1' | base64
echo -n 'motDePasseSolide2' | base64
```

Nous créons notre objet secret :
```
vi test-secret.yml
```

```
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
type: Opaque
data:
  secretkey1: <valeur base64 motDePasseSolide1>
  secretkey2: <valeur base64 motDePasseSolide2>
```

```
kubectl create -f test-secret.yml
```

**- lister et afficher les objets secret**<br>
Par exemple, l'on peut lister les objets secret :
```
kubectl get secret
```

L'on peut afficher le détail d'un objet secret :
```
kubectl describe secret test-secret
```

**- utiliser un objet secret comme variable d'environnement**<br>
Nous créons un objet pod et fournissons les données de l'objet secret à l'aide de variables d'environnement.
```
vi env-secret-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: env-secret-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'echo "secret: $SECRETVAR"']
    env:
    - name: SECRETVAR
      valueFrom:
        secretKeyRef:
          name: test-secret
          key: secretkey1
```

```
kubectl create -f env-secret-pod.yml
```

En inspectant les logs du pod, l'on pourra voir la valeur de la variable d'environnement **SECRETVAR** s'afficher.
```
kubectl logs env-secret-pod
```

**- monter un objet secret comme volume**<br>
Nous créons un objet pod et fournissons des données de l'objet secret à l'aide de volumes.
```
vi volume-secret-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: volume-secret-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'while true; do sleep 3600; done']
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/config/secret
  volumes:
  - name: secret-volume
    secret:
      secretName: test-secret
```

```
kubectl create -f volume-secret-pod.yml
```

Dans ce montage, chaque clé de l'objet secret sera un fichier. Ainsi la définition ci-dessus permettra de créer deux fichiers dans le conteneur *busybox* au niveau du répertoire de montage **/etc/config/secret** . L'on pourra vérifier cela en exécutant les commandes ci-dessous :<br>
```
kubectl exec volume-secret-pod -- ls /etc/config/secret
kubectl exec volume-secret-pod -- cat /etc/config/secret/secretkey1
kubectl exec volume-secret-pod -- cat /etc/config/secret/secretkey2
```