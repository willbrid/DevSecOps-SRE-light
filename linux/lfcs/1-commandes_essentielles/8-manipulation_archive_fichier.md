# Archiver, sauvegarder, compresser, décompresser et décompresser des fichiers

**TAR - Tape ARchive** : Une application Linux créée à l'origine pour écrire des fichiers sur un lecteur de bande. Désormais couramment utilisé pour créer des fichiers d'archives à utiliser pour la sauvegarde et la récupération en collectant une série de fichiers et de répertoires dans un seul fichier.

La commande **tar** nous permet de spécifier ses options de ligne de commande de trois manières différentes. Ci-dessous un exemple avec l'option **t** permettant de lister le contenu d'un fichier archive :

```
tar --list --file archive.tar
```

```
tar -tf archive.tar
```
 
```
tar tf archive.tar
```

### Préparation du repertoire de test

```
mkdir -p $HOME/test_dir/test_subdir && touch $HOME/test_dir/file1.txt $HOME/test_dir/file2.txt && touch $HOME/test_dir/test_subdir/file3.txt
```

### Archivage de fichier ou dossier

- Créer un fichier **file.tar** (ou tarball) depuis le fichier **$HOME/test_dir/file1.txt**

```
tar cvf file.tar $HOME/test_dir/file1.txt
```

- Créer un fichier **test_dir.tar** depuis le repertoire **$HOME/test_dir**

```
tar cvf test_dir.tar $HOME/test_dir
```

L'option **c** ou **--create** permet de créer un fichier archive. <br>
L'option **f** ou **--file** permet d'indiquer le fichier de destination à créer. <br>
L'option **v** est le mode verbose.

Un fichier archive stocke également les informations de permission et de propriété de tous les fichiers et repertoires. <br>
Cependant si nous sommes connectés en tant que **willbrid1** et qu'un fichier dans l'archive appartient à **willbrid2**, alors **willbrid1** n'a pas les permissions nécessaires pour créer un fichier appartenant à **willbrid2**, mais le compte **root** a ce privilège. Donc si nous voulons nous assurer que toutes les informations de propriété et de permission sont restaurées exactement comme elles ont été capturées, nous pouvons utiliser la commande avec **sudo**.

- Afficher le contenu des fichiers **file.tar** et **test_dir.tar**

```
tar tvf file.tar
```

```
tar tvf test_dir.tar
```

L'option **t** ou **--list** permet d'indiquer le fichier archive à afficher le contenu.

- Extraire le contenu des fichiers **file.tar** et **test_dir.tar**

```
tar xvf file.tar
```

```
tar xvf test_dir.tar --directory=/tmp
```

L'option **x** ou **--extract** permet d'extraire le contenu d'un fichier archive. <br>
L'option **--directory** ou **-C** permet d'indiquer le repertoire d'extraction.

- Ajouter le fichier **$HOME/test_dir/file2.txt** au fichier archive **file.tar** préalablement créé

```
tar rvf file.tar $HOME/test_dir/file2.txt
```

L'option **r** ou **--append** permet d'ajouter un fichier ou un repertoire à un fichier archive.

### Compression et décompression

Par défaut les utilitaires de compression sont **gzip**, **bzip2** et **xz**.

- créer un fichier **.gz** à partir du fichier **$HOME/test_dir/test_subdir/file3.txt**

```
gzip $HOME/test_dir/test_subdir/file3.txt
```

- créer un fichier **.bz2** à partir du fichier **$HOME/test_dir/file2.txt**

```
bzip2 $HOME/test_dir/file2.txt
```

- créer un fichier **.xz** à partir du fichier **$HOME/test_dir/file1.txt**

```
xz $HOME/test_dir/file1.txt
```

Par défaut les utilitaires de décompression sont **gunzip**, **bunzip2** et **unxz**.

- décompresser le fichier **$HOME/test_dir/test_subdir/file3.txt.gz**

```
gunzip $HOME/test_dir/test_subdir/file3.txt.gz
```

- décompresser le fichier **$HOME/test_dir/file2.txt.bz2**

```
bunzip2 $HOME/test_dir/file2.txt.bz2
```

- décompresser le fichier **$HOME/test_dir/file1.txt.xz**

```
unxz $HOME/test_dir/file1.txt.xz
```

Par défaut lorsqu'un fichier est compressé, le fichier original est supprimé. Cependant nous pouvons utiliser l'option **--keep** pour sauvegarder le fichier original.

```
gzip --keep $HOME/test_dir/test_subdir/file3.txt
```

```
bzip2 --keep $HOME/test_dir/file2.txt
```

```
xz --keep $HOME/test_dir/file1.txt
```

### Archivage et compression

Les utilitaires **gzip**, **bzip2** et **xz** n'ont pas d'option pour prendre un répertoire et le mettre dans un seul fichier compressé. C'est pourquoi ils sont généralement utilisés avec l'utilitaire d'archive **tar**.

- Créer 3 fichiers **file.tar.gz**, **file.tar.bz2** et **file.tar.xz** depuis le fichier **$HOME/test_dir/file1.txt**

```
tar cvzf file.tar.gz $HOME/test_dir/file1.txt
```

```
tar cvjf file.tar.bz $HOME/test_dir/file2.txt
```

```
tar cvJf file.tar.xz $HOME/test_dir/test_subdir/file3.txt
```

- Afficher le contenu des fichiers **file.tar.gz**, **file.tar.bz2** et **file.tar.xz**

```
tar tvzf file.tar.gz
```

```
tar tvjf file.tar.bz
```

```
tar tvJf file.tar.xz
```

- Extraire le contenu des fichiers **file.tar.gz**, **file.tar.bz2** et **file.tar.xz** dans le repertoire **/tmp/**

```
tar xvzf file.tar.gz -C /tmp
```

```
tar xvjf file.tar.bz -C /tmp
```

```
tar xvJf file.tar.xz -C /tmp
```

- On ne peut pas mettre à jour les fichiers archive compressées **file.tar.gz**, **file.tar.bz2** et **file.tar.xz** comme avec les fichiers archives.