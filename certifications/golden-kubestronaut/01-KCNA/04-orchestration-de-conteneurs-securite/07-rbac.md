# RBAC : Role-Based Access Control

Le **RBAC** est un mécanisme robuste pour gérer l'**accès aux ressources** d'un cluster Kubernetes. Il repose sur deux objets : les **Roles** (qui définissent des permissions) et les **RoleBindings** (qui lient ces permissions à des utilisateurs).

### Créer un Role (point essentiel)

Un **Role** encapsule un ensemble de permissions pour des ressources, **dans un namespace**. Composants clés :
- **apiVersion** : `rbac.authorization.k8s.io/v1`
- **kind** : `Role`
- **metadata.name** : nom du rôle (ex. `developer`)
- **rules** : liste définissant les **apiGroups**, **resources** et **verbs** (actions) autorisés.

> **Point important** : pour les ressources du **core group**, laisser le champ `apiGroups` **vide** (`[""]`). Pour les autres groupes, spécifier le nom du groupe.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list", "get", "create", "update", "delete"]
- apiGroups: [""]
  resources: ["ConfigMap"]
  verbs: ["create"]
```

```bash
kubectl create -f role-definition.yaml
```

> **Roles ET RoleBindings sont limités à un namespace** (namespace-scoped). Par défaut, ils s'appliquent au namespace `default` ; pour un autre, ajouter le champ `namespace` dans `metadata`.

- Afficher les ressources API prises en charge sur le serveur api-server

--- ceux au scope namespace

```
kubectl api-resources --namespaced=true
```

--- ceux au scope non namespace

```
kubectl api-resources --namespaced=false
```

### Créer un RoleBinding (point essentiel)

Le **RoleBinding** connecte un **utilisateur** à un **Role** dans un namespace, accordant ainsi à l'utilisateur les permissions du rôle.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devuser-developer-binding
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl create -f rolebinding-definition.yaml
```

Structure : **`subjects`** (qui ? l'utilisateur) + **`roleRef`** (quel rôle ?).

### Vérifier les Roles et RoleBindings

```bash
kubectl get roles                              # lister les rôles
kubectl get rolebindings                       # lister les liaisons
kubectl describe role developer                # détail d'un rôle
kubectl describe rolebinding devuser-developer-binding  # détail d'une liaison
```

### Vérifier les permissions d'un utilisateur (commande très utile)

La commande **`kubectl auth can-i`** teste si une action est autorisée :

```bash
kubectl auth can-i create deployments
kubectl auth can-i delete nodes
# → no
```

**Astuce admin** : tester les permissions d'un **autre utilisateur** sans changer de compte, grâce au flag **`--as`** :

```bash
kubectl auth can-i create deployments --as dev-user
kubectl auth can-i create pods --as dev-user
# → yes
```

> On peut ajouter **`--namespace`** pour cibler un namespace précis.

### Restreindre l'accès à des ressources spécifiques (point avancé)

Le champ **`resourceNames`** limite les permissions à des **instances nommées** précises. Ex. : accès aux seuls pods « blue » et « orange » :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "create", "update"]
  resourceNames: ["blue", "orange"]
```

### À retenir

- **RBAC = Role + RoleBinding** : le Role **définit** les permissions, le RoleBinding les **attribue** à un utilisateur.
- Les deux sont **namespace-scoped** (limités à un namespace).
- Une **rule** combine : `apiGroups` (`[""]` pour le core group), `resources` et `verbs`.
- **`kubectl auth can-i`** vérifie les permissions ; **`--as`** permet de tester à la place d'un autre utilisateur.
- **`resourceNames`** restreint l'accès à des instances précises.
- Structure d'un RoleBinding : **`subjects`** (qui) + **`roleRef`** (quel rôle).

### Liens utiles

- Documentation officielle RBAC : https://kubernetes.io/docs/reference/access-authn-authz/rbac/
