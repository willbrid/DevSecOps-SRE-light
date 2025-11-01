# Création d'un conteneur d'une application : cas de Nextcloud

Lien Github de l'application : [Github Nextcloud](https://github.com/nextcloud/server)

Nous allons installer un conteneur de l'application **Nextcloud** basé sur l'image **docker.io/library/nextcloud:31.0.1-apache**, qui va se connecter à sa base de données (**nextcloud**) via le conteneur **Mariadb**, tout ceci en utilisant la fonctionnalité **Quadlet** de **Podman**. Pour cela, nous suivrons les étapes suivantes.

- **Créer le fichier service du réseau de notre application avec sa base de données**

```
vi /home/vagrant/.config/containers/systemd/stackappnet.network
```

```
[Unit]
Description=Stackappnet network
After=network-online.target

[Network]
NetworkName=stackappnet

[Install]
WantedBy=default.target
```

- **Mettre à jour le fichier service du conteneur Mariadb pour prendre compte la configuration service réseau**

```
vi /home/vagrant/.config/containers/systemd/mariadb.container
```

```
[Unit]
Description=Mariadb image 11.7.2
After=local-fs.target

[Container]
ContainerName=mariadb
Image=docker.io/library/mariadb:11.7.2
Network=stackappnet.network
Environment=MARIADB_USER=nextcloud
Environment=MARIADB_DATABASE=nextcloud
Secret=mariadbpassword,type=env,target=MARIADB_PASSWORD
Secret=mariadbrootpassword,type=env,target=MARIADB_ROOT_PASSWORD
Timezone=Europe/Paris
Volume=/var/lib/mariadb:/var/lib/mysql:Z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload

systemctl --user restart mariadb
```

- **Configurer les repertoires de persistence des données de Nextcloud**

```
sudo mkdir -p /var/lib/nextcloud/apps

sudo mkdir -p /var/lib/nextcloud/data

sudo mkdir -p /var/lib/nextcloud/config
```

```
sudo chown -R vagrant:vagrant /var/lib/nextcloud

sudo chmod -R 0770 /var/lib/nextcloud
```

- **Créer un secret podman contenant le mot de passe de l'utilisateur web admin de Nextcloud**

```
printf "nextcloudadmin@2025" | podman secret create nextcloudadminpassword -
```

-  **Créer et configurer le fichier service du conteneur Nextcloud**

```
vi /home/vagrant/.config/containers/systemd/nextcloud.container
```

```
[Unit]
Description=Nextcloud image 31.0.1-apache
After=local-fs.target

[Container]
ContainerName=nextcloud
Image=docker.io/library/nextcloud:31.0.1-apache
Network=stackappnet.network
PublishPort=8080:80
Environment=NEXTCLOUD_ADMIN_USER=admin
Environment=MYSQL_DATABASE=nextcloud
Environment=MYSQL_HOST=mariadb
Environment=MYSQL_USER=nextcloud
Secret=nextcloudadminpassword,type=env,target=NEXTCLOUD_ADMIN_PASSWORD
Secret=mariadbpassword,type=env,target=MYSQL_PASSWORD
Timezone=Europe/Paris
Volume=/var/lib/nextcloud:/var/www/html:z
Volume=/var/lib/nextcloud/apps:/var/www/html/custom_apps:z
Volume=/var/lib/nextcloud/config:/var/www/html/config:z
Volume=/var/lib/nextcloud/data:/var/www/html/data:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload

systemctl --user start nextcloud
```

**NB:** **mariadb** conformément au nom du service, est le nom fqdn utilisé par le sevice nextcloud (via la variable **MYSQL_HOST**) pour accéder à sa base de données.

vérifier que le conteneur Nextcloud est en cours d'exécution

```
systemctl --user status nextcloud
```

```
podman container ps
```

Autoriser le port d'exposition 8080 du conteneur Nextcloud au niveau du service firewalld

```
sudo systemctl enable --now firewalld
```

```
sudo firewall-cmd --permanent --add-port=8080/tcp

sudo firewall-cmd --reload
```

- **Faire un test d'accès à la page web de Nextcloud via un navigateur**

Il suffira d'accéder à l'interface web de Nextcloud via le lien http://192.168.56.9:8080.