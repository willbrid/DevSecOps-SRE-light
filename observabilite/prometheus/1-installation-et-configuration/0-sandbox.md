# Mise en place de la sandbox

Nous allons mettre en place deux serveurs **Redhat 9** avec **vagrant** couplé à **virtualbox 7.0** depuis une machine hôte **ubuntu 24.04**.

```
mkdir $HOME/homelab-prometheus && cd $HOME/homelab-prometheus
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
  config.vbguest.iso_path = "./VBoxGuestAdditions_7.0.20.iso"

  # General Vagrant VM configuration.
  config.vm.box = "rockylinux/9"
  config.vm.box_version = "6.0.0"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  SERVERS = [
    { hostname: "monitoring", ip: "192.168.56.230", vcpu: 2, mem: 2048 },
    { hostname: "server1", ip: "192.168.56.231", vcpu: 1, mem: 1024 },
    { hostname: "server2", ip: "192.168.56.232", vcpu: 1, mem: 1024 }
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