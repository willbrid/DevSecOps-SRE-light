# Restreindre les autorisations du compte de service
Assurons-nous que les comptes de service ne disposent que des autorisations RBAC nécessaires.<br>

Examinons les RoleBindings et ClusterRoleBindings existants pour déterminer les autorisations dont dispose un ServiceAccount.<br>
Concevons notre configuration RBAC de manière à ce que les comptes de service ne disposent pas d'autorisations inutiles.<br>
Nous pouvons lier plusieurs rôles à un compte de service. Utilisons ceci pour garder le rôle séparé, plutôt que de le surcharger avec beaucoup d'autorisations.<br>
Nous pouvons lier un ClusterRole avec un RoleBinding pour fournir les autorisations nécessaires uniquement dans l'espace de noms du RoleBinding.<br>

Pour commencer, exécutons le fichier manifeste d'installation. Ce fichier crée une configuration ServiceAccount moins qu'idéale qui utilise un ServiceAccount partagé avec des autorisations combinées. Nous pouvons reconfigurer la configuration RBAC pour utiliser des comptes de service distincts afin de rendre la configuration plus sécurisée.<br>


Utilisons le fichier *2-setup.yml*, créons les objets de démarrage et vérifions les journaux des deux pods.
```
kubectl create -f 2-setup.yml
```

```
kubectl logs deployment-viewer-pod -n sa-permissions-test
kubectl logs pod-viewer-pod -n sa-permissions-test
```

Vérifions les autorisations dans le rôle shared-sa-role utilisé par le compte de service des pods.
```
kubectl describe role shared-sa-role -n sa-permissions-test
```

Notons qu'un seul des deux pods doit pouvoir afficher les déploiements, et l'autre doit uniquement afficher les pods.
Ni l'un ni l'autre n'a besoin d'autorisation pour afficher les secrets.
Nous rendrons cette configuration plus sécurisée en séparant les autorisations des pods dans des comptes de service distincts, chacun avec uniquement les autorisations nécessaires pour chaque pod.<br>

- créons une nouvelle configuration ServiceAccount et RBAC pour le pod deployment-viewer-pod.
```
vi deployment-viewer-pod-sa-rbac.yml
```

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: deployment-viewer-sa
  namespace: sa-permissions-test
automountServiceAccountToken: true
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-viewer-role
  namespace: sa-permissions-test
rules:
- apiGroups: [""]
  resources: ["deployments"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployment-viewer-rb
  namespace: sa-permissions-test
subjects:
- kind: ServiceAccount
  name: deployment-viewer-sa
  namespace: sa-permissions-test
roleRef:
  kind: Role
  name: deployment-viewer-role
  apiGroup: rbac.authorization.k8s.io
```

```
kubectl create -f deployment-viewer-pod-sa-rbac.yml
```

Nous faisons de même pour le pod pod-viewer-pod.
```
vi pod-viewer-pod-sa-rbac.yml
```

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-viewer-sa
  namespace: sa-permissions-test
automountServiceAccountToken: true
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-viewer-role
  namespace: sa-permissions-test
rules:
- apiGroups: [""]
  resources: ["pod"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-viewer-rb
  namespace: sa-permissions-test
subjects:
- kind: ServiceAccount
  name: pod-viewer-sa
  namespace: sa-permissions-test
roleRef:
  kind: Role
  name: pod-viewer-role
  apiGroup: rbac.authorization.k8s.io
```

```
kubectl create -f pod-viewer-pod-sa-rbac.yml
```

- Nous modifions le manifeste du pod *deployment-viewer-pod* pour définir le nouveau ServiceAccount.
```
vi new-deployment-viewer-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: deployment-viewer-pod
  namespace: sa-permissions-test
spec:
  serviceAccountName: deployment-viewer-sa
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token); while true; do if curl -s -o /dev/null -k -m 3 -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc.cluster.local/api/v1/namespaces/auth/deployments/; then echo "[SUCCESS] Successfully viewed Deployments!"; else echo "[FAIL] Failed to view Deployments!"; fi; sleep 5; done']

```

Nous faisons de même pour le pod pod-viewer-pod.
```
vi new-pod-viewer-pod.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-viewer-pod
  namespace: sa-permissions-test
spec:
  serviceAccountName: pod-viewer-sa
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token); while true; do if curl -s -o /dev/null -k -m 3 -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc.cluster.local/api/v1/namespaces/auth/pods/; then echo "[SUCCESS] Successfully viewed Pods!"; else echo "[FAIL] Failed to view Pods!"; fi; sleep 5; done']
```

Nous supprimons les anciens pods, puis les recréons à l'aide des manifestes.
```
kubectl delete pod deployment-viewer-pod -n sa-permissions-test
kubectl delete pod pod-viewer-pod -n sa-permissions-test
kubectl create -f new-deployment-viewer-pod.yml
kubectl create -f new-pod-viewer-pod.yml
```

Nous consultons les journaux des pods pour vérifier qu'ils fonctionnent toujours avec la configuration RBAC nouvellement restreinte.
```
kubectl logs deployment-viewer-pod -n sa-permissions-test
kubectl logs pod-viewer-pod -n sa-permissions-test
```

Nous supprimons l'ancien ServiceAccount.
```
kubectl delete sa shared-sa -n sa-permissions-test
```