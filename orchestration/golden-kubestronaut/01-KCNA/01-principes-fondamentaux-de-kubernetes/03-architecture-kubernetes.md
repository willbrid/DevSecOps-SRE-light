# Architecture Kubernetes

Avant de configurer un cluster Kubernetes, il est essentiel de comprendre ses **composants fondamentaux** et sa terminologie, afin de concevoir un système robuste, évolutif et hautement disponible.

### Concepts de base

- **Nœud (node)** : une machine physique ou virtuelle qui exécute le logiciel Kubernetes. Les nœuds (anciennement appelés **minions**) sont les machines de travail qui exécutent les applications conteneurisées.
- **Cluster** : un groupe de nœuds travaillant ensemble. Si un nœud tombe en panne, les autres continuent d'exécuter les applications, garantissant ainsi la haute disponibilité.

### Le nœud maître (Master Node)

Le nœud maître gère l'ensemble du cluster : il surveille l'état des nœuds de travail, orchestre les déploiements et veille à ce que l'**état désiré** du cluster soit maintenu.

### Composants clés de Kubernetes

Lors de l'installation, plusieurs composants essentiels forment le **plan de contrôle (control plane)** :

| Composant | Rôle |
|-----------|------|
| **API Server** | Interface frontale de Kubernetes, gère la communication entre les utilisateurs, la CLI et le cluster. |
| **etcd** | Base de données clé-valeur distribuée stockant les données du cluster ; assure la cohérence et la réplication en environnement multi-maîtres. |
| **Scheduler** | Attribue les nouvelles tâches (conteneurs) aux nœuds de travail adaptés selon les ressources disponibles. |
| **Controllers** | Le « cerveau » de l'orchestration : surveillent les événements et remplacent les conteneurs ou nœuds défaillants. |
| **Container Runtime** | Logiciel qui exécute les conteneurs (Docker, containerd, CRI-O). |
| **kubelet** | Agent présent sur chaque nœud de travail, communique avec le maître pour garantir le bon fonctionnement des conteneurs. |

### Nœuds maîtres vs nœuds de travail

- **Nœuds de travail** : hébergent les conteneurs ; contiennent le **container runtime** et l'**agent kubelet**.
- **Nœud maître** : contient le **kube-apiserver**, le **controller manager**, le **scheduler** et le **stockage clé-valeur etcd**.

### Gérer le cluster avec kubectl

`kubectl` est l'outil en ligne de commande indispensable pour interagir avec le cluster. Commandes de base :
- **`kubectl run`** : déploie une application sur le cluster.
- **`kubectl cluster-info`** : affiche les informations détaillées du cluster.
- **`kubectl get nodes`** : liste tous les nœuds du cluster.

```bash
kubectl run hello-minikube
kubectl cluster-info
kubectl get nodes
```

Ces commandes constituent la base d'une gestion efficace du cluster, avant d'aborder des fonctionnalités et concepts plus avancés.
