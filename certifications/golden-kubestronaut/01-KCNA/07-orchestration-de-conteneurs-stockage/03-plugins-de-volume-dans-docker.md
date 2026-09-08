# Plugins de volume dans docker

Le plugin de volume **par défaut** de Docker est **`local`** :
- Il crée un volume sur l'**hôte Docker** ;
- Il stocke les données sous le répertoire **`/var/lib/docker/volumes`**.

### Les autres plugins de volume (stockage tiers / cloud)

En plus du plugin `local`, de nombreux **plugins de volume** permettent de créer des volumes sur des **solutions de stockage tierces**, par exemple :
- **Azure File Storage** ;
- **Convoy** ;
- **DigitalOcean Block Storage** ;
- **Flocker** ;
- **Google Compute Persistent Disks** ;
- **Cluster FS**, **NetApp**, **Rex Ray**, **Portworx**, **VMware vSphere Storage**, etc.

### Les plugins de volume multi-fournisseurs : exemple de Rex Ray

Certains plugins de volume supportent **plusieurs fournisseurs** de stockage. Par exemple, le plugin de volume **Rex Ray** permet de provisionner du stockage sur :
- **AWS Elastic Block Store (EBS)** ;
- **Amazon S3** ;
- Baies de stockage **EMC** (Isilon, ScaleIO) ;
- **Google Persistent Disk** ;
- **OpenStack Cinder**.

### Fonctionnement

Au lancement d'un conteneur Docker, on peut spécifier un **plugin de volume particulier** (ex. **Rex Ray EBS**) pour provisionner un volume depuis un **fournisseur cloud** (ex. Amazon EBS). Résultat : un conteneur est créé avec un **volume attaché depuis le cloud AWS** → même si le conteneur s'arrête, les **données restent stockées en sécurité**.

> **Les plugins de volume** permettent de **connecter les conteneurs à diverses solutions de stockage cloud**, pour un stockage **scalable et persistant** à travers différents environnements.

### Exemple de commande (MySQL avec Rex Ray EBS)

```bash
docker run -it \
  --name mysql \
  --volume-driver rexray/ebs \
  --mount src=ebs-vol,target=/var/lib/mysql \
  mysql
```

Décomposition :
- **`--volume-driver rexray/ebs`** : spécifie le plugins de volume **Rex Ray EBS** ;
- **`--mount src=ebs-vol,target=/var/lib/mysql`** : monte le volume `ebs-vol` (provisionné sur AWS EBS) dans le conteneur ;
- Les données MySQL sont ainsi stockées sur **AWS EBS**, persistantes au-delà de la vie du conteneur.

### À retenir

- Pour persister des données → **créer un volume** ; les volumes sont gérés par les **plugins de volume** (et **non** par les pilotes de stockage).
- Plugin de volume **par défaut** = **`local`** (stockage sur l'hôte, sous `/var/lib/docker/volumes`).
- De nombreux plugins de volume permettent le stockage **cloud/tiers** : Azure File Storage, DigitalOcean, GCE Persistent Disks, NetApp, Portworx, **Rex Ray**, etc.
- Certains plugins de volume (ex. **Rex Ray**) sont **multi-fournisseurs** (AWS EBS, S3, EMC, Google Persistent Disk, OpenStack Cinder).
- On spécifie le plugin de volume au lancement via **`--volume-driver`** + **`--mount`**, permettant un stockage cloud **persistant**.

### Liens utiles

- Documentation Docker – Volume Plugins : https://docs.docker.com/engine/extend/plugins_volume/
