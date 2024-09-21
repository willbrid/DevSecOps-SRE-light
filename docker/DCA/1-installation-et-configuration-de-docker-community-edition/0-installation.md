# Installation multiplatforme sur Ubuntu server 22.04

### Installation du bac à sable

Nous utiliserons **vagrant** avec **virtualbox 7.0** depuis une machine hôte **Ubuntu desktop 22.04**. Nous suivons les étapes ci-dessous pour provisionner notre serveur qui contiendra notre installation **docker**.

```
cd ~ && mkdir ubuntu-docker
```

```
cd ubuntu-docker
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
  config.vbguest.iso_path = "./VBoxGuestAdditions_7.0.12.iso"

  # General Vagrant VM configuration.
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_version = "202407.23.0"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider :virtualbox do |v|
    v.memory = 4096
    v.cpus = 2
    v.linked_clone = true
  end

  # Serveur Ubuntu 20.04.
  config.vm.define "srv-ubuntu-docker" do |srv|
    srv.vm.hostname = "srv-ubuntu-docker"
    srv.vm.network :private_network, ip: "192.168.56.250"
  end
end
```

```
vagrant up
```

### Installation multiplatforme de docker

**Télécharger le script sh**

```
curl -fsSL https://get.docker.com -o get-docker.sh
```

**Exécuter le script**
```
sudo sh get-docker.sh
```

**Ajouter un utilisateur au groupe docker**

Pour accorder à un utilisateur l'autorisation d'exécuter des commandes Docker, ajoutez l'utilisateur au groupe Docker. L'utilisateur aura accès à Docker après sa prochaine connexion.

```
sudo usermod -a -G docker $USER
```

**Démarrer et activer le service Docker**

```
sudo systemctl start docker
sudo systemctl enable docker
```

**Tester l'installation de docker**

Nous pouvons tester notre installation Docker en exécutant un simple conteneur.

```
docker run hello-world
```

**Références**:
- [docker-engine-install](https://docs.docker.com/engine/install/)
- [docker-doc-install](https://docs.docker.com/engine/install/centos/)