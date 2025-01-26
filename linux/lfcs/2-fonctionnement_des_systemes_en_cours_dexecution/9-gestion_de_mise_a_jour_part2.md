# Mettre à jour et gérer les logiciels pour fournir les fonctionnalités et la sécurité requises, partie 2 - CentOS/Redhat

En tant qu'administrateur système, maintenir la stabilité et la sécurité est une tâche essentielle. Les mises à jour du système et les correctifs constituent un élément clé de cet objectif.

Les distributions **Redhat/CentOS** offrent plusieurs outils pour maintenir le système d'exploitation et les applications à jour afin de maintenir la santé du système.

### rpm

- Gestionnaire de paquets pour les systèmes basés sur RedHat
- Outil de bas niveau utilisé pour installer, supprimer et fournir des informations sur les paquets RPM téléchargés
- Répertorie manuellement les dépendances des paquets, effectue des vérifications de dépendances mais n'installe pas automatiquement
- Syntaxe :

Installation d'un paquet
```
rpm -ivh filename.rpm
```

Mise à niveau d'un paquet
```
rpm -Uvh filename.rpm
```

Désinstallation d'un paquet
```
rpm -e pkgname
```

Lister les paquets installés
```
rpm -qa
```

Ici l'option **-q** permet de faire une interrogation (**query**) de la base de données des packages installés

Obtenir les informations sur un paquet installé
```
rpm -qi pkgname
```

Trouver le propriétaire du fichier
```
rpm -qf /path/to/file
```

Quelques options de **rpm** :
- **-i** : cette option permet d'installer un paquet **rpm**
- **-v** : cette option permet d'afficher plus de détails (**mode verbose**)
- **-h** : cette option permet d'afficher des marqueurs au fur et à mesure que le paquet s'installe et est utilisée avec l'option **-v**
- **-U** : cette option permet de mettre à jour un paquet
- **-e** : cette option permet de désinstaller un paquet
- **-q** : cette option permet d'effectuer une requête sur une ou plusieurs paquets installés et est utilisée pour obtenir des informations sur les paquets déjà installés sur le système
- **-qa** : cette option permet d'interroger (ou vérifier) tous les paquets
- **-qf** : cette option permet d'interroger (ou vérifier) le(s) paquet(s) possédant le fichier installé
- **-qd** : cette option permet de lister les fichiers de documentation appartenant à un paquet
- **-qc** : cette option permet de lister les fichiers de configuration d'un paquet

Exemples :

Lister les paquets installés
```
rpm -qa
```

Lister les paquets associés à **ssh**
```
rpm -qa | grep ssh
```

Trouver le paquet associé au fichier binaire **/usr/bin/gzip**
```
rpm -qf /usr/bin/gzip
```

Afficher les informations sur le paquet **gzip**
```
rpm -qi gzip
```

- Cas pratique

Utilisons **RPM** pour rechercher la configuration, la documentation et les informations sur le paquet propriétaire de **/sbin/httpd**, ainsi que sur tous les paquets installés. Après avoir installé un paquet comme **httpd**, nous pouvons utiliser **rpm** pour demander ses détails de configuration, sa documentation et d'autres informations.

Examinons tous les fichiers de documentation appartenant au paquet **httpd**
```
rpm -qd httpd
```

Affichons les fichiers de configuration du paquet **httpd**
```
rpm -qc httpd
```

Affichons quel paquet possède le fichier **/sbin/httpd**
```
rpm -qf /sbin/httpd
```

Affichons tous les paquets installés par ordre de temps d'installation, du plus ancien au plus récent
```
rpm -qa --last | tac
```

Affichons les paquets qui commencent par **httpd**
```
rpm -qa 'httpd*'
```

Vérifions que le paquet **elinks** est installé
```
rpm -q elinks
```

### yum

- Gestionnaire de paquets pour les systèmes RedHat
- Outil officiel de haut niveau qui fournit une interface de ligne de commande pour installer, mettre à niveau, supprimer et fournir des informations sur les paquets **.rpm**
- Gère les contrôles de dépendance
- Syntaxe :

Installation d'un paquet
```
yum install pkgname
```

Suppression d'un paquet
```
yum remove pkgname
```

Mise à jour d'un paquet
```
yum update pkgname
```

Lister les paquets installés
```
yum list installed
```

Rechercher dans les référentiels un paquet
```
yum search keyword
```

Exemples :

Lister les paquets installés
```
yum list installed
```

Lister les paquets associés à **ssh**
```
yum list installed | grep ssh
```

Rechercher dans les référentiels le paquet tmux
```
yum search tmux
```

Installer le paquet tmux
```
sudo yum install tmux
```

Désinstaller le paquet tmux
```
sudo yum remove tmux
```

Rechercher les paquets à mettre à jour
```
yum check-update
```

Mettre à jour un paquet
```
sudo yum update python-perf.x86_64
```

- Cas pratique

Supposons que les métadonnées et le cache **YUM** soient obsolètes et résolvons le problème afin que nous puissions mettre à jour le système. <br>
Nettoyons les métadonnées et le cache **YUM** existants et créons-en un nouveau

```
yum clean all
```

```
yum makecache
```

Listons les mises à jour disponibles
```
yum list updates
```

Mettons à jour les paquets sur le système
```
sudo yum -y update
```

Recherchons tous les paquets avec **apache** ou **http** dans leurs noms
```
yum search 'apache http'
```

Le serveur **apache** est livré avec un fichier **httpd**. Trouvons quel paquet inclut (fournit) un tel fichier
```
yum provides httpd
```

Installons le paquet **httpd**
```
sudo yum -y install httpd
```

### dnf

- Outil de haut niveau qui fournit une interface de ligne de commande pour installer, mettre à niveau, supprimer et fournir des informations sur les paquets **.rpm**
- Gère les contrôles de dépendance
- Gestionnaire de paquets par défaut pour **Fedora** et **RedHat8**. Conçu pour de meilleures performances, une optimisation de la mémoire et une résolution améliorée des dépendances
- Partage de nombreuses commandes et similitudes avec **yum**
- Syntaxe :

Installation d'un paquet
```
dnf install pkgname
```

Suppression d'un paquet
```
dnf remove pkgname
```

Mise à jour d'un paquet
```
dnf update pkgname
```

Lister les paquets installés
```
dnf list installed
```

Rechercher dans les référentiels un paquet
```
dnf search keyword
```

Exemples :

Lister les paquets installés
```
dnf list installed
```

Installer le paquet tmux
```
sudo dnf install tmux
```

Désinstaller le paquet tmux
```
sudo dnf remove tmux
```