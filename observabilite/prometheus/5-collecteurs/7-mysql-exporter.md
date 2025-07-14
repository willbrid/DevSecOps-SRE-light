# Mise en place du mysql exporter dans prometheus

### Installation de nos bases de données sur le serveur server1 de la sandbox

Nous utiliserons une image docker **mariadb:10.5.17** de mariadb pour monter une base de données.

- Installons notre gestionnaire de conteneur **podman** via le package **container-tools**

```
sudo dnf install container-tools
```

- Démarrons notre conteneur nommé **srv-db**

```
podman run -d --name srv-db --network=host --env MARIADB_ROOT_PASSWORD=cool1234567db docker.io/library/mariadb:10.5.17
```

- Connectons-nous à Mariadb en root, créons l'utilisateur de monitoring **mysqlexporter** avec son mot de passe : **cool1234567db**, et configurons ses droits requis

```
podman container exec -it srv-db /bin/bash

mysql -h 127.0.0.1 -u root -p
```

```
CREATE USER 'mysqlexporter'@'192.168.56.231' IDENTIFIED BY 'cool1234567db' WITH MAX_USER_CONNECTIONS 3;

GRANT PROCESS, REPLICATION CLIENT, REPLICATION SLAVE, SLAVE MONITOR, SELECT ON *.* TO 'mysqlexporter'@'192.168.56.231';
```

### Installation et configuration de mysql exporter sur le serveur server1 de la sandbox

- Créeons un utilisateur **mysqld_exporter** 

```
sudo useradd -M -r -s /bin/false mysqld_exporter
```

- Téléchargeons et installons le binaire **mysqld_exporter** version 0.17.2

```
curl -LO https://github.com/prometheus/mysqld_exporter/releases/download/v0.17.2/mysqld_exporter-0.17.2.linux-amd64.tar.gz
```


```
tar xvfz mysqld_exporter-0.17.2.linux-amd64.tar.gz
```

```
sudo mv mysqld_exporter-0.17.2.linux-amd64/mysqld_exporter /usr/local/bin/
```

```
sudo chown mysqld_exporter:mysqld_exporter /usr/local/bin/mysqld_exporter
```

- Créons un fichier de configuration *config.cnf*

```
sudo mkdir -p /etc/mysqld_exporter
```

```
sudo vi /etc/mysqld_exporter/config.cnf
```

```
[client]
user = mysqlexporter
password = cool1234567db
host = 192.168.56.231
port = 3306
[client.srvdb]
user = mysqlexporter
password = cool1234567db
host = 192.168.56.231
port = 3306
```

```
sudo chown -R mysqld_exporter:mysqld_exporter /etc/mysqld_exporter
```

Dans cette exemple, nous configurons les paramètres d'accès à la base de données sur **Mariadb-10.5** du conteneur **srv-db** dans le fichier de configuration **config.cnf**. Les paramètres sous la section **client** sont les paramètres par défaut dont nous n'utiliserons pas.

- Configurons un service systemd pour mysqld_exporter

```
sudo vi /etc/systemd/system/mysqld_exporter.service
```

```
[Unit]
Description=Mysqld Exporter 0.17.2
Wants=network-online.target
After=network-online.target

[Service]
User=mysqld_exporter
Group=mysqld_exporter
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/mysqld_exporter --config.my-cnf=/etc/mysqld_exporter/config.cnf --collect.auto_increment.columns'

[Install]
WantedBy=multi-user.target
```

- Activons et démarrons le service mysqld_exporter

```
sudo systemctl daemon-reload
sudo systemctl enable mysqld_exporter
sudo systemctl start mysqld_exporter
```

- Assurons-nous que le service mysqld_exporter fonctionne

```
sudo systemctl status mysqld_exporter
```

Pour permettre à prometheus de récupérer les métriques de l'instant Mariadb **srv-db**, nous devons d'abord autoriser le port 9104 au niveau du pare-feu

```
sudo firewall-cmd --permanent --add-port=9104/tcp
sudo firewall-cmd --reload
```

### Configuration de Prometheus sur le serveur monitoring de la sandbox pour utiliser mysqld_exporter

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
scrape_configs:
  ...
  - job_name: mysql_exporter_server1
    metrics_path: /probe
    scrape_interval: 5s
    params:
      auth_module: [client.srvdb]
    static_configs:
      - targets:
        - 192.168.56.231:3306
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 192.168.56.231:9104
...
```

```
sudo systemctl restart prometheus
```

Le paramètre **replacement** permet de préciser l'adresse IP du serveur hébergeant le service **mysqld_exporter** : dans notre cas le même serveur **server1**.

Vérifions que Prometheus est en mesure d'atteindre mysqld_exporter et récupérer les kpi. Accédons à Prometheus dans un navigateur Web à l'adresse : **http://192.168.56.230:9090** .

Cliquons sur le menu **Graph**, entrons le mot clé **mysql_global_status_connections** .