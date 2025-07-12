# Installation de node-exporter sur le serveur monitoring de la sandbox

-  Téléchargement et extraction de l'archive de node-exporter v1.9.1

```
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz

tar -xvf node_exporter-1.9.1.linux-amd64.tar.gz
```

- Copie du binaire node_exporter du dossier node_exporter-1.9.1.linux-amd64 vers /usr/local/bin

```
sudo mv node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/
```

- Création d'un utilisateur **node_exporter** pour exécuter le service d'exporteur de nœud

```
sudo useradd -rs /bin/false node_exporter
```

- Création du fichier service node_exporter

```
sudo vi /etc/systemd/system/node_exporter.service
```

```
[Unit]
Description=Node Exporter v1.9.1
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/node_exporter'

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

- Vérification du status du service node_exporter

```
sudo systemctl status node_exporter
```

- Configuration du job associé au service node_exporter

```
sudo vi /etc/prometheus/prometheus.yml
```

```
global:
  scrape_interval: 10s

scrape_configs:
  ...
  - job_name: 'node_exporter_monitoring'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
```

```
sudo systemctl restart prometheus
```

Maintenant, si nous vérifions la cible dans l'interface utilisateur Web prometheus (http://prometheus-ip:9090/targets), nous pourrons voir le statut du node_exporter_monitoring à **UP**.