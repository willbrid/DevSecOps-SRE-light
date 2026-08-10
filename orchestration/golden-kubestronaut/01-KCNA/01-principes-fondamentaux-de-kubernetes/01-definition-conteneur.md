# Qu'est ce qu'un conteneru ?

Ce contenu introduit les fondamentaux de Kubernetes en commençant par deux concepts clés : les **conteneurs** et l'**orchestration**. Il se concentre d'abord sur Docker, la technologie de conteneurisation la plus répandue.

### Le problème résolu par Docker

Le déploiement d'applications multi-composants (Node.js, MongoDB, Redis, Ansible) posait plusieurs difficultés :
- **Incompatibilités de versions** entre systèmes d'exploitation et bibliothèques (la « matrice de l'enfer »).
- **Onboarding complexe** des nouveaux développeurs, avec des environnements incohérents entre développement et production.

Docker résout cela en **encapsulant chaque composant dans un conteneur isolé**, incluant ses bibliothèques, dépendances et un système de fichiers léger.

### Qu'est-ce qu'un conteneur ?

Un **conteneur** fournit un environnement isolé (processus, réseau, montages de fichiers), comparable à une machine virtuelle, mais qui **partage le noyau (kernel) du système hôte**. Des technologies antérieures comme LXC ont ouvert la voie à Docker.

### Le rôle du noyau

Chacun **os linux** est composé de :
- noyau du système d'exploitation : interagit directement avec le matériel.
- un ensemble de progiciels : ceux-ci définissent l'interface utilisateur, les pilotes, les compilateurs, les gestionnaires de fichiers et les outils de développement.

Docker partage le noyau de l'hôte : un système Ubuntu peut héberger des conteneurs Debian, Fedora, SUSE ou CentOS. **Exception** : Docker sous Linux ne peut pas exécuter de conteneurs Windows (différences de noyau).

### Conteneurs vs Machines virtuelles

| Critère | Conteneur Docker | Machine virtuelle |
|---------|------------------|-------------------|
| Architecture | OS hôte + daemon Docker | OS hôte + hyperviseur + OS invité |
| Ressources | Léger (Mo) | Lourd (Go) |
| Démarrage | Secondes | Minutes |
| Isolation | Partage du noyau | Isolation OS complète |

Les conteneurs consomment moins de ressources, mais offrent une isolation moindre.

### Images et conteneurs

- Une **image** est un modèle (template) contenant les instructions de création d'un conteneur.
- Un **conteneur** est une instance en cours d'exécution de cette image.

On peut utiliser des images prêtes à l'emploi (**Docker Hub**, **Quay io**) ou créer les siennes via un **Dockerfile**.

### Changement des responsabilités Dev/Ops

Docker transforme la relation développeurs/opérations : les développeurs définissent l'environnement dans un Dockerfile, et l'image validée se comporte de manière identique sur toutes les plateformes. Cela élimine le fameux problème du « ça marche sur ma machine ».

Ces bases posées, on peut ensuite aborder **Kubernetes** et ses capacités d'orchestration.
