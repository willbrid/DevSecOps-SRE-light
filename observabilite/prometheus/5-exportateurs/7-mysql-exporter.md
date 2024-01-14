# Mise en place du mysql exporter dans prometheus

Nous mettons en place notre infra via vagrant sur virtualbox 6.1.34 avec deux serveurs de base de données (**srv-db1** et **srv-db2**) et un serveur prometheus (**srv-monitoring**). Tous les 3 serveurs ont un 1Go de mémoire.

```
vi Vagrantfile
```

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vbguest.installer_options = { running_kernel_modules: ["vboxguest"] }
  config.vbguest.auto_update = true
  # General Vagrant VM configuration.
  config.vm.box = "willbrid/rockylinux8"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.linked_clone = true
  end

  # DB server 1.
  config.vm.define "db1" do |app|
    app.vm.hostname = "srv-db1"
    app.vm.network :private_network, ip: "192.168.56.4"
  end

  # DB server 2. 
  config.vm.define "db2" do |app|
    app.vm.hostname = "srv-db2"
    app.vm.network :private_network, ip: "192.168.56.5"
  end

  # Prometheus server
  config.vm.define "monitoring" do |db|
    db.vm.hostname = "srv-monitoring"
    db.vm.network :private_network, ip: "192.168.56.7"
  end
end
```

```
vagrant up
```

Pour l'installation de prometheus dans notre serveur **srv-monitoring**, il faudrait suivre la démarche via la partie **1-installation-et-configuration** de ce même référentiel. 

## Installation de nos bases de données
Nous utiliserons une image docker **mariadb:10.5.17** de mariadb pour monter nos deux base de données. Pour cela nous nous connectons par ssh (avec pour mot de passe **vagrant**) sur chaque serveur de base de données (srv-db1 et srv-db2) pour lancer un conteneur mariadb .

- srv-db1

```
ssh vagrant@192.168.56.4
```

Nous installons notre gestionnaire de conteneur **podman**
```
sudo yum -y module install container-tools
```

Nous lançons notre conteneur nommé **srv-db1**
```
podman run -d --name srv-db1 -p 3306:3306 --env MARIADB_USER=cooldb1 --env MARIADB_PASSWORD=cool1234567db1 --env MARIADB_ROOT_PASSWORD=cool1234567db1 docker.io/library/mariadb:10.5.17
```

Nous exposons le port 3306 à l'extérieur
```
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

- srv-db2
```
ssh vagrant@192.168.56.5
```

Nous installons notre gestionnaire de conteneur **podman**
```
sudo yum -y module install container-tools
```

Nous lançons notre conteneur nommé **srv-db2**
```
podman run -d --name srv-db2 -p 3306:3306 --env MARIADB_USER=cooldb2 --env MARIADB_PASSWORD=cool1234567db2 --env MARIADB_ROOT_PASSWORD=cool1234567db2 docker.io/library/mariadb:10.5.17
```

Nous exposons le port 3306 à l'extérieur
```
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

## Installation et configuration de mysql exporter

- connectons nous à notre serveur **srv-monitoring** avec pour mot de passe **vagrant**

```
ssh vagrant@192.168.56.7
```

- créeons un utilisateur **mysqld_exporter** 
```
sudo useradd -M -r -s /bin/false mysqld_exporter
```

- téléchargeons et installons le binaire **mysqld_exporter** version 0.14

```
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.14.0/mysqld_exporter-0.14.0.linux-amd64.tar.gz
```


```
tar xvfz mysqld_exporter-0.14.0.linux-amd64.tar.gz
```

```
sudo mv mysqld_exporter-0.14.0.linux-amd64/mysqld_exporter /usr/local/bin/
```

```
sudo chown mysqld_exporter:mysqld_exporter /usr/local/bin/mysqld_exporter
```

- créeons un fichier de configuration *config.cnf*
```
sudo mkdir -p /etc/mysqld_exporter
```

```
sudo vi /etc/mysqld_exporter/config.cnf
```

```
[client]
user = cooldb1
password = cool1234567db1
host = 192.168.56.4
[client.srvdb1]
user = cooldb1
password = cool1234567db1
host = 192.168.56.4
[client.srvdb2]
user = cooldb2
password = cool1234567db2
host = 192.168.56.5
```

```
sudo chown -R mysqld_exporter:mysqld_exporter /etc/mysqld_exporter
```

Dans cette exemple, nous configurons les paramètres d'accès aux bases  de données **Mariadb-10.5** des serveurs **srv-db1** et **srv-db2** dans le fichier de configuration **config.cnf**. Les paramètres sous la section **client** sont les paramètres par défaut dont nous n'utiliserons pas.

- configurons un service systemd pour mysqld_exporter
```
sudo vi /etc/systemd/system/mysqld_exporter.service
```

```
[Unit]
Description=Mysqld Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=mysqld_exporter
Group=mysqld_exporter
Type=simple
ExecStart=/bin/sh -c '/usr/local/bin/mysqld_exporter --config.my-cnf=/etc/mysqld_exporter/config.cnf --collect.auto_increment.columns'

[Install]
WantedBy=multi-user.target
```

- activons et démarrons le service mysqld_exporter
```
sudo systemctl daemon-reload
sudo systemctl enable mysqld_exporter
sudo systemctl start mysqld_exporter
```

- Assurons-nous que le service mysqld_exporter fonctionne
```
sudo systemctl status mysqld_exporter
```

## Configuration de Prometheus pour utiliser mysqld_exporter

```
sudo vi /etc/prometheus/prometheus.yml
```

```
...
scrape_configs:
  ...
  - job_name: mysql 
    scrape_interval: 5s
    static_configs:
    - targets:
      - 192.168.56.4:3306?auth_module=client.srvdb1
      - 192.168.56.5:3306?auth_module=client.srvdb2
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9104
...
```

```
sudo systemctl restart prometheus
```

Le paramètre **replacement** permet de préciser l'adresse IP du serveur hébergeant le service **mysqld_exporter** : dans notre cas le même serveur où est installé **prometheus**.
<br>
Vérifions que Prometheus est en mesure d'atteindre mysqld_exporter et récupérer les kpi. Accédons à Prometheus dans un navigateur Web à l'adresse :
```
http://<IP_SERVEUR_PROMETHEUS>:9090.
```

Cliquons sur le menu **Graph**, entrons le mot clé **mysql_up** et vérifions que les résultats affichent **1**