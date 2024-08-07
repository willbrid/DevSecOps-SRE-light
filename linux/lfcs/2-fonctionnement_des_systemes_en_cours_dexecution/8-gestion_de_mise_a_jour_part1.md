# Mettre à jour et gérer les logiciels pour fournir les fonctionnalités et la sécurité requises, partie 1 - Ubuntu/Debian

En tant qu'administrateur système, maintenir la stabilité et la sécurité est une tâche essentielle. Les mises à jour du système et les correctifs constituent un élément clé de cet objectif.

Les distributions **Debian/Ubuntu** offrent plusieurs outils pour maintenir le système d'exploitation et les applications à jour, afin de maintenir la santé du système.

### dpkg

- Gestionnaire de paquets pour les systèmes basés sur Debian
- Outil de bas niveau utilisé pour installer, supprimer et fournir des informations sur les paquets **.deb** téléchargés
- N'effectue pas de contrôles de dépendance
- Syntaxe :

Installation d'un paquet
```
dpkg -i filename.deb
```

Liste des paquets installés
```
dpkg -l
```

Désinstallation d'un paquet
```
dpkg -r pkgname
```

Vérifier si les commandes **zip** et **unzip** sont installées

```
dpkg -l zip
```

```
dpkg -l unzip
```

Utilisons la commande **dpkg** pour afficher les informations sur le paquet **tzdata**

```
dpkg -s tzdata
```

Utilisons **dpkg-reconfigure** pour ajuster le fuseau horaire sur **Africa/Douala**.

```
dpkg-reconfigure tzdata
```

Quelques options de **dpkg** :
- **-i** : cette option permet d'installer un paquet **deb**
- **-l** : cette option permet de lister ou vérifier les paquets installés
- **-r** : cette option permet de supprimer un paquet installé
- **-s** : cette option permet d'afficher les informations détaillées sur un paquet

### aptitude

- Interface de haut niveau avec le système de paquets Debian
- Fournit une interface frontale en ligne de commande pour installer, mettre à niveau, supprimer et fournir des informations sur les paquets **.deb**
- Gère les contrôles de dépendance
- Peut être utilisé avec les options de ligne de commande mais plus couramment utilisé pour son interface
- Syntaxe :

Installation d'un paquet
```
aptitude install pkgname
```

Liste des informations sur un paquet
```
aptitude show pkgname
```

Désinstallation d'un paquet
```
aptitude remove pkgname
```

Pour afficher l'interface interactive, on exécute :

```
sudo aptitude
```

### apt/apt-get

- Interface de haut niveau avec le système de paquets Debian
- Fournit une interface de ligne de commande pour installer, mettre à niveau, supprimer et fournir des informations sur les paquets **.deb**
- Gère les contrôles de dépendance
- Syntaxe :

Installation d'un paquet
```
apt install pkgname
```

Liste des informations sur un paquet
```
apt show pkgname
```

Désinstallation d'un paquet
```
apt purge pkgname
```

|        apt       | apt-get                   | description                                                            |
| :---             | :----:                    | ---:                                                                   |
| apt install      | apt-get install           | installer un paquet                                                   |
| apt remove       | apt-get remove            | désinstaller un paquet                                                |
| apt purge        | apt-get purge             | désinstaller un paquet avec ses configurations                        |
| apt update       | apt-get update            | actualiser l'index du référentiel                                      |
| apt upgrade      | apt-get upgrade           | effectuer les mises à niveau                                           |
| apt autoremove   | apt-get autoremove        | supprimer les paquets indésirables                                    |
| apt full-upgrade | apt-get dist-upgrade      | mettre à niveau les paquets avec gestion automatique des dépendances  |
| apt search       | apt-cache search          | rechercher un programme                                                |
| apt show         | apt-cache show            | afficher les détails d'un paquet                                      |


```
sudo apt update
```

```
apt search htop
```

```
apt search tmux
```

```
sudo apt install tmux
```

```
sudo apt remove tmux
```