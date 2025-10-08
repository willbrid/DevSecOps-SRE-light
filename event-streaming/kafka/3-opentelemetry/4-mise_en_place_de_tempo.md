# Mise en place de Tempo

Les configurations de ces différentes sections se feront dans notre serveur **monitoring**.

Dans cette section, nous allons déployer **Tempo** en un seul conteneur.

**Référence :** https://github.com/grafana/tempo/blob/main/example/docker-compose/alloy/docker-compose.yaml

### Configuration des préréquis

- Création du repertoire de **Tempo**

```
mkdir -p $HOME/tempo/data

sudo chmod 777 -R $HOME/tempo/data
```

- Définition du fichier de configuration

```
vi $HOME/tempo/tempo.yaml
```

```
stream_over_http_enabled: true
server:
  http_listen_port: 3200
  log_level: info

query_frontend:
  search:
    duration_slo: 5s
    throughput_bytes_slo: 1.073741824e+09
    metadata_slo:
      duration_slo: 5s
      throughput_bytes_slo: 1.073741824e+09
  trace_by_id:
    duration_slo: 5s

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: "tempo:4317"
        http:
          endpoint: "tempo:4318"

ingester:
  max_block_duration: 5m

compactor:
  compaction:
    block_retention: 1h

storage:
  trace:
    backend: s3
    s3:
      bucket: tempo
      endpoint: minio:9000
      access_key: admin
      secret_key: verysecurepassword
      insecure: true
    wal:
      path: /var/tempo/wal
    local:
      path: /var/tempo/blocks
```

### Configuration du service tempo

```
vi $HOME/.config/containers/systemd/tempo.container
```

```
[Unit]
Description=tempo
After=local-fs.target
After=minio.container
Requires=minio.container

[Container]
ContainerName=tempo
Image=docker.io/grafana/tempo:main-7c925e6
Network=monitoring.network
Timezone=Europe/Paris
Exec=-config.file=/etc/tempo.yaml
Volume=/home/vagrant/tempo/tempo.yaml:/etc/tempo.yaml:z
Volume=/home/vagrant/tempo/data:/var/tempo:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start tempo
```

Verification du statut du service tempo

```
systemctl --user status tempo
```

### Ajout de Tempo comme datasource dans Grafana

- Accéder à l’interface de Grafana

1- Connectons-nous à notre instance Grafana via le lien : **http://192.168.56.211:3000** <br>
2- Entrons nos identifiants

- Ajouter une nouvelle source de données Loki

1- Dans le menu latéral gauche, cliquons sur **“Connections”** > “**Data Sources**” <br>
2- Cliquons ensuite sur le bouton “**Add data source**” <br>
3- Recherchons “**Tempo**” dans la liste et sélectionnons-le

- Configurer la source de données

1- Définissons le nom de la source de données : **tempo** <br>
2- Définissons l'url de loki : **http://tempo:3200** <br>
4- Cliquons sur le bouton “**Save & Test**” : Grafana devrait afficher un message de succès.