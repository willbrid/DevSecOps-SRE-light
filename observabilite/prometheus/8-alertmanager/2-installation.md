# Installation d'Alertmanager

### Installation et configuration d'Alertmanager sur le serveur monitoring de la sandbox

Nous installerons *Alertmanager v0.28.1* en procédant comme suit.

- Créons un utilisateur **alertmanager**

```
sudo useradd -M -r -s /bin/false alertmanager
```

- Téléchargeons et installons les binaires **alertmanager** et son fichier de configuration

```
curl -LO https://github.com/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz
```

```
tar xvfz alertmanager-0.28.1.linux-amd64.tar.gz
```

```
sudo mv alertmanager-0.28.1.linux-amd64/{alertmanager,amtool} /usr/local/bin/
```

```
sudo chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}
```

```
sudo mkdir -p /etc/alertmanager
```

```
sudo mv alertmanager-0.28.1.linux-amd64/alertmanager.yml /etc/alertmanager
```

```
sudo chown -R alertmanager:alertmanager /etc/alertmanager
```

- Créons un répertoire de données pour alertmanager

```
sudo mkdir -p /var/lib/alertmanager
```

```
sudo chown -R alertmanager:alertmanager /var/lib/alertmanager
```

- Créons un fichier de configuration pour amtool

```
sudo mkdir -p /etc/amtool
```

```
sudo vi /etc/amtool/config.yml
```

```
alertmanager.url: http://localhost:9093
```

- Configurons un service systemd pour alertmanager

```
sudo vi /etc/systemd/system/alertmanager.service
```

```
[Unit]
Description=Prometheus Alertmanager 0.28.1
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/alertmanager --config.file /etc/alertmanager/alertmanager.yml --storage.path="/var/lib/alertmanager"'

[Install]
WantedBy=multi-user.target
```

- Activons et démarrons le service alertmanager

```
sudo systemctl daemon-reload
sudo systemctl enable alertmanager
sudo systemctl start alertmanager
```

- Assurons-nous que le service alertmanager fonctionne

```
sudo systemctl status alertmanager

curl -v localhost:9093
```

Nous pouvons également accéder à Alertmanager dans un navigateur Web à l'adresse : **http://192.168.56.230:9093** (le port 9093 doit être autorisé au niveau firewall).


- Vérifions qu'amtool est capable de se connecter à Alertmanager et de récupérer la configuration actuelle

```
amtool config show
```

### Configuration de Prometheus sur le serveur monitoring de la sandbox pour se connecter à Alertmanager

Editons le fichier de configuration de prometheus.

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
alerting:
  alertmanagers:
    - static_configs:
      - targets: ["localhost:9093"]
... 
```

```
sudo systemctl restart prometheus
```

Vérifions que Prometheus est en mesure d'atteindre Alertmanager. Accédons à Prometheus dans un navigateur Web à l'adresse : **http://192.168.56.230:9090** .

Cliquons sur le menu **Status > Runtime & Build Information** et vérifions que notre instance Alertmanager apparaît dans la section *Alertmanagers*.