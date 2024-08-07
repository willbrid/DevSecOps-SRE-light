# Configurer la mise en réseau et la résolution du nom d'hôte de manière statique ou dynamique

En tant qu'administrateur Linux, nous devons être capable de gérer manuellement la configuration réseau de nos systèmes afin de maintenir les serveurs en ligne et accessibles à tout moment.

Les systèmes Linux partagent désormais des réseaux avec les systèmes Windows, les systèmes macOS et les appareils matériels, mais doivent désormais également faire face aux appareils mobiles (tablettes et téléphones) ainsi qu'aux appareils intelligents. Linux doit être aussi flexible que possible, nous devons donc être capable de prendre en charge les adresses IP dynamiques et statiques ainsi que la résolution DNS.

### Distributions anciennes

- Les configurations d'interface étaient stockées sous forme de fichiers texte, généralement situés dans le répertoire **/etc/network**.
- Les interfaces pouvaient se trouver dans le fichier **/etc/network/interfaces** ou individuellement dans le sous-répertoire **/etc/network/interfaces.d/**.

Exemple avec le système ubuntu 16.04

Afficher les détails sur les interfaces réseau

```
ifconfig
```

Fichier de configuration globale des interfaces

```
cat /etc/network/interfaces
```

```
auto lo
iface lo inet loopback

source /etc/network/interfaces.d/*.cfg
```

Fichier de configuration spécifique pour une interface

```
cat /etc/network/interfaces.d/50-cloud-init.cfg
```

```
# Dynamic
auto lo
iface lo inet loopback

auto ens5
iface ens5 inet dhcp
iface ens5 inet6 dhcp

# Static
auto lo
iface lo inet loopback

auto ens5
iface ens5 inet static
address 192.168.56.120
netmask 255.255.255.0
gateway 192.168.56.1
dns-search local.la
dns-nameservers 8.8.8.8 8.8.4.4

iface ens5 inet6 dhcp
```

### Distributions Récentes

- **Sous Ubuntu 20.04**

Afficher les détails sur les interfaces réseau

```
ip addr show
```

Afficher le contenu du repertoire **/etc/netplan**

```
ls -alh /etc/netplan
```

```
total 16K
drwxr-xr-x  2 root root 4.0K Oct 31 06:22 .
drwxr-xr-x 82 root root 4.0K Oct 31 06:22 ..
-rw-r--r--  1 root root  195 Feb 12  2022 01-netcfg.yaml
-rw-r--r--  1 root root  115 Oct 31 06:22 50-vagrant.yaml
```

Afficher les configurations statiques (interface **enp0s8**) réseau créées par vagrant

```
cat /etc/netplan/50-vagrant.yaml
```

```
---
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      addresses:
      - 192.168.56.111/24
```

Afficher les configurations dynamiques (interface **enp0s3**) réseau créées par vagrant

```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: yes
```

L'on peut ajuster la configuration statique (interface **enp0s8**) de la manière suivante

```
---
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      dhcp4: no
      addresses:
      - 192.168.56.111/24
      gateway: 10.0.2.2 # passerelle par défaut via la deuxième interface
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
      dhcp6: yes  
      set-name: enp0s8 # configuration du nom de l'interface 
```

Après configuration, l'on peut redemarrer en toute sécurité l'interface configurée

```
sudo ip link set enp0s8 down && sudo ip link set enp0s8 up
```

- **Sous Rocky Linux 8**

Afficher les détails sur les interfaces réseau

```
ip addr show
```

Afficher le contenu du repertoire **/etc/sysconfig/network-scripts**

```
ls -alh /etc/sysconfig/network-scripts
```

```
total 12K
drwxr-xr-x. 2 root    root      46 Oct 31 06:22 .
drwxr-xr-x. 5 root    root    4.0K Oct 14 10:28 ..
-rw-r--r--. 1 root    root     248 Oct 14 10:28 ifcfg-enp0s3
-rw-------. 1 vagrant vagrant  217 Oct 31 06:22 ifcfg-enp0s8
```

Afficher les configurations statiques (interface **enp0s8**) réseau créées par vagrant

```
cat /etc/sysconfig/network-scripts/ifcfg-enp0s8
```

```
NM_CONTROLLED=yes
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.56.110
NETMASK=255.255.255.0
DEVICE=enp0s8
PEERDNS=no
```

L'on peut aussi ajuster la configuration statique (interface **enp0s8**) de la manière suivante

```
NM_CONTROLLED=yes
BOOTPROTO=none
ONBOOT=yes
TYPE=Ethernet
IPV6INIT=yes
IPADDR=192.168.56.110
PREFIX=24
GATEWAY=10.0.2.2 # passerelle par défaut via la deuxième interface
DEVICE=enp0s8
DNS1=8.8.8.8
DNS2=8.8.4.4
```

Après configuration, l'on peut redemarrer en toute sécurité l'interface configurée

```
sudo ip link set enp0s8 down && sudo ip link set enp0s8 up
```

Afficher les configurations dynamiques (interface **enp0s3**) réseau créées par vagrant

```
cat /etc/sysconfig/network-scripts/ifcfg-enp0s3
```

```
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=enp0s3
UUID=44acfdc2-0001-419f-9cc6-3c1a70302e36
DEVICE=enp0s3
ONBOOT=yes
```