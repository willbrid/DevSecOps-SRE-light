# Explorer les comptes de service
Les rôles et les clusterRoles définissent les autorisations. Les rôles fonctionnent dans un espace de nom. Les clusterRoles fonctionnent dans tous les espaces de nom.<br>

Les RoleBindings (dans un espace de nom) et ClusterRoleBindings (dans tous les espaces de nom) attachent des rôles et des ClusterRoles aux utilisateurs.<br>

Les comptes de service permettent aux pods d'accéder à l'API Kubernetes. 
Leurs autorisations sont régies par des objets RBAC réguliers.<br>

Assurons-nous toujours qu'un ServiceAccount ne dispose que des autorisations RBAC nécessaires.<br>

Si un conteneur est compromis, un attaquant pourrait utiliser le ServiceAccount pour accéder à l'API Kubernetes. C'est pourquoi il faut utiliser Kubernetes RBAC pour contrôler ce que ServiceAccounts peut faire et limiter les autorisations à ce qui est nécessaire.