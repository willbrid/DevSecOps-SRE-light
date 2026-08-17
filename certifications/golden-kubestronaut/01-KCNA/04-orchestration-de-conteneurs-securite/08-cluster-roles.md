# Cluster Roles

Là où les **Roles** et **RoleBindings** sont limités à un namespace, les **ClusterRoles** et **ClusterRoleBindings** gèrent l'accès aux ressources **à l'échelle du cluster** (cluster-scoped).

### Ressources namespaced vs cluster-scoped

- **Namespaced** (limitées à un namespace) : pods, deployments, services, roles, rolebindings…
- **Cluster-scoped** (non liées à un namespace) :
  - **Nodes** (nœuds) ;
  - **Persistent Volumes** ;
  - **Certificate Signing Requests** ;
  - **Namespace objects** (les namespaces eux-mêmes).

Pour ces ressources, on **ne spécifie pas** de namespace lors de la création.

Découvrir quelles ressources sont dans chaque catégorie :

```bash
kubectl api-resources --namespaced=true    # ressources namespaced
kubectl api-resources --namespaced=false   # ressources cluster-scoped
```

### Créer un ClusterRole

Fonctionne comme un Role, mais pour les ressources cluster-scoped. Ex. : un rôle d'administrateur de cluster gérant les nœuds.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-administrator
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list", "get", "create", "delete"]
```

Autres exemples : un rôle « storage admin » gérant les Persistent Volumes et Claims.

### Créer un ClusterRoleBinding

Lie un utilisateur ou groupe au ClusterRole :

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-role-binding
subjects:
- kind: User
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-administrator
  apiGroup: rbac.authorization.k8s.io
```

Structure identique au RoleBinding : **`subjects`** (qui) + **`roleRef`** (quel ClusterRole).

### Point important : ClusterRole et ClusterRoleBinding sur des ressources namespaced

Bien que les ClusterRoles et les ClusterRoleBindings soient principalement utilisés pour gérer des ressources à l'échelle du cluster, ils peuvent également s'appliquer à des ressources limitées à un espace de noms. Lorsqu'ils sont utilisés de cette manière, l'utilisateur concerné obtient un accès à ces ressources dans tous les espaces de noms, contrairement aux rôles limités à un espace de noms, qui restreignent l'accès à un espace de noms spécifique.

### Comparaison Role vs ClusterRole

| Aspect | Role / RoleBinding | ClusterRole / ClusterRoleBinding |
|--------|-------------------|----------------------------------|
| Portée | Un **namespace** unique | **Tout le cluster** |
| Ressources visées | Namespaced (pods, services…) | Cluster-scoped (nodes, PV…) **ou** namespaced (tous namespaces) |
| Namespace par défaut | `default` si non précisé | Sans objet (cluster-wide) |

### Les Cluster Roles par défaut

Kubernetes crée **plusieurs cluster roles par défaut** à l'initialisation du cluster. Ils sont prêts à l'emploi et couvrent diverses tâches administratives.

### À retenir

- **ClusterRole + ClusterRoleBinding** = équivalents des Role/RoleBinding mais à l'**échelle du cluster**.
- Ressources **cluster-scoped** : **nodes**, **persistent volumes**, **CSR**, **namespaces**.
- `kubectl api-resources --namespaced=true/false` pour classer les ressources.
- Un ClusterRole appliqué à une ressource namespaced donne l'accès **dans tous les namespaces**.
- Kubernetes fournit des **cluster roles par défaut** dès l'installation.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/


