# Travailler avec les sauvegardes et la compression

## Définition

- **tar** : crée un fichier **tar** en convertissant des groupes de fichiers et de répertoires en une archive. Ces fichiers se terminent par l'extension **.tar** suivie de la compression utilisée, le cas échéant (par exemple, **.tar.gz**). Les options notables : <br>
--- **c** : créer une archive <br>
--- **x** : extraire une archive <br>
--- **f** : spécifier le nom du fichier d'archive <br>
--- **t** : afficher le contenu d'une archive existant <br>
--- **z** : filtrer l'archive via gzip <br>
--- **j** : filtrer l'archive via bzip2 <br>
--- **J** : filtrer l'archive via xz <br>
--- **v** : afficher les fichiers en cours de traitement par la commande <br>

Les options peuvent être regroupées ou séparées par un "-". Lorsqu'elles sont regroupées, toute option prenant un argument doit apparaître à la fin.

- **rsync** : il signifie remote sync (synchronisation à distance) et est utilisé pour copier et synchroniser des fichiers et des répertoires, à la fois à distance et localement. Les options notables : <br>
--- **a** : utiliser le mode archive, qui préserve les autorisations, la propriété <br>
--- **v** : utiliser une sortie détaillée <br>
--- **z** : compresser les fichiers pendant le transfert <br>
--- **h** : afficher la sortie dans un format lisible <br>
--- **b** : effectuer une sauvegarde lors de la synchronisation des données <br>
--- **n** : effectuer un dry run <br>
--- **r** : copier les données de manière récursive (ne pas conserver la propriété, l'autorisation,...) <br>
--- **u** : ignorer les fichiers qui sont plus récents sur la destination <br>

NB : Une barre oblique à la fin d'une source copiera le contenu du répertoire, pas le répertoire par son nom.

## Pratiques

- Créons un repertoire **data** au niveau de notre dossier **home**, puis créons 7 fichiers texte nommés : **doc0...doc6**

```
mkdir ~/data
cd data
touch doc{0..6}
ls -l
```

- créons une archive de tous les fichiers doc* sans préciser la compression

```
tar -cvf backup.tar doc*
ls -lh
```

- affichons le contenu de notre fichier archive **backup.tar** créé

```
tar -tvf backup.tar
```

- créons une archive compressée (type de compression **gzip**) de tous les fichiers doc*

```
tar -cvzf backup.tgz doc*
ls -lh
```

- affichons le contenu de notre fichier archive compressé **backup.tgz** créé

```
tar -tvzf backup.tgz
```

- Créons un repertoire **backup** au niveau de notre dossier **home**

```
mkdir ~/backup
cd backup
```

- Créons une archive compressée (type de compression **bzip2**) **server01.tbz** des répertoires **/etc/**, **/home/** et **/var/log/**

```
sudo tar -cvjf server01.tbz /etc/ /home/ /var/log/
ls -lh
```

- affichons la taille des répertoires /etc/, /home/ et /var/log/

```
sudo du -h --max-depth=0 /etc/ /home/ /var/log/
```

Nous contaterons que la commande précédente a considérablement compressé ces répertoires.

- faisons une extraction du fichier archive **backup.tar** dans le répertoire **/tmp/**

```
cd ~/data
```

```
tar -xvf backup.tar -C /tmp/
ls -lh /tmp/
```

L'option **-C** permet de préciser la destination d'extraction.

- positionnons nous au niveau de répertoire **/tmp/** et faisons une extraction du fichier archive compressé **backup.tgz** sans préciser la destination d'extraction

```
cd /tmp/
```

```
tar -xvzf ~/data/backup.tgz
```

Les fichiers seront extraits dans le répertoire courant **/tmp/**.

- utilisons la commande **rsync** pour transférer le fichier **backup.tgz** vers un autre serveur

```
sudo rsync -avzh backup.tgz USER_AUTRE_SERVEUR@IP_AUTRE_SERVEUR:/home/USER_AUTRE_SERVEUR
```

- utilisons la commande **rsync** pour transférer le fichier contenu du répertoire **data** vers un autre serveur

```
sudo rsync -avzh ~/data/ USER_AUTRE_SERVEUR@IP_AUTRE_SERVEUR:/home/USER_AUTRE_SERVEUR/data
```

- créons deux fichiers **doc7**, **doc8** dans le répertoire **data** et utilisons à nouveau la commande **rsync** pour transférer le fichier contenu du répertoire **data** vers un autre serveur

```
cd ~/data
touch doc7 doc8
```

```
sudo rsync -avzh ~/data/ USER_AUTRE_SERVEUR@IP_AUTRE_SERVEUR:/home/USER_AUTRE_SERVEUR/data
```

Nous constatons que c'est uniquement les nouveaux fichiers créés qui seront transférés.

- mettons à jour le fichier **doc7** du répertoire **data** avec pour contenu "Bonjour tout le monde !" et utilisons à nouveau la commande **rsync** pour transférer le fichier contenu du répertoire **data** vers un autre serveur

```
echo "Bonjour tout le monde !" > ~/data/doc7
```

```
sudo rsync -avzh ~/data/ USER_AUTRE_SERVEUR@IP_AUTRE_SERVEUR:/home/USER_AUTRE_SERVEUR/data
```

Nous constatons que c'est uniquement le fichier **doc7** mis à jour qui est transféré.