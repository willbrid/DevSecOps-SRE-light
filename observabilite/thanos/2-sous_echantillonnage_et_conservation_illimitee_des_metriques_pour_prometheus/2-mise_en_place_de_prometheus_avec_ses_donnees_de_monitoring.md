# Mise en place de prometheus avec ses données de monitoring

Nous simulerons l'état d'un serveur Prometheus ayant déjà un an de prometheus !. Nous l'utiliserons pour sauvegarder de manière transparente toutes les anciennes données du stockage objet et configurer Prometheus pour le mode de sauvegarde continue, ce qui nous permettra d'obtenir une rétention illimitée pour Prometheus.

### Génération des métriques artificielles pendant 1 an sur le serveur srv-monitoring

Nous générons les métriques artificielles sur 1 an en saisissant la commande ci-dessous

```
mkdir -p $HOME/prom-data
```

```
podman run -i quay.io/thanos/thanosbench:v0.2.0-rc.1 block plan -p continuous-365d-tiny --labels 'cluster="CL-A"' --max-time=6h | podman run -v $HOME/prom-data:/prom-data:z -i quay.io/thanos/thanosbench:v0.2.0-rc.1 block gen --output.dir prom-data
```

**prom-data** représente le répertoire des données prometheus.

Pour vérifier les données générées, nous exécutons 

```
ls -lR $HOME/prom-data
```

### Mise en place de prometheus sur le serveur srv-monitoring

- Nous préparons le fichier de configuration de prometheus

```
vi $HOME/prometheus0_CL-A.yml
```

```
global:
  scrape_interval: 5s
  external_labels:
    cluster: CL-A
    replica: 0
    tenant: team-CL-A

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.56.151:9090']
```

- Nous démarrons notre serveur prometheus avec ses données prégénérées dans le repertoire **$HOME/prom-data**

```
podman run -d --net=host \
    -v $HOME/prometheus0_CL-A.yml:/etc/prometheus/prometheus.yml:z \
    -v $HOME/prom-data:/prometheus:z \
    -u root \
    --name prometheus-0-CL-A \
    quay.io/prometheus/prometheus:v2.53.2 \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.retention.time=1000d \
    --storage.tsdb.wal-compression \
    --storage.tsdb.path=/prometheus \
    --storage.tsdb.max-block-duration=2h \
    --storage.tsdb.min-block-duration=2h \
    --web.listen-address=:9090 \
    --web.external-url=http://prometheus-cla.local:9090 \
    --web.enable-lifecycle \
    --web.enable-admin-api
```

Nous avons étendu la rétention Prometheus **--storage.tsdb.retention.time=1000d** . En effet, Prometheus supprime par défaut toutes les données datant de plus de 2 semaines et actuellement nous avons les données prégénérées d'un an.

Nous avons désactivé le processus de compactage local de Prometheus avec les indicateurs **storage.tsdb.max-block-duration** et **storage.tsdb.min-block-duration**. Actuellement, cela est important pour le scénario de sauvegarde de stockage d'objets de base afin d'éviter les conflits entre le bucket et les compactages locaux.

Nous activons le parefeu **firewalld** sur le serveur **srv-monitoring** puis nous autorisons le port **9090**

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

Sur notre machine hôte ubuntu20.04, nous ajoutons un mappage dns statique dans le fichier **/etc/hosts**

```
sudo vi /etc/hosts
```

```
...
192.168.56.151  prometheus-cla.local
```

Nous accédons à notre interface de prometheus via le lien **http://prometheus-cla.local:9090**.