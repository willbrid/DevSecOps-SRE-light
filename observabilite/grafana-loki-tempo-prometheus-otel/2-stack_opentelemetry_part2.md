# Mise en place de MinIO s3 et Redis sur le serveur server-storage

### Mise en place de MinIO s3

- Installation

```
mkdir -p $HOME/minio-data
```

```
podman run -d --name minio \
     -v $HOME/minio-data:/data:z \
     -p 9000:9000 \
     -p 9090:9090 \ 
     -e "MINIO_ROOT_USER=admin" \
     -e "MINIO_ROOT_PASSWORD=verysecurepassword" \
     quay.io/minio/minio:RELEASE.2024-08-03T04-33-23Z.fips \
     server /data --console-address ":9090"
```

- Autorisation des ports **9000** et **9090** de **MinIO** sur le firewall

```
sudo firewall-cmd --permanent --add-port={9000/tcp,9090/tcp}

sudo firewall-cmd --reload
```

Pour vérifier, nous saisissons pour chaque port, les commandes 

```
sudo firewall-cmd --list-all | grep 9000

sudo firewall-cmd --list-all | grep 9090
```

- Accès à l'interface web et création de 3 buckets : **bucket-traces**, **bucket-logs**, **bucket-metrics**

Nous accédons à l'interface web via l'adresse : **http://192.168.56.20:9090/**, puis nous saisissons les crédentials :

```
Username : admin
Password : verysecurepassword
```

Pour chaque bucket, nous cliquons sur le bouton **Create Bucket**, puis nous saisissons le nom du bucket.

Nous créons une clé d'accès à nos buckets MinIO S3 (qui permettra de lire et d'écrire les données dans tous les buckets) en suivant les étapes ci-dessous :

- accéder au menu **Access Keys**
- cliquer sur le bouton **Create access key**
- cliquer sur le bouton **create**
- télécharger le fichier de clé créé

Dans notre exemple, nous avons généré :

```
ACCESS KEY : 1MpVon6pfJgf9JiFQYfK
SECRET KEY : 4j3jdcAeCf4jqgPxBxJ6ZuPVzcRtgjaoefCQICES
```

### Mise en place de Redis

- Installation

```
mkdir redis-data
```

```
podman run -d --name redis-cache \
       -v $HOME/redis-data:/data:z \
       -p 6379:6379 \
       -e REDIS_ARGS="--appendonly yes" \
       docker.io/redis/redis-stack-server:7.2.0-v6
```

- Autorisation du port **6379** de **Redis** sur le firewall

```
sudo firewall-cmd --permanent --add-port=6379/tcp

sudo firewall-cmd --reload
```

Pour vérifier, nous saisissons la commande 

```
sudo firewall-cmd --list-all | grep 6379
```