# Installation de notre bac-à-sable

Nous pouvons utiliser des conteneurs Podman pour explorer nos concepts d'équilibrage de charge en utilisant un seul hôte avec notre OS rocky linux 8.

Nous utiliserons **vagrant** et **virtualbox** pour provisionner notre serveur avec la box vagrant **rockylinux/9** version **5.0.0**.

- installons nos deux machines virtuelles **client** (haproxy-client -> 192.168.56.7) et **server** (haproxy-server -> 192.168.56.8) grâce à notre fichier vagrantfile

```
mkdir -p $HOME/haproxy-test && cd $HOME/haproxy-test
```

```
wget https://download.virtualbox.org/virtualbox/7.0.24/VBoxGuestAdditions_7.0.24.iso
```

```
vi Vagrantfile
```

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vbguest.auto_update = false
  config.vbguest.no_remote = true
  config.vbguest.iso_path = "./VBoxGuestAdditions_7.0.24.iso"
  
  # General Vagrant VM configuration.
  config.vm.box = "rockylinux/9"
  config.vm.box_version = "5.0.0"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.linked_clone = true
  end

  # Application client.
  config.vm.define "client" do |app|
    app.vm.hostname = "haproxy-client"
    app.vm.network :private_network, ip: "192.168.56.7"
  end

  # Application client1.
  config.vm.define "client1" do |app|
    app.vm.hostname = "haproxy-client1"
    app.vm.network :private_network, ip: "192.168.56.9"
  end

  # Application server. 
  config.vm.define "server" do |app|
    app.vm.hostname = "haproxy-server"
    app.vm.network :private_network, ip: "192.168.56.8"
  end
end
```

```
vagrant up
```

NB: Nos deux machines virtuelles ont pour login **vagrant** et mot de passe : **vagrant** . Nous les utiliserons pour nous connecter par ssh.

- Installons Podman via le package **container-tools** sur notre serveur **haproxy-server**
```
ssh vagrant@192.168.56.8
```

```
sudo yum -y module install container-tools
```

- Installons le package **figlet** pour créer les bannières textuelles

```
sudo yum -y install epel-release
```

```
sudo yum -y install figlet
```

- Créeons nos sites de test

Nous allons avoir besoin de fichiers de test pour nos conteneurs de serveur Web. Nous allons utiliser 6 conteneurs en 2 groupes de 3. Nous allons utiliser la commande **figlet** pour pimenter un peu nos fichiers texte !

```
mkdir -p ~/testfiles
```

```
vi ~/createServerFiles.sh
```

```
#!/bin/bash

for site in `seq 1 2` 
do 
  for server in `seq 1 3`
  do 
    figlet -f big SITE$site - WEB$server > ~/testfiles/site$site\_server$server.txt  
  done 
done
```

```
chmod +x createServerFiles.sh
./createServerFiles.sh
```

Nous pouvons vérifier nos fichiers :
```
ls -la ~/testfiles/*
```

Cela nous donnera en affichage :
```
site1_server1.txt  site1_server3.txt  site2_server2.txt
site1_server2.txt  site2_server1.txt  site2_server3.txt
```

- Démarrons nos conteneurs de serveur Web

Nous allons démarrer un total de 6 conteneurs nginx en utilisant Podman, en simulant 2 sites, avec 3 serveurs web par site. Nos serveurs Web seront disponibles sur les ports 8081 à 8086 .

```
vi ~/loadServer.sh
```

```
#!/bin/bash

port=1; 

for site in `seq 1 2` 
do 
  for server in `seq 1 3`
  do 
    podman run -dt --name site$site\_server$server -p 808$(($port)):80 nginx 
    sudo firewall-cmd --permanent --add-port=808$(($port))/tcp
    port=$((port + 1)) 
  done 
done

sudo firewall-cmd --reload
```

```
chmod +x loadServer.sh
./loadServer.sh
```

Hébergeons nos fichiers précédemment créés dans nos conteneurs web
```
vi ~/hostServer.sh
```

```
#!/bin/bash

for site in `seq 1 2` 
do 
  for server in `seq 1 3`
  do 
    podman cp ~/testfiles/site$site\_server$server.txt site$site\_server$server:/usr/share/nginx/html/test.txt
  done 
done
```

```
chmod +x hostServer.sh
./hostServer.sh
```

- Testons nos serveurs web depuis notre machine client : haproxy-client

```
ssh vagrant@192.168.56.7
```

```
curl -S http://192.168.56.8:8081/test.txt
curl -S http://192.168.56.8:8082/test.txt
curl -S http://192.168.56.8:8083/test.txt
curl -S http://192.168.56.8:8084/test.txt
curl -S http://192.168.56.8:8085/test.txt
curl -S http://192.168.56.8:8086/test.txt
```