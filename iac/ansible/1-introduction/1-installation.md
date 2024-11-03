# Installation d'ansible 2.9 sur ubuntu 22.04 et sur rocky linux 8.9

Les packages communautaires d'Ansible sont distribués de deux manières : un package de langage et d'exécution minimaliste appelé **ansible-core**, et un package "batteries included" beaucoup plus grand appelé **ansible**, qui ajoute une sélection de collections Ansible organisée par la communauté pour automatiser une grande variété de périphériques.

### Localiser Python

Nous installerons ansible avec **python version 3**. Ainsi il faudrait se rassurer que le package python3 est bien installé à une version stable : pour le cas actuel, nous considérons la version **3.9** .

### Installer ansible version spécifique

- **Sous Ubuntu 22.04**

Obtenons la version spécifique du package **ansible**

```
apt show ansible
```

Installons le package spécifique **ansible 2.10.7+merged+base+2.10.8+dfsg-1**

```
sudo apt install ansible=2.10.7+merged+base+2.10.8+dfsg-1
```

- **Sous Rocky linux 8.10**

Obtenons la version spécifique du package **ansible**

```
sudo yum install epel-release
```

```
dnf info ansible
dnf info ansible-core
```

Installons le package spécifique **ansible 9.2.0** relié à **ansible-core 2.16.3**

```
sudo yum install ansible-9.2.0
```

source : [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)