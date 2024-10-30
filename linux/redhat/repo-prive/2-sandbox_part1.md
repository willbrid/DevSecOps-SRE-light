# Sandbox [Part1]

Nous allons mettre en place deux serveurs **Redhat 8.9** avec **vagrant** couplé à **virtualbox 7.0** depuis une machine hôte **ubuntu 22.04** :
- un serveur **rhel-repo-server** pour la mise en place du repo privé
- un serveur **rhel-server** pour consommer ce repo privé

En guise d'exemple, nous configurerons le repo privé des packages de kubernetes (**kubeadm**, **kubectl**, **kubelet**) et du gestionnaire de conteneur **cri-o**. Puis nous installerons ces packages depuis notre serveur **rhel-server** utilisant le repo local configuré sur le serveur **rhel-repo-server**.

```
cd ~ && mkdir private-redhat-repo
```

```
cd private-redhat-repo
```

```
wget https://download.virtualbox.org/virtualbox/7.0.20/VBoxGuestAdditions_7.0.20.iso
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
  config.vbguest.iso_path = "./VBoxGuestAdditions_7.0.20.iso"

  # General Vagrant VM configuration
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.box = "generic/rhel8"
  config.vm.box_version = "4.3.12"
  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
    v.linked_clone = true
  end
  
  # Rocky Server
  config.vm.define "rhel-server" do |srv|
    srv.vm.hostname = "rhel-server"
    srv.vm.network :private_network, ip: "192.168.56.120"
  end

  # Repo Server
  config.vm.define "rhel-repo-server" do |srv|
    srv.vm.hostname = "rhel-repo-server"
    srv.vm.network :private_network, ip: "192.168.56.121"
  end
end
```

```
vagrant up
```