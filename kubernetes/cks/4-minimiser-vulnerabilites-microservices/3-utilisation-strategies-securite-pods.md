# Utilisation des stratégies de sécurité des pods

Pour utiliser les politiques de sécurité de Pod, nous devons d'abord activer le contrôleur d'admission **PodSecurityPolicy**.

- Activons le contrôleur d'admission **PodSecurityPolicy** en l'ajoutant à l'indicateur **--enable-admission-plugins** sur le composant **kube-apiserver**.
- Un Pod doit satisfaire au moins une règle **PodSecurityPolicy** pour être autorisé. Si nous activons le contrôleur d'admission avant de créer des règles, aucun pod ne sera autorisé !<br>

Un objet **PodSecurityPolicy** peut être créé à partir de YAML comme n'importe quel objet Kubernetes.

- **privileged** : détermine si les pods créés à l'aide de la stratégie peuvent exécuter des conteneurs en mode privilégié.
- **runAsUser** : détermine sous quel(s) utilisateur(s) les conteneurs du pod peuvent s'exécuter. **RunAsAny** permet aux conteneurs de s'exécuter comme n'importe quel utilisateur.
- Consultons la documentation pour plus d'informations sur les paramètres que les stratégies de sécurité des pods peuvent contrôler <br>

Pour qu'un utilisateur utilise une politique de sécurité de pod pour valider ses pods, il doit être autorisé à utiliser la politique via RBAC.<br>
Le verbe **use** dans un Role ou un ClusterRole permet à un utilisateur d'utiliser **PodSecurityPolicy**.
Chaque nouveau pod doit être autorisé par au moins une stratégie que l'utilisateur est autorisé à utiliser. Si l'utilisateur n'est autorisé à utiliser aucune politique, il ne peut pas créer de pod !<br>

Les politiques d'autorisation :
- **User** : <br>
-- l'utilisateur qui crée le pod a accès à la stratégie. <br>
-- contrôle quels utilisateurs peuvent créer des pods en fonction de quelles politiques. <br>
-- ne fonctionne pas bien pour les pods qui ne sont pas créés directement par les utilisateurs (pensons aux déploiements, aux ReplicaSets, aux DaemonSets, etc.).<br>

- **ServiceAccount** : <br>
-- le compte de service du pod a accès pour utiliser la stratégie. <br>
-- fonctionne avec des pods créés indirectement, tels que ceux créés à l'aide de déploiements, etc. <br>
-- c'est la méthode préférée dans la plupart des cas : ainsi pour appliquer une règle **PodSecurityPolicy** dans le contexte d'un espace de noms spécifique, autorisons un ServiceAccount dans cet espace de noms à utiliser la stratégie.<br>

## Activons le contrôleur d'admission PodSecurityPolicy

Modifions le fichier manifest du serveur d'API Kubernetes en recherchant la ligne qui commence par **--enable-admission-plugins** et en ajoutant **PodSecurityPolicy** à la liste.

```
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

```
- --enable-admission-plugins=NodeRestriction,PodSecurityPolicy
```

Testons le serveur API (cela peut prendre quelques instants pour revenir à la normale).

```
kubectl get nodes
```

## créons un objet PodSecurityPolicy

créons une **PodSecurityPolicy** qui autorise la plupart des pods de base, mais les empêche d'utiliser le mode privilégié.

```
vi psp-nonpriv.yml
```

```
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: psp-nonpriv
spec:
  privileged: false
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - secret
  - projected
```

```
kubectl create -f psp-nonpriv.yml
```

## Configuration RBAC

créons un espace de noms et un ServiceAccount.

```
kubectl create namespace psp-test
kubectl create serviceaccount psp-test-sa -n psp-test
```

créons un ClusterRole avec des autorisations pour **PodSecurityPolicy**.

```
vi cr-use-psp-psp-nonpriv.yml
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cr-use-psp-psp-nonpriv
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  verbs: ['use']
  resourceNames:
  - psp-nonpriv
```

```
kubectl create -f cr-use-psp-psp-nonpriv.yml
```

Créons un RoleBinding pour lier le ClusterRole au ServiceAccount.

```
vi rb-psp-test.yml
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-psp-test
  namespace: psp-test
roleRef:
  kind: ClusterRole
  name: cr-use-psp-psp-nonpriv
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: psp-test-sa
  namespace: psp-test
```

```
kubectl create -f rb-psp-test.yml
```

## Testons la politique

Créons un pod.

```
vi pod-psp-test.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-psp-test
  namespace: psp-test
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
```

```
kubectl create -f pod-psp-test.yml
```

Cela réussira puisque l'utilisateur administrateur peut utiliser **PodSecurityPolicy**.<br>
Modifions le pod pour utiliser le ServiceAccount qui dispose des autorisations appropriées.

```
vi pod-psp-test.yml
```

```
...
spec:
  serviceAccountName: psp-test-sa
```

```
kubectl create -f pod-psp-test.yml
```

Cela réussira car le pod n'est pas créé en mode privilégié.<br>

Essayons de créer un pod qui utilise un conteneur privilégié.

```
vi pod-psp-test-priv.yml
```

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-psp-test-priv
  namespace: psp-test
spec:
  serviceAccountName: psp-test-sa
  containers:
  - name: nginx
    image: nginx:1.14.2
    securityContext:
      privileged: true
```

```
kubectl create -f pod-psp-test-priv.yml
```

Cela devrait échouer, car le pod ne répond aux exigences d'aucune *PodSecurityPolicy* applicable.

## Désactiver le contrôleur d'admission PodSecurityPolicy

Si nous souhaitons continuer à travailler avec notre cluster sans nous soucier des politiques de sécurité du pod, désactivons le contrôleur d'admission **PodSecurityPolicy**.
<br>
Modifions le manifeste du serveur d'API Kubernetes en recherchant la ligne qui commence par **--enable-admission-plugins** et en enlevant **PodSecurityPolicy** à la liste.

```
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

```
- --enable-admission-plugins=NodeRestriction
```