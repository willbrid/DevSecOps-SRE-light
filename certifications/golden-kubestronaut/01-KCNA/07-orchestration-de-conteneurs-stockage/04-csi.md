# CSI

Le **Container Storage Interface (CSI)** joue un rôle crucial en **standardisant** la manière dont les pilotes de stockage interagissent avec les plateformes d'orchestration comme **Kubernetes, Cloud Foundry et Mesos**.

**Le mouvement vers la modularité** :
- Au départ, Kubernetes intégrait la fonctionnalité de container runtime **directement dans son code source** avec Docker ;
- Avec l'arrivée de runtimes alternatifs (**Rocket**, etc.), il est devenu essentiel de **découpler** le runtime de Kubernetes → naissance du **CRI (Container Runtime Interface)** ;
- Le même besoin de modularité s'est étendu au **réseau** et au **stockage** → **CNI (Container Networking Interface)** et **CSI (Container Storage Interface)**.

> CSI est donc le **pendant du CRI et du CNI**, mais pour le **stockage**.

### Pourquoi le CSI est important

Le CSI a été conçu pour supporter une **large gamme de solutions de stockage** sans être lié à des implémentations **spécifiques à Kubernetes**.

Avantages :
- Les développeurs peuvent créer des **pilotes personnalisés** pour divers systèmes de stockage → **flexibilité et innovation** ;
- **Nature vendor-agnostic (indépendante du fournisseur)** : n'importe quel outil d'orchestration compatible peut s'interfacer avec n'importe quel système de stockage supportant le CSI.

Grands fournisseurs ayant adopté le standard : **Portworx, Amazon EBS, Azure Disk, Dell EMC, Isilon, PowerMax, Unity, XtremIO, NetApp, Nutanix, HPE, Hitachi, Pure Storage**, etc.

### Fonctionnement

À la base, le CSI définit une série de **RPC (Remote Procedure Calls)** utilisés par les orchestrateurs pour interagir avec les pilotes de stockage.

Interactions typiques :
- **Création de volume (Create Volume)** : quand un pod est déployé et nécessite un volume, Kubernetes lance un appel RPC **« Create Volume »**, en fournissant des détails (nom du volume, paramètres de configuration). Le pilote de stockage **provisionne** alors un nouveau volume sur la baie de stockage et retourne le **statut** de l'opération.
- **Suppression de volume (Delete Volume)** : quand un volume n'est plus nécessaire, Kubernetes lance un appel RPC **« Delete Volume »**. Le pilote de stockage **décommissionne** le volume et communique le résultat à Kubernetes.

Chaque RPC défini par le CSI inclut des **spécifications détaillées** : les **paramètres** envoyés par l'appelant, les **réponses attendues** du système de stockage, et les **codes d'erreur** à utiliser selon les scénarios.

Comprendre le CSI est essentiel pour l'orchestration de conteneurs et la gestion du stockage. Son approche **standardisée** assure la **compatibilité** entre divers systèmes de stockage et runtimes, favorisant un écosystème de conteneurs plus **flexible et dynamique**.

### Le trio des interfaces standardisées

| Interface | Domaine | Rôle |
|-----------|---------|------|
| **CRI** (Container Runtime Interface) | Runtime | Définit une **API standard** permettant à Kubernetes (kubelet) de dialoguer avec **n'importe quel container runtime** (containerd, CRI-O…) pour gérer pods, conteneurs et images |
| **CNI** (Container Networking Interface) | Réseau | Définit une **norme** permettant à Kubernetes de configurer le **réseau des pods** via n'importe quel **plugin réseau** compatible (Calico, Flannel, Cilium…) |
| **CSI** (Container Storage Interface) | Stockage | Définit une **norme (basée sur des RPC)** permettant à Kubernetes de provisionner et gérer du **stockage** via n'importe quel **pilote de stockage** compatible (EBS, Azure Disk, Portworx…) |

> **Le point commun (l'idée clé)** : ces trois interfaces sont des **standards** qui **découplent** une fonctionnalité (runtime, réseau, stockage) du **code source** de Kubernetes. Grâce à elles, Kubernetes n'a plus besoin de coder en dur le support de chaque fournisseur : n'importe quelle implémentation respectant l'interface fonctionne automatiquement, ce qui apporte **modularité, flexibilité** et évite le **vendor lock-in**.

### À retenir

- Le **CSI** standardise l'interaction entre les **pilotes de stockage** et les orchestrateurs (Kubernetes, Cloud Foundry, Mesos), à l'image du **CRI** (runtime) et du **CNI** (réseau).
- Il est **vendor-agnostic** : n'importe quel orchestrateur compatible fonctionne avec n'importe quel stockage compatible CSI → **flexibilité** et pas de **vendor lock-in**.
- Nombreux fournisseurs adoptent le standard (Portworx, Amazon EBS, Azure Disk, NetApp, Pure Storage…).
- Fonctionnement via des **RPC** : notamment **Create Volume** (provisionner) et **Delete Volume** (décommissionner), avec des spécifications précises (paramètres, réponses, codes d'erreur).

### Liens utiles

- Spécification officielle du CSI sur GitHub : https://github.com/container-storage-interface/spec

