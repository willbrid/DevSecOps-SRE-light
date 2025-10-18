# Configuration de SecurityContext pour les conteneurs
Le *SecurityContext* d'un conteneur vous permet de contrôler les paramètres avancés liés à la sécurité pour le conteneur.<br>
Définissons l'ID utilisateur (UID) et l'ID de groupe (GID) du conteneur avec *securitContext.runAsUser* et *securityContext.runAsGroup* .<br>
Activons ou désactivons l'élévation des privilèges avec *securityContext.allowPrivilegeEscalation* .<br>
Rendons le système de fichiers racine du conteneur en lecture seule avec *securityContext.readOnlyRootFilesystem* .<br>

créons un pod qui utilise des paramètres securityContext personnalisés.<br>
Ces paramètres permettront de :
- éxécuter le conteneur sous l'ID utilisateur 3000.
- éxécuter le conteneur avec l'ID de groupe 4000.
- désactiver le mode d'escalade des privilèges sur le processus de conteneur.

```
vi securitycontext-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: securitycontext-pod
spec:
  containers:
  - name: busybox
    image: busybox:stable
    command: ['sh', '-c', 'while true; do echo Running...; sleep 5; done']
    securityContext:
      runAsUser: 3000
      runAsGroup: 4000
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
```

```
kubectl apply -f securitycontext-pod.yml
```

Vérifions l'ID d'utilisateur et de groupe utilisé par le conteneur.
```
kubectl exec securitycontext-pod -- id
```

Essayons d'écrire dans un fichier à l'intérieur du conteneur
```
kubectl exec securitycontext-pod -- sh -c "echo test > test.txt"
```

Cela échouera, car l'ID utilisateur 3000 n'a pas été autorisé à écrire dans le fichier.