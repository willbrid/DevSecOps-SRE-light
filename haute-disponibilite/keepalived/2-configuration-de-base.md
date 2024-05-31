# Configuration de base

Nous supposerons cette topologie via notre fichier **Vagrantfile** :

```
mkdir $HOME/actif-passif-with-keepalived && cd $HOME/actif-passif-with-keepalived
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
    v.memory = 1024
    v.linked_clone = true
  end

  # Server 1.
  config.vm.define "srv1" do |app|
    app.vm.hostname = "srv1-test"
    app.vm.network :private_network, ip: "192.168.56.4"
  end

  # Server 2. 
  config.vm.define "srv2" do |app|
    app.vm.hostname = "srv2-test"
    app.vm.network :private_network, ip: "192.168.56.5"
  end
end
```

```
vagrant up
```

Deux serveurs : srv1 -> 192.168.56.4 et srv2 -> 192.168.56.5

- Installation de keepalived **2.3.1** sur chaque serveur

```
sudo yum install -y gcc openssl-devel libnl3-devel
```

```
wget https://www.keepalived.org/software/keepalived-2.3.1.tar.gz
```

```
tar -xvf keepalived-2.3.1.tar.gz
```

```
cd keepalived-2.3.1
```

```
sudo ./configure
```

```
sudo make
```

```
sudo make install
```

Pour vérifier notre installation, nous exécutons la commande :
```
keepalived --version
```

La communication VRRP entre les routeurs utilise l'adresse IP multidiffusion **224.0.0.18** ([rfc5798#section-5.1.1.2](https://www.rfc-editor.org/rfc/rfc5798#section-5.1.1.2)) et le numéro de protocole IP 112 ([rfc5798#section-5.1.1.4](https://www.rfc-editor.org/rfc/rfc5798#section-5.1.1.4)), nous devons autoriser cette communication sur chaque serveur.

```
sudo firewall-cmd --direct --permanent --add-rule ipv4 filter INPUT 0 --in-interface enp0s8 --destination 224.0.0.18 --protocol vrrp -j ACCEPT
```

```
sudo firewall-cmd --direct --permanent --add-rule ipv4 filter OUTPUT 0 --out-interface enp0s8 --destination 224.0.0.18 --protocol vrrp -j ACCEPT
```

```
sudo firewall-cmd --reload
```

**enp0s8** est notre interface principale de mise en réseau sur nos deux serveurs.

- Configuration du serveur master srv1 -> 192.168.56.4

```
sudo mkdir -p /etc/keepalived
cd /etc/keepalived
```

```
sudo vi keepalived.conf
```

```
vrrp_instance VI_1 {
    state MASTER
    interface enp0s8
    virtual_router_id 52
    priority 150
    advert_int 1
    unicast_src_ip 192.168.56.4 # adresse IP de la master
    unicast_peer {
        192.168.56.5 # adresse IP du serveur secondaire
    }
    authentication {
        auth_type PASS
        auth_pass 12345678
    }
    virtual_ipaddress {
        192.168.56.7/24
    }
}
```

```
sudo systemctl enable keepalived
sudo systemctl start keepalived
```

Nous vérifions le status du service keepalived :
```
sudo systemctl status keepalived
```

- Configuration du serveur secondaire srv2 -> 192.168.56.5

```
sudo mkdir -p /etc/keepalived
cd /etc/keepalived
```

```
sudo vi keepalived.conf
```

```
vrrp_instance VI_1 {
    state BACKUP
    interface enp0s8
    virtual_router_id 52
    priority 100
    advert_int 1
    unicast_src_ip 192.168.56.5 # adresse IP du serveur secondaire 
    unicast_peer {
        192.168.56.4 # adresse IP de la master
    }
    authentication {
        auth_type PASS
        auth_pass 12345678
    }
    virtual_ipaddress {
        192.168.56.7/24
    }
}
```

```
sudo systemctl enable keepalived
sudo systemctl start keepalived
```

Nous vérifions le status du service keepalived :
```
sudo systemctl status keepalived
```

- Vérification du serveur qui porte le trafic actuel

Pour vérifier le serveur qui porte le trafic actuel, nous exécutons sur chaque serveur la commande :

```
ip addr show | grep enp0s8
```

Nous constaterons que l'un des résultats de cette commande sur chacun des serveurs affichera l'adresse IP virtuel : **192.168.56.7/24**.

- Surveillance du trafic VRRP

Les captures de paquets de ligne de commande à l'aide de **tcpdump** peuvent révéler tout ce que nous devons savoir sur notre configuration VRRP, y compris le VRID et la priorité du maître actif :

```
sudo yum install tcpdump -y
```

```
sudo tcpdump proto 112 -i enp0s8
```