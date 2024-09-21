# Installation de virtual 7.0

Dans ce tutoriel, nous allons installer virtualbox version **7.0** sous **Ubuntu desktop 22.04**.

- Ajoutons la ligne suivante à notre **/etc/apt/sources.list**

```
sudo vi /etc/apt/sources.list
```

```
deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian jammy contrib
```

- Ajoutons la clé publique Oracle de vérification des signatures :

```
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
```

- Installons virtualbox **7.0**

```
sudo apt-get update
sudo apt-get install virtualbox-7.0
```

- Installons VirtualBox Extension Pack

Assurons-nous de télécharger la version Extension Pack qui correspond à la version de VirtualBox 7.0 sur notre système Ubuntu. Pour connaître notre version de VirtualBox, exécutons cette commande :

```
vboxmanage -v | cut -dr -f1
```

Cette commande renverra le numéro de version dans un format similaire à **7.0.20**. Avec ces informations, nous pouvons procéder au téléchargement du pack d'extension approprié à l'aide de la commande

```
cd ~
```

```
wget https://download.virtualbox.org/virtualbox/7.0.20/Oracle_VM_VirtualBox_Extension_Pack-7.0.20.vbox-extpack
```

Pour installer le pack d'extension que nous venons de télécharger, utilisons la commande **vboxmanage**

```
sudo vboxmanage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-7.0.20.vbox-extpack
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

**Sources**: 
- [Virtualbox](https://www.virtualbox.org/wiki/Linux_Downloads)