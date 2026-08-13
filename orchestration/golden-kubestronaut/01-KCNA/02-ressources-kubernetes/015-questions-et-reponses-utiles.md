# Questions et réponses utiles

Voici quelques points clés à retenir, organisés par thème.

### ReplicaSets et Replication Controllers

- **Rôle d'un ReplicaSet** : surveiller et scaler les pods.
- **Importance d'un replication controller** :
  - il garantit que plusieurs instances d'un pod sont en cours d'exécution pour assurer la **haute disponibilité** ;
  - il aide à **récupérer et remplacer automatiquement** les pods défaillants ;
  - il gère la réplication des pods à des fins de **load balancing**.
- **Où spécifier les labels** que le ReplicaSet utilise pour identifier ses pods : sous **`matchLabels`**.
- **Comment un ReplicaSet sait quels pods surveiller** : il utilise les **labels** pour filtrer et sélectionner les pods à surveiller.
- **Pourquoi un ReplicaSet exige un selector**, même si le template définit déjà le pod : le **selector** permet au ReplicaSet d'**identifier les pods créés avant lui** (pour les adopter).
- **Pourquoi la section `template` est requise**, même s'il existe déjà des pods aux labels correspondants : pour **créer de nouveaux pods** en cas de besoin.

### Labels

- **Intérêt des labels lors du déploiement de plusieurs pods** : ils permettent un **regroupement et un filtrage faciles** des pods selon leurs caractéristiques.

### Deployments et Rollouts

- **Objectif d'un Deployment** : gérer et mettre à niveau les instances sous-jacentes de manière transparente grâce aux **rolling updates**.
- **Résultat du processus de rollout** lors de la création d'un nouveau déploiement :
  - création d'un **nouveau ReplicaSet** ;
  - création d'une **nouvelle révision de déploiement**.
- **Importance des rollouts et des révisions** : ils permettent de **suivre les changements** apportés au déploiement.
- **Commande pour voir tous les objets créés** après un déploiement : **`kubectl get all`**.

### Controllers

- **Rôle principal des controllers** : ils **surveillent les objets Kubernetes** et prennent les actions appropriées en fonction de leur état.

### Approche impérative vs déclarative

- **Approche déclarative** : celle qui consiste à exécuter **`kubectl apply`** pour créer, mettre à jour ou supprimer un objet.
- **Commandes considérées comme impératives** : **`kubectl run`**, **`kubectl create -f`**, **`kubectl delete -f`**.

### kubectl apply et Last Applied Configuration

- **Sources considérées par `kubectl apply`** avant de décider des changements :
  - le **fichier de configuration local**, la **définition de l'objet live** (en mémoire dans Kubernetes) et la **dernière configuration appliquée** (last applied configuration).
- **Que devient le YAML local** lors de la création via `kubectl apply` : il est **converti au format JSON** et stocké comme **last applied configuration**.
- **Utilité de la « last applied configuration »** : elle aide à **identifier les champs qui ont été supprimés** du fichier de configuration local.
- **Ce que Kubernetes utilise pour stocker les informations sur un objet en interne**, quelle que soit l'approche de création : la **configuration live** sur le cluster Kubernetes.

### Pods et scaling

- **Avantage de plusieurs conteneurs dans un même pod** : cela permet aux conteneurs de **partager le même namespace réseau et les mêmes volumes de stockage**.
- **Approche recommandée pour étendre la capacité physique** d'un cluster quand un nœud manque de ressources : **déployer des pods supplémentaires sur un nouveau nœud** du cluster.

### Namespaces

- **Namespace créé au démarrage contenant les services internes** (réseau et DNS) : le namespace **`kube-system`**.
- **Namespace contenant les ressources accessibles à tous les utilisateurs** : le namespace **`kube-public`**.