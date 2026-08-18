# Pod Networking

Ce contenu explore comment les pods reçoivent des **adresses IP uniques** et **communiquent** à la fois au sein d'un même nœud et à travers plusieurs nœuds, avec l'usage du **CNI (Container Network Interface)** pour l'automatisation.

Prérequis atteints : les nœuds master et worker sont configurés et interconnectés, les firewalls / security groups autorisent la communication entre les composants du control plane (kube-apiserver, etcd, kubelets). L'étape suivante est de **configurer le réseau des pods**.

Questions essentielles à se poser avant de déployer :
- Comment les pods sont-ils **adressés** ?
- Comment les pods **communiquent**-ils entre eux ?
- Comment accéder aux services des pods, **depuis l'intérieur** du cluster et **depuis l'extérieur** ?

#### Les exigences réseau imposées par Kubernetes

Kubernetes **ne fournit PAS** de solution réseau clé en main, mais définit des **exigences strictes** que l'implémentation doit satisfaire :
- Chaque pod doit recevoir sa **propre adresse IP unique** ;
- Tout pod sur le **même nœud** doit pouvoir joindre tout autre pod via son IP ;
- Tout pod sur des **nœuds différents** doit communiquer **sans NAT (Network Address Translation) supplémentaire**, quelles que soient les plages IP sous-jacentes.

> Tant que la solution **assigne automatiquement les IP** et fournit une **connectivité intra- et inter-nœuds sans NAT manuel**, elle satisfait les exigences.

### Construire un réseau de pods

Conception d'une solution de base à partir de concepts réseau : **routage, gestion des IP (IPAM), namespaces, et CNI**.

**Scénario** : un cluster de 3 nœuds où tous les nœuds (quel que soit leur rôle) participent **également** au réseau. Le réseau externe assigne des IP en `192.168.1.x` (node 1 = `192.168.1.11`, node 2 = `192.168.1.12`, node 3 = `192.168.1.13`).

À la création des conteneurs, chacun reçoit son **network namespace** dédié. Pour permettre la communication entre ces namespaces, on rattache chacun à un **bridge network local** sur chaque nœud.

Créer et configurer le bridge network sur chaque nœud :

```bash
ip link add v-net-0 type bridge
ip link set dev v-net-0 up
ip addr add 192.168.15.5/24 dev v-net-0
ip link add veth-red type veth peer name veth-red-br
ip link set veth-red netns red
ip -n red addr add 192.168.15.1 dev veth-red
ip -n red link set veth-red up
ip link set veth-red-br master v-net-0
ip netns exec blue ip route add 192.168.1.0/24 via 192.168.15.5
iptables -t nat -A POSTROUTING -s 192.168.15.0/24 -j MASQUERADE
```

Tous les nœuds sont traités de manière **équivalente** (pods de gestion et pods de charge suivent les mêmes principes réseau).

#### Planifier la connectivité

Les nœuds ayant des IP publiques, on attribue à **chaque bridge de nœud son propre sous-réseau privé** :
- Node 1 : `10.244.1.0/24`
- Node 2 : `10.244.2.0/24`
- Node 3 : `10.244.3.0/24`

Assigner l'IP correspondante à l'interface bridge de chaque nœud :

```bash
ip link add v-net-0 type bridge
# Sur node 1
ip addr add 10.244.1.1/24 dev v-net-0
# Sur node 2
ip addr add 10.244.2.1/24 dev v-net-0
# Sur node 3
ip addr add 10.244.3.1/24 dev v-net-0
```

Chaque conteneur nécessite une configuration réseau. Un **script** peut automatiser, pour chaque nouveau conteneur :
1. Créer une **paire veth** reliant le namespace du conteneur au bridge du nœud ;
2. Configurer une **IP** dans le conteneur et définir une **passerelle par défaut**.

Exemple (IP libre `10.244.1.2` allouée à un conteneur) :

```bash
# Créer la paire veth
ip link add <veth_container> type veth peer name <veth_bridge>
# Rattacher la paire veth au namespace et au bridge
ip link set <veth_container> netns <namespace>
ip link set <veth_bridge> master v-net-0
# Assigner l'IP et configurer le routage dans le namespace
ip -n <namespace> addr add 10.244.1.2/24 dev <veth_container>
ip -n <namespace> route add default via 10.244.1.1
# Activer l'interface dans le namespace
ip -n <namespace> link set <veth_container> up
```

Ces commandes configurent **un seul** conteneur → il faut **répliquer et automatiser** ce script sur tous les nœuds pour passer à l'échelle.

### Communication inter-nœuds

Une fois les IP uniques établies sur chaque nœud, le défi est la **communication entre nœuds**.

**Scénario** : un pod `10.244.1.2` (node 1) doit joindre un pod `10.244.2.2` (node 2). Sans route appropriée, node 1 **ne sait pas** comment atteindre le pod de node 2.

Solution : ajouter une route dans la table de routage de node 1, dirigeant le trafic du sous-réseau `10.244.2.0/24` via l'**IP externe de node 2** (`192.168.1.12`) :

```bash
# Sur node 1
ip route add 10.244.2.2 via 192.168.1.12
```

Après cela, les pods de node 1 peuvent joindre ceux de node 2. Des **routes similaires** doivent être configurées sur **tous les nœuds**.

> La configuration manuelle des routes convient aux **petits déploiements**, mais à mesure que l'infrastructure grandit, il faut envisager un **routeur centralisé** ou des **protocoles de routage dynamique**. Un routeur central peut simplifier la gestion en **agrégeant les sous-réseaux** (ex. `10.244.1.0/24` + `10.244.2.0/24` + `10.244.3.0/24` en un seul `10.244.0.0/16`).

### Automatiser avec le CNI

Configurer manuellement bridges et routes pour chaque conteneur est **impraticable** dans les grands environnements (des milliers de pods créés par minute). Le **CNI (Container Network Interface)** automatise ces tâches en exécutant des scripts réseau au démarrage des pods.

**Fonctionnement** :
- Le **container runtime** de chaque nœud lit une **configuration CNI** spécifiant le script réseau ;
- À la création d'un pod, le runtime invoque le script avec la commande **`add`**, en passant les détails du conteneur (nom, namespace) → le script configure le réseau du pod.

Exemple de script simplifié :

```bash
# Créer une paire veth
ip link add <veth_container> type veth peer name <veth_bridge>
# Rattacher au namespace et au bridge
ip link set <veth_container> netns <namespace>
ip link set <veth_bridge> master v-net-0
# Assigner l'IP et le routage par défaut dans le namespace
ip -n <namespace> addr add <container_ip>/24 dev <veth_container>
ip -n <namespace> route add default via <bridge_ip>
# Activer l'interface
ip -n <namespace> link set <veth_container> up
```

**Exigence CNI** : le script doit aussi supporter une opération **delete** pour nettoyer les interfaces réseau et **libérer l'IP** quand le pod est terminé :

```bash
ip -n <namespace> link set <veth_container> down
ip link del <veth_bridge>
```

Le container runtime exécute le script ainsi :

```bash
./net-script.sh add <container> <namespace>   # à la création
./net-script.sh del <container> <namespace>   # à la suppression
```

### À retenir

- Kubernetes impose 3 exigences : **IP unique par pod**, communication **intra-nœud**, communication **inter-nœuds sans NAT**.
- Briques de base : **network namespace** (par conteneur), **bridge** (par nœud, ex. `v-net-0`), **sous-réseau distinct par nœud** (`10.244.X.0/24`), **paires veth**.
- Communication inter-nœuds = **routes** via l'IP externe des nœuds → à automatiser (routeur central, `10.244.0.0/16`).
- Le **CNI** automatise tout via un script appelé en **`add`** (création) et **`del`** (suppression) par le container runtime.
