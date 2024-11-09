# Sandbox

Nous allons mettre en place 3 serveurs **Rocky 8.10** avec **vagrant** couplé à **virtualbox 7.0** depuis une machine hôte **ubuntu 22.04** :

- un serveur **server-storage** pour la mise en place des composants **MinIO s3** et **Redis**
- un serveur **server-monitoring** pour la mise en place des composants : **otelcollector**, **grafana**, **prometheus**, **tempo**, **loki**, **alertmanager**
- un serveur **server-app** où sera herbégé une application web opensource faite en nodejs pour le backend, en reactjs pour le frontend

```
mkdir $HOME/opentelemetry && cd $HOME/opentelemetry
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
  config.vm.provider :virtualbox do |v|
    v.memory = 4096
    v.cpus = 2
    v.linked_clone = true
  end
  
  # server-storage
  config.vm.define "server-storage" do |srv|
    srv.vm.box = "willbrid/rockylinux8"
    srv.vm.box_version = "0.0.3"
    srv.vm.hostname = "server-storage"
    srv.vm.network :private_network, ip: "192.168.56.20"
  end

  # server-monitoring
  config.vm.define "server-monitoring" do |srv|
    srv.vm.box = "willbrid/rockylinux8"
    srv.vm.box_version = "0.0.3"
    srv.vm.hostname = "server-monitoring"
    srv.vm.network :private_network, ip: "192.168.56.21"
  end

  # server-app
  config.vm.define "server-app" do |srv|
    srv.vm.box = "willbrid/rockylinux8"
    srv.vm.box_version = "0.0.3"
    srv.vm.hostname = "server-app"
    srv.vm.network :private_network, ip: "192.168.56.22"
  end
end
```

```
vagrant up
```