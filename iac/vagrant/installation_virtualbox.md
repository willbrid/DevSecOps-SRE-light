# Installation de virtual 7.2

Dans ce tutoriel, nous allons installer virtualbox version **7.2** sous **Ubuntu desktop 24.04**.

- Ajoutons la ligne suivante à notre **/etc/apt/sources.list**

```
sudo vi /etc/apt/sources.list
```

```
deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian noble contrib
```

- Ajoutons la clé publique Oracle de vérification des signatures :

```
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
```

- Installons virtualbox **7.2**

```
sudo apt-get update
sudo apt-get install virtualbox-7.2
```

- Installons VirtualBox Extension Pack

Assurons-nous de télécharger la version Extension Pack qui correspond à la version de VirtualBox **7.2** sur notre système Ubuntu. Pour connaître notre version de VirtualBox, exécutons cette commande :

```
vboxmanage -v | cut -dr -f1
```

Cette commande renverra le numéro de version dans un format similaire à **7.2.14**. Avec ces informations, nous pouvons procéder au téléchargement du pack d'extension approprié à l'aide de la commande

```
cd ~
```

```
wget https://download.virtualbox.org/virtualbox/7.2.14/Oracle_VirtualBox_Extension_Pack-7.2.14.vbox-extpack
```

Pour installer le pack d'extension que nous venons de télécharger, utilisons la commande **vboxmanage**

```
sudo vboxmanage extpack install --replace Oracle_VirtualBox_Extension_Pack-7.2.14.vbox-extpack
```

L'option **--replace** permet de remplacer l'installation existante.

Pour valider la version du Pack d'extension que nous avons installé, utilisons la commande suivante

```
sudo vboxmanage list extpacks
```

Pour utiliser VirtualBox, ajoutons notre compte utilisateur au groupe **vboxusers**

```
sudo usermod -a -G vboxusers $USER
```

Pour cette version virtualbox (version 7.2.14), nous pouvons utiliser **VBoxGuestAdditions 7.2.14**

```
wget https://download.virtualbox.org/virtualbox/7.2.14/VBoxGuestAdditions_7.2.14.iso
```

**Sources**: 
- [Virtualbox](https://www.virtualbox.org/wiki/Linux_Downloads)