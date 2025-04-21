# Installation d'ansible sur ubuntu 24.04 et sur rocky linux 8.10

Les packages communautaires d'Ansible sont distribués de deux manières : un package de langage et d'exécution minimaliste appelé **ansible-core**, et un package "batteries included" beaucoup plus grand appelé **ansible**, qui ajoute une sélection de collections Ansible organisée par la communauté pour automatiser une grande variété de périphériques.

### Localiser Python

Nous installerons ansible avec **python version 3**. Ainsi il faudrait se rassurer que le package **python3** est bien installé à une version stable.

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

Injection du package **requests** nécessaire pour interroger la socket docker

```
pipx inject ansible-core requests
```

**Sources** :
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html)
- [Pipx](https://pipx.pypa.io/stable/)
- [Release_and_maintenance](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html)