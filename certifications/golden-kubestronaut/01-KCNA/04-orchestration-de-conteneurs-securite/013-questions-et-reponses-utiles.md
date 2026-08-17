# Questions et réponses utiles

Voici quelques points clés à retenir, organisés par thème.

### Autorisation

- **Rôle de l'Open Policy Agent (OPA)** vis-à-vis de l'autorisation : cela facilite le **contrôle d'admission** et **l'autorisation** en effectuant des appels API pour déterminer si un utilisateur doit être autorisé à accéder au système, en fonction de ses besoins d'accès.
- **Ce qui détermine les actions autorisées** une fois un utilisateur authentifié : les **mécanismes d'autorisation**.
- **Mode d'autorisation par défaut** du kube-apiserver si l'option `--authorization-mode` n'est pas spécifiée : **AlwaysAllow**.
- **Qui est autorisé par le node authorizer** à faire des requêtes au kube-apiserver : toute requête provenant d'un utilisateur nommé **`system:node`** et faisant partie du groupe **`system:nodes`**.

### Gestion des comptes

- **Comment Kubernetes gère les comptes utilisateurs par défaut** : il utilise un **service d'identité tiers** comme **LDAP** pour gérer les comptes utilisateurs.
- **Qu'est-ce qu'un service account** : un compte utilisé par une **application** pour interagir avec un cluster Kubernetes.

### API et ressources

- **Comment les ressources sont catégorisées selon leur portée** : en **namespaced** (limitées à un namespace) ou **cluster-scoped** (à l'échelle du cluster).
- **Ressources du sous-groupe `apps`** (named group) : chaque ressource du sous-groupe `apps` possède un **ensemble d'actions (verbs)** qui lui sont associées.
- **Champ pour restreindre l'accès à des ressources spécifiques** : le champ **`resourceNames`**.

### Kubeconfig

- **Format des sections du fichier kubeconfig** : chaque section (clusters, users, contexts) est au format **tableau (array)**.

### Réseau

- **Rôle du Kube Proxy** : il assure la **connectivité entre les pods et les services** à travers les différents nœuds du cluster.
