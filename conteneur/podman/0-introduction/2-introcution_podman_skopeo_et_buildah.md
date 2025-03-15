# Introduction Podman, Skopeo et Buildah

### Qu'est ce que Podman ?

- Moteur de conteneurs par défaut dans RHEL
- Développer, exécuter et gérer des conteneurs OCI
- Sans démon
- Interopérabilité avec Kubernetes
- Créer des conteneurs SystemD avec Podman

Il est utilisé pour gérer directement les conteneurs et les images de conteneurs sous Linux.

**Podman** peut capturer la configuration des conteneurs et des pods locaux, puis générer ces informations de configuration sous forme de fichier yaml pouvant être importé dans Kubernetes, nous permettant ainsi de tirer parti des fonctionnalités avancées de Kubernetes.

**Podman** peut accélérer le déploiement des conteneurs à l'aide de systemd.

### Qu'est ce que Skopeo ?

- Utilitaire en ligne de commande permettant d'effectuer diverses opérations sur les images de conteneurs et les référentiels d'images.
- Utilisable par les utilisateurs non root.
- Ne nécessite pas de démon.
- Fonctionne avec les images de conteneurs OCI et Docker v2.

Il est utilisé pour inspecter, copier, supprimer et signer les images de conteneurs et gérer les référentiels d'images.

### Qu'est ce que Buildah ?

Il s'agit d'un outil en ligne de commande permettant de créer rapidement et facilement des images de conteneurs OCI (compatibles avec Docker et Kubernetes). Il peut remplacer directement la ligne de commande **docker build** du démon Docker (c'est-à-dire créer des images avec un fichier Dockerfile traditionnel), mais il est suffisamment flexible pour nous permettre de créer des images avec les outils de notre choix. Il est facile à intégrer aux scripts et aux pipelines de build, et surtout, il ne nécessite pas de démon de conteneur en cours d'exécution pour créer son image.

Il est utilisé pour créer de nouvelles images de conteneur, sans démon.

### Quelle est la différence entre Docker et Podman ?

|Docker|Podman|
|---|----|
`Multiplateforme`|`Ne fonctionne que sur les systèmes Linux`
`Nécessite un démon`|`Aucun démon requis`
`Le référentiel local est /var/lib/docker`|`Le référentiel local est /var/lib/containers`
`Nécessite des autorisations root`|`Prend en charge les conteneurs sans root`
`Operation docker-cli->docker-daemon->containerd->runc`|`Operation podman->runc`