# Mise en place d'un authentification et autorisation client oauth avec keycloak

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

Nous allons installer mariadb sur le serveur **serverauth** de notre sandbox.

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
Description=Mariadb image 11.7.2
After=network-online.target,local-fs.target

[Container]
ContainerName=mariadb
Image=docker.io/library/mariadb:11.7.2
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
