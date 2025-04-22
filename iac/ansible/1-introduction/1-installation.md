# Installation d'ansible sur ubuntu 24.04 et sur rocky linux 8.10

Les packages communautaires d'Ansible sont distribués de deux manières : un package de langage et d'exécution minimaliste appelé **ansible-core**, et un package "batteries included" beaucoup plus grand appelé **ansible**, qui ajoute une sélection de collections Ansible organisée par la communauté pour automatiser une grande variété de périphériques.

### Installer Python3 avec certaines dépendances nécessaires

Nous installerons ansible avec **python version 3**. Nous devons installer **python3** avec les packages de dépendances supplémentaires.

Sous ubuntu
```
sudo apt install -y python3 python3-pip libssl-dev
```

Sous Rocky
```
sudo dnf install -y gcc python3 python3-pip python3-devel openssl-devel python3-libselinux
```

### Installer ansible avec pipx sous ubuntu 24.04 ou rocky linux 8.10

- Installation de **pipx**

Sous ubuntu
```
sudo apt install pipx
```

Sous Rocky
```
sudo dnf install pipx
```

- Installation du **package complet ansible**

```
pipx install --include-deps ansible
```

```
pipx inject ansible argcomplete
```

- Installation du package ansible-core version **2.18.4** (ce qui sera utilisé)

```
pipx install ansible-core==2.18.4
```

```
pipx inject ansible-core argcomplete
```

**Sources** :
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)
- [Pipx](https://pipx.pypa.io/stable/)
- [Release_and_maintenance](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html)