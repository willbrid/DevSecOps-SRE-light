# Stockage dans Docker

Ce contenu explore le **stockage des conteneurs** et la **gestion du système de fichiers** dans Docker : les **pilotes de stockage**, l'**architecture en couches** et les différences entre données **persistantes** et **éphémères**.

### La structure de répertoires de Docker

À l'installation, Docker crée une arborescence sous **`/var/lib/docker`** avec des sous-répertoires :
- **`overlay2`** ;
- **`containers`** : fichiers liés aux conteneurs ;
- **`image`** : données des images ;
- **`volumes`** : données persistantes des conteneurs.

### Docker's Layered Architecture (Architecture en couches)

Docker construit les images selon une **structure en couches** : **chaque instruction** d'un Dockerfile crée une **nouvelle couche** contenant **uniquement les changements** par rapport à la précédente.

Exemple de Dockerfile :
```dockerfile
FROM ubuntu
RUN apt-get update && apt-get -y install python
RUN pip install flask flask-mysql
COPY . /opt/source-code
ENTRYPOINT ["flask", "run"]
```

```bash
docker build -t willbrid/my-custom-app .
```

Les couches créées :
- **Base Layer** : l'image officielle Ubuntu ;
- **Packages Layer** : paquets APT installés ;
- **Dependencies Layer** : bibliothèques Python via pip (Flask, flask-mysql) ;
- **Application Code Layer** : le code source copié dans l'image ;
- **Entry Point Layer** : la commande de démarrage.

> Comme les couches ne stockent que les **changements**, la taille de l'image dépend de ces modifications incrémentales (ex. Ubuntu ≈ 120 Mo, tandis que les couches de code restent petites).

#### Réutilisation des couches (Reusing Layers)

Deux applications partageant la plupart des couches du Dockerfile **réutilisent** les couches communes.

**Dockerfile 2** (2ᵉ app, seul le code diffère) :
```dockerfile
FROM ubuntu
RUN apt-get update && apt-get -y install python
RUN pip install flask flask-mysql
COPY app2.py /opt/source-code
ENTRYPOINT ["flask", "run"]
```

```bash
docker build -t willbrid/my-custom-app-2 -f Dockerfile2 .
```

Les **3 premières couches étant identiques**, Docker **réutilise le cache** et ne reconstruit que les couches différentes (le code + l'entry point) → **builds plus rapides** et **économie de disque**.

> Si l'on modifie **seulement le code** (ex. `app.py`), Docker utilise le cache pour les couches inchangées et ne reconstruit que la couche de code mise à jour.

#### Couches d'image et de conteneur (Image and Container Layers)

Une image Docker est composée de **couches immuables (read-only)**, empilées ainsi :
1. **Base Layer** (Ubuntu) ;
2. **Packages Layer** (paquets APT) ;
3. **Dependencies Layer** (paquets pip) ;
4. **Application Code Layer** (code source) ;
5. **Entry Point Layer** (commande de démarrage).

**Point essentiel** : au lancement d'un conteneur, Docker ajoute une **couche inscriptible (writable layer)** au-dessus des couches **read-only**. Cette couche capture les changements runtime (logs, données temporaires, modifications). Ex. : créer un fichier `temp.txt` dans un conteneur → stocké dans cette couche writable.

**Copy-on-Write (point crucial)** : le mécanisme « copy-on-write » fait que toute modification d'un fichier **provenant de l'image** est d'abord **copiée dans la couche writable** avant d'être modifiée — l'image originale reste intacte.

### Persisting Data with Volumes and Bind Mounts (Persistance des données)

La couche writable étant **temporaire**, persister les données importantes (surtout pour les applications **stateful** comme les bases de données) est **critique**. Docker offre **deux méthodes** : les **volumes** et les **bind mounts**.

#### Volumes (gérés par Docker)

Créer un volume :
```bash
docker volume create data_volume
```

→ crée un répertoire sous `/var/lib/docker/volumes/data_volume`.

Monter le volume dans un conteneur (ex. persistance MySQL) :

```bash
docker run -v data_volume:/var/lib/mysql mysql
```

> Docker **crée automatiquement** le volume s'il n'existe pas :

```bash
docker run -v data_volume2:/var/lib/mysql mysql
```

#### Bind Mounts (répertoire existant de l'hôte)

Utilise un répertoire **existant** du système hôte (ex. `/data/mysql`) :

```bash
docker run -v /data/mysql:/var/lib/mysql mysql
```

#### L'option --mount (syntaxe explicite)

Syntaxe plus verbeuse mais équivalente. Exemple pour un bind mount :
```bash
docker run \
  --mount type=bind,source=/data/mysql,target=/var/lib/mysql \
  mysql
```

Les deux (`-v` et `--mount`) permettent de mapper un répertoire hôte au conteneur, assurant la **persistance des données au-delà de la vie du conteneur**.

#### Volume vs Bind Mount (distinction clé)

| Méthode | Emplacement | Géré par |
|---------|-------------|----------|
| **Volume** | `/var/lib/docker/volumes/...` | **Docker** |
| **Bind Mount** | N'importe quel répertoire de l'**hôte** | L'**utilisateur** |

### Pilotes de stockage (Docker Storage Drivers)

Les **pilotes de stockage** sont essentiels pour implémenter le **système de fichiers en couches** et gérer la **couche writable**. Ils gèrent la **création des couches** et le mécanisme **copy-on-write**.

Pilotes courants :
- **AUFS**
- **ZFS**
- **Btrfs**
- **Device Mapper**
- **Overlay** et **Overlay2**

**Choix du driver** : dépend du **système d'exploitation**. Ex. : Ubuntu utilise généralement **AUFS**, Fedora/CentOS peuvent utiliser **Device Mapper**. Docker **choisit automatiquement** le driver optimal selon le système, chacun ayant ses caractéristiques de **performance et stabilité**.

### À retenir

- Docker stocke ses données sous **`/var/lib/docker`** (`overlay2`, `containers`, `images`, `volumes`).
- **Architecture en couches** : chaque instruction du Dockerfile = une couche de **changements** ; les couches communes sont **réutilisées via le cache** (builds rapides).
- Les couches d'**image sont read-only** ; au runtime, Docker ajoute une **couche writable** avec le mécanisme **copy-on-write** (l'image reste intacte).
- La couche writable étant **temporaire**, on persiste via **volumes** (gérés par Docker, `/var/lib/docker/volumes`) ou **bind mounts** (répertoire hôte existant), avec `-v` ou `--mount`.
- Les **storage drivers** (AUFS, ZFS, Btrfs, Device Mapper, Overlay/Overlay2) implémentent les couches et le copy-on-write ; le choix dépend de l'OS.

### Liens utiles

- Documentation Docker – Storage Drivers : https://docs.docker.com/storage/storagedriver/
- Documentation Docker : https://docs.docker.com/
- Vue d'ensemble du stockage Docker : https://docs.docker.com/storage/
- Bonnes pratiques des applications conteneurisées : https://www.docker.com/resources/what-container
