# Mise en place de Prometheus avec Thanos

Les configurations de ces différentes sections se feront dans notre serveur **monitoring**.

Dans cette section, nous allons déployer **Prometheus**, **Alertmanager** et **Thanos** sous forme de composants indépendants : **Thanos sidecar**, **Thanos compactor**, **Thanos Gateway** et **Thanos query** afin d’obtenir notre déploiement de test.

### Configuration des préréquis

- Création du repertoire de **Prometheus**

```
mkdir -p $HOME/prometheus/data

mkdir -p $HOME/prometheus/rules

mkdir -p $HOME/prometheus/alertmanager/data

mkdir -p $HOME/prometheus/thanos-compactor-data

mkdir -p $HOME/prometheus/thanos-gateway-data

sudo chmod 777 -R $HOME/prometheus/data

sudo chmod 777 -R $HOME/prometheus/alertmanager/data

sudo chmod 777 -R $HOME/prometheus/thanos-compactor-data

sudo chmod 777 -R $HOME/prometheus/thanos-gateway-data
```

- Création du fichier de configuration d'**Alertmanager**

```
vi $HOME/prometheus/alertmanager/alertmanager.yml
```

```
route:
  receiver: 'admin'
  repeat_interval: 1h

receivers:
  - name: 'admin'
    webhook_configs:
      - url: 'http://alertsender:5957/api-alert'
        send_resolved: true
        http_config: 
          basic_auth:
            username: test
            password: test@test
          tls_config:
            insecure_skip_verify: true
```

- Création du fichier de configuration de **Prometheus**

```
vi $HOME/prometheus/prometheus.yml
```

```
global:
  scrape_interval: 10s
  external_labels:
    cluster: cluster
    replica: 0
    tenant: tenant

rule_files:
  - "/etc/prometheus/rules/*"

alerting:
  alertmanagers:
    - static_configs:
      - targets: ['alertmanager:9093']

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['127.0.0.1:9090']
```

- Création du fichier de configuration de **Thanos** pour s3

```
vi $HOME/prometheus/bucket_storage.yaml
```

```
type: S3
config:
  bucket: "prometheus"
  endpoint: "minio:9000"
  insecure: true
  signature_version2: true
  access_key: "admin"
  secret_key: "verysecurepassword"
```

### Configuration du service alertmanager

```
vi $HOME/.config/containers/systemd/alertmanager.container
```

```
[Unit]
Description=alertmanager
After=local-fs.target

[Container]
ContainerName=alertmanager
Image=docker.io/prom/alertmanager:v0.28.1
Network=monitoring.network
Timezone=Europe/Paris
Exec=--config.file=/config/alertmanager.yml
Volume=/home/vagrant/prometheus/alertmanager/alertmanager.yml:/config/alertmanager.yml:z
Volume=/home/vagrant/prometheus/alertmanager/data:/data:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start alertmanager
```

Verification du statut du service alertmanager

```
systemctl --user status alertmanager
```

### Configuration du service prometheus

```
vi $HOME/.config/containers/systemd/prometheus.container
```

```
[Unit]
Description=prometheus
After=local-fs.target
After=alertmanager.container
Requires=alertmanager.container

[Container]
ContainerName=prometheus
Image=quay.io/prometheus/prometheus:v2.53.5
Network=monitoring.network
Timezone=Europe/Paris
Exec=--config.file=/etc/prometheus/prometheus.yml --storage.tsdb.retention.time=6h --storage.tsdb.wal-compression --storage.tsdb.path=/prometheus --storage.tsdb.max-block-duration=2h --storage.tsdb.min-block-duration=2h --web.listen-address=:9090 --web.external-url=http://prometheus:9090 --web.enable-lifecycle --web.enable-admin-api --web.enable-remote-write-receiver
Volume=/home/vagrant/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:z
Volume=/home/vagrant/prometheus/data:/prometheus:z
Volume=/home/vagrant/prometheus/rules:/etc/prometheus/rules:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start prometheus
```

Verification du statut du service prometheus

```
systemctl --user status prometheus
```

### Configuration du service thanos-sidecar

```
vi $HOME/.config/containers/systemd/thanos-sidecar.container
```

```
[Unit]
Description=thanos-sidecar
After=local-fs.target
After=minio.container
Requires=minio.container

[Container]
ContainerName=thanos-sidecar
Image=quay.io/thanos/thanos:v0.39.2
Network=monitoring.network
Timezone=Europe/Paris
Exec=sidecar --tsdb.path /prometheus --objstore.config-file /etc/thanos/minio-bucket.yaml --shipper.upload-compacted --http-address 0.0.0.0:19090 --grpc-address 0.0.0.0:19190 --prometheus.url http://prometheus:9090
Volume=/home/vagrant/prometheus/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z
Volume=/home/vagrant/prometheus/data:/prometheus:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start thanos-sidecar
```

Verification du statut du service thanos-sidecar

```
systemctl --user status thanos-sidecar
```

### Configuration du service thanos-compactor

```
vi $HOME/.config/containers/systemd/thanos-compactor.container
```

```
[Unit]
Description=thanos-compactor
After=local-fs.target
After=minio.container
Requires=minio.container

[Container]
ContainerName=thanos-compactor
Image=quay.io/thanos/thanos:v0.39.2
Network=monitoring.network
Timezone=Europe/Paris
Exec=compact --wait --wait-interval 30s --consistency-delay 0s --data-dir=/data --objstore.config-file /etc/thanos/minio-bucket.yaml --http-address 0.0.0.0:19095
Volume=/home/vagrant/prometheus/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z
Volume=/home/vagrant/prometheus/thanos-compactor-data:/data:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start thanos-compactor
```

Verification du statut du service thanos-compactor

```
systemctl --user status thanos-compactor
```

### Configuration du service thanos-gateway

```
vi $HOME/.config/containers/systemd/thanos-gateway.container
```

```
[Unit]
Description=thanos-gateway
After=local-fs.target
After=minio.container
Requires=minio.container

[Container]
ContainerName=thanos-gateway
Image=quay.io/thanos/thanos:v0.39.2
Network=monitoring.network
Timezone=Europe/Paris
Exec=store --data-dir=/data --objstore.config-file /etc/thanos/minio-bucket.yaml --http-address 0.0.0.0:19091 --grpc-address 0.0.0.0:19191
Volume=/home/vagrant/prometheus/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z
Volume=/home/vagrant/prometheus/thanos-gateway-data:/data:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start thanos-gateway
```

Verification du statut du service thanos-gateway

```
systemctl --user status thanos-gateway
```

### Configuration du service thanos-querier

```
vi $HOME/.config/containers/systemd/thanos-querier.container
```

```
[Unit]
Description=thanos-querier
After=local-fs.target
After=minio.container
Requires=minio.container
After=thanos-sidecar.container
Requires=thanos-sidecar.container
After=thanos-gateway.container
Requires=thanos-gateway.container

[Container]
ContainerName=thanos-querier
Image=quay.io/thanos/thanos:v0.39.2
Network=monitoring.network
Timezone=Europe/Paris
Exec=query --http-address 0.0.0.0:9091 --query.replica-label replica --endpoint thanos-sidecar:19190 --endpoint thanos-gateway:19191

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start thanos-querier
```

Verification du statut du service thanos-querier

```
systemctl --user status thanos-querier
```

### Ajout de Thanos-querier comme datasource dans Grafana

- Accéder à l’interface de Grafana

1- Connectons-nous à notre instance Grafana via le lien : **http://192.168.56.211:3000** <br>
2- Entrons nos identifiants

- Ajouter une nouvelle source de données Loki

1- Dans le menu latéral gauche, cliquons sur **“Connections”** > “**Data Sources**” <br>
2- Cliquons ensuite sur le bouton “**Add data source**” <br>
3- Recherchons “**Prometheus**” dans la liste et sélectionnons-le

- Configurer la source de données

1- Définissons le nom de la source de données : **thanos-querier** <br>
2- Définissons l'url de loki : **http://thanos-querier:9091** <br>
4- Cliquons sur le bouton “**Save & Test**” : Grafana devrait afficher un message de succès.