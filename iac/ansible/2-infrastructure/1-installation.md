# Construction de notre infrastructure avec Vagrant pour les tests

Nous allons gérer trois VM : deux serveurs d'applications et un serveur de base de données. Pour cela, nous allons utiliser vagrant pour mettre en place notre infrastructure de test.

- Créeons un nouveau dossier **ansible-test**
```
mkdir ~/ansible-test
cd ~/ansible-test
```

```
wget https://download.virtualbox.org/virtualbox/7.0.12/VBoxGuestAdditions_7.0.12.iso
```

- Créeons un fichier **Vagrantfile** et insérons le contenu de notre infrastructure

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
  config.vbguest.iso_path = "./VBoxGuestAdditions_7.0.12.iso"
  
  # General Vagrant VM configuration.
  config.vm.box = "willbrid/rockylinux8"
  config.vm.box_version = "0.0.2"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 512
    v.linked_clone = true
  end

  # Application server 1.
  config.vm.define "app1" do |app|
    app.vm.hostname = "orc-app1.test"
    app.vm.network :private_network, ip: "192.168.56.4"
  end

  # Application server 2. 
  config.vm.define "app2" do |app|
    app.vm.hostname = "orc-app2.test"
    app.vm.network :private_network, ip: "192.168.56.5"
  end

  # Database server.
  config.vm.define "db" do |db|
    db.vm.hostname = "orc-db.test"
    db.vm.network :private_network, ip: "192.168.56.7"
  end
end
```

Ce fichier **Vagrantfile** définit les trois serveurs que nous voulons gérer et donne à chacun un nom d'hôte unique, un nom de machine (pour VirtualBox) et une adresse IP. Les 3 serveurs ont tous une RAM de 512 Mo avec le système rockylinux8.6 provenant du vagrant box **willbrid/rockylinux8** .

- Entrons la commande permettant à Vagrant de construire les trois machines virtuelles.

```
vagrant up
```

Cette commande doit s'exécuter à la racine du repertoire **ansible-test** précédemment créé.