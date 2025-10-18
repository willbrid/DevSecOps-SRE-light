# Authentification k8s
Les utilisateurs normaux s'authentifient généralement à l'aide de certificats clients, tandis que les comptes de service utilisent généralement des jetons.<br>
L'autorisation des utilisateurs normaux et des comptes de service peut être gérée à l'aide du contrôle d'accès basé sur les rôles (RBAC).<br>
Les rôles et les ClusterRoles définissent un ensemble spécifique d'autorisations.
Les RoleBindings et ClusterRoleBindings lient les rôles ou les ClusterRoles aux utilisateurs/ServiceAccounts. <br>

- créons un rôle qui donne l'autorisation de répertorier les pods
```
vi list-pods-role.yml
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: list-pods-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list"]
```

```
kubectl apply -f list-pods-role.yml
```

- créons un RoleBinding pour lier le nouveau rôle au compte de service *my-sa*. <br>
NB : Ce compte de service a été créé dans le tutoriel précédent (voir fichier **2-compte-de-service.md**).
```
vi list-pods-rb.yml
```

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: list-pods-rb
subjects:
- kind: ServiceAccount
  name: my-sa
  namespace: default
roleRef:
  kind: Role
  name: list-pods-role
  apiGroup: rbac.authorization.k8s.io
```

```
kubectl apply -f list-pods-rb.yml
```

Nous pouvons vérifier les journaux du conteneur :
```
kubectl logs sa-pod
```
Maintenant que les autorisations ont été fournies au ServiceAccount à l'aide de RBAC, le journal doit indiquer que le pod est en mesure d'accéder avec succès à l'API et de récupérer une liste de pods dans l'espace de noms par défaut.<br>
NB: Pod créé au tutoriel précédent (voir fichier **2-compte-de-service.md**).
