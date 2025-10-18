# S'assurer que les conteneurs sont immuables

## Qu'est-ce que l'immuabilité des conteneurs ?

Les conteneurs immuables (ou sans état) ne changent pas pendant leur durée de vie. Au lieu d'être modifiés, ils sont remplacés par
nouveaux contenants. Cela signifie souvent que le système de fichiers du conteneur reste statique et que le conteneur ne dépend pas de ressources hôtes non immuables qui nécessitent un accès privilégié.
<br>

- **Immuabilité et sécurité**

L'immuabilité présente des avantages en matière de sécurité. Par exemple, un attaquant ne peut pas télécharger de logiciels ou d'outils malveillants dans un conteneur, ni modifier le code d'exécution du conteneur.
<br>

- **Évitons les privilèges élevés**

--- **mode privilégié** : pour maintenir l'immuabilité, n'utilisons pas **securityContext.privileged: true**. <br>

--- **espaces de noms d'hôte** : des paramètres tels que **hostNetwork : true** peuvent rendre les conteneurs muables. <br>

--- **élévation des privilèges** : **securityContext.allowPrivilegeEscalation : true** permet à un conteneur d'obtenir plus de privilèges que le processus parent. Cela peut rendre un conteneur muable. <br>

--- **utilisateur root** : **securityContext.runAsUser : root ou 0** exécute le processus de conteneur en tant que **root**. Utilisons un autre utilisateur pour maintenir l'immuabilité.<br><br>

- Les conteneurs immuables ne modifient pas leur code, ce qui signifie qu'ils ne doivent pas pouvoir écrire dans le système de fichiers du conteneur.
- Utilisons **readOnlyRootFilesystem: true** pour appliquer cela. Un conteneur sans ce paramètre peut ne pas être considéré comme **immuable**.
- Si l'application a besoin d'écrire des données, utilisons des montages de volume pour le prendre en charge.

## Créons un manifeste de pod muable

```
vi immutability-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: immutability-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    securityContext:
      privileged: true
      allowPrivilegeEscalation: true
      runAsUser: 0
      readOnlyRootFilesystem: false
```

```
kubectl create -f immutability-pod.yml
```

Vérifions la configuration du pod

```
kubectl get pod immutability-pod -o yaml
```

Supprimons le pod

```
kubectl delete pod immutability-pod --force
```

Modifions le pod pour le rendre immuable

```
vi immutability-pod.yml
```

--- Tout d'abord, supprimons le mode privilégié en supprimant **securityContext.privileged: true** .<br>
--- Désactivons l'escalade des privilèges en supprimant **securityContext.allowPrivilegeEscalation: true** . <br>
--- Faisons en sorte que le conteneur s'exécute en tant qu'utilisateur autre que **root** en supprimant **securityContext.runAsUser: 0** . <br>
--- Rendons le système de fichiers racine en lecture seule :

```
securityContext:
  readOnlyRootFilesystem: true
```

Ajoutons des volumes **emptyDir** pour les chemins sur lesquels Nginx doit écrire :

```
    volumeMounts:
    - name: cache
      mountPath: /var/cache/nginx
    - name: run
      mountPath: /var/run
  volumes:
  - name: cache
    emptyDir: {}
  - name: run
    emptyDir: {}
```

Recréons le pod

```
kubectl create -f immutability-pod.yml
```

Vérifions l'état du pod

```
kubectl get pod immutability-pod
```

Vérifions à nouveau la configuration du pod

```
kubectl get pod immutability-pod -o yaml
```