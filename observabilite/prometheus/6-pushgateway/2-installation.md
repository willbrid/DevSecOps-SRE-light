# Installation de pushgateway
## Installation et configuration de pushgateway
Sur notre serveur rocky linux où est installé prometheus, nous installerons *pushgateway v1.4.3*. Nous procédons comme suit.

- créeons un utilisateur **pushgateway**
```
sudo useradd -M -r -s /bin/false pushgateway
```

- téléchargeons et installons le binaire **pushgateway** version 1.4.3
```
wget https://github.com/prometheus/pushgateway/releases/download/v1.4.3/pushgateway-1.4.3.linux-amd64.tar.gz
```

```
tar xvfz pushgateway-1.4.3.linux-amd64.tar.gz
```

```
sudo cp pushgateway-1.4.3.linux-amd64/pushgateway /usr/local/bin/
```

```
sudo chown pushgateway:pushgateway /usr/local/bin/pushgateway
```

- configurons un service systemd pour pushgateway
```
sudo vi /etc/systemd/system/pushgateway.service
``` 

```
[Unit]
Description=Prometheus Pushgateway
Wants=network-online.target
After=network-online.target

[Service]
User=pushgateway
Group=pushgateway
Type=simple
ExecStart=/usr/local/bin/pushgateway

[Install]
WantedBy=multi-user.target
```

- activons et démarrons le service pushgateway
```
sudo systemctl enable pushgateway
sudo systemctl start pushgateway
```

- Assurons-nous que le service pushgateway fonctionne
```
sudo systemctl status pushgateway
curl localhost:9091/metrics
```

## Configuration de prometheus pour récupérer les métriques de Pushgateway

Nous éditons le fichier de configuration de prometheus :
```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
- job_name: 'Pushgateway'
  honor_labels: true
  static_configs:
  - targets: ['localhost:9091']
...  
```

L'option *honor_labels* contrôle la manière dont Prometheus gère les conflits entre les étiquettes déjà présentes dans les données récupérées et les étiquettes que Prometheus attacherait.

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques Pushgateway dans prometheus en accédant au lien 
```
http://<IP_SERVEUR_PROMETHEUS>:9090.
```

et en saisissant cette requête pour afficher quelques données métriques de Pushgateway :
```
pushgateway_build_info
```