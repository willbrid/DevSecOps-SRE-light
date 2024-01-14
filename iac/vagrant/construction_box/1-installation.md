# Installation vagrant 2.4

Dans ce tutoriel, nous allons construire notre propre vagrant box. De ce fait, nous devons télécharger et installer Vagrant, puis configurer un simple fichier **Vagrantfile** afin de tester notre installation.

## Installation de vagrant

```
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

```
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```
sudo apt update && sudo apt install vagrant
```

Enfin nous ajoutons le plugin vagrant-vbguest de vagrant

```
vagrant plugin install vagrant-vbguest
```

Nous pouvons ajouter une box vagrant pour rocky linux 8 :

```
vagrant box add willbrid/rockylinux8
```

Nous pouvons faire un test pour vérifier notre installation :

```
mkdir ~/ansible-test
cd ansible-test
```

```
vagrant init willbrid/rockylinux8
```

Un fichier Vagrantfile sera créé. Ensuite nous lançons notre vm contenant les configurations par défaut définies dans le fichier Vagrantfile :

```
vagrant up
```

**Sources**: 
- [Vagrant](https://www.vagrantup.com/downloads)