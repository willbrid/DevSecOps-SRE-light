# Création de pod avec plusieurs conteneurs

Nous allons ici créer un pod **nextcloudapp** et ajouter nos conteneurs **Mariadb** et **Nextcloud** dans ce pod en utilisant la fonctionnalité **Quadlet** de **Podman**. Pour cela, nous suivrons les étapes suivantes.

- Arrêter les services conteneurs **Mariadb** et **Nextcloud**

```
systemctl --user stop mariadb

systemctl --user stop nextcloud
```

- **Créer le fichier service pod pour notre application avec sa base de données**

```
vim /home/vagrant/.config/containers/systemd/nextcloudapp.pod
```

```
[Unit]
Description=Pod for nextcloud application

[Pod]
PodName=nextcloudapp
Network=stackappnet.network
PublishPort=8080:80

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload

systemctl --user start nextcloudapp-pod
```

Par défaut, le **pod** Podman a le même nom que l'unité, mais avec un préfixe **systemd-**, c'est-à-dire qu'un fichier **$name.pod** crée une unité **$name-pod.service** et un pod **systemd-$name** Podman. L'option **PodName** permet de remplacer ce nom par défaut (**systemd-$name**) par un nom fourni par l'utilisateur.

- **Mettre à jour le fichier du conteneur Mariadb pour l'ajouter à notre pod nextcloudapp**

```
vim /home/vagrant/.config/containers/systemd/mariadb.container
```

```
[Unit]
Description=Mariadb image 11.7.2
After=local-fs.target

[Container]
ContainerName=mariadb
Image=docker.io/library/mariadb:11.7.2
Pod=nextcloudapp.pod
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

Nous avons juste enlevé la ligne avec l'option **Network** et ajouter une ligne avec l'option **Pod** en indiquant comme valeur **nextcloudapp.pod**.

- **Mettre à jour le fichier du conteneur Nextcloud pour l'ajouter à notre pod nextcloudapp**

```
vim /home/vagrant/.config/containers/systemd/nextcloud.container
```

```
[Unit]
Description=Nextcloud image 31.0.1-apache
After=local-fs.target

[Container]
ContainerName=nextcloud
Image=docker.io/library/nextcloud:31.0.1-apache
Pod=nextcloudapp.pod
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

Nous avons juste enlevé les lignes avec les options **Network** et **PublishPort** puis ajouter une ligne avec l'option **Pod** en indiquant comme valeur **nextcloudapp.pod**.

- **Lister les pods en exécution**

```
podman pod ps
```

- **Lister les conteneurs avec leur pod**

```
podman container ps --pod
```

- **Faire un test d'accès à la page web de Nextcloud via un navigateur**

Il suffira d'accéder à l'interface web de Nextcloud via le lien http://192.168.56.9:8080.