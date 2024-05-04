# Installation spécifique et multiplatforme depuis Ubuntu 20.04

### Installation du bac à sable

Nous utiliserons **vagrant** avec **virtualbox 7.0** depuis une machine hôte **ubuntu 20.04**. Nous suivons les étapes ci-dessous pour provisionner notre serveur qui contiendra notre installation **docker**.

```
cd ~ && mkdir ubuntu-docker
```

```
cd ubuntu-docker
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
  config.vm.box = "geerlingguy/ubuntu2004"
  config.vm.box_version = "1.0.4"
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

### Installation de docker sur Ubuntu 20.04

**Installer les packages requis**

```
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```

**Ajoutez la clé GNU Privacy Guard (GPG) du référentiel Docker et vérifier l'empreinte digitale**

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
```

NB: C'est une bonne idée de vérifier l'empreinte digitale de la clé. Il s'agit d'une étape facultative, mais fortement recommandée. Nous devrions recevoir une sortie indiquant que la clé a été trouvée.

**Ajouter le référentiel Docker Ubuntu**

```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

**Installer les packages Docker CE**

```
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

**Ajouter un utilisateur au groupe docker**

Pour accorder à un utilisateur l'autorisation d'exécuter des commandes Docker, ajoutez l'utilisateur au groupe Docker. L'utilisateur aura accès à Docker après sa prochaine connexion.

```
sudo usermod -a -G docker <user>
```

**Tester l'installation de docker**

Nous pouvons tester notre installation Docker en exécutant un simple conteneur.

```
docker run hello-world
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
sudo usermod -a -G docker <user>
```

**Démarrer et activer le service Docker**

```
sudo systemctl start docker
sudo systemctl enable docker
```


**Références**:
- [docker-engine-install](https://docs.docker.com/engine/install/)
- [docker-doc-install](https://docs.docker.com/engine/install/centos/)