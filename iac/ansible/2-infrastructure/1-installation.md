# Construction de notre infrastructure avec Vagrant pour les tests

Nous allons gérer trois VM : deux serveurs d'applications et un serveur de base de données. Pour cela, nous allons utiliser vagrant pour mettre en place notre infrastructure de test.

- Créeons un nouveau dossier **ansible-test**
```
mkdir ~/ansible-test
cd ~/ansible-test
```

```
wget https://download.virtualbox.org/virtualbox/7.0.20/VBoxGuestAdditions_7.0.24.iso
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
  config.vbguest.iso_path = "./VBoxGuestAdditions_7.0.24.iso"
  
  # General Vagrant VM configuration.
  config.vm.box = "rockylinux/9"
  config.vm.box_version = "6.0.0"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 1024
    v.linked_clone = true
  end

  SERVERS = [
    { servername: "app1", hostname: "orc-app1.test", ip: "192.168.56.4" },
    { servername: "app2", hostname: "orc-app2.test", ip: "192.168.56.5" },
    { servername: "db", hostname: "orc-db.test", ip: "192.168.56.7" }
  ]

  SERVERS.each do |server|
    config.vm.define server[:servername] do |srv|
      srv.vm.hostname = server[:hostname]
      srv.vm.network :private_network, ip: server[:ip]
    end
  end
end
```

Ce fichier **Vagrantfile** définit les trois serveurs que nous voulons gérer et donne à chacun un nom d'hôte unique, un nom de machine (pour VirtualBox) et une adresse IP. Les 3 serveurs ont tous une RAM de 1024 Mo avec le système **Rocky Linux 9** provenant du vagrant box **rockylinux/9** .

- Entrons la commande permettant à Vagrant de construire les trois machines virtuelles.

```
vagrant up
```

Cette commande doit s'exécuter à la racine du repertoire **ansible-test** précédemment créé.