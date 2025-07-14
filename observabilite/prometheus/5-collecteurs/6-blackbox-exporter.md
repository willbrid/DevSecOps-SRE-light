# Mise en place du blackbox exporter dans prometheus

### Installation et configuration de blackbox exporter sur le serveur monitoring de la sandbox

- Créeons un utilisateur **blackbox_exporter** 

```
sudo useradd -M -r -s /bin/false blackbox_exporter
```

- Téléchargeons et installons le binaire **blackbox_exporter** version 0.27.0

```
curl -LO https://github.com/prometheus/blackbox_exporter/releases/download/v0.27.0/blackbox_exporter-0.27.0.linux-amd64.tar.gz
```

```
tar xvfz blackbox_exporter-0.27.0.linux-amd64.tar.gz
```

```
sudo mv blackbox_exporter-0.27.0.linux-amd64/blackbox_exporter /usr/local/bin/
```

```
sudo chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter
```

- Créeons un fichier de configuration *blackbox.yml*

```
sudo mkdir -p /etc/blackbox_exporter
```

```
sudo mv blackbox_exporter-0.27.0.linux-amd64/blackbox.yml /etc/blackbox_exporter/
```

```
sudo chown -R blackbox_exporter:blackbox_exporter /etc/blackbox_exporter
```

Le fichier de configuration par défaut du collecteur **Blackbox** contient déjà un ensemble de modules préconfigurés : **http_2xx**, **http_post_2xx**, **tcp_connect**, **pop3s_banner**, **grpc**, **grpc_plain**, **ssh_banner**, **ssh_banner_extract**, **irc_banner**, **icmp**, **icmp_ttl5**.

- Configurons un service systemd pour blackbox_exporter

```
sudo vi /etc/systemd/system/blackbox_exporter.service
```

```
[Unit]
Description=Blackbox Exporter 0.27.0
Wants=network-online.target
After=network-online.target

[Service]
User=blackbox_exporter
Group=blackbox_exporter
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/blackbox_exporter --config.file /etc/blackbox_exporter/blackbox.yml'

[Install]
WantedBy=multi-user.target
```

- Activons et démarrons le service blackbox_exporter

```
sudo systemctl daemon-reload
sudo systemctl enable blackbox_exporter
sudo systemctl start blackbox_exporter
```

- Assurons-nous que le service blackbox_exporter fonctionne

```
sudo systemctl status blackbox_exporter
```

### Configuration de Prometheus sur le serveur monitoring de la sandbox pour utiliser blackbox_exporter

Nous allons monitorer le port d'écoute **22** des services ssh des serveurs **server1** et **server2** de la sandbox

Nous éditons le fichier de configuration de prometheus :

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
scrape_configs:
  ...
  - job_name: 'blackbox_exporter_monitoring'
    metrics_path: /probe
    scrape_interval: 5s
    params:
      module: [tcp_connect]
    static_configs:
      - targets: ['192.168.56.231:22', '192.168.56.232:22']
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9115  # Ici nous avons l'adresse ip (localhost) du serveur contenant blackbox exporter et son port 9115
... 
```

```
sudo systemctl restart prometheus
```

Vérifions que Prometheus est en mesure d'atteindre blackbox_exporter et récupérer les kpi. Accédons à Prometheus dans un navigateur Web à l'adresse : **http://192.168.56.230:9090** .

Cliquons sur le menu **Graph**, entrons le mot clé **probe_success** et vérifions que les résultats affichent un statut **200**