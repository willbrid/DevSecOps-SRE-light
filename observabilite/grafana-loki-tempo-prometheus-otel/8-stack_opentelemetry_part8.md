# Mise en place de la stack app et système

### Utilisation de promtail pour collecter les logs systèmes du serveur server-app

- Installation de **promtail 3.2.1**

```
sudo vi /etc/yum.repos.d/grafana.repo
```

```
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
```

```
sudo dnf install promtail-3.2.1
```

- Verification du statut de **promtail**

```
systemctl status promtail.service
```

- Configuration de **promtail** pour le job **system**

```
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
- url: http://192.168.56.21:3500/loki/api/v1/push # Adresse du recepteur du collecteur opentelemetry

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      __path__: /var/log/*log
      stream: stdout
```

```
sudo systemctl restart promtail.service
```

Nous accédons à grafana via l'url **http://192.168.56.21:3000/** puis nous suivons les étapes :

--- clic sur le bouton **Toggle menu** <br>
--- sélection du menu **Explore** <br>
--- choix de la datasource **Loki-Query-Frontend** <br>
--- au niveau de **Label filters** on sélectionne le label **service_name**, puis sa valeur **unknowm_service**

On pourra visualiser les logs système sur l'espace **Logs** plus bas.