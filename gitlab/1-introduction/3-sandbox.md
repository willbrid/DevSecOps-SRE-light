# Sandbox de l'architecture

Supposons que nous souhaiterons mettre en place une architecture **ci/cd** avec **gitlab** où nous avons 4 serveurs :
- un serveur **gitlab** (domaine : **gitlab.willbrid.com**) intégrant un système de gestion de code source, un système de gestion des images et un composant ci/cd
- un serveur **gitlab-runner** (domaine : **gitlab-runner.willbrid.com**) constitué d'un composant **runner** permettant d'exécuter les jobs **ci/cd** et un composant **vault** permettant de gérer les informations sensibles
- un serveur **kubernetes** (domaine : **k8s.willbrid.com**) constitué d'un composant **kubernetes** permettant de faire de la gestion et de l'orchestration de conteneurs.
- un serveur **mail** (domaine : **mail.willbrid.com**)  intégrant un composant de messagerie

<p align="center">
<img src="../images/gitlab-devops.png" alt="gitlab-devops.png" width="620" height="520" />
</p>

Nous utiliserons **vagrant** avec **virtualbox 7.0** depuis une machine hôte **ubuntu 22.04**. Nous suivons les étapes ci-dessous pour provisionner nos 4 serveurs.


```
cd ~ && mkdir gitlab-devops
```

```
cd gitlab-devops
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
goVersion="1.22.7"
gotestsumVersion="1.11.0"
goBinPath="/etc/profile.d/go_bin_path_setting.sh"
usrLocalBinPathSetting="/etc/profile.d/usr_local_bin_path_setting.sh"

mkdir -p /usr/local/bin

# Ajout dans le $PATH des repertoires d'installation des binaires Go et Gotestsum
if [[ ":$PATH:" != *":/usr/local/go/bin:"* ]]; then
  echo 'export PATH=$PATH:/usr/local/go/bin' > $goBinPath
  source $goBinPath
fi
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  echo 'export PATH=$PATH:/usr/local/bin' > $usrLocalBinPathSetting
  source $usrLocalBinPathSetting
fi

# Installation du binaire go
if ! command -v go &> /dev/null; then
  echo "Go is not installed, installation in progress..."
  wget -q https://go.dev/dl/go$goVersion.linux-amd64.tar.gz 2>&1
  tar -C /usr/local -xzf go$goVersion.linux-amd64.tar.gz
  rm -f go$goVersion.linux-amd64.tar.gz
fi

# Installation du binaire gotestsum
if ! command -v gotestsum &> /dev/null; then
  echo "Gotestsum is not installed, installation in progress..."
  GOTESTSUM_TMP="$(mktemp -dt gotestsum-installer-XXXXXXX)"
  wget -q -P $GOTESTSUM_TMP https://github.com/gotestyourself/gotestsum/releases/download/v$gotestsumVersion/gotestsum_$gotestsumVersion_linux_amd64.tar.gz
  tar Czxvf $GOTESTSUM_TMP $GOTESTSUM_TMP/gotestsum_$gotestsumVersion_linux_amd64.tar.gz
  mv $GOTESTSUM_TMP/gotestsum /usr/local/bin
  rm -rf $GOTESTSUM_TMP
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
    v.memory = 4096
    v.cpus = 2
    v.linked_clone = true
  end

  # Serveur gitlab.
  config.vm.define "gitlab" do |gt|
    gt.vm.hostname = "gitlab"
    gt.vm.network :private_network, ip: "192.168.56.170"
    gt.vm.provider :virtualbox do |v|
        v.memory = 7168
    end
  end

  # Serveur gitlab-runner. 
  config.vm.define "gitlab-runner" do |gtr|
    gtr.vm.hostname = "gitlab-runner"
    gtr.vm.network :private_network, ip: "192.168.56.171"
    gtr.trigger.after :up do |trigger|
      trigger.run_remote = { inline: $script, privileged: true }
    end
  end

  # Serveur kubernetes.
  config.vm.define "kubernetes" do |k8s|
    k8s.vm.hostname = "kubernetes"
    k8s.vm.network :private_network, ip: "192.168.56.172"
    k8s.vm.provider :virtualbox do |v|
        v.cpus = 3
    end
  end

  # Serveur mail.
  config.vm.define "mail" do |msg|
    msg.vm.hostname = "mail"
    msg.vm.network :private_network, ip: "192.168.56.173"
    msg.vm.provider :virtualbox do |v|
        v.cpus = 1
        v.memory = 2048
    end
  end
end
```

```
vagrant up
```