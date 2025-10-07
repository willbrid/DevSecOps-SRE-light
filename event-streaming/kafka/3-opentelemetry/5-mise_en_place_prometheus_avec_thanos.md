# Mise en place de Prometheus avec Thanos

Les configurations de ces différentes sections se feront dans notre serveur **monitoring**.

Dans cette section, nous allons déployer **Prometheus**, **Alertmanager** et **Thanos** sous forme de composants indépendants : **Thanos sidecar**, **Thanos compactor**, **Thanos Gateway** et **Thanos query** afin d’obtenir notre déploiement de test.

### Configuration des préréquis

- Création du repertoire de **Prometheus**

```
mkdir -p $HOME/prometheus/data

mkdir -p $HOME/prometheus/rules

mkdir -p $HOME/prometheus/alertmanager/data

sudo chmod 777 -R $HOME/prometheus/data

sudo chmod 777 -R $HOME/prometheus/alertmanager/data
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
Exec=--config.file=/etc/prometheus/prometheus.yml --storage.tsdb.retention.time=6h --storage.tsdb.wal-compression --storage.tsdb.path=/prometheus --storage.tsdb.max-block-duration=2h --storage.tsdb.min-block-duration=2h --web.listen-address=:9090 --web.external-url=http://prometheus.local:9090 --web.enable-lifecycle --web.enable-admin-api
Volume=/home/vagrant/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:z
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
systemctl --user start prometheus
```

Verification du statut du service prometheus

```
systemctl --user status prometheus
```