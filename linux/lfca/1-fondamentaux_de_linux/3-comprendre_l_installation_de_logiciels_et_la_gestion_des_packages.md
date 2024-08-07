# Comprendre l'installation de logiciels et la gestion des packages

## Les distrubtions de Redhat

Leurs gestionnaires de packages : yum, dnf, zypper,...

Programme d'installation : **rpm**

**Example avec le package d'apache**

- rechercher le package d'apache

```
sudo yum search apache
```

- installer le package d'apache

```
sudo yum install httpd
```

- lister tous les packages installés

```
sudo yum list installed
```

- vérifier si le package d'apache s'est installé

```
sudo yum list installed | grep httpd
```

- mettre à jour tous les packages du système

```
sudo yum update
```

- mettre à jour le package d'apache

```
sudo yum update httpd
```

- désinstaller le package d'apache

```
sudo yum remove httpd -y
```

## Les distributions de Debian

Leurs gestionnaires de packages : apt, apt-get, aptitude,...

Programme d'installation : **dpkg**

- mettre à jour l'index des packages locaux

```
sudo apt update
```

- rechercher le package d'apache

```
sudo apt search apache | head
```

ou 

```
sudo apt-cache search apache | head
```

- installer le package d'apache

```
sudo apt install apache2
```

- désinstaller le package d'apache

```
sudo apt remove apache2
```