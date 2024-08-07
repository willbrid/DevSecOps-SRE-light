# Archiver, sauvegarder, compresser, décompresser et décompresser des fichiers

**TAR - Tape ARchive** : Une application Linux créée à l'origine pour écrire des fichiers sur un lecteur de bande. Désormais couramment utilisé pour créer des fichiers d'archives à utiliser pour la sauvegarde et la récupération en collectant une série de fichiers et de répertoires dans un seul fichier.

### Créer un fichier tar (ou tarball)

```
cd ~
```

```
tar cvf filename.tar /path/to/source
```

**Exemple :** 

```
sudo tar cvf hosts.tar /etc/hosts 
```

### Créer un fichier tar compressé à l'aide de gzip

```
tar cvfz filename.tar.gz /path/to/source
```

**Exemple :** 

```
sudo tar cvfz hosts.tar.gz /etc/hosts
```

### Afficher le contenu d'un fichier tar ou tar.gz

```
tar -tf filename.tar
tar -tf filename.tar.gz
```

**Exemple :** 

```
tar -tf hosts.tar
tar -tf hosts.tar.gz
```

### Extraire le contenu d'un fichier tar ou tar.gz

```
tar -xvf filename.tar
tar xvfz filename.tar.gz
```

**Exemple :** 

```
tar -xvf hosts.tar
tar xvfz hosts.tar.gz
```

Ici un dossier **etc** sera créé à la racine de notre repertoire **home**.

On peut aussi extraire un fichier archivé dans un repertoire précis.

```
mkdir torestore
tar xvfz hosts.tar.gz --directory=torestore/
```