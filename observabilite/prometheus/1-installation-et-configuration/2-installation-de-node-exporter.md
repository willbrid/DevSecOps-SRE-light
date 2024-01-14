# Installation de node-exporter sur le noeud de prometheus
-  Nous téléchargeons et faisons l'extraction de node-exporter v1.3.1
```
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz

tar -xvf node_exporter-1.3.1.linux-amd64.tar.gz
```

- Nous copieons le binaire node_exporter du dossier node_exporter-1.3.1.linux-amd64 vers /usr/local/bin
```
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
```

- Nous créeons un utilisateur node_exporter pour exécuter le service d'exportation de nœud
```
sudo useradd -rs /bin/false node_exporter
```

- Nous créeons un fichier de service node_exporter sous systemd
```
sudo vi /etc/systemd/system/node_exporter.service
```

```
[Unit]
Description=Node Exporter
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

- Nous vérifions le status du service node_exporter
```
sudo systemctl status node_exporter
```

- Nous configurons le service node_exporter en tant que cible sur le service Prometheus
```
sudo vi /etc/prometheus/prometheus.yml
```

```
global:
  scrape_interval: 10s

scrape_configs:
  ...
  - job_name: 'node_exporter_metrics'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
```

```
sudo systemctl restart prometheus
```

Maintenant, si nous vérifions la cible dans l'interface utilisateur Web prometheus (http://prometheus-ip:9090/targets), nous pourrons voir le statut du node_exporter_metrics à *UP*.