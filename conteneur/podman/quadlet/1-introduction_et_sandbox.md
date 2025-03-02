# Introduction et Sandbox

**Quadlet** est une fonctionnalité de Podman qui transforme des fichiers de configuration Podman simplifiés en unités de service **systemd**. 
Grâce à cette intégration, nous pouvons gérer nos conteneurs comme des services **systemd**, en bénéficiant de fonctionnalités avancées 
telles que le redémarrage automatique, la gestion des dépendances et les limites de ressources, le tout avec la puissance et la flexibilité 
de **systemd**.

### Environnement Quadlet

- **Quadlet** est embarqué dans **Podman** à partie de la version **>=4.4** de **Podman** et nécessite **cgroups v2**.
- Pour gérer les conteneurs en tant que root, les fichiers seront à placer dans : **/etc/containers/systemd**.
- Pour gérer les conteneurs en tant que non root, les fichiers seront à placer dans : **~/.config/containers/systemd**. C'est à dire à
partir de la racine d'un utilisateur non root.
- Les conteneurs en mode rootless nécessitent des mappages dans **/etc/subuid** et **/etc/subgid** avec un utilisateur non root.

```
echo "username:100000:65536" >> /etc/subuid
echo "username:100000:65536" >> /etc/subgid
```

Ces deux commandes doivent être exécutées en tant que root, après avoir remplacé **username** par le nom de votre utilisateur non root.

- Pour le mode non root, il faudrait permettre aux services de continuer à s'exécuter après la déconnexion de votre utilisateur non root.

```
sudo loginctl enable-linger username
```

où **username** représente un utilisateur non-root chargé de lancer les conteneurs Podman.

### Sandbox

```
mkdir $HOME/quadlet-sandbox && cd $HOME/quadlet-sandbox
```

```
wget https://download.virtualbox.org/virtualbox/7.0.20/VBoxGuestAdditions_7.0.20.iso
```

```
vim Vagrantfile
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
    v.memory = 2048
    v.cpus = 2
    v.linked_clone = true
  end
  
  # Rocky Server
  config.vm.define "rocky-server" do |srv|
    srv.vm.box = "generic/rocky9"
    srv.vm.box_version = "4.3.12"
    srv.vm.hostname = "rocky-server"
    srv.vm.network :private_network, ip: "192.168.56.9"
  end
end  
```

```
vagrant up
```

**NB:** Vous pouvez utiliser le rôle [ansible-role-podman-installer](https://github.com/willbrid/ansible-role-podman-installer/tree/main) pour installer **podman** et préparer l'environnement d'exécution de conteneur en mode rootless via l'utilisateur **vagrant**.

### Références

- [podman-systemd.unit](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)