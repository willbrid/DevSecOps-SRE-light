# Sauvegarde continue du stockage d'objets

Prometheus, lors du scraping des données, regroupe initialement tous les échantillons en mémoire et WAL (on-disk write-head-log). Ce n'est qu'après 2-3 heures qu'il "compacte" les données sur le disque sous la forme d'un bloc TSDB de 2 heures. C'est pourquoi nous devons toujours interroger Prometheus pour obtenir les données les plus récentes, mais dans l'ensemble, grâce à ce changement, nous pouvons maintenir la rétention de Prometheus au minimum. Il est recommandé de conserver Prometheus dans ce cas pendant au moins 6 heures, afin de disposer d'un tampon sûr pour un événement potentiel de partition réseau.

### Mise en place du stockage s3 minio sur le serveur srv-storage

```
mkdir -p $HOME/minio
```

```
podman run -d --name minio \
     -v $HOME/minio:/data:z \
     -p 9000:9000 \
     -p 9090:9090 \ 
     -e "MINIO_ROOT_USER=admin" \
     -e "MINIO_ROOT_PASSWORD=verysecurepassword" \
     quay.io/minio/minio:RELEASE.2023-12-14T18-51-57Z.fips \
     server /data --console-address ":9090"
```

Nous activons le parefeu **firewalld** sur le serveur **srv-storage** puis nous autorisons les ports **9000** et **9090**

```
sudo systemctl enable firewalld --now
```

```
sudo systemctl status firewalld
```

```
sudo firewall-cmd --permanent --add-port=9000/tcp --add-port=9090/tcp
sudo firewall-cmd --reload
```

Sur notre machine hôte ubuntu20.04, nous ajoutons un mappage dns statique dans le fichier **/etc/hosts**

```
sudo vi /etc/hosts
```

```
...
192.168.56.150  s3-storage.local
```

Nous accédons à notre interface de prometheus via le lien **http://s3-storage.local:9090** et nous entrons les informations d'identification comme mentionné ci-dessous :

```
username = admin 
password = verysecurepassword
```

Nous créons un bucket nommé **thanos** en suivant les étapes ci-dessous :
- accèder au menu **Buckets**
- cliquer sur le bouton **Create Bucket**
- saisir le nom **thanos** et cliquer sur le bouton **Create Bucket**

Nous créons une clé d'accès au s3 (qui sera nécessaire pour la mise en place des composants **thanos sidecar**, **thanos gateway** et **thanos compactor**) en suivant les étapes ci-dessous :

- accéder au menu **Access Keys**
- cliquer sur le bouton **Create access key**
- cliquer sur le bouton **create**
- télécharger le fichier de clé créé

### Mise en place du composant thanos sidecar sur le serveur srv-monitoring

Tous les composants Thanos qui utilisent le stockage d'objets utilisent le même indicateur **objstore.config** indiquant le fichier de configuration du bucket.

- Nous définissons le fichier de configuration **bucket_storage.yaml**

```
vi $HOME/bucket_storage.yaml
```

```
type: S3
config:
  bucket: "thanos"
  endpoint: "192.168.56.150:9000"
  insecure: true
  signature_version2: true
  access_key: "L3sbDHFPyZCIGIYjSwPP"
  secret_key: "hwpxQ1ydql5hvCh9GsxOJfJ4VQ21H07x8cZXuls5"
```

Avec **config.endpoint** nous indiquons l'adresse et le port de notre serveur s3. Avec **access_key** et **secret_key** nous indiquons la clé d'accès précédemment créée.

- Nous installons notre composant **thanos sidecar**

```
podman run -d --net=host \
    -v $HOME/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z \
    -v $HOME/prom-data:/prometheus:z \
    --name prometheus-0-CL-A-sidecar \
    -u root \
    quay.io/thanos/thanos:v0.28.0 \
    sidecar \
    --tsdb.path /prometheus \
    --objstore.config-file /etc/thanos/minio-bucket.yaml \
    --shipper.upload-compacted \
    --http-address 0.0.0.0:19090 \
    --grpc-address 0.0.0.0:19190 \
    --prometheus.url http://192.168.56.151:9090
```

**--shipper.upload-compacted** doit être défini si nous souhaitons télécharger des blocs déjà compactés au démarrage du **thanos sidecar**. Utilisons-le uniquement lorsque nous souhaitons télécharger des blocs jamais vus auparavant sur le nouveau Prometheus introduit dans le système Thanos.

Nous pouvons vérifier si les données sont téléchargées dans le bucket **Thanos** en visitant Minio. Il faudra quelques secondes pour synchroniser tous les blocs.

Nous autorisons le port **19190** sur le firewalld de notre serveur **srv-monitoring** : ce qui permettra au composant **thanos querier** de lire de nouvelles données de monitoring 

```
sudo firewall-cmd --permanent --add-port=19190/tcp
sudo firewall-cmd --reload
```