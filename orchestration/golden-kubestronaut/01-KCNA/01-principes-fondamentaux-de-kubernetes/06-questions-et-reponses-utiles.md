# Questions et réponses utiles

Voici quelques points clés à retenir, organisés par thème.

### Conteneurs et conteneurisation

- **Conteneurisation** : exécuter des microservices dans leur propre conteneur.
- **Technologie sous-jacente de Docker** : Docker utilise principalement **LXC**.
- **Conteneurs vs VM (noyau)** : les conteneurs **partagent le même noyau OS que le système hôte**, tandis que les VM possèdent leur propre noyau indépendant.

### Orchestration de conteneurs

- **Orchestration de conteneurs** : processus automatisé de déploiement et de gestion des conteneurs, incluant la gestion de la connectivité et le scaling selon la charge de travail.
- **Kubernetes** : technologie d'orchestration réputée un peu difficile à installer et démarrer, mais offrant de nombreuses possibilités de personnalisation du déploiement.

### Architecture Kubernetes

- **Controllers** : composant responsable des décisions pour créer de nouveaux conteneurs en réponse aux défaillances de nœuds, conteneurs ou endpoints.
- **Rôle d'etcd** :
  - assure le stockage distribué des informations sur tous les nœuds du cluster ;
  - implémente des verrous (locks) pour éviter les conflits entre les masters ;
  - stocke toutes les données utilisées pour gérer le cluster.

### CRI (Container Runtime Interface)

- **Définition du CRI** : une interface de plugin qui permet à n'importe quel fournisseur de conteneurs de fonctionner comme runtime pour Kubernetes.
- **Bénéfice des runtimes compatibles CRI** : meilleure compatibilité et standardisation entre les runtimes de conteneurs.
- **Compatibilité des images Docker** : les images Docker continuent de fonctionner car elles respectent le standard **OCI (Open Container Initiative)**.
- **Suppression du dockershim en 1.24** : pour encourager l'usage de runtimes supportant le CRI.

### Outils CLI

- **ctr** : conçu **uniquement pour le débogage** de ContainerD, avec un ensemble de fonctionnalités limité.
- **nerdctl** :
  - fonctionnalités **absentes de Docker** : distribution d'images **P2P**, **images de conteneurs chiffrées**, **lazy pulling** (téléchargement paresseux) ;
  - **avantage sur ctr** : donne accès aux fonctionnalités les plus récentes de ContainerD.
- **crictl** :
  - utilisé pour **inspecter et déboguer** les runtimes de conteneurs ;
  - maintenu et développé par la **communauté Kubernetes** ;
  - spécifier un endpoint runtime : via l'option `--runtime-endpoint` **ou** la variable d'environnement `CONTAINER_RUNTIME_ENDPOINT`.

### Cloud Native

- **Cloud Native** : approche moderne du développement et du déploiement d'applications qui exploite les avantages du cloud computing, tirant parti de ses capacités de calcul distribué pour construire et exécuter efficacement les applications.
- **Non-bénéfice du cloud computing** : une **dépendance accrue à l'infrastructure physique** (au contraire, le cloud la réduit).