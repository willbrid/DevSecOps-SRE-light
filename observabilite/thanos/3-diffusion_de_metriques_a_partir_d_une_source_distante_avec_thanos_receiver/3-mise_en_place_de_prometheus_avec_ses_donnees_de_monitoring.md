# Mise en place de prometheus avec ses données de monitoring

Nous allons configurer un serveur Prometheus qui téléchargera ses données vers notre composant **thanos receiver**.

### Mise en place d'un service node-exporter sur le serveur srv-monitoring

Nous installons un service **node-exporter** sur le serveur **srv-monitoring** qui permettra à prometheus de superviser notre serveur **srv-monitoring**.

```
podman run -d --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  -u root \
  --name node_exporter \
  quay.io/prometheus/node-exporter:v1.7.0 \
  --path.rootfs=/host
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

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.56.161:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['192.168.56.161:9100']

remote_write:
- url: 'http://192.168.56.160:10908/api/v1/receive'
```

L'option **remote_write** permet de préciser le endpoint de réception des données de notre composant **thanos receiver**.

- Nous démarrons notre serveur prometheus

```
podman run -d --net=host \
    -v $HOME/prometheus0_CL-A.yml:/etc/prometheus/prometheus.yml:z \
    -v $HOME/prom-data:/prometheus:z \
    -u root \
    --name prometheus-0-CL-A \
    quay.io/prometheus/prometheus:v2.38.0 \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.retention.time=1d \
    --storage.tsdb.path=/prometheus \
    --storage.tsdb.max-block-duration=2h \
    --storage.tsdb.min-block-duration=2h \
    --web.listen-address=:9090 \
    --web.external-url=http://prometheus-cla.local:9090 \
    --web.enable-lifecycle \
    --web.enable-admin-api
```

Nous avons défini la rétention Prometheus à 1 jour via le paramètre **--storage.tsdb.retention.time=1d**.

Nous avons désactivé le processus de compactage local de Prometheus avec les indicateurs **storage.tsdb.max-block-duration** et **storage.tsdb.min-block-duration**. Actuellement, cela est important pour le scénario de sauvegarde de stockage d'objets de base afin d'éviter les conflits entre le bucket et les compactages locaux.

Après quelques secondes, nous pouvons remarquer, via l'interface graphique de la console du service s3, que prometheus a téléchargé ses données vers le composant **thanos receiver** qui a lui même téléchargé ces données vers le bucket **thanos** de notre service s3.

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
192.168.56.161  prometheus-cla.local
```

Nous accédons à notre interface de prometheus via le lien **http://prometheus-cla.local:9090**.

### Mise en place de prometheus en mode agent sur le serveur srv-monitoring

Si nous ne voulons pas alerter localement ou utiliser des règles d'enregistrement depuis nos emplacements périphériques, si nous ne souhaitons pas interroger les données localement et nous souhaitons les stocker pour une durée aussi courte que possible alors c'est là que le mode Agent s'avère utile ! Il s'agit d'un mode Prometheus natif intégré au binaire Prometheus. Si nous ajoutons l'indicateur **--enable-feature=agent** lors de l'exécution de Prometheus, il exécutera une base de données dédiée, spécialement rationalisée, optimisée à des fins de transfert, mais capable de conserver les données récupérées en cas de panne, de redémarrage ou de déconnexion du réseau.

- Nous stoppons et supprimons notre conteneur **prometheus-0-CL-A**, puis nous démarrons une nouvelle instance de notre serveur prometheus en mode agent

```
podman container stop prometheus-0-CL-A
podman container rm prometheus-0-CL-A
rm -R prom-data/*
```

```
podman run -d --net=host \
    -v $HOME/prometheus0_CL-A.yml:/etc/prometheus/prometheus.yml:z \
    -v $HOME/prom-data:/prometheus:z \
    -u root \
    --name prometheus-0-CL-A \
    quay.io/prometheus/prometheus:v2.38.0 \
    --enable-feature=agent \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.agent.path=/prometheus \
    --web.listen-address=:9090 \
    --web.enable-lifecycle \
    --web.external-url=http://prometheus-cla.local:9090
```

Il expose également l'interface utilisateur avec des pages relatives au scraping, à la découverte de services, à la configuration et aux informations de build. Ainsi nous accédons à notre interface de prometheus via le lien **http://prometheus-cla.local:9090**.