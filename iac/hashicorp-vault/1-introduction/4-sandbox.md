# Sandbox de l'architecture

Supposons que nous souhaiterons mettre en place une simple architecture d'intégration de **vault** où nous avons 3 serveurs :
- un serveur **Rocky 8.10** où sera installé et configuré : **vault**, **consul**
- deux serveurs client de vault :  **Rocky 8.10** et **Ubuntu 22.04**

Nous configurerons une pki du wildcard domain : **\*.willbrid.com** .

Nous utiliserons **vagrant** avec **virtualbox 7.0** depuis une machine hôte **ubuntu 22.04**. Nous suivons les étapes ci-dessous pour provisionner nos 3 serveurs.

```
cd ~ && mkdir -p vault-sandbox
```

```
cd vault-sandbox
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

$script = <<-SCRIPT
if ! grep -q "vault.willbrid.com" /etc/hosts; then
  echo -e "192.168.56.70\tvault.willbrid.com" >> /etc/hosts
fi
SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vbguest.auto_update = false
  config.vbguest.no_remote = true
  config.vbguest.iso_path = "./VBoxGuestAdditions_7.0.20.iso"

  # General Vagrant VM configuration.
  config.vm.box = "willbrid/rockylinux8"
  config.vm.box_version = "0.0.3"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
    v.linked_clone = true
  end

  # Serveur vault-server.
  config.vm.define "vault-server" do |vs|
    vs.vm.hostname = "vault-server"
    vs.vm.network :private_network, ip: "192.168.56.70"
    vs.trigger.after :up do |trigger|
      trigger.run_remote = { inline: $script, privileged: true }
    end
  end

  # Serveur ubuntu-server. 
  config.vm.define "ubuntu-server" do |us|
    us.vm.box = "bento/ubuntu-22.04"
    us.vm.box_version = "202407.23.0"
    us.vm.hostname = "ubuntu-server"
    us.vm.network :private_network, ip: "192.168.56.71"
    us.trigger.after :up do |trigger|
      trigger.run_remote = { inline: $script, privileged: true }
    end
  end

  # Serveur rocky-server.
  config.vm.define "rocky-server" do |rs|
    rs.vm.hostname = "rocky-server"
    rs.vm.network :private_network, ip: "192.168.56.72"
    rs.trigger.after :up do |trigger|
      trigger.run_remote = { inline: $script, privileged: true }
    end
  end
end
```

```
vagrant up
```