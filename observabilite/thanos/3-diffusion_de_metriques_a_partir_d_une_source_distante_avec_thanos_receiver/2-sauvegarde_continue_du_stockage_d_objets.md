# Sauvegarde continue du stockage d'objets

Sur le serveur **srv-storage**, nous allons installer notre service **s3 minio** avec notre composant **thanos receiver**. 

**NB: Version de thanos -> 0.36**

### Mise en place du stockage s3 (version 2024-08-03T04-33-23Z.fips) minio sur le serveur srv-storage

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
     quay.io/minio/minio:RELEASE.2024-08-03T04-33-23Z.fips \
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
192.168.56.160  s3-storage.local
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

Nous créons une clé d'accès au s3 (qui sera nécessaire pour la mise en place des composants **thanos receiver**, **thanos gateway** et **thanos compactor**) en suivant les étapes ci-dessous :

- accéder au menu **Access Keys**
- cliquer sur le bouton **Create access key**
- cliquer sur le bouton **create**
- télécharger le fichier de clé créé

### Mise en place du composant thanos receiver sur le serveur srv-storage

Tous les composants Thanos qui utilisent le stockage d'objets utilisent le même indicateur **objstore.config** indiquant le fichier de configuration du bucket.

- Nous définissons le fichier de configuration **bucket_storage.yaml**

```
vi $HOME/bucket_storage.yaml
```

```
type: S3
config:
  bucket: "thanos"
  endpoint: "192.168.56.160:9000"
  insecure: true
  signature_version2: true
  access_key: "povVmT6mdlD9X0a6Nz0l"
  secret_key: "sm7sZGmWWDgLSpB32uWwIHpTTvam1fAPbr4g02PN"
```

Avec **config.endpoint**, nous indiquons l'adresse et le port de notre serveur s3. Avec **access_key** et **secret_key** nous indiquons la clé d'accès précédemment créée.

- Nous installons notre composant **thanos receiver**

```
mkdir $HOME/receive-data
```

```
podman run -d --net=host \
    -v $HOME/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z \
    -v $HOME/receive-data:/receive-data:z \
    --name receiver \
    -u root \
    quay.io/thanos/thanos:v0.36.0 \
    receive \
    --tsdb.path "/receive-data" \
    --grpc-address 192.168.56.160:10907 \
    --http-address 192.168.56.160:10909 \
    --objstore.config-file /etc/thanos/minio-bucket.yaml \
    --label "receive_replica=\"0\"" \
    --label "receive_cluster=\"CL-A\"" \
    --tsdb.retention=0d \
    --remote-write.address 192.168.56.160:10908
```

Nous utilisons l'indicateur **--tsdb.retention=0d** afin de définir aucune rétention de données locales : le composant **thanos receiver** va immédiatement télécharger les données locales dans le bucket **thanos** du service s3.

Cela démarre **thanos Receiver** qui écoute sur le endpoint **http://192.168.56.160:10908/api/v1/receive** pour l'écriture à distance et sur **192.168.56.160:10907** pour **thanos StoreAPI**.

Quelques paramètres importants :

- **--label** : **thanos receiver** nécessite qu'au moins une étiquette soit définie. Celles-ci sont appelées « étiquettes externes » et sont utilisées pour identifier de manière unique cette instance de **thanos Receiver**.
- **--remote-write.address** : il s'agit de l'adresse sur laquelle **thanos receiver** écoute les demandes d'écriture à distance de Prometheus.

Nous autorisons les ports **10907** et **10908** sur le firewalld de notre serveur **srv-storage** : ce qui permettra au composant **thanos querier** de lire de nouvelles données de monitoring (**port 10907**) et à prometheus de télécharger les données (**port 10908**).

```
sudo firewall-cmd --permanent --add-port=10907/tcp --add-port=10908/tcp
sudo firewall-cmd --reload
```