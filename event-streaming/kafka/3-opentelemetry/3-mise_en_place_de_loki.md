# Mise en place de Loki

Les configurations de ces différentes sections se feront dans notre serveur **monitoring**.

Dans cette section, nous allons déployer **Loki** sous forme de composants indépendants : **Read**, **Write**, **Gateway** et **Backend** afin d’obtenir notre déploiement de test.

**Référence :** https://github.com/grafana/loki/blob/main/examples/getting-started/docker-compose.yaml

### Configuration des préréquis

- Création du repertoire de **Loki**

```
mkdir -p $HOME/loki
```

- Définition du fichier de configuration

```
vi $HOME/loki/config.yaml
```

```
---
server:
  http_listen_address: 0.0.0.0
  http_listen_port: 3100

memberlist:
  join_members: ["loki-read", "loki-write", "loki-backend"]
  dead_node_reclaim_time: 30s
  gossip_to_dead_nodes_time: 15s
  left_ingesters_timeout: 30s
  bind_addr: ['0.0.0.0']
  bind_port: 7946
  gossip_interval: 2s

schema_config:
  configs:
    - from: 2023-01-01
      store: tsdb
      object_store: s3
      schema: v13
      index:
        prefix: index_
        period: 24h
common:
  path_prefix: /loki
  replication_factor: 1
  compactor_address: http://loki-backend:3100
  storage:
    s3:
      endpoint: http://minio:9000
      insecure: true
      bucketnames: loki-data
      access_key_id: admin
      secret_access_key: verysecurepassword
      s3forcepathstyle: true
  ring:
    kvstore:
      store: memberlist
ruler:
  storage:
    s3:
      bucketnames: loki-ruler

compactor:
  working_directory: /tmp/compactor
```

### Configuration du service loki-read

```
vi $HOME/.config/containers/systemd/loki-read.container
```

```
[Unit]
Description=loki-read
After=local-fs.target
After=minio.container
Requires=minio.container

[Container]
ContainerName=loki-read
Image=docker.io/grafana/loki:main-1474ede
Network=monitoring.network
Timezone=Europe/Paris
Exec=-config.file=/etc/loki/config.yaml -target=read
Volume=/home/vagrant/loki/config.yaml:/etc/loki/config.yaml:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start loki-read
```

Verification du statut du service loki-read

```
systemctl --user status loki-read
```

### Configuration du service loki-write

```
vi $HOME/.config/containers/systemd/loki-write.container
```

```
[Unit]
Description=loki-write
After=local-fs.target
After=minio.container
Requires=minio.container

[Container]
ContainerName=loki-write
Image=docker.io/grafana/loki:main-1474ede
Network=monitoring.network
Timezone=Europe/Paris
Exec=-config.file=/etc/loki/config.yaml -target=write
Volume=/home/vagrant/loki/config.yaml:/etc/loki/config.yaml:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start loki-write
```

Verification du statut du service loki-write

```
systemctl --user status loki-write
```

### Configuration du service loki-gateway

Il s'agit ici de configurer un conteneur **nginx**.

- Définition du fichier de configuration de notre service loki-gateway

```
vi $HOME/loki/nginx.conf
```

```
user nginx;
worker_processes 5;

events {
    worker_connections 1000;
}

http {
    resolver 10.89.0.1; # Ce paramètre pourrait être différent dans votre configuration

    server {
        listen 3100;

        location = / {
            return 200 'OK';
            auth_basic off;
        }

        location = /api/prom/push {
            proxy_pass       http://loki-write:3100$request_uri;
        }

        location = /api/prom/tail {
            proxy_pass       http://loki-read:3100$request_uri;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location ~ /api/prom/.* {
            proxy_pass       http://loki-read:3100$request_uri;
        }

        location = /loki/api/v1/push {
            proxy_pass       http://loki-write:3100$request_uri;
        }

        location = /loki/api/v1/tail {
            proxy_pass       http://loki-read:3100$request_uri;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location ~ /loki/api/.* {
            proxy_pass       http://loki-read:3100$request_uri;
        }
    }
}
```

Pour trouver la valeur d'adresse du paramètre **resolver**, il faut exécuter la commande :

```
podman network inspect monitoring | grep gateway
```

- Configuration du fichier service loki-gateway

```
vi $HOME/.config/containers/systemd/loki-gateway.container
```

```
[Unit]
Description=loki-gateway
After=local-fs.target
After=loki-read.container
After=loki-write.container
Requires=loki-read.container
Requires=loki-write.container

[Container]
ContainerName=loki-gateway
Image=docker.io/library/nginx:1.29.1
Network=monitoring.network
Timezone=Europe/Paris
Exec=nginx -g 'daemon off;'
Volume=/home/vagrant/loki/nginx.conf:/etc/nginx/nginx.conf:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start loki-gateway
```

Verification du statut du service loki-gateway

```
systemctl --user status loki-gateway
```

### Configuration du service loki-backend

```
vi $HOME/.config/containers/systemd/loki-backend.container
```

```
[Unit]
Description=loki-backend
After=local-fs.target
After=loki-gateway.container
Requires=loki-gateway.container

[Container]
ContainerName=loki-backend
Image=docker.io/grafana/loki:main-1474ede
Network=monitoring.network
Timezone=Europe/Paris
Exec=-config.file=/etc/loki/config.yaml -target=backend -legacy-read-mode=false
Volume=/home/vagrant/loki/config.yaml:/etc/loki/config.yaml:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start loki-backend
```

Verification du statut du service loki-backend

```
systemctl --user status loki-backend
```

### Ajout de Loki comme datasource dans Grafana

- Accéder à l’interface de Grafana

1- Connectons-nous à notre instance Grafana via le lien : **http://192.168.56.211:3000** <br>
2- Entrons nos identifiants

- Ajouter une nouvelle source de données Loki

1- Dans le menu latéral gauche, cliquons sur **“Connections”** > “**Data Sources**” <br>
2- Cliquons ensuite sur le bouton “**Add data source**” <br>
3- Recherchons “**Loki**” dans la liste et sélectionnons-le

- Configurer la source de données

1- Définissons le nom de la source de données : **loki** <br>
2- Définissons l'url de loki : **http://loki-gateway:3100** <br>
3- Ajoutons un header personnalisé en cliquant sur le bouton “**Add Header**” de la section **HTTP headers**, puis en définissant un header : **X-Scope-OrgID** et sa valeur **tenant** <br>
4- Cliquons sur le bouton “**Save & Test**” : Grafana devrait afficher un message de succès.