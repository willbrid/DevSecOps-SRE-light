# Rechercher des fichiers [Part1]

Pour débuter créeons 4 fichiers et déplaçons les dans le répertoire **/etc**

```
sudo touch /etc/search.txt
sudo touch /etc/SeArch.txt
sudo touch /etc/SeARCH.txt
sudo touch /etc/SEARCH.txt
```

### Commande find

--- Commande très puissante utilisée pour rechercher des fichiers ou des répertoires <br>
--- Peut rechercher par nom, type de fichier, horodatage et de nombreux autres attributs de fichier <br>
--- Prend en charge les expressions et les blobs pour les recherches avancées <br>
--- Recherche en temps réel, ce qui peut être lent sur les machines avec beaucoup de fichiers <br>

- **Recherche de fichiers par son nom dans le répertoire courant**

```
find -name "search.txt"
```

- **Recherche de fichiers par son nom dans tout le système**

```
find / -name "search.txt"
```

En mode non privilège, nous constaterons plusieurs lignes d'erreur mentionnant que nous n'avons pas de permission.

```
sudo find / -name "search.txt"
```

- **Recherche de fichiers par son nom dans un repertoire spécifique**

```
sudo find /etc -name "search.txt"
```

- **Recherche de fichiers par son nom dans un repertoire spécifique sans respecter la casse sur le nom du fichier**

```
sudo find /etc -iname "search.txt"
```

- **Recherche de fichiers par son type et par son nom dans tout le système**

```
sudo find / -type f -name "*.log"
```

Les types de fichiers sont : <br>
--- **b** -> bloc (tamponné) spécial <br>
--- **c** -> caractère (non tamponné) spécial <br>
--- **d** -> répertoire <br>
--- **p** -> tube nommé (FIFO) <br>
--- **f** -> fichier régulier <br>
--- **l** -> lien symbolique : ceci n'est jamais vrai si l'option **-L** ou l'option **-follow** est active, sauf si le lien symbolique est rompu. Si nous souhaitons rechercher des liens symboliques lorsque **-L** est activé, utilisons **-xtype**. <br>
--- **s** -> socket <br>
--- **D** -> door (Solaris)

Pour rechercher plusieurs types à la fois, nous pouvons fournir la liste combinée des lettres de type séparées par une virgule ',' (extension GNU).

- **Recherche de fichiers par son type et par le nom de son propriétaire dans un repertoire spécifique**

```
sudo find /etc -type f -user username
```

**username** est le nom d'utilisateur créé sur le système.

- **Rechercher et lister un repertoire**

```
sudo mkdir /opt/app
sudo touch /opt/app/file1 /opt/app/file2 /opt/app/test.sh
```

Listons le contenu du repertoire **/opt/app**

```
find /opt/app -ls
```

Utilisons la commande **chown** avec **find** pour remplacer la propriété de l'utilisateur par l'utilisateur et le groupe courant non root pour le répertoire **/opt/app** et son contenu :

```
find /opt/app -exec sudo chown $(id -un):$(id -gn) {} \;
```

Listons à nouveau le contenu du repertoire **/opt/app**

```
find /opt/app -ls
```

Utilisons la commande **chmod** avec **find** pour définir les autorisations **rw-rw----**, ou **660**, sur tous les fichiers **/opt/app**, à l'exception du répertoire lui-même et du fichier **/opt/app/test.sh** :

```
find /opt/app -name "f*" -ok chmod 660 {} \;
```

Nous tapons simplement **y** pour chaque invite **yes/no**.

Modifions les autorisations pour **rwxrwx---**, ou **770** sur tout ce qui ne commence pas par **f** (le répertoire lui-même et le script **test.sh**)

```
find /opt/app '!' -name "f*" -ok chmod 770 {} \;
```

Nous tapons simplement **y** pour chaque invite **yes/no**.

Recherchons un **répertoire** sous **/home** qui n'appartient pas à un utilisateur ou à un groupe

```
find /home -nouser -nogroup -ls
```

Recherchons **tout ce qui** n'est pas propriétaire d'un utilisateur ou d'un groupe

```
find /home -nouser -a -nogroup -ls
```

Exécutons **chown** avec **find** pour modifier les fichiers qui n'ont aucun utilisateur ou groupe actuel

```
sudo find /home -nouser -nogroup -exec sudo chown $(id -un):$(id -gn) {} \;
```

Vérifions que nous les avons tous

```
sudo find /home -nouser -a -nogroup -ls
```

### Commande locate

--- Recherche plus rapide que la commande **find** <br>
--- Options de recherche limitées : impossible de rechercher par attributs ou métadonnées <br>
--- Recherche par défaut sur le système de fichiers complet <br>
--- S'appuie sur une base de données pour la recherche, qui doit être rafraîchie régulièrement <br>
--- Par défaut la recherche est faite en respectant la casse

- **Recherche de fichiers par son nom**

```
locate "search.txt"
```

Nous pouvons mettre à jour la base de données de recherche de la commande **locate**.

```
sudo updatedb
```

Recherchons à nouveau notre fichier **search.txt** et nous aurons plusieurs résultats.

- **Recherche de fichiers par son nom sans respecter la casse sur ce nom**

```
locate -i "search.txt"
```

### Les commandes stat, lsattr et chattr

- Commande **stat**

Elle affiche l'état du fichier ou du système de fichiers.

```
stat /etc/hosts
```

```
# Résultat
 Fichier : /etc/hosts
   Taille : 234       	Blocs : 8          Blocs d'E/S : 4096   fichier
Périphérique : 801h/2049d	Inœud : 4594101     Liens : 1
Accès : (0644/-rw-r--r--)  UID : (    0/    root)   GID : (    0/    root)
Accès : 2023-09-17 08:44:50.544849467 +0100
Modif. : 2023-05-11 04:30:29.140988583 +0100
Changt : 2023-05-11 04:30:29.168987682 +0100
  Créé : -
```

- Commande **lsattr** et **chattr**

Sur les systèmes d'exploitation Linux, la commande **chattr** modifie les **attributs des fichiers** et **lsattr** les affiche.

Sous Linux, les **attributs de fichier** sont des indicateurs qui affectent la manière dont le fichier est stocké et accessible par le système de fichiers. Ce sont des métadonnées stockées dans l'**inode** associé au fichier.

```
cd $HOME && touch file file2 .file
```

```
lsattr -a
```

```
lsattr file
```

La première commande affichera les attributs de fichiers de tous les fichiers contenu dans le repertoire **home**.

La deuxième commande affichera uniquement les attributs de fichiers du fichier **file**.

```
sudo chattr +i file2
```

Cette commande ajoutera l'attribut de fichier **i** sur le fichier **file2**. Pour vérifier la modification apportée, nous exécutons

```
lsattr file2
```