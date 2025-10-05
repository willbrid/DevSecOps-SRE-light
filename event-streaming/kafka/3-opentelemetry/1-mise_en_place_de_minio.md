# Configuration de l’environnement Quadlet et installation de MinIO

Les configurations de ces différentes sections se feront dans notre serveur **monitoring**.

### Configuration de notre environnement quadlet

Dans cette section, nous allons créer le repertoire **$HOME/.config/containers/systemd** et autoriser l’utilisateur **vagrant** à exécuter des services systemd en dehors d’une session active.

- Création du répertoire **$HOME/.config/containers/systemd**

```
mkdir -p $HOME/.config/containers/systemd
```

- Autorisation de l'utilisateur vagrant à exécuter en continu des services

```
sudo loginctl enable-linger vagrant
```

### Création du fichier service réseau

Dans cette section, nous allons définir le fichier **service réseau Quadlet** nécessaire au déploiement des différents composants de notre stack de monitoring.

```
vi $HOME/.config/containers/systemd/monitoring.network
```

```
[Unit]
Description=Monitoring network
After=network-online.target

[Network]
NetworkName=monitoring

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
sudo reboot
```

### Installation de MinIO

- Création du repertoire des données

```
mkdir -p $HOME/minio
```

- Création des secrets pour l'utilisateur admin et son mot de passe

```
printf "admin" | podman secret create adminuser -
```

```
printf "verysecurepassword" | podman secret create adminpassword -
```

- Configuration du fichier service

```
vi $HOME/.config/containers/systemd/minio.container
```

```
[Unit]
Description=MinIO image RELEASE.2025-07-23T15-54-02Z
After=local-fs.target

[Container]
ContainerName=minio
Image=quay.io/minio/minio:RELEASE.2025-07-23T15-54-02Z
Network=monitoring.network
PublishPort=9090:9090
Secret=adminuser,type=env,target=MINIO_ROOT_USER
Secret=adminpassword,type=env,target=MINIO_ROOT_PASSWORD
Exec=server /data --console-address ":9090"
Timezone=Europe/Paris
Volume=/home/vagrant/minio:/data:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start minio
```

Verification du statut du service minio

```
systemctl --user status minio
```

- Activation du parefeu firewalld et autorisation du port 9090

```
sudo systemctl enable firewalld --now

sudo systemctl status firewalld
```

```
sudo firewall-cmd --permanent --add-port=9090/tcp

sudo firewall-cmd --reload
```

Nous pouvons à présent accéder à notre interface web minio via le lien : **http://192.168.56.211:9090** et entrer les informations d'identification comme mentionné ci-dessous :

```
username = admin 
password = verysecurepassword
```

### Création des buckets de monitoring dans minio

Nous créons 3 buckets nommés **prometheus**, **loki** et **tempo** en suivant les étapes ci-dessous :

- accèder au menu Buckets
- cliquer sur le bouton **Create Bucket**
- saisir le **nom du bucket à créer** et cliquer sur le bouton **Create Bucket**
