# Création d'un conteneur SGBD : cas de MariaDB

Nous allons installer un conteneur MariaDB basé sur l'image **mariadb:11.7.2** en utilisant la fonctionnalité **Quadlet** de **Podman**. Pour cela, nous suivrons les étapes suivantes.

- **Créer le repertoire systemd de l'utilisateur vagrant**

```
mkdir -p /home/vagrant/.config/containers/systemd
```

NB: Il est nécessaire de se connecter au préalable à la session de l'utilisateur **vagrant**.

- **Configurer le repertoire /var/lib/mariadb de persistence des données de Mariadb**

```
sudo mkdir -p /var/lib/mariadb

sudo chown -R vagrant:vagrant /var/lib/mariadb

sudo chmod 0770 -R /var/lib/mariadb
```

- **Autoriser les services de l'utilisateur vagrant à continuer à s'exécuter après sa déconnexion**

```
sudo loginctl enable-linger vagrant
```

vérifier que cette configuration a été bien effectuée

```
sudo loginctl show-user vagrant | grep -i linger
```

Comme résultat nous devons avoir la ligne "**Linger=yes**".

- **Créer deux secrets podman** 

--- secret pour le mot de passe de l'utilisateur applicatif pour notre futur application 

```
printf "nextcloud@2025" | podman secret create mariadbpassword -
```

--- secret pour le mot de passe root de Mariadb

```
printf "rootstrong@2025" | podman secret create mariadbrootpassword -
```

- **Créer le fichier service du conteneur Mariadb**

```
vim /home/vagrant/.config/containers/systemd/mariadb.container
```

```
[Unit]
Description=Mariadb image 11.7.2
After=network-online.target,local-fs.target

[Container]
ContainerName=mariadb
Image=docker.io/library/mariadb:11.7.2
Network=host
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

Pour plus de compréhension sur les lignes de ce fichier service, vous pouvez consultez le lien [podman-systemd](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html).

Recharger la configuration du systemd pour l'utilisateur **vagrant**

```
systemctl --user daemon-reload
```

Démarrer le conteneur **Mariadb**

```
systemctl --user start mariadb
```

vérifier que le conteneur Mariadb est en cours d'exécution

```
systemctl --user status mariadb
```

```
podman container ps
```

- **Faire un test de connexion au conteneur Mariadb avec les utilisateurs : nextcloud et root**

--- Avec l'utilisateur **nextcloud**

```
podman run --rm -it --network=host docker.io/library/mariadb:11.7.2 mariadb -h 127.0.0.1 -u nextcloud -p
```

**MP: nextcloud@2025**

--- Avec l'utilisateur **root**

```
podman run --rm -it --network=host docker.io/library/mariadb:11.7.2 mariadb -h 127.0.0.1 -u root -p
```

**MP: rootstrong@2025**