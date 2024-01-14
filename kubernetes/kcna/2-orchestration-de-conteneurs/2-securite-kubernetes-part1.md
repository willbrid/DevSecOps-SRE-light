# Sécurité kubernetes (Part1)

**Les 4C de la sécurité Cloud Native** : chaque couche du modèle de sécurité Cloud Native s'appuie sur la couche la plus externe suivante.

#### Cloud

Le Cloud (ou les serveurs colocalisés ou le centre de données d'entreprise) est la base informatique de confiance d'un cluster Kubernetes. Si la couche Cloud est vulnérable (ou configurée de manière vulnérable), il n'y a aucune garantie que les composants construits au-dessus de cette base soient sécurisés. Chaque fournisseur de cloud fait des recommandations de sécurité pour exécuter les charges de travail en toute sécurité dans son environnement.

<br>

**Sécurité du fournisseur de cloud** : si nous exécutons un cluster Kubernetes sur un fournisseur de cloud, il faudrait consulter leur documentation pour connaître les bonnes pratiques de sécurité.

<br>

**Suggestions pour sécuriser notre infrastructure dans un cluster Kubernetes** :

- Accès réseau au serveur API (plan de contrôle) : tous les accès au plan de contrôle Kubernetes ne sont pas autorisés publiquement sur Internet et sont contrôlés par des listes de contrôle d'accès réseau limitées à l'ensemble d'adresses IP nécessaires à l'administration du cluster.

- **Accès réseau aux nœuds (nœuds)** : les nœuds doivent être configurés pour n'accepter que les connexions (via des listes de contrôle d'accès réseau) du plan de contrôle sur les ports spécifiés, et accepter les connexions pour les services dans Kubernetes de type NodePort et LoadBalancer. Si possible, ces nœuds ne doivent pas être entièrement exposés sur l'Internet public.

- **Accès Kubernetes à l'API du fournisseur de cloud** : chaque fournisseur de cloud doit accorder un ensemble d'autorisations différent au plan de contrôle et aux nœuds Kubernetes. Il est préférable de fournir au cluster un accès au fournisseur de cloud qui suit le principe du moindre privilège pour les ressources qu'il doit administrer. La documentation Kops fournit des informations sur les stratégies et les rôles IAM.

- **Accès à etcd** : L'accès à etcd (le magasin de données de Kubernetes) doit être limité au plan de contrôle uniquement. En fonction de notre configuration, nous devons essayer d'utiliser etcd sur TLS. Plus d'informations peuvent être trouvées dans la documentation d'etcd. <br>

- **Chiffrement etcd** : dans la mesure du possible, il est recommandé de chiffrer tout le stockage au repos, et puisque etcd détient l'état de l'ensemble du cluster (y compris les secrets), son disque doit en particulier être chiffré au repos.


#### Cluster

Il existe deux domaines de préoccupation pour la sécurisation de Kubernetes :

- Sécurisation des composants du cluster configurables

si nous souhaitons protéger notre cluster des accès accidentels ou malveillants et adopter de bonnes pratiques d'information, il faut consulter les recommandations sur la sécurisation de notre cluster.

[https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/](https://kubernetes.io/docs/tasks/administer-cluster/securing-a-cluster/)

- Sécuriser les applications qui s'exécutent dans le cluster

Les points suivants répertorient les recommandations pour sécuriser les charges de travail exécutées dans Kubernetes : <br>
--- définir les autorisations RBAC <br>
--- configurer les mécanismes d'authentification <br>
--- gérer les secrets applicatifs <br>
--- s'assurer que les pods répondent aux normes de sécurité définies pour les pods <br>
--- configurer les politiques réseau <br>
--- configurer le protocole TLS pour l'ingress Kubernetes <br>

#### Conteneur

Quelques recommandations concernant la sécurité des conteneurs :
- analyse des vulnérabilités des conteneurs et sécurité des dépendances du système d'exploitation
- signature d'image et application
- interdire les utilisateurs privilégiés
- utiliser le runtime de conteneur avec une isolation renforcée

#### Code

Le code d'application est l'une des principales surfaces d'attaque sur lesquelles nous avons le plus de contrôle. uelques recommandations :
- accès via TLS uniquement
- limitation des plages de ports de communication
- sécurité des dépendances tierces
- analyse de code statique
- évaluation de la sécurité de l'application en utilisant un outil d'analyse dynamique (**OWASP Zed Attack proxy**) : SQL injection, CSRF, and XSS.


[https://kubernetes.io/docs/concepts/security/overview/](https://kubernetes.io/docs/concepts/security/overview/)