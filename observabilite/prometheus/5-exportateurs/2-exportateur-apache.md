# Mise en place d'un exportateur apache dans prometheus
## Installation et configuration d'un exportateur apache
Sur une machine virtuelle où est installé le service apache et dont nous souhaiterons monitorer, nous procédons comme suit.
<br>

- créeons un utilisateur **apache_exporter** 
```
sudo useradd -M -r -s /bin/false apache_exporter
```

- téléchargeons et installons le binaire **apache_exporter** version 0.11
```
wget https://github.com/Lusitaniae/apache_exporter/releases/download/v0.11.0/apache_exporter-0.11.0.linux-amd64.tar.gz
```

```
tar xvfz apache_exporter-0.11.0.linux-amd64.tar.gz
```

```
sudo cp apache_exporter-0.11.0.linux-amd64/apache_exporter /usr/local/bin/
```

```
sudo chown apache_exporter:apache_exporter /usr/local/bin/apache_exporter
```

- configurons un service systemd pour apache exporter 
```
sudo vi /etc/systemd/system/apache_exporter.service
```

```
[Unit]
Description=Prometheus Apache Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=apache_exporter
Group=apache_exporter
Type=simple
ExecStart=/usr/local/bin/apache_exporter

[Install]
WantedBy=multi-user.target
```

- activons et démarrons le service apache_exporter

```
sudo systemctl enable apache_exporter
sudo systemctl start apache_exporter
```

- Assurons-nous que le service apache_exporter fonctionne
```
sudo systemctl status apache_exporter
curl localhost:9117/metrics
```

## Configuration de prometheus pour récupérer les métriques d'apache
Sur une machine virtuelle où est installé prometheus nous procédons comme suit.
<br>
Nous éditons le fichier de configuration de prometheus :
```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
- job_name: 'Apache'
  static_configs:
  - targets: ['<IP_PRIVE_DU_SERVEUR_APACHE>:9117']
...  
```

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques apache dans prometheus en accédant au lien 
```
http://<IP_SERVEUR_PROMETHEUS>:9090.
```

et en saisissant cette requête pour afficher quelques données métriques d'apache :
```
apache_workers
```