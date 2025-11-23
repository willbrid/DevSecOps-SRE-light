# Mise en place d'une authentification et autorisation client oauth avec keycloak

Grâce au plugin SASL/OAUTHBEARER, Kafka permet aux clients d’obtenir un jeton OAuth2 auprès d’un Identity Provider (IdP), puis de l’utiliser pour s’authentifier auprès des brokers. Couplé au système d’autorisations basé sur les ACLs ou sur un Authorizer personnalisé, ce mécanisme offre un niveau de sécurité robuste, moderne et parfaitement adapté aux environnements multi-services.

Dans ce tutoriel, nous allons mettre cela en pratique en intégrant Kafka avec Keycloak, un IdP Open Source largement utilisé. Nous verrons comment configurer Keycloak pour émettre des jetons OAuth2, comment adapter les brokers Kafka pour vérifier ces jetons et, enfin, comment mettre en place les règles d’autorisation permettant de contrôler précisément les actions des clients.

> NB: Cette section s’inscrit dans la continuité des configurations précédentes.

### Préréquis concernant les serveurs broker et serverauth

Nous utiliserons comme nom de domaine d'accès à keycloak : **oauth.devsecops-dojo.sandbox**.

Depuis nos deux serveurs **broker** et **serverauth**, ajoutons une entrée avec ce nom de domaine :

```
sudo vi /etc/hosts
```

```
...
192.168.56.213  oauth.devsecops-dojo.sandbox
```

### Installation de mariadb

Nous allons installer **mariadb** (**version LTS 11.8**) sur le serveur **serverauth** de notre sandbox.

- **Créer deux secrets podman pour mariadb**

secret pour le mot de passe de l'utilisateur applicatif **keycloak**

```
printf "keycloak2025" | podman secret create mariadbpassword -
```

- secret pour le mot de passe root de Mariadb

```
printf "superroot2025" | podman secret create mariadbrootpassword -
```

- **Configurer le repertoire /var/lib/mariadb de persistence des données de Mariadb**

```
sudo mkdir -p /var/lib/mariadb

sudo chown -R vagrant:vagrant /var/lib/mariadb

sudo chmod 0770 -R /var/lib/mariadb
```

- **Créer et configurer le fichier service du conteneur Mariadb**

```
mkdir -p $HOME/.config/containers/systemd
```

```
vi $HOME/.config/containers/systemd/mariadb.container
```

```
[Unit]
Description=Mariadb image 11.8 - LTS
After=network-online.target,local-fs.target

[Container]
ContainerName=mariadb
Image=docker.io/library/mariadb:11.8
Network=host
Environment=MARIADB_USER=keycloak
Environment=MARIADB_DATABASE=keycloak
Secret=mariadbpassword,type=env,target=MARIADB_PASSWORD
Secret=mariadbrootpassword,type=env,target=MARIADB_ROOT_PASSWORD
Timezone=Europe/Paris
Volume=/var/lib/mariadb:/var/lib/mysql:Z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

Recharger la configuration du systemd pour l'utilisateur **vagrant**, démarrer et vérifier le statut du conteneur **Mariadb**

```
systemctl --user daemon-reload
```

```
systemctl --user start mariadb
```

```
systemctl --user status mariadb

podman container ps
```

### Générons les fichiers tls pour keycloak [sandbox : servertools]

- Pour une configuration **https**, générons les fichiers **keycloak-keystore.p12** et **keycloak.csr** du client, signons avec le CA pour générer le fichier **keycloak.crt** et importons le CA et le fichier crt dans le keystore keycloak

```
keytool -genkeypair -keystore keycloak-keystore.p12 -alias localhost -validity 730 -keyalg RSA -storetype pkcs12

keytool -certreq -keystore keycloak-keystore.p12 -alias localhost -ext SAN=DNS:localhost,DNS:oauth.devsecops-dojo.sandbox,IP:192.168.56.213 -file keycloak.csr
```

> NB: Pour la première commande, on a le mot de passe : `keycloak2025` et les différentes réponses aux questions

```
What is your first and last name?
  [Unknown]: keycloak
What is the name of your organizational unit?
  [Unknown]: devsecops-dojo
What is the name of your organization?
  [Unknown]: devsecops-dojo
What is the name of your City or Locality?
  [Unknown]: idf
What is the name of your State or Province?
  [Unknown]: idf 
What is the two-letter country code for this unit?
  [Unknown]: FR
```

```
openssl ca -config openssl-ca.cnf -policy signing_policy -extensions signing_req -out keycloak.crt -infiles keycloak.csr
```

```
keytool -keystore keycloak-keystore.p12 -alias CARoot -import -file cacert.pem

keytool -keystore keycloak-keystore.p12 -alias localhost -import -file keycloak.crt
```

- Générons le fichier **keycloak-truststore.p12**

Cette étape consiste à ajouter l'autorité de certification générée au magasin de certificats de confiance de **keycloak**

```
keytool -keystore keycloak-truststore.p12 -alias CARoot -import -file cacert.pem
```

Mot de passe du magasin de certificats de confiance de keycloak : `keycloak2027`.

### Installation de keycloak [sandbox : serverauth]

Nous allons installer **keycloak** (**version 26.4**) en **https** sur le serveur **serverauth** de notre sandbox.

- Copions les fichiers **keycloak-keystore.p12** et **ca.pem**

```
mkdir -p $HOME/keycloak/ssl
```

```
scp vagrant@192.168.56.214:/home/vagrant/pki/keycloak-keystore.p12 $HOME/keycloak/ssl/

scp vagrant@192.168.56.214:/home/vagrant/pki/keycloak-truststore.p12 $HOME/keycloak/ssl/
```

- **Créer un secret podman pour l'utilisateur admin de keycloak**

```
printf "keycloak2028" | podman secret create keycloakpassword -
```

- Editons le fichier service du conteneur keycloak


```
vi $HOME/.config/containers/systemd/keycloak.container
```

```
[Unit]
Description=Keycloak image 26.4
After=network-online.target,local-fs.target

[Container]
ContainerName=keycloak
Image=quay.io/keycloak/keycloak:26.4
Network=host
Exec=start
Environment=KC_DB=mariadb
Environment=KC_DB_URL_HOST=127.0.0.1
Environment=KC_DB_URL_PORT=3306
Environment=KC_DB_URL_DATABASE=keycloak
Environment=KC_DB_USERNAME=keycloak
Environment=KC_HTTP_ENABLED=false
Environment=KC_HTTPS_KEY_STORE_FILE=/opt/keycloak/keycloak-keystore.p12
Environment=KC_HTTPS_KEY_STORE_PASSWORD='keycloak2025'
Environment=KC_HTTPS_TRUST_STORE_FILE=/opt/keycloak/keycloak-truststore.p12
Environment=KC_HTTPS_TRUST_STORE_PASSWORD='keycloak2027'
Environment=KC_TLS_HOSTNAME_VERIFIER='DEFAULT'
Environment=KC_HTTPS_CLIENT_AUTH='request'
Environment=KC_HTTPS_PORT=8443
Environment=KC_HTTPS_PROTOCOLS='TLSv1.3,TLSv1.2'
Environment=KC_HOSTNAME='https://oauth.devsecops-dojo.sandbox:8443'
Environment=KC_HOSTNAME_ADMIN='https://oauth.devsecops-dojo.sandbox:8443'
Environment=KC_BOOTSTRAP_ADMIN_USERNAME='admin'
Secret=mariadbpassword,type=env,target=KC_DB_PASSWORD
Secret=keycloakpassword,type=env,target=KC_BOOTSTRAP_ADMIN_PASSWORD
Timezone=Europe/Paris
Volume=/home/vagrant/keycloak/ssl/keycloak-keystore.p12:/opt/keycloak/keycloak-keystore.p12:Z
Volume=/home/vagrant/keycloak/ssl/keycloak-truststore.p12:/opt/keycloak/keycloak-truststore.p12:Z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user start keycloak.service
```

Vérification du statut du service keycloak

```
systemctl --user status keycloak.service
```

```
podman container ls
```

Activons le service **firewalld** et autorisons le port **8443** de keycloak

```
sudo systemctl enable --now firewalld.service
```

```
sudo firewall-cmd --permanent --add-port=8443/tcp

sudo firewall-cmd --reload
```

L'on pourra accéder à la console via le lien : `https://oauth.devsecops-dojo.sandbox:8443/admin` . <br>
Les variables d’environnement `KC_BOOTSTRAP_ADMIN_USERNAME` et `KC_BOOTSTRAP_ADMIN_PASSWORD` sont temporaires : une fois Keycloak démarré et que le realm principal est créé, elles doivent être supprimées.

Si nous ne parvenons pas à nous connecter avec les identifiants indiqués via ces variables d'environnement alors nous pouvons exécuter ces commandes ci-dessous dans le conteneur de keycloak :

```
podman container exec -it --workdir /opt/keycloak/bin/ keycloak /bin/bash
```

```
./kc.sh bootstrap-admin user --username:env KC_BOOTSTRAP_ADMIN_USERNAME --password:env KC_BOOTSTRAP_ADMIN_PASSWORD
```

Puis l'on pourra se connecter avec les identifiants temporaires et créer un nouveau utilisateur `keycloakadmin`avec pour mot de passe permanent `keycloak2029` et pour rôles : `default-roles-master` et `admin`. Une fois terminée, nous pouvons supprimer les deux variables d'environnements `KC_BOOTSTRAP_ADMIN_USERNAME` et `KC_BOOTSTRAP_ADMIN_PASSWORD`.