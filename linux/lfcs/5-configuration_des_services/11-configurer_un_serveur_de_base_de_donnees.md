# Configurer un serveur de base de données

Les bases de données constituent une partie importante de nombreuses applications prises en charge par un administrateur système Linux. Nous devons donc savoir comment gérer diverses bases de données. Linux propose de nombreuses options de base de données, comme **MariaDB**, **Oracle**, **PostgreSQL** et **Mongo**. <br>
Nous prenons le cas de la mise en place d'un SGDB : **MariaDB**.

### Installation du serveur MariaDB et son client 

- Ajoutons le référentiel de packages pour **Mariadb** version 10.11 LTS

```
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.11"
```

- Installons la version 10.11 LTS de Mariadb

Sous **Ubuntu**

```
sudo apt update && sudo apt -y install mariadb-server mariadb-client
```

Sous **Rocky linux**

```
sudo dnf install -y MariaDB-server MariaDB-client
```

### Configuration du serveur MariaDB

Les récommandations de configuration : <br>
--- définir toujours un mot de passe root MariaDB <br>
--- désactiver les comptes anonymes lorsque cela est possible <br>
--- désactiver l'accès à la connexion racine à distance de MariaDB lorsque cela est possible.

- Activons le service MariaDB et vérifions son statut

```
sudo systemctl enable --now mariadb
```

```
sudo systemctl status mariadb
```

Sous **Rocky linux**, autorisons le port 3306

```
sudo firewall-cmd --permanent --add-port=3306/tcp
```

```
sudo firewall-cmd --reload
```

- Configurons les paramètres initiaux pour MariaDB

```
sudo mariadb-secure-installation
```

```
Enter current password for root (enter for none): (aucun mot de passe pour la première fois)
Switch to unix_socket authentication [Y/n]: n
Change the root password? [Y/n]: y (test@test2024)
Remove anonymous users? [Y/n]: y
Disallow root login remotely? [Y/n]: y
Remove test database and access to it? [Y/n]: y
Reload privilege tables now? [Y/n]: y
```

Testons notre configuration

```
mariadb -u root -p
```

Notre mot de passe ici est : **test@test2024**.

Depuis l'invite de Mariadb, nous pouvons saisir les commandes

```
show grants for root@localhost;
```

```
show databases;
```

Depuis l'invite de Mariadb, créons une base de données **testdb**

```
create database testdb;
```

```
show databases;
```

Depuis l'invite de Mariadb, connectons à la base de données **testdb**

```
use testdb;
```

Depuis l'invite de Mariadb connecté à la base de données **testdb**, affichons les tables

```
show tables;
```

Pour quitter l'invite de Mariadb

```
exit;
```