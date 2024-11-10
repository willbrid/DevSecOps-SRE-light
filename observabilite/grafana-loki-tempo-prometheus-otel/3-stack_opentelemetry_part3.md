# Mise en place d'Alertmanager, de Grafana et d'un service de messagerie sur le serveur server-monitoring

- Installation de **podman-compose**

```
sudo dnf install podman-compose
```

- Création du réseau interne des conteneurs

```
podman network create server-monitoring
```

- Ajout d'une entrée de nom **mail.willbrid.com** sur le serveur **server-monitoring**

```
sudo vi /etc/hosts
```

```
192.168.56.21  mail.willbrid.com
```

- Préparation du repertoire de données du service de messagerie avec le frontend **Roundcubemail**

```
mkdir $HOME/mail && mkdir $HOME/mail/data $HOME/mail/state $HOME/mail/logs $HOME/mail/config
```

```
mkdir $HOME/roundcubemail && mkdir $HOME/roundcubemail/www $HOME/roundcubemail/sqlite
```

- Préparation du repertoire de configuration et de données d'Alertmanager

```
mkdir -p $HOME/alertmanager/data && cd $HOME/alertmanager
```

```
# $HOME/alertmanager/alertmanager.yml
global:
  smtp_require_tls: false
  smtp_smarthost: 'mail.willbrid.com:1025'
  smtp_hello: 'mail.willbrid.com'

route:
  receiver: 'mail'
  repeat_interval: 1h

receivers:
  - name: 'mail'
    email_configs:
      - from: 'alertmanager@willbrid.com'
        to: 'admin@willbrid.com'
```

- Préparation du repertoire de données de **Grafana**

```
mkdir $HOME/grafana-storage
```

- Preparation du fichier **docker-compose** et installation des composants : **alertmanager**, **Grafana** et **service de messagerie**

```
vi $HOME/docker-compose.yml
```

```
version: '3.8'

services:
  grafana:
    image: docker.io/grafana/grafana-oss:10.0.10
    ports:
      - "3000:3000"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/grafana-storage:/var/lib/grafana:z'

  mailserver:
    image: docker.io/mailserver/docker-mailserver:13.2.0
    ports:
      - "1025:25"
      - "1143:143"
      - "1587:587"
    networks:
      - networks-monitoring
    environment:
      OVERRIDE_HOSTNAME: mail.willbrid.com
      POSTMASTER_ADDRESS: postmaster@willbrid.com
      POSTFIX_INET_PROTOCOLS: ipv4
      PERMIT_DOCKER: none
      ONE_DIR: 1
      TZ: 'Europe/Paris'
    volumes:
      - '$HOME/mail/data:/var/mail:z'
      - '$HOME/mail/state:/var/mail-state:'
      - '$HOME/mail/logs:/var/log/mail:z'
      - '$HOME/mail/config:/tmp/docker-mailserver:z'

  roundcubemail:
    image: docker.io/roundcube/roundcubemail:1.6.9-apache
    ports:
      - "8080:80"
    networks:
      - networks-monitoring  
    depends_on:
      - mailserver
    environment:
      ROUNDCUBEMAIL_DEFAULT_HOST: mail.willbrid.com
      ROUNDCUBEMAIL_DEFAULT_PORT: 1143
      ROUNDCUBEMAIL_SMTP_SERVER: mail.willbrid.com
      ROUNDCUBEMAIL_SMTP_PORT: 1025
      ROUNDCUBEMAIL_SMTP_AUTH_TYPE: "null"
      ROUNDCUBEMAIL_SMTP_USER: ""
      ROUNDCUBEMAIL_SMTP_PASS: ""
      ROUNDCUBEMAIL_DB_TYPE: sqlite
    volumes:
      - '$HOME/roundcubemail/www:/var/www/html:z'
      - '$HOME/roundcubemail/sqlite:/var/roundcube/db:z'

  alertmanager:
    image: docker.io/prom/alertmanager:v0.26.0
    command: ['--config.file=/config/alertmanager.yml', '--log.level=debug']
    ports:
      - "9093:9093"
    networks:
      - networks-monitoring  
    volumes:
      - '$HOME/alertmanager/alertmanager.yml:/config/alertmanager.yml:z'
      - '$HOME/alertmanager/data:/data:z'

networks:
  networks-monitoring:
    name: server-monitoring
    external: true
```

```
podman-compose up -d
```

- Création de 2 comptes mail sur **mailserver**

On se connecte au container **mailserver** et on exécute la commande permettant d'ajouter 2 boîtes mail : **admin@willbrid.com** et **alertmanager@willbrid.com**

```
podman exec -it vagrant_mailserver_1 /bin/sh
```

```
setup email add admin@willbrid.com
```

```
setup email add alertmanager@willbrid.com
```

Le mot de passe entré pour ces 2 boîtes mail sera : **test1234567**.

- Autorisation des ports de Grafana et Rouncubemail au niveau du firewall

```
sudo firewall-cmd --permanent --add-port={3000/tcp,8080/tcp}

sudo firewall-cmd --reload
```

- Connexion web à Grafana et Roundcubemail

--- pour Grafana via le lien : http://192.168.56.21:3000/ avec un crédential par défaut qu'il faudrait modifier

```
username : admin
password : admin
```

--- pour Roundcubemail via le lien : http://192.168.56.21:8080 avec un crédential

```
username : admin@willbrid.com
password : test1234567
```