# Configuration d'un service de notification et Installation de Grafana

Les configurations de ces différentes sections se feront dans notre serveur **monitoring**.

### Configuration de notre service de notification

Il s'agit dans cette section de mettre en place un webhook de notification vers un canal **slack** des alertes prometheus : **Easy_api_prom_sms_alert**.

```
mkdir -p $HOME/easy_api_prom_sms_alert
```

```
vi $HOME/easy_api_prom_sms_alert/config.yaml
```

```
easy_api_prom_sms_alert:
  simulation: false
  auth:
    enabled: true
    username: test
    password: test@test
  provider:
    url: "https://slack.com/api/chat.postMessage"
    content_type: "application/json"
    authentication:
      enabled: true
      authorization_type: 'Bearer'
      authorization_credential: 'xxxxxxx'
    parameters: 
      from: 
        param_name: "username"
        param_value: "prometheus"
        param_method: "post"
      to:
        param_name: "channel"
        param_value: "administration"
        param_method: "post"
      message: 
        param_name: "text"
    timeout: 10s
  recipients: 
  - name: "administration"
    members:
    - "devsecops-dojo-alertes"
```

**xxxxxxx** représente le token bot configuré depuis le lien : **https://api.slack.com/apps** .

- Configuration du fichier service **alertsender**

```
vi $HOME/.config/containers/systemd/alertsender.container
```

```
[Unit]
Description=Alertsender
After=local-fs.target

[Container]
ContainerName=alertsender
Image=docker.io/willbrid/easy-api-prom-sms-alert:v1.3.3
Network=monitoring.network
Environment=EASY_API_PROM_SMS_ALERT_ENABLE_HTTPS=false
Timezone=Europe/Paris
Volume=/home/vagrant/easy_api_prom_sms_alert/config.yaml:/etc/easy-api-prom-sms-alert/config.yaml:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start alertsender
```

### Installation de grafana

- Création du répertoire des données de grafana

```
mkdir -p $HOME/grafana-storage && sudo chmod 777 -R $HOME/grafana-storage
```

- Configuration du fichier service **grafana**

```
vi $HOME/.config/containers/systemd/grafana.container
```

```
[Unit]
Description=Grafana 12.2.0
After=local-fs.target

[Container]
ContainerName=grafana
Image=docker.io/grafana/grafana-oss:12.2.0-17142428006
Network=monitoring.network
PublishPort=3000:3000
Timezone=Europe/Paris
Volume=/home/vagrant/grafana-storage:/var/lib/grafana:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start grafana
```

- Autorisation du port 3000

```
sudo firewall-cmd --permanent --add-port=3000/tcp

sudo firewall-cmd --reload
```

Nous pouvons à présent accéder à notre interface web minio via le lien : **http://192.168.56.211:3000** et entrer les informations d'identification par défaut et le nouveau mot de passe comme mentionné ci-dessous :

```
username : admin
password : admin

new password : admintest
```