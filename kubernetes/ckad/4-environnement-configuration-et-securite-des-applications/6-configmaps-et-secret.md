# Configuration des applications avec ConfigMaps et secrets
Un ConfigMap stocke les données de configuration qui peuvent être transmises aux conteneurs.<br>
Un secret est conçu pour stocker des données de configuration sensibles telles que des mots de passe ou des clés API.<br>
Les données de ConfigMaps et de Secrets peuvent être transmises aux conteneurs à l'aide d'un montage de volume ou de variables d'environnement.<br>

## Configmap
créons un configmap
```
vi my-configmap.yml
```

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  message: Hello, World!
  app.cfg: |
    # A configuration file!
    key1=value1
    key2=value2
```

```
kubectl apply -f my-configmap.yml
```

créons un pod qui utilise ce configmap
```
vi cm-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: cm-pod
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'echo $MESSAGE; cat /config/app.cfg']
    env:
    - name: MESSAGE
      valueFrom:
        configMapKeyRef:
          name: my-configmap
          key: message
    volumeMounts:
    - name: config
      mountPath: /config
      readOnly: true
  volumes:
  - name: config
    configMap:
      name: my-configmap
      items:
      - key: app.cfg
        path: app.cfg
```

```
kubectl apply -f cm-pod.yml
```

Nous vérifions les journaux du pod. Nous devrions voir le message suivi du contenu du fichier de configuration, tous deux issus de ConfigMap.
```
kubectl logs cm-pod
```

## Secret
Obtenons des chaînes encodées en base64 pour certaines données sensibles.
```
echo Secret Stuff! | base64
echo Secret stuff in a file! | base64
```

créons un secret à l'aide des données encodées en base64
```
vi my-secret.yml
```

```
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  sensitive.data: U2VjcmV0IFN0dWZmIQo=
  passwords.txt: U2VjcmV0IHN0dWZmIGluIGEgZmlsZSEK
```

```
kubectl apply -f my-secret.yml
```

créons un pod qui utilise ce secret
```
vi secret-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  restartPolicy: Never
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'echo $SENSITIVE_STUFF; cat /config/passwords.txt']
    env:
    - name: SENSITIVE_STUFF
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: sensitive.data
    volumeMounts:
    - name: secret-config
      mountPath: /config
      readOnly: true
  volumes:
  - name: secret-config
    secret:
      secretName: my-secret
      items:
      - key: passwords.txt
        path: passwords.txt
```

```
kubectl apply -f secret-pod.yml
```

Nous vérifions les journaux du pod. Nous devrions voir les données du secret, à la fois la variable d'environnement et le fichier.
```
kubectl logs secret-pod
```