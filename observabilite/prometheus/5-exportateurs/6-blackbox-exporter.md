# Mise en place du blackbox exporter dans prometheus
## Installation et configuration de blackbox exporter
Sur une machine virtuelle où est installé le service prometheus, nous procédons comme suit.
<br>

- créeons un utilisateur **blackbox_exporter** 
```
sudo useradd -M -r -s /bin/false blackbox_exporter
```

- téléchargeons et installons le binaire **blackbox_exporter** version 0.22
```
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.22.0/blackbox_exporter-0.22.0.linux-amd64.tar.gz
```

```
tar xvfz blackbox_exporter-0.22.0.linux-amd64.tar.gz
```

```
sudo cp blackbox_exporter-0.22.0.linux-amd64/blackbox_exporter /usr/local/bin/
```

```
sudo chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter
```

- créeons un fichier de configuration *blackbox.yml*
```
sudo mkdir -p /etc/blackbox_exporter
```

```
sudo vi /etc/blackbox_exporter/blackbox.yml
```

```
modules:
  tcp_connect:
    prober: tcp
    timeout: 5s
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
      valid_status_codes: []
      method: GET
      follow_redirects: false
      tls_config:
        insecure_skip_verify: false
      preferred_ip_protocol: "ip4"
      ip_protocol_fallback: false    
```

```
sudo chown -R blackbox_exporter:blackbox_exporter /etc/blackbox_exporter
```

Dans cette exemple, nous définissons deux modules dans le fichier de configuration : <br/>
--- un module **tcp_connect** avec un timeout de 5 secondes pour les requêtes tcp <br/>
--- un module **http_2xx** avec un timeout de 5 secondes pour les requêtes http; nous configurons deux versions du protocol http (http1 et http2); nous nous intéressons uniquement aux requêtes GET avec pour statut 200; nous désactivons le suivi de redirection, la vérification tls et l'utilisation de l'IPv6.
<br/>

- configurons un service systemd pour blackbox_exporter
```
sudo vi /etc/systemd/system/blackbox_exporter.service
```

```
[Unit]
Description=Blackbox Exporter
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

- activons et démarrons le service blackbox_exporter
```
sudo systemctl daemon-reload
sudo systemctl enable blackbox_exporter
sudo systemctl start blackbox_exporter
```

- Assurons-nous que le service blackbox_exporter fonctionne
```
sudo systemctl status blackbox_exporter
```

## Configuration de Prometheus pour utiliser blackbox_exporter

Nous supposerons ici que nous souhaiterons monitorer l'api : *http://www.example.com/api/healthcheck* <br/>
Nous éditons le fichier de configuration de prometheus :
```
sudo vi /etc/prometheus/prometheus.yml
```

```
global:
  scrape_interval: 10s

scrape_configs:
  ...
  - job_name: 'blackbox'
    metrics_path: /probe
    scrape_interval: 5s
    params:
      module: [http_2xx]
    static_configs:
      - targets: ['http://www.example.com/api/healthcheck']
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

Vérifions que Prometheus est en mesure d'atteindre blackbox_exporter et récupérer les kpi. Accédons à Prometheus dans un navigateur Web à l'adresse :
```
http://<IP_SERVEUR_PROMETHEUS>:9090.
```

Cliquons sur le menu **Graph**, entrons le mot clé **probe_http_status_code** et vérifions que les résultats affichent un statut **200**