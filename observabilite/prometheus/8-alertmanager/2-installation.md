# Installation d'Alertmanager
## Installation et configuration d'Alertmanager

Sur notre serveur rocky linux où est installé prometheus, nous installerons *Alertmanager v0.24.0*. Nous procédons comme suit.

- créeons un utilisateur **alertmanager**
```
sudo useradd -M -r -s /bin/false alertmanager
```

- téléchargeons et installons les binaires **alertmanager** et son fichier de configuration
```
wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
```

```
tar xvfz alertmanager-0.24.0.linux-amd64.tar.gz
```

```
sudo cp alertmanager-0.24.0.linux-amd64/{alertmanager,amtool} /usr/local/bin/
```

```
sudo chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}
```

```
sudo mkdir -p /etc/alertmanager
```

```
sudo cp alertmanager-0.24.0.linux-amd64/alertmanager.yml /etc/alertmanager
```

```
sudo chown -R alertmanager:alertmanager /etc/alertmanager
```

- Créeons un répertoire de données pour alertmanager
```
sudo mkdir -p /var/lib/alertmanager
```

```
sudo chown alertmanager:alertmanager /var/lib/alertmanager
```

- Créeons un fichier de configuration pour amtool
```
sudo mkdir -p /etc/amtool
```

```
sudo vi /etc/amtool/config.yml
```

```
alertmanager.url: http://localhost:9093
```

- configurons un service systemd pour alertmanager
```
sudo vi /etc/systemd/system/alertmanager.service
```

```
[Unit]
Description=Prometheus Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
 --config.file /etc/alertmanager/alertmanager.yml \
 --storage.path /var/lib/alertmanager/

[Install]
WantedBy=multi-user.target
```

- activons et démarrons le service alertmanager
```
sudo systemctl enable alertmanager
sudo systemctl start alertmanager
```

- Assurons-nous que le service alertmanager fonctionne
```
sudo systemctl status alertmanager
curl localhost:9093
```

Nous pouvons également accéder à Alertmanager dans un navigateur Web à l'adresse :
```
http://<IP_SERVEUR_PROMETHEUS>:9093.
```

- Vérifions qu'amtool est capable de se connecter à Alertmanager et de récupérer la configuration actuelle
```
amtool config show
```

## Configuration de Prometheus pour se connecter à Alertmanager

Nous éditons le fichier de configuration de prometheus :
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

Vérifions que Prometheus est en mesure d'atteindre Alertmanager. Accédons à Prometheus dans un navigateur Web à l'adresse :
```
http://<IP_SERVEUR_PROMETHEUS>:9090.
```

Cliquons sur le menu **Status > Runtime & Build Information** et vérifions que notre instance Alertmanager apparaît dans la section *Alertmanagers*.