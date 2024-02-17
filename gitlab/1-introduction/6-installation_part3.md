# Installation [Part3]

Ici nous allons installer la plateforme **gitlab** (image **docker.io/gitlab/gitlab-ce:16.8.1-ce.0**), depuis notre serveur **gitlab** en activant sa fonctionnalité de notification par mail, sa fonctionnalité de registry d'images et en prenant en charge la sécurité via la configuration du protocole https pour la partie web.

- Création des répertoires nécessaires pour **gitlab**

```
mkdir /home/vagrant/gitlab
```

```
export GITLAB_HOME=/home/vagrant/gitlab
```

```
mkdir $GITLAB_HOME/config $GITLAB_HOME/logs $GITLAB_HOME/data $GITLAB_HOME/ssl $GITLAB_HOME/registry
```

Nous copions le certificat et la clé privée précédemment créés dans le repertoire **$GITLAB_HOME/ssl**.

```
cp willbrid.com.crt $GITLAB_HOME/ssl/willbrid.com.crt
cat ca.crt >> $GITLAB_HOME/ssl/willbrid.com.crt
cp willbrid.com.key $GITLAB_HOME/ssl/willbrid.com.key
```

```
mkdir /home/vagrant/installation && cd /home/vagrant/installation
```

```
vi docker-compose.yaml
```

```
version: '3.6'
services:
  gitlab:
    image: docker.io/gitlab/gitlab-ce:16.8.1-ce.0
    user: root
    name: gitlab
    restart: always
    hostname: 'gitlab.willbrid.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://gitlab.willbrid.com:8443'
        gitlab_rails['time_zone'] = 'Africa/Douala'
        gitlab_rails['gitlab_shell_ssh_port'] = 2222
        gitlab_rails['initial_root_password'] = 'SuperSecret'
        gitlab_rails['smtp_enable'] = true
        gitlab_rails['smtp_address'] = 'mail.willbrid.com'
        gitlab_rails['smtp_port'] = 1025
        gitlab_rails['smtp_domain'] = 'mail.willbrid.com'
        gitlab_rails['smtp_tls'] = false
        gitlab_rails['smtp_openssl_verify_mode'] = 'none'
        gitlab_rails['smtp_enable_starttls_auto'] = false
        gitlab_rails['smtp_ssl'] = false
        gitlab_rails['smtp_force_ssl'] = false
        nginx['listen_https'] = true
        nginx['redirect_http_to_https'] = true
        letsencrypt['enable'] = false
        nginx['ssl_certificate'] = "/etc/gitlab/ssl/willbrid.com.crt"
        nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/willbrid.com.key"
        nginx['listen_port'] = 8443
        registry['enable'] = true
        registry_nginx['listen_https'] = true
        registry_nginx['listen_port'] = 5050
        registry_nginx['redirect_http_to_https'] = true
        registry_external_url 'https://gitlab.willbrid.com:5050'
        gitlab_rails['registry_path'] = "/var/opt/registry"
        registry_nginx['ssl_certificate'] = "/etc/gitlab/ssl/willbrid.com.crt"
        registry_nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/willbrid.com.key"
    ports:
      - '8443:8443'
      - '2222:2222'
      - '5050:5050'
    volumes:
      - '$GITLAB_HOME/config:/etc/gitlab:z'
      - '$GITLAB_HOME/logs:/var/log/gitlab:z'
      - '$GITLAB_HOME/data:/var/opt/gitlab:z'
      - '$GITLAB_HOME/ssl:/etc/gitlab/ssl:z'
      - '$GITLAB_HOME/registry:/var/opt/registry:z'
    shm_size: '256m'
```

```
podman-compose up -d
```

- Autorisons les ports 8443 et 5050 sur le serveur **gitlab**

```
sudo firewall-cmd --permanent --add-port=8443/tcp --add-port=5050/tcp
sudo firewall-cmd --reload
```

Après quelques minutes, nous accédons à l'interface web via le lien **https://gitlab.willbrid.com:8443**