# Récupérer des métriques à partir du Bucket

Le composant **thanos Gateway** implémente l'API Store au-dessus des données historiques dans un bucket de stockage d'objets. Il agit principalement comme une passerelle API et n'a donc pas besoin de quantités importantes d'espace disque local. Il conserve une petite quantité d'informations sur tous les blocs distants sur le disque local et les synchronise avec le bucket. Ces données peuvent généralement être supprimées en toute sécurité lors des redémarrages, au prix d'un temps de démarrage plus long.

**NB: Version de thanos -> 0.36**

### Mise en place du composant thanos Gateway sur le serveur srv-storage

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

- Nous installons notre composant **thanos Gateway**

```
podman run -d --net=host \
    -v $HOME/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z \
    --name store-gateway \
    quay.io/thanos/thanos:v0.36.0 \
    store \
    --objstore.config-file /etc/thanos/minio-bucket.yaml \
    --http-address 0.0.0.0:19091 \
    --grpc-address 0.0.0.0:19191
```

Nous autorisons le port **19191** sur le firewalld de notre serveur **srv-storage** : ce qui permettra au composant **thanos querier** de lire d'anciennes données de monitoring 

```
sudo firewall-cmd --permanent --add-port=19191/tcp
sudo firewall-cmd --reload
```

### Mise en place du composant thanos Compactor sur le serveur srv-storage

**Thanos Compactor** est obligatoire si nous utilisons le stockage d'objets, sinon **Thanos Gateway** sera trop lent sans utiliser de compacteur.

```
podman run -d --net=host \
    -v $HOME/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z \
    --name thanos-compact \
    quay.io/thanos/thanos:v0.36.0 \
    compact \
    --wait --wait-interval 30s \
    --consistency-delay 0s \
    --objstore.config-file /etc/thanos/minio-bucket.yaml \
    --http-address 0.0.0.0:19095
```

L'indicateur **--wait** est utilisé pour s'assurer que tous les compactages ont été traités tandis que **--wait-interval** est maintenu dans 30 secondes pour effectuer tous les compactages et sous-échantillonnages très rapidement. De plus, cela ne fonctionne que lorsque l'indicateur **--wait** est spécifié. Un autre indicateur **--consistency-delay** est essentiellement utilisé pour les buckets qui ne sont pas fortement cohérents. C'est l'âge minimum des blocs non compactés avant leur traitement. Ici, nous avons maintenu le délai à **0 s** en supposant que le bucket est cohérent.

Pour vérifier si le compacteur fonctionne correctement, nous pouvons consulter la vue de notre bucket **thanos**.

### Mise en place du composant thanos querier sur le serveur srv-zoneAdmin

```
podman run -d --net=host \
   --name querier \
   quay.io/thanos/thanos:v0.36.0 \
   query \
   --http-address 0.0.0.0:9091 \
   --query.replica-label replica \
   --store 192.168.56.151:19190 \
   --store 192.168.56.150:19191
```

Nous avons ajouté les interfaces storeApi du composant **thanos gateway** (**192.168.56.150:19191**) et du composant **thanos sidecar** (**192.168.56.151:19190**).

Nous démarrons le parefeu **firewalld** et autorisons le port **9091** sur le serveur **srv-zoneAdmin**

```
sudo systemctl enable firewalld --now
sudo systemctl status firewalld
```

```
sudo firewall-cmd --permanent --add-port=9091/tcp
sudo firewall-cmd --reload
```

Au niveau de notre machine hôte ubuntu20.04, nous ajoutons un mappage dns statique dans le fichier **/etc/hosts**

```
sudo vi /etc/hosts
```

```
...
192.168.56.152  thanos-querier-s3.local
```

Nous accédons à ce lien **http://thanos-querier-s3.local:9091** via notre navigateur de la machine hôte, puis nous saisissons une requête promQL des données datant d'un an

```
continuous_app_metric0
```