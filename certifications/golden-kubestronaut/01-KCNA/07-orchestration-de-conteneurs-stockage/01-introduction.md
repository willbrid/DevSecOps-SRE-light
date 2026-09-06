# Introduction au Stockage Docker

Ce contenu aborde le fonctionnement du **stockage** dans les plateformes d'orchestration de conteneurs comme Kubernetes, en partant des concepts fondamentaux du **stockage Docker**.

### Pourquoi commencer par Docker ?

Une bonne compréhension des mécanismes de stockage de **Docker** est **cruciale**, car elle **facilite la transition** vers les concepts utilisés dans Kubernetes.

### Les deux éléments fondamentaux du stockage Docker

Le stockage **Docker** s'articule autour de **deux éléments** :

| Élément | Rôle |
|---------|------|
| **pilotes de stockage** (Storage Drivers) | Gèrent la manière dont Docker stocke et gère les couches d'images et les données des conteneurs |
| **plugins de pilotes de volume** (Volume Driver Plugins) | Gèrent les **volumes** (stockage persistant) attachés aux conteneurs |

### À retenir

- Comprendre le **stockage Docker** est un prérequis pour aborder le stockage dans **Kubernetes**.
- Deux notions clés : les **storage drivers** (gestion des couches d'images et données de conteneurs) et les **volume driver plugins** (gestion des volumes / stockage persistant).
