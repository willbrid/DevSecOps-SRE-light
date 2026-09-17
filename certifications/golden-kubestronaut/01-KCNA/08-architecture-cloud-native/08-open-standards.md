# Open Standards

Ce contenu explore les **Open Standards** (standards ouverts) et leur impact sur l'**interopérabilité** et la **neutralité vis-à-vis des fournisseurs** dans les technologies cloud-native.

**Analogie (point de compréhension)** : imaginez voyager avec votre téléphone. À l'étranger, il faut parfois un **chargeur ou adaptateur différent** car les pays utilisent des designs de prises différents. De même, dans l'écosystème cloud-native, divers services (conteneurs, orchestration, réseau, stockage) doivent interagir. **Sans lignes directrices universelles**, ces technologies risquent des **problèmes de compatibilité** et le **vendor lock-in**.

### Définition

Les **Open Standards** sont des **spécifications, protocoles ou formats publiquement disponibles**, développés **collaborativement par consensus**. Ils favorisent **trois qualités clés** :
- **Interopérabilité** : les technologies fonctionnent ensemble ;
- **Portabilité** : possibilité de migrer entre technologies ;
- **Neutralité vis-à-vis des fournisseurs (Vendor Neutrality)** : pas de dépendance à un fournisseur unique.

**Analogie des prises électriques** : de nombreux pays ont adopté quelques designs communs (types A, B, C, D). Un chargeur de type A (USA, Japon) fonctionne dans les pays supportant ce type, sans adaptateur. Un standard global unique serait idéal, mais la standardisation actuelle nous rend déjà bien service.

### Les bénéfices dans le cloud-native

Adopter les **Open Standards** permet aux technologies d'interagir **quel que soit leur fournisseur d'origine** :
- Les développeurs intègrent diverses technologies **sans modifications majeures** ;
- Flexibilité de **basculer entre technologies** → minimise la dépendance à un fournisseur → favorise **concurrence saine et innovation**.

**Exemple concret** : vous développez une app conteneurisée avec un format/runtime du **Vendor X**. Plus tard, pour migrer vers un cloud utilisant le format/runtime du **Vendor Y**, les **Open Standards** assurent une **transition fluide** sans réécriture ni reconfiguration extensive.

### Le rôle de l'OCI dans la technologie des conteneurs

La **fragmentation** de l'écosystème des conteneurs nécessite un **langage commun** → l'**Open Container Initiative (OCI)**, organisation dédiée aux standards ouverts pour les images, runtimes et distributions de conteneurs.

L'OCI a introduit **trois standards** :

| Standard | Rôle | Exemples d'outils |
|----------|------|-------------------|
| **1. Image Specification** | Définit comment un **filesystem bundle** doit être packagé en image | BuildKit, Podman, Buildah, Docker |
| **2. Container Runtime Specification** | Définit comment **télécharger, décompresser et exécuter** le **filesystem bundle** | ContainerD, CRI, Kata Containers, gVisor, Firecracker |
| **3. Distribution Specification** | Définit les **protocoles standardisés** pour distribuer les images | Docker Hub, Amazon ECR, Microsoft Azure |

### Kubernetes et les Open Standards

Kubernetes est un **fervent partisan** des standards ouverts et de la **modularité**. En supportant des **couches enfichables (pluggable)** pour le runtime, le réseau, les service meshes et le stockage, il offre un environnement flexible. Ce **découplage** permet d'assembler les **meilleurs composants** de divers fournisseurs.

#### Les 4 interfaces clés de Kubernetes

| Interface | Domaine | Rôle |
|-----------|---------|------|
| **CRI** (Container Runtime Interface) | Runtime | Couche runtime enfichable ; choisir le runtime optimal (des nœuds différents peuvent même utiliser des runtimes distincts) |
| **CNI** (Container Network Interface) | Réseau | Interface standard pour les plugins réseau ; permet network policies, service discovery, load balancing, connexions à des solutions tierces |
| **CSI** (Container Storage Interface) | Stockage | Permet de travailler avec divers stockages (cloud, NAS, SAN) ; plugins tiers pour le provisioning dynamique |
| **SMI** (Service Mesh Interface) | Service Mesh | Standardise l'interaction entre composants de service mesh ; APIs vendor-agnostic pour trafic, sécurité, observabilité |

**Détails importants** :
- **CRI** : au départ Kubernetes s'appuyait sur **Docker**, mais beaucoup de clusters utilisent désormais **ContainerD** par défaut (compatible CRI, contrairement à Docker) ;
- **CNI** : active network policies, service discovery, load balancing ;
- **CSI** : sépare les fonctions cœur de Kubernetes des implémentations de stockage → intégration transparente de plugins tiers ;
- **SMI** : assure une communication fluide entre **control planes** et **data planes** des service meshes.

### À retenir

- Les **Open Standards** = spécifications publiques développées par **consensus**, apportant **interopérabilité, portabilité et neutralité fournisseur** (évitent le **vendor lock-in**).
- L'**OCI (Open Container Initiative)** définit **3 standards** : **Image Spec** (packaging des images), **Runtime Spec** (exécution), **Distribution Spec** (distribution).
- Kubernetes est **modulaire** et enfichable via **4 interfaces** : **CRI** (runtime), **CNI** (réseau), **CSI** (stockage), **SMI** (service mesh).
- Ce découplage permet d'**assembler les meilleurs composants** de différents fournisseurs et de **migrer** sans réécriture majeure.

### Liens utiles

- Open Container Initiative (OCI) : https://opencontainers.org
- Cloud Native Computing Foundation (CNCF) : https://www.cncf.io
