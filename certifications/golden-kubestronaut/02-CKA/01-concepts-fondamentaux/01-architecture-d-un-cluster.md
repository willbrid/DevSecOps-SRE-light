# Architecture d'un cluster Kubernetes

> Vue d'ensemble de l'architecture d'un cluster Kubernetes : rôles et composants des nœuds *master* (plan de contrôle) et *worker* (nœuds de travail) dans la gestion des applications conteneurisées.

Kubernetes simplifie le **déploiement, la mise à l'échelle et la gestion** des applications conteneurisées grâce à l'automatisation.

Analogie utile pour comprendre : imaginez deux types de navires.
- Les **cargos** = les *worker nodes* (nœuds de travail) qui transportent les conteneurs.
- Les **navires de contrôle** = les *master nodes* (nœuds maîtres) qui surveillent et gèrent les cargos.

Un cluster est constitué de **nœuds** (physiques ou virtuels, sur site ou dans le cloud) qui hébergent les applications conteneurisées.

### Composants du nœud maître (Master Node)

Le nœud maître contient les composants du **plan de contrôle** (*control plane*) qui gèrent l'ensemble du cluster : suivi de tous les nœuds, décision de l'emplacement d'exécution des applications, surveillance continue. C'est le **centre de commandement central**.

Composants clés :

- **ETCD Cluster** : magasin de données clé-valeur, **hautement disponible**, qui stocke la configuration et l'état de tout le cluster. Il utilise un format clé-valeur simple et un mécanisme de **quorum** pour garantir un stockage fiable et cohérent des données.
- **Kube Scheduler** (planificateur) : comparable aux **grues portuaires**, il détermine sur quel *worker node* déployer un nouveau conteneur. Il tient compte de la charge actuelle, des besoins en ressources et de contraintes spécifiques comme les **taints, tolerations ou règles d'affinité de nœud** (*node affinity*).
- **Controllers** (contrôleurs) : tels le personnel du bureau portuaire, ils garantissent que le **nombre souhaité de conteneurs** est en cours d'exécution et gèrent le cycle de vie des nœuds, la réplication des conteneurs et la stabilité du système.
- **Kube API Server** : **hub central** de communication et de gestion du cluster.

> Le *replication controller* et les autres contrôleurs veillent à ce que le nombre voulu de conteneurs tourne et gèrent les opérations sur les nœuds.

### Composants du nœud de travail (Worker Node)

Les *worker nodes* (comparables aux cargos) sont responsables de **l'exécution des applications conteneurisées**. Chaque nœud est piloté par le **Kubelet**, son « capitaine ».

- **Kubelet** : gère le **cycle de vie des conteneurs** sur un nœud individuel. Il reçoit les instructions du Kube API Server pour créer, mettre à jour ou supprimer des conteneurs, et rapporte régulièrement l'état du nœud.
- **Kube Proxy** : configure les **règles réseau** sur les *worker nodes*, permettant la communication inter-conteneurs entre les nœuds (ex. : un serveur web sur un nœud qui communique avec une base de données sur un autre nœud).

> Tout le système de contrôle est **conteneurisé**. Quel que soit le moteur utilisé (**Docker, Containerd ou CRI-O**), chaque nœud — y compris les nœuds maîtres avec leurs composants conteneurisés — nécessite un **moteur d'exécution de conteneurs** (*container runtime*) compatible.

### Résumé de l'architecture

| Catégorie de composant | Composants clés | Description |
| ---------------------- | --------------- | ----------- |
| **Master Node** | etcd, Kube Scheduler, Controllers, Kube API Server | Contrôle et gestion centralisés de l'ensemble du cluster. |
| **Worker Node** | Kubelet, Kube Proxy | Gestion du cycle de vie des conteneurs et communication réseau entre les services. |

La **séparation claire** et la **coordination** entre nœuds maîtres et nœuds de travail sont fondamentales dans la capacité de Kubernetes à automatiser et rationaliser l'orchestration des conteneurs.

### Points essentiels à retenir pour l'apprentissage

- **etcd** = source de vérité de l'état du cluster (clé-valeur + quorum).
- **Scheduler** = *où* placer un pod (ressources, taints/tolerations, affinité).
- **Controllers** = maintien de l'état désiré (réplication, cycle de vie des nœuds).
- **API Server** = point d'entrée unique de toute communication du cluster.
- **Kubelet** = agent sur chaque nœud qui exécute réellement les conteneurs.
- **Kube Proxy** = réseau et communication entre conteneurs/nœuds.
- Un **container runtime** (Docker / Containerd / CRI-O) est requis sur **tous** les nœuds.
