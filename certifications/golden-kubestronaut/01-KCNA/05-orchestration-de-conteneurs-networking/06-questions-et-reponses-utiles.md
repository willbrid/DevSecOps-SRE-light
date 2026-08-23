# Questions et réponses utiles

Voici quelques points clés à retenir, organisés par thème.

### CNI et configuration des plugins

- **Champ `isGateway`** : détermine si le **bridge network doit agir comme une passerelle (gateway)**.
- **Champ `type` pour un réseau bridge** : on définit la valeur **`bridge`**.
- **Champ `type` réglé sur `host-local` (section IPAM)** : indique le **type de gestion des adresses IP** utilisé pour les pods.
- **Champ `ipMasquerade`** : détermine si une **règle NAT doit être ajoutée** pour l'IP masquerading.
- **Section IPAM** : définit le **sous-réseau (subnet) ou la plage d'adresses IP** assignés aux pods.
- **Qui définit le format du fichier de configuration du plugin** : le **standard CNI**.
- **Où sont stockés les plugins CNI supportés** : dans le **répertoire CNI bin** (`/opt/cni/bin`), sous forme d'**exécutables**.
- **Où le kubelet cherche quel plugin utiliser** : dans le **répertoire de configuration CNI** contenant les fichiers de configuration.
- **Où le CNI est configuré dans le cluster** : dans le **service kubelet de chaque nœud** du cluster.

### Container Runtime et networking

- **Responsabilités du container runtime en matière de réseau** :
  - **appeler** le plugin réseau approprié ;
  - **identifier et attacher** les namespaces au réseau approprié ;
  - **créer** les network namespaces des conteneurs.

### Solutions réseau et couches

- **Solutions réseau populaires pour le pod networking** : **flannel, cilium, weaveWorks**.
- **Couche réseau cruciale pour le fonctionnement au niveau des pods** : la **couche réseau (network layer)**.
- **Identifiants uniques requis pour les hôtes d'un réseau** : un **hostname unique** et une **adresse MAC unique**.

### Commandes

- **Commande pour voir le service kubelet en cours d'exécution** : **`ps -aux | grep kubelet`**.

### DNS dans Kubernetes

- **Kubernetes déploie-t-il un serveur DNS intégré par défaut ?** : **Oui**, un serveur DNS intégré est automatiquement déployé par défaut.
- **Ce qui se passe à la création d'un service** : le service DNS crée **automatiquement un enregistrement** pour le service.
- **Ce que mappe l'enregistrement DNS d'un service** : le **nom du service vers son adresse IP**.
- **Comment un pod peut joindre un service** : en utilisant le **nom du service**.
- **Condition pour joindre un service par son nom** : uniquement si le **pod et le service sont dans le même namespace**.
- **Comment joindre un service dans un namespace séparé nommé `apps`** (depuis `default`) : en utilisant le motif **`.apps`** (ex. `service.apps`).
- **Comment les pods et services d'un namespace sont regroupés dans le sous-domaine DNS** : ils sont regroupés sous le **sous-domaine portant le nom du namespace**.
- **Convention de nommage des enregistrements de pods** (quand activés) : les enregistrements sont créés en **remplaçant les points de l'adresse IP par des tirets** comme nom d'enregistrement (ex. `10.244.2.5` → `10-244-2-5`).
