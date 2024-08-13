# Mise en place des 3 serveurs prometheus

Nous allons mettre en place 3 serveurs prometheus. Nous avons un serveur Prometheus dans un cluster **A**. Nous avons 2 répliques de serveurs Prometheus dans un cluster **B** qui récupère les mêmes cibles.

**NB: Version de prometheus -> LTS 2.53**

### Création des fichiers de configuration de nos 3 serveurs

Sur le serveur **srv-clusterA**, nous définissons le fichier **prometheus0_A.yml** de la manière suivante

```
vi $HOME/prometheus0_A.yml
```

```
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: A
    replica: 0

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.56.140:9090']
```

Sur le serveur **srv-clusterA**, nous définissons les fichiers **prometheus0_B.yml** et **prometheus1_B.yml** de la manière suivante

```
vi $HOME/prometheus0_B.yml
```

```
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: B
    replica: 0

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.56.141:9091','192.168.56.141:9092']
```

```
vi $HOME/prometheus1_B.yml
```

```
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: B
    replica: 1

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.56.141:9091','192.168.56.141:9092']
```

Chaque instance Prometheus doit avoir un ensemble unique d’étiquettes d’identification. Ces étiquettes sont importantes car elles représentent certains « flux » de données (par exemple sous la forme de blocs TSDB). Au sein de ces étiquettes externes exactes, les compactages et le sous-échantillonnage sont effectués, **Thanos querier** filtre ses API de magasin, des options de partitionnement supplémentaires, la déduplication et des capacités potentielles de multi-location sont disponibles. Ceux-ci ne sont pas faciles à modifier rétroactivement, il est donc important de fournir un ensemble compatible d'étiquettes externes afin que **Thanos** puisse agréger les données sur toutes les instances disponibles.

### Démarrage de nos 3 serveurs prometheus

- Nous allons créer les 3 répertoires de données de nos instances prometheus.

Sur le serveur **srv-clusterA**

```
mkdir -p $HOME/prometheus0_A_data
```

Sur le serveur **srv-clusterB**

```
mkdir -p $HOME/prometheus0_B_data $HOME/prometheus1_B_data
```

- Nous démarrons nos 3 serveurs prometheus avec **podman**

Nous passons à nos 3 serveurs prometheus les options :

--- **--web.enable-admin-api** qui permet à **Thanos Sidecar** d'obtenir des métadonnées de Prometheus comme des étiquettes externes. <br>
--- **--web.enable-lifecycle** qui permet à **Thanos Sidecar** de recharger les fichiers de configuration et de règles de Prometheus s'ils sont utilisés.

Sur le serveur **srv-clusterA**

```
podman run -d --net=host \
    -v $HOME/prometheus0_A.yml:/etc/prometheus/prometheus.yml:z \
    -v $HOME/prometheus0_A_data:/prometheus:z \
    -u root \
    --name prometheus-0-A \
    quay.io/prometheus/prometheus:v2.53.2 \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus \
    --storage.tsdb.wal-compression \
    --storage.tsdb.retention.time=12h \
    --storage.tsdb.max-block-duration=2h \
    --storage.tsdb.min-block-duration=2h \
    --web.listen-address=:9090 \
    --web.external-url=http://prometheusA.local:9090 \
    --web.enable-lifecycle \
    --web.enable-admin-api && echo "Prometheus 0 A started!"
```

Nous activons le parefeu **firewalld** sur le serveur **srv-clusterA** puis nous autorisons le port **9090**

```
sudo systemctl enable firewalld --now
```

```
sudo systemctl status firewalld
```

```
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --reload
```

Sur le serveur **srv-clusterB**

```
podman run -d --net=host \
    -v $HOME/prometheus0_B.yml:/etc/prometheus/prometheus.yml:z \
    -v $HOME/prometheus0_B_data:/prometheus:z \
    -u root \
    --name prometheus-0-B \
    quay.io/prometheus/prometheus:v2.53.2 \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus \
    --storage.tsdb.wal-compression \
    --storage.tsdb.retention.time=12h \
    --storage.tsdb.max-block-duration=2h \
    --storage.tsdb.min-block-duration=2h \
    --web.listen-address=:9091 \
    --web.external-url=http://prometheusB.local:9091 \
    --web.enable-lifecycle \
    --web.enable-admin-api && echo "Prometheus 0 B started!"
```

```
podman run -d --net=host \
    -v $HOME/prometheus1_B.yml:/etc/prometheus/prometheus.yml:z \
    -v $HOME/prometheus1_B_data:/prometheus:z \
    -u root \
    --name prometheus-1-B \
    quay.io/prometheus/prometheus:v2.53.2 \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus \
    --storage.tsdb.wal-compression \
    --storage.tsdb.retention.time=12h \
    --storage.tsdb.max-block-duration=2h \
    --storage.tsdb.min-block-duration=2h \
    --web.listen-address=:9092 \
    --web.external-url=http://prometheusB.local:9092 \
    --web.enable-lifecycle \
    --web.enable-admin-api && echo "Prometheus 1 B started!"
```

Nous activons le parefeu **firewalld** sur le serveur **srv-clusterB** puis nous autorisons les ports **9091** et **9092**

```
sudo systemctl enable firewalld --now
```

```
sudo systemctl status firewalld
```

```
sudo firewall-cmd --permanent --add-port=9091/tcp --add-port=9092/tcp
sudo firewall-cmd --reload
```

- Puis au niveau de notre machine hôte ubuntu20.04, nous ajoutons un mappage dns statique dans le fichier **/etc/hosts**

```
sudo vi /etc/hosts
```

```
...
192.168.56.140  prometheusA.local
192.168.56.141  prometheusB.local
```

Puis nous pouvons tester via notre navigateur de notre machine hôte les liens suivants 

```
http://prometheusA.local:9090/
http://prometheusB.local:9091/
http://prometheusB.local:9092/
```