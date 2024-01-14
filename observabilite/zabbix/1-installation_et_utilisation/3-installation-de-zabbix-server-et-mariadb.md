# Installation de Zabbix-server et Mariadb

Connectons-nous par ssh à nos deux serveurs : **srv-lab1** et **srv-db-lab**.

- Ajoutons le référentiel zabbix 6.2 à notre serveur **srv-lab1**

```
sudo su
rpm -Uvh https://repo.zabbix.com/zabbix/6.2/rhel/8/x86_64/zabbix-release-6.2-3.el8.noarch.rpm
dnf clean all
```

- Ajoutons le référentiel Mariadb (version <= **10.10.xx** pour garantir la compatibilité) à notre serveur **srv-db-lab**

```
sudo su
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup
./mariadb_repo_setup --mariadb-server-version="mariadb-10.10.3"
```

- installons le service Mariadb sur notre serveur **srv-db-lab**

```
dnf install mariadb-server
systemctl enable mariadb
systemctl start mariadb
```

- Après avoir installé MariaDB, nous devons sécuriser notre installation avec la commande suivante

```
/usr/bin/mariadb-secure-installation
```

Nous devons répondre aux questions par oui ( Y ) et configurer un mot de passe root sécurisé. Nous devons exécuter la configuration de l'installation sécurisée et nous assurer d'enregistrer notre mot de passe quelque part. <br>
Il est fortement recommandé d'utiliser un mot de passe **vault**. Notre mot de passe root configuré est **strongstrong**.

- Installons Zabbix server avec prise en charge de Mariadb sur notre serveur **srv-lab1**

```
dnf install zabbix-server-mysql zabbix-sql-scripts
```

- Une fois le serveur Zabbix installé, nous sommes prêts à créer notre base de données Zabbix sur notre serveur **srv-db-lab** <br>
--- connectons-nous à MariaDB <br>

```
mysql -u root -p
```

--- créons la base de données monitoring de zabbix et ses crédentials (user : **zabbix** et password : **strongpassword**) de connexion à sa base de données

```
create database monitoring character set utf8mb4 collate utf8mb4_bin;
create user zabbix@'%' identified by 'strongpassword';
grant all privileges on monitoring.* to zabbix@'%' identified by 'strongpassword';
flush privileges;
quit
```

--- nous devons maintenant importer notre schéma de base de données Zabbix dans notre nouvelle base de données Zabbix. <br>
----- depuis notre serveur **srv-db-lab**, nous copions le fichier **server.sql.gz** sur le serveur **srv-lab1** :

```
scp vagrant@192.168.56.37:/usr/share/zabbix-sql-scripts/mysql/server.sql.gz .
```

----- nous importons notre schéma depuis notre serveur **srv-db-lab**

```
zcat server.sql.gz | mysql -u zabbix -p monitoring
```

Ici l'option **-p** permet de préciser le nom de la base de données **monitoring**. <br>

----- nous activons notre service parefeu **firewalld.service** sur notre serveur **srv-db-lab** 

```
systemctl enable firewalld.service
systemctl start firewalld.service
```

----- nous autorisons la communication sur le port 3306 via le parfeu de notre serveur **srv-db-lab**

```
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload
```

- Le serveur Zabbix est configuré à l'aide du fichier de configuration du serveur Zabbix. Ce fichier se trouve dans **/etc/zabbix/** . Configurons l'accès à notre base de données **monitoring** de zabbix sur notre serveur **srv-lab1**

```
vim /etc/zabbix/zabbix_server.conf
```

```
DBHost=192.168.56.35 # adresse IP du serveur srv-db-lab
DBPort=3306
DBName=monitoring
DBUser=zabbix
DBPassword=strongpassword
LogFileSize=100
```

Avec l'option **LogFileSize=100**, nous configurons la taille des fichiers de logs sur 100 MB. <br>

Nous sommes maintenant prêts à démarrer notre serveur Zabbix :

```
systemctl enable zabbix-server
systemctl start zabbix-server
```

Vérifions si tout démarre comme prévu avec ce qui suit :

```
systemctl status zabbix-server
```

Nous pouvons également surveiller le fichier journal, qui fournit une description détaillée du processus de démarrage de Zabbix :

```
tail -f /var/log/zabbix/zabbix_server.log
```