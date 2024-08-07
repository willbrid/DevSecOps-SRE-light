# Bac à sable

Nous allons mettre en place notre bac à sable avec vagrant sous virtualbox 7.0 depuis une machine hôte **ubuntu 20.04**. Nous installerons les systèmes **Rocky Linux 8.9** et **Ubuntu 20.04**

```
mkdir $HOME/rocky-and-ubuntu && cd $HOME/rocky-and-ubuntu
```

```
wget https://download.virtualbox.org/virtualbox/7.0.12/VBoxGuestAdditions_7.0.12.iso
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
  config.vbguest.iso_path = "./VBoxGuestAdditions_7.0.12.iso"

  # General Vagrant VM configuration
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 4096
    v.cpus = 3
    v.linked_clone = true
  end
  
  # Rocky Server
  config.vm.define "rocky-server" do |srv|
    srv.vm.box = "willbrid/rockylinux8"
    srv.vm.box_version = "0.0.2"
    srv.vm.hostname = "rocky-server"
    srv.vm.network :private_network, ip: "192.168.56.110"
    srv.vm.disk :disk, name: "storage1", size: "5GB"
    srv.vm.disk :disk, name: "storage2", size: "5GB"
  end

  # Ubuntu Server
  config.vm.define "ubuntu-server" do |srv|
    srv.vm.box = "geerlingguy/ubuntu2004"
    srv.vm.box_version = "1.0.4"
    srv.vm.hostname = "ubuntu-server"
    srv.vm.network :private_network, ip: "192.168.56.111"
    srv.vm.disk :disk, name: "storage3", size: "5GB"
    srv.vm.disk :disk, name: "storage4", size: "5GB"
  end
end
```

```
vagrant up
```