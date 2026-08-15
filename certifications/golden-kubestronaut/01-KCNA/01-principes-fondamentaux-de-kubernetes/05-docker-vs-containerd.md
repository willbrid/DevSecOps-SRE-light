# Docker vs ContainerD

Ce contenu clarifie les distinctions entre **Docker** et **ContainerD**, ainsi que les outils CLI associés (**ctr**, **nerdctl**, **crictl**). La documentation ancienne mentionne souvent Docker, tandis que les ressources récentes privilégient ContainerD.

### L'évolution des runtimes de conteneurs

- Docker était l'outil dominant grâce à sa simplicité, et Kubernetes y était étroitement intégré à l'origine.
- Avec l'apparition d'autres runtimes (comme Rocket), Kubernetes a introduit le **CRI (Container Runtime Interface)**, un standard API compatible avec les runtimes respectant l'**OCI (Open Container Initiative)**.
- L'OCI définit deux spécifications essentielles :
  - **Image specification** : comment les images doivent être construites ;
  - **Runtime specification** : les standards pour les runtimes de conteneurs.
- Docker est antérieur au CRI et n'en a pas le support natif → Kubernetes a utilisé le **Docker Shim** pour combler cet écart. Avec la maturité de ContainerD (issu de l'architecture de Docker), ce shim est devenu inutile.

### Les composants de Docker

Docker n'est pas qu'un simple runtime, c'est une **suite d'outils** comprenant : Docker CLI, API, outils de build, gestion des volumes, authentification et sécurité. 

Un composant clé est **containerd** : un daemon responsable de l'exécution des conteneurs via le runtime **runc**. Initialement intégré à Docker, containerd est désormais un **projet séparé et conforme au CRI**, installable indépendamment.

### Les outils CLI (point essentiel)

| Outil | Communauté | Usage principal | Recommandation |
|-------|-----------|-----------------|----------------|
| **ctr** | ContainerD | Débogage uniquement, fonctionnalités très limitées | Non recommandé pour un usage courant |
| **nerdctl** | ContainerD | CLI complète type Docker | **Idéal pour la production** |
| **crictl** | Kubernetes | Inspection/débogage de tout runtime compatible CRI | Débogage, pas pour créer des conteneurs |

#### ctr (ContainerD)

Livré avec ContainerD, conçu surtout pour le **débogage**. Syntaxe :

```bash
ctr images pull docker.io/library/redis:alpine
ctr run docker.io/library/redis:alpine redis
```

#### nerdctl (expérience type Docker)

Développé par la communauté ContainerD, il offre une expérience identique à Docker plus des fonctions avancées : **images chiffrées, lazy pulling, distribution P2P, signature et vérification d'images, support des namespaces Kubernetes, Docker Compose**. Il suffit de remplacer `docker` par `nerdctl` :

```bash
nerdctl run --name redis redis:alpine
nerdctl run --name webserver -p 80:80 -d nginx
```

#### crictl (perspective Kubernetes)

Maintenu par la communauté Kubernetes, il fonctionne avec **tous les runtimes compatibles CRI** (ContainerD, Rocket, CRI-O). Utilisé pour **inspecter et déboguer**. 

> **Important** : bien qu'il puisse techniquement créer des conteneurs, ce n'est **pas recommandé** — les conteneurs créés hors du contrôle du **kubelet** peuvent être supprimés.

```bash
crictl pull busybox
crictl images
crictl ps -a
```

Il gère aussi les détails spécifiques aux **pods**, ce que Docker ne fait pas.

### Changements des endpoints CRI avec Kubernetes 1.24 (point essentiel)

Avant la 1.24, crictl se connectait selon un ordre par défaut incluant `dockershim.sock`. 

Avec **Kubernetes 1.24**, le **Docker shim a été supprimé** et le docker-socket remplacé. Les utilisateurs doivent désormais **configurer manuellement l'endpoint** :

```bash
crictl --runtime-endpoint
export CONTAINER_RUNTIME_ENDPOINT=<votre_endpoint>
```

Endpoints valides :
```
unix:///run/containerd/containerd.sock
unix:///run/crio/crio.sock
unix:///var/run/cri-dockerd.sock
```

### Récapitulatif

- **ctr** : débogage de ContainerD, fonctionnalités limitées.
- **nerdctl** : CLI complète type Docker, idéale en production avec ContainerD.
- **crictl** : maintenu par Kubernetes, excellent pour le débogage et l'inspection sur toute plateforme compatible CRI.