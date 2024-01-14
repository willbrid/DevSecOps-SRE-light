# Installation de Haproxy sous rocky linux 8

## Installation via le référentiel de rocky linux 8

```
sudo yum -y install haproxy
```

- Configurons SELinux pour HAProxy

Nous devons définir haproxy_connect_any sur 1 pour faire fonctionner HAProxy :

```
sudo setsebool -P haproxy_connect_any 1
```

## Installation via la méthode compilée

Ici, nous installerons Haproxy version **LTS 2.6**. Afin de compiler HAProxy, nous devons nous assurer que quelques packages des référentiels standard sont installés. L'un des packages requis se trouve dans le référentiel **powertools**. 

- Activons le référentiel **powertools**.

```
sudo dnf config-manager --enable powertools
```

- Installons les packages **openssl-devel**, **readline-devel**, **systemd-devel**, **make**, **pcre-devel**, **tar**, **lua**, **lua-devel**

```
sudo dnf install gcc openssl-devel readline-devel systemd-devel make pcre-devel tar lua lua-devel
```

- Téléchargeons HAProxy version 2.6.12

```
wget https://www.haproxy.org/download/2.6/src/haproxy-2.6.12.tar.gz
```

- Extrayons les fichiers d'archive sources et accédons au répertoire créé par **tar**

```
tar -xvzf haproxy-2.6.12.tar.gz
cd haproxy-2.6.12
```

- Compilons HAProxy

```
make TARGET=linux-glibc USE_LUA=1 USE_OPENSSL=1 USE_PCRE=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_PROMEX=1
```

L'option **USE_PROMEX** permet d'activer la fonctionnalité d'exporteur prometheus

- Installons HAProxy

```
sudo make install-bin
```

- Vérifions si HAProxy est bien installé

```
haproxy -vv
```

Nous verrons un message indiquant que **prometheus-exporter** natif à HAProxy est activé.

- Créons le groupe et l'utilisateur haproxy

```
sudo groupadd -g 1001 haproxy
sudo useradd -g 1001 -u 1002 -m -d /var/lib/haproxy -s /sbin/nologin -c haproxy haproxy
```

- Créons un répertoire pour stocker les fichiers de configuration HAProxy

```
sudo mkdir /etc/haproxy
```

- Créons le fichier de configuration de base

```
sudo vi /etc/haproxy/haproxy.cfg
```

```
global
	# Refuser de démarrer si un avertissement est émis au démarrage (garder les configurations propres)
	zero-warning

    # Nombre de connexions simultanées
    maxconn 2000

	# Renforcement de la sécurité : isoler et supprimer les privilèges
	chroot /var/lib/haproxy
	user haproxy
	group haproxy

	# Mode démon
	daemon
	# pidfile /var/run/haproxy.pid // Déjà précisé dans la configuration du service HAProxy

	# Ne pas conserver les anciens processus plus longtemps qu'après un rechargement
	hard-stop-after 5m
    
	# Configuration par défaut des logs
	log stderr local0 info

	# Sécurité intermédiaire pour SSL
	ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
	ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
	ssl-default-bind-options prefer-client-ciphers no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets

# Paramètres par défaut communs à tous les proxys HTTP ci-dessous
defaults http
	mode http
	option httplog
	log global
	timeout client 1m
	timeout server 1m
	timeout connect 10s
	timeout http-keep-alive 2m
	timeout queue 15s
	timeout tunnel 4h  # Pour websocket  
```

- Attribuons les droits appropriés à notre repertoire **/etc/haproxy**

```
sudo chown -R haproxy:haproxy /etc/haproxy/
```

- Vérifions notre configuration avec la commande haproxy

```
haproxy -c -f /etc/haproxy/haproxy.cfg
```

```
# Résultat
Configuration file is valid
```

L'option **-c** permet d'activer la vérification du fichier de configuration et l'option **-f** permet de préciser le fichier de configuration.

- Créons le fichier d'environnement SystemD pour HAProxy

```
sudo vi /etc/sysconfig/haproxy
```

```
# Option à fournir lors du démarrage de HAProxy
CLI_OPTIONS="-Ws"

# Fichier de configuration de HAProxy
CONFIG_FILE=/etc/haproxy/haproxy.cfg

# Fichier du process ID de HAProxy
PID_FILE=/var/run/haproxy.pid
```

L'option **-Ws** exécute HAProxy dans un mode où il est capable de notifier SystemD lorsqu'il a fini de démarrer.

- Créons le fichier d'unité SystemD pour HAProxy

```
sudo vi /etc/systemd/system/haproxy.service
```

```
[Unit]
Description=HAProxy 2.6.12
After=syslog.target network.target

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/haproxy
ExecStart=/usr/local/sbin/haproxy -f $CONFIG_FILE -p $PID_FILE $CLI_OPTIONS
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -USR1 $MAINPID

[Install]
WantedBy=multi-user.target
```

Le signal **USR2** ordonne à HAProxy de recharger sa configuration sans l'arrêter. **USR1** arrête HAProxy, permettant aux processus de terminer ce qu'ils étaient en train de faire avant de quitter.

- Chargeons la configuration du service HAProxy, activons-le au démarrage du serveur et démarrons-le

```
sudo systemctl daemon-reload
sudo systemctl enable haproxy
sudo systemctl start haproxy
```

- Vérifions le statut de haproxy

```
sudo systemctl status haproxy
```

- Configurons SELinux pour HAProxy

Nous devons définir haproxy_connect_any sur 1 pour faire fonctionner HAProxy :
```
sudo setsebool -P haproxy_connect_any 1
```

NB : C'est cette version (**2.6.12**) de HAProxy que nous allons utiliser tout au long de notre parcours.