# Installation de pushgateway

### Installation et configuration de pushgateway sur le serveur monitoring de la sandbox

Sur notre serveur rocky linux où est installé prometheus, nous installerons *pushgateway v1.11.1*. Nous procédons comme suit.

- Créeons un utilisateur **pushgateway**

```
sudo useradd -M -r -s /bin/false pushgateway
```

- Téléchargeons et installons le binaire **pushgateway** version 1.11.1

```
curl -LO https://github.com/prometheus/pushgateway/releases/download/v1.11.1/pushgateway-1.11.1.linux-amd64.tar.gz
```

```
tar xvfz pushgateway-1.11.1.linux-amd64.tar.gz
```

```
sudo mv pushgateway-1.11.1.linux-amd64/pushgateway /usr/local/bin/
```

```
sudo chown pushgateway:pushgateway /usr/local/bin/pushgateway
```

- Configurons un service systemd pour pushgateway

```
sudo vi /etc/systemd/system/pushgateway.service
``` 

```
[Unit]
Description=Prometheus Pushgateway 1.11.1
Wants=network-online.target
After=network-online.target

[Service]
User=pushgateway
Group=pushgateway
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/pushgateway'

[Install]
WantedBy=multi-user.target
```

- Activons et démarrons le service pushgateway

```
sudo systemctl daemon-reload
sudo systemctl enable pushgateway
sudo systemctl start pushgateway
```

- Assurons-nous que le service pushgateway fonctionne

```
sudo systemctl status pushgateway

curl -v localhost:9091/metrics
```

### Configuration de prometheus sur le serveur monitoring de la sandbox pour récupérer les métriques de Pushgateway

Nous éditons le fichier de configuration de prometheus :

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
scrape_configs:
  ...
  - job_name: 'pushgateway'
    honor_labels: true
    static_configs:
      - targets: ['localhost:9091']
...  
```

L'option **honor_labels** contrôle la manière dont Prometheus gère les conflits entre les étiquettes déjà présentes dans les données récupérées et les étiquettes que Prometheus attacherait.

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques Pushgateway dans prometheus en accédant au lien : **http://192.168.56.230:9090** .

Et en saisissant cette requête pour afficher quelques données métriques de Pushgateway :

```
pushgateway_build_info
```