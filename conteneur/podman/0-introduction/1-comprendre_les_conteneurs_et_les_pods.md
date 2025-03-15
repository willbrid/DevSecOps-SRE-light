# Comprendre les conteneurs et les pods

### Que sont les conteneurs

Un conteneur est une technologie qui permet d'assembler et d'isoler des applications avec leur environnement d'exécution complet, c'est-à-dire tous les fichiers nécessaires à leur exécution. Les applications conteneurisées sont plus faciles à déplacer d'un environnement à un autre (développement, test, production, etc.), tout en conservant l'intégralité de leurs fonctions.

### Composants clés d'un conteneur

- **Application**: l'application que nous souhaitons exécuter. Nous pouvons exécuter plusieurs applications par conteneur, mais la plupart des utilisateurs s'en tiennent à une seule application par conteneur.

- **Fichiers de support**: ces derniers sont des bibliothèques et autres fichiers de support nécessaires à l'exécution de l'application ou des applications.

- **Moteur d'exécution de conteneur**: **podman** utilise un environnement d'exécution de conteneur compatible OCI (runc) pour fonctionner avec le système d'exploitation et gérer les conteneurs.

### Qu'est ce qu'un moteur d'exécution de conteneur ?

Un **moteur d'exécution de conteneur** exécute et gère les images de conteneurs sur un serveur.

**Quelques exemples de moteur d'exécution de conteneur** :
- Podman (runc)
- Docker (containerd)
- Kubernetes (CRI-O)
- Openshift (CRI-O)

### Qu'est-ce que l'orchestration de conteneurs

L'**orchestration de conteneurs** automatise le déploiement, la gestion, la mise à l'échelle et la mise en réseau des conteneurs, ce qui facilite la gestion des environnements de conteneurs plus volumineux.

**Exemple de framework d'orchestration de conteneurs** :
- Kubernetes
- Openshift
- Docker Swarm
- Cloud (AWS, AZURE, GCP,...)

### Pourquoi utiliser les conteneurs ?

- sa portabilité
- sa légèreté
- sa rapidité à démarrer
- sa modularité

### Qu'est ce qu'un pod ?

Un **pod** est un groupe d'un ou plusieurs conteneurs, avec des ressources de stockage et de réseau partagées, et une spécification d'exécution des conteneurs. Le contenu d'un **pod** est toujours colocalisé et co-planifié, et s'exécute dans un contexte partagé.

Les pods sont les plus petites unités de calcul déployables que nous pouvons créer et gérer dans Kubernetes.

### Composants clés d'un pod

- **Pod**
--- partage des liaisons de port, des valeurs parentes des cgroups et des espaces de noms du noyau. <br>
--- une fois le pod créé, ces attributs ne peuvent plus être modifiés ; il faut recréer le pod avec les modifications. <br>
--- chaque conteneur possède sa propre instance de **conmon**. Ce qui permet à **podman** de s'exécuter en mode détaché.

**Conmon** est un programme de surveillance et un outil de communication entre un gestionnaire de conteneurs (comme **Podman** ou **CRI-O**) et un **runtime OCI** (comme **runc** ou **crun)** pour un seul conteneur.

- **Conteneurs**
--- notre conteneur habituel avec nos applications. <br>
--- il peut communiquer avec d'autres conteneurs du pod via un espace de noms réseau partagé.

- **Conteneur infra**
--- contient les espaces de noms associés au pod. <br>
--- permet à **Podman** de connecter d'autres conteneurs au pod. <br>
--- il est basé par défaut sur le conteneur d'image **k8s.gcr.io/pause**.

### Pourquoi utiliser les pods ?

- **Ressources partagées** : les conteneurs du même pod partageront les mêmes ressources et le même réseau local
- **Communication** : les conteneurs peuvent facilement communiquer avec d'autres dans le même pod comme s'ils étaient sur le même serveur
- **Evolutivité** : à mesure que la demande pour les services de notre pod augmente, nous déployons simplement des pods supplémentaires