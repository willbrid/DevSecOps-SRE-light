# Docker vs ContainerD

> Relation entre Docker et ContainerD, leurs différences, et les outils CLI pour interagir avec les *container runtimes* (CTR, NerdCTL, crictl).

### L'évolution des container runtimes

Aux débuts des conteneurs, **Docker dominait** grâce à son interface intuitive. Kubernetes a d'abord été conçu pour orchestrer des conteneurs Docker, créant un **fort couplage** entre les deux. D'autres runtimes (comme **Rocket/rkt**) ont ensuite cherché à s'intégrer.

Pour répondre à ce besoin, Kubernetes a introduit la **CRI (Container Runtime Interface)**. La CRI standardise les runtimes en imposant la conformité aux standards **OCI (Open Container Initiative)** :
- **Image specification** → pour la construction des images
- **Runtime specification** → pour l'exécution des conteneurs

Comme Docker a été créé **avant** la CRI, il n'était pas compatible. Une solution temporaire, le **Docker Shim**, a permis de faire fonctionner Docker avec Kubernetes. Puis des runtimes nativement compatibles CRI comme **ContainerD** sont apparus.

**ContainerD** :
- Compatible CRI → s'intègre **directement** à Kubernetes, sans Docker Shim.
- À l'origine intégré à Docker, il est devenu un **projet indépendant** sous la **Cloud Native Computing Foundation (CNCF)**.
- Peut être installé **seul**, sans tout l'écosystème Docker, si l'on veut uniquement le runtime.

Composants internes de Docker :
- Docker CLI et API
- Outils de construction d'images
- Support des volumes, de l'authentification et de la sécurité
- Le runtime de conteneur (**runc**), géré par containerd

> À partir de **Kubernetes 1.24**, le support de Docker comme runtime a été **retiré** (complexité de maintenance du Docker Shim). **Mais** les images Docker restent **conformes OCI** et fonctionnent parfaitement avec ContainerD.

### Approfondissement de ContainerD

Si l'on n'a pas besoin des fonctionnalités additionnelles de Docker, on peut installer **ContainerD** seul. Il introduit ses propres outils CLI (à la place de `docker run`).

Exemple d'installation :
```bash
wget https://github.com/containerd/containerd/releases/download/v2.3.5/containerd-2.3.5-linux-amd64.tar.gz
$ tar -C /usr/local -zxvf containerd-2.3.5-linux-amd64.tar.gz
# fournit notamment : bin/ctr, bin/containerd
```

#### CTR
- Livré **avec ContainerD**.
- Permet de puller des images et d'effectuer des opérations de base.
- **Orienté débogage**, fonctionnalités limitées → **non recommandé** pour la gestion quotidienne.

```bash
$ ctr images pull docker.io/library/redis:alpine
$ ctr run docker.io/library/redis:alpine redis
```

#### NerdCTL
- Offre une expérience CLI **similaire à Docker** + des fonctionnalités propres à ContainerD.
- Fonctionnalités clés : **images chiffrées**, **lazy pulling** (téléchargement paresseux), **distribution peer-to-peer** des images, **signature et vérification** d'images dans les namespaces Kubernetes.
- Migration simple : il suffit de remplacer `docker` par `nerdctl` dans les commandes.

```bash
# Docker
$ docker run --name redis redis:alpine
$ docker run --name webserver -p 80:80 -d nginx
# Équivalent : remplacer "docker" par "nerdctl"
```

### Les outils CRI : la perspective Kubernetes

**crictl (CRI CTL)** :
- Interagit avec **n'importe quel runtime compatible CRI** (ContainerD, Rocket, etc.).
- Maintenu par la **communauté Kubernetes** (contrairement à CTR et NerdCTL, développés par la communauté ContainerD).
- Destiné au **débogage et à l'inspection**.

Usages principaux :
- Puller des images
- Lister les images et les conteneurs
- Inspecter les logs et exécuter des commandes dans les conteneurs (`-i`, `-t`)
- **Lister les pods** (fonctionnalité absente des commandes Docker)

```bash
$ crictl pull busybox
$ crictl images
$ crictl ps -a
```

> Les conteneurs créés manuellement avec crictl peuvent être **supprimés par le Kubelet**, car ils ne sont pas enregistrés comme faisant partie d'un Pod Kubernetes.

**Docker CLI vs crictl** : nombreuses commandes communes (`attach`, `exec`, `images`, `info`, `inspect`, `logs`, `ps`, `stats`, `version`), avec des différences dans la création et la gestion des conteneurs.

### Changements des endpoints de runtime dans Kubernetes

Ordre des endpoints par défaut du kubelet dans les versions antérieures :
```text
unix:///var/run/dockershim.sock
unix:///run/containerd/containerd.sock
unix:///run/crio/crio.sock
unix:///var/run/cri-dockerd.sock
```

Avec **Kubernetes 1.24** : le docker-socket est remplacé par **`cri-dockerd.sock`** et les endpoints par défaut sont mis à jour. Il est désormais recommandé de définir manuellement l'endpoint :
```bash
$ crictl --runtime-endpoint <endpoint>
$ export CONTAINER_RUNTIME_ENDPOINT=<endpoint>
```

### À retenir

- **CRI** = interface qui standardise les runtimes pour Kubernetes ; s'appuie sur les standards **OCI** (image + runtime).
- **Docker Shim** = solution temporaire pour brancher Docker (non-CRI) sur Kubernetes → supprimée en **1.24**.
- Les **images Docker sont OCI** → toujours compatibles avec ContainerD, même sans Docker.
- **ContainerD** = runtime CRI indépendant (CNCF), installable seul.
- Les 3 outils CLI à ne pas confondre :

| Outil | Communauté | Rôle principal |
| ----- | ---------- | -------------- |
| **ctr** | ContainerD | Débogage uniquement, fonctionnalités limitées |
| **nerdctl** | ContainerD | Gestion **courante** des conteneurs (CLI façon Docker) + fonctions avancées → **recommandé** |
| **crictl** | Kubernetes | Débogage/inspection de **tous** les runtimes compatibles CRI |

- **Piège** : un conteneur créé à la main via crictl peut être nettoyé par le Kubelet.

### Liens utiles

- Dépôt Kubernetes (voir PR 869 et issue 868) : https://github.com/kubernetes/kubernetes
