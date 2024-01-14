# Bac à sable

Pour mettre en place notre bac à sable, nous utiliserons vagrant avec virtualbox 6.1.34. Nous allons mettre en place notre architecture avec 2 serveurs Zabbix et 1 serveur de base de données Mariadb via le fichier **Vagrantfile** suivant :

```
vim Vagrantfile
```

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vbguest.auto_update = false
  config.vbguest.no_remote = true
  config.vbguest.iso_path = "./VBoxGuestAdditions_6.1.38.iso"

  # General Vagrant VM configuration.
  config.vm.box = "geerlingguy/rockylinux8"
  config.vm.box_version = "1.0.1"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
    v.linked_clone = true
  end

  # Serveur zabbix 1.
  config.vm.define "srv-lab1" do |srv1|
    srv1.vm.hostname = "srv-lab1"
    srv1.vm.network :private_network, ip: "192.168.56.37"
  end

  # Serveur zabbix 2. 
  config.vm.define "srv-lab2" do |srv2|
    srv2.vm.hostname = "srv-lab2"
    srv2.vm.network :private_network, ip: "192.168.56.34"
  end

  # Database Mariadb.
  config.vm.define "srv-db-lab" do |db|
    db.vm.hostname = "srv-db-lab"
    db.vm.network :private_network, ip: "192.168.56.35"
  end
end
```

```
vagrant up
```

Si tout se passe bien, nous aurons nos 3 machines virtuelles installées.
<br>
NB: Nous utilisons la version 1.34 de virtualbox, c'est pourquoi il faudrait télécharger l'iso **VBoxGuestAdditions_6.1.38.iso**.