# Mise en place d'une sandbox

Nous utiliserons **vagrant** avec **virtualbox 7.0** depuis une machine hôte **ubuntu 20.04**. Nous suivons les étapes ci-dessous pour provisionner notre serveur qui contiendra notre service **grafana**.

```
cd ~ && mkdir grafana
```

```
cd grafana
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

  # Serveur Grafana.
  config.vm.define "srv-grafana" do |gr|
    gr.vm.hostname = "srv-grafana"
    gr.vm.network :private_network, ip: "192.168.56.240"
  end
end
```

```
vagrant up
```