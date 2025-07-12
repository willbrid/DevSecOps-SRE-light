# Installation de prometheus 3.4.2 sur le serveur monitoring de la sandbox

- Mise à jour des packages de notre système

```
sudo yum update -y
```

- Téléchargement et extraction de l'archive de prometheus v3.4.2

```
curl -LO https://github.com/prometheus/prometheus/releases/download/v3.4.2/prometheus-3.4.2.linux-amd64.tar.gz

tar -xvf prometheus-3.4.2.linux-amd64.tar.gz
```

- Renommage du dossier **prometheus-3.4.2.linux-amd64** en **prometheus-files**

```
mv prometheus-3.4.2.linux-amd64 prometheus-files
```

- Création d'un utilisateur Prometheus, des répertoires requis et autorisation de cet utilisateur en tant que propriétaire de ces répertoires

```
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

- Copie des binaires **prometheus** et **promtool** du dossier **prometheus-files** vers **/usr/local/bin** et modification du propriétaire pour les attribuer à l'utilisateur prometheus

```
sudo cp prometheus-files/prometheus /usr/local/bin/
sudo cp prometheus-files/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
```

- Création du fichier de configuration de prometheus et modification du propriétaire pour les attribuer à l'utilisateur prometheus

```
sudo vi /etc/prometheus/prometheus.yml
```

```
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
```

*targets* indique l'adresse et le port de prometheus.

```
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
```

- Configuration du service Prometheus

```
sudo vi /etc/systemd/system/prometheus.service
```

```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --storage.tsdb.retention.time 2d

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

- **storage.tsdb.path** indique le répertoire de stockage des données de prometheus. 
- **config.file** indique son fichier de configuration. 
- **storage.tsdb.retention.time** indique la durée maximale de sauvegarde des données.

- Vérification de l'état du service prometheus

```
sudo systemctl status prometheus
```

Pour accéder à l'interface web, nous devons d'abord autoriser le port 9090 au niveau du pare-feu

```
sudo systemctl start firewalld.service && sudo systemctl enable firewalld.service

sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --reload
```

Nous pouvons maintenant accéder à l'interface Web prometheus (http://192.168.56.230:9090) du service prometheus.