# Mise en place de notre sandbox avec vagrant

Nous mettons en place notre sandbox d'installation de kubernetes.
Via notre fichier **Vagrantfile**, nous allons installer 4 machines virtuelles virtualbox avec les caractéristiques suivantes :
- Master   -> host : k8s-control - Ram : 4096 - CPU : 2 - IP : 192.168.56.87
- Worker1  -> host : k8s-worker1 - Ram : 7168 - CPU : 2 - IP : 192.168.56.88
- Worker2  -> host : k8s-worker2 - Ram : 7168 - CPU : 2 - IP : 192.168.56.89
- Worker3  -> host : k8s-worker3 - Ram : 7168 - CPU : 2 - IP : 192.168.56.90

```
mkdir ~/kubernetes
cd ~/kubernetes
```

## Pour Ubuntu 22.04 (box : generic/ubuntu2204 version 4.3.12)

```
mkdir ~/kubernetes/ubuntu
cd ~/kubernetes/ubuntu
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

  # General Vagrant VM configuration.
  config.vm.box = "generic/ubuntu2204"
  config.vm.box_version = "4.3.12"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 4096
    v.cpus = 2
    v.linked_clone = true
  end

  # Master
  config.vm.define "k8s-control" do |srv|
    srv.vm.hostname = "k8s-control"
    srv.vm.network :private_network, ip: "192.168.56.87"
  end

  # Worker1
  config.vm.define "k8s-worker1" do |srv|
    srv.vm.hostname = "k8s-worker1"
    srv.vm.network :private_network, ip: "192.168.56.88"
    srv.vm.provider :virtualbox do |v|
        v.memory = 7168
    end
  end

  # Worker2
  config.vm.define "k8s-worker2" do |srv|
    srv.vm.hostname = "k8s-worker2"
    srv.vm.network :private_network, ip: "192.168.56.89"
    srv.vm.provider :virtualbox do |v|
        v.memory = 7168
    end
  end

  # Worker3
  config.vm.define "k8s-worker3" do |srv|
    srv.vm.hostname = "k8s-worker3"
    srv.vm.network :private_network, ip: "192.168.56.90"
    srv.vm.provider :virtualbox do |v|
        v.memory = 7168
    end
  end
end
```

```
vagrant up
```

## Pour Rocky linux 8 (box : willbrid/rockylinux8 version 0.0.2)

```
mkdir ~/kubernetes/rocky
cd ~/kubernetes/rocky
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

  # General Vagrant VM configuration.
  config.vm.box = "willbrid/rockylinux8"
  config.vm.box_version = "0.0.2"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 4096
    v.cpus = 2
    v.linked_clone = true
  end

  # Master
  config.vm.define "k8s-control" do |srv|
    srv.vm.hostname = "k8s-control"
    srv.vm.network :private_network, ip: "192.168.56.87"
  end

  # Worker1
  config.vm.define "k8s-worker1" do |srv|
    srv.vm.hostname = "k8s-worker1"
    srv.vm.network :private_network, ip: "192.168.56.88"
    srv.vm.provider :virtualbox do |v|
        v.memory = 7168
    end
  end

  # Worker2
  config.vm.define "k8s-worker2" do |srv|
    srv.vm.hostname = "k8s-worker2"
    srv.vm.network :private_network, ip: "192.168.56.89"
    srv.vm.provider :virtualbox do |v|
        v.memory = 7168
    end
  end

  # Worker3
  config.vm.define "k8s-worker3" do |srv|
    srv.vm.hostname = "k8s-worker3"
    srv.vm.network :private_network, ip: "192.168.56.90"
    srv.vm.provider :virtualbox do |v|
        v.memory = 7168
    end
  end
end
```

```
vagrant up
```