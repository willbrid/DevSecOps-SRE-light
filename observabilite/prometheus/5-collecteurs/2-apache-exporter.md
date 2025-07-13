# Mise en place d'un collecteur apache dans prometheus

### Installation et configuration minimale d'apache sur le serveur server1 de la sandbox

- installons le package **httpd**

```
sudo dnf -y install httpd
```

- désactivons la configuration **welcome.conf**

```
sudo  mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.org
```

- configurons le module **mod_status** d'apache qui permettra au collecteur de récupérer les métriques d'apache via le endpoint **/server-status**

```
sudo vi /etc/httpd/conf/httpd.conf
```

```
...
# ligne 164
<Location "/server-status">
    SetHandler server-status
    Require host localhost
</Location>
...
```

- activons et démarrons le service apache

```
sudo systemctl enable --now httpd
```

- assurons-nous que le service apache fonctionne

```
sudo systemctl status httpd
```

- créons une simple page web

```
sudo vi /var/www/html/index.html
```

```
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Test Page service apache
</div>
</body>
</html>
```

### Installation et configuration d'un collecteur apache sur le serveur server1 de la sandbox

Sur une machine virtuelle où est installé le service apache et dont nous souhaiterons monitorer, nous procédons comme suit.

- créeons un utilisateur **apache_exporter** 

```
sudo useradd -M -r -s /bin/false apache_exporter
```

- téléchargeons et installons le binaire **apache_exporter** version v1.0.10

```
curl -LO https://github.com/Lusitaniae/apache_exporter/releases/download/v1.0.10/apache_exporter-1.0.10.linux-amd64.tar.gz
```

```
tar xvfz apache_exporter-1.0.10.linux-amd64.tar.gz
```

```
sudo mv apache_exporter-1.0.10.linux-amd64/apache_exporter /usr/local/bin/
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
Description=Prometheus Apache Exporter v1.0.10
Wants=network-online.target
After=network-online.target

[Service]
User=apache_exporter
Group=apache_exporter
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/apache_exporter --scrape_uri="http://localhost/server-status?auto"'

[Install]
WantedBy=multi-user.target
```

**NB:** L'option **--scrape_uri** permet de configurer le endpoint du module **mod_status** d'apache.

- activons et démarrons le service apache_exporter

```
sudo systemctl daemon-reload
sudo systemctl enable apache_exporter
sudo systemctl start apache_exporter
```

- assurons-nous que le service apache_exporter fonctionne

```
sudo systemctl status apache_exporter

curl -v http://localhost:9117/metrics
```

Pour permettre à prometheus de récupérer les métriques d'apache, nous devons d'abord autoriser le port 9117 au niveau du pare-feu

```
sudo systemctl start firewalld.service && sudo systemctl enable firewalld.service

sudo firewall-cmd --permanent --add-port=9117/tcp
sudo firewall-cmd --reload
```

### Configuration de prometheus sur le serveur monitoring de la sandbox pour récupérer les métriques d'apache

Nous éditons le fichier de configuration de prometheus :

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
- job_name: 'apache_exporter_server1'
  scrape_interval: 5s
  static_configs:
    - targets: ['192.168.56.231:9117']
...  
```

```
sudo systemctl restart prometheus
```

Nous utilisons le navigateur d'expressions pour vérifier que nous pouvons voir les métriques apache dans prometheus en accédant au lien : **http://192.168.56.230:9090** .

Et en saisissant cette requête pour afficher quelques données métriques d'apache.

```
apache_connections
```