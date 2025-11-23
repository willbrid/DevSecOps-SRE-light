# Sandbox

Nous allons mettre en place 4 serveurs **Rocky Linux 9** avec **vagrant** couplé à **virtualbox 7.0** depuis une machine hôte **ubuntu 24.04**.

- un serveur **broker** : contenant les conteneurs **kafka controller**, les conteneurs **kafka broker** avec un conteneur **haproxy** pour exposer les endpoints **kafka broker**
- un serveur **monitoring** : contenant les conteneurs **grafana**, **prometheus**, **tempo**, **loki**, **opentelemetry collector** et **easy_api_prom_sms_alert**
- un serveur **serverapp** : contenant un utilitaire client kafka utilisable en ligne de commande appelé : **kcat**

```
mkdir $HOME/homelab-kafka && cd $HOME/homelab-kafka
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
  config.vm.box_version = "6.0.0"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  SERVERS = [
    { hostname: "broker", ip: "192.168.56.209", vcpu: 2, mem: 2048 },
    { hostname: "monitoring", ip: "192.168.56.211", vcpu: 3, mem: 4096 },
    { hostname: "serverapp", ip: "192.168.56.212", vcpu: 1, mem: 1024 },
    { hostname: "serverauth", ip: "192.168.56.213", vcpu: 1, mem: 1024 },
    { hostname: "servertools", ip: "192.168.56.214", vcpu: 1, mem: 1024 }
  ]

  SERVERS.each do |server|
    config.vm.define server[:hostname] do |srv|
      srv.vm.hostname = server[:hostname]
      srv.vm.network :private_network, ip: server[:ip]
      srv.vm.provider :virtualbox do |v|
        v.cpus = server[:vcpu]
        v.memory = server[:mem]
      end
    end
  end
end
```

```
vagrant up
```