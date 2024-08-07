# Gestion des fichiers et des répertoires

- **touch** : il modifie l'horodatage des fichiers existants ou créer de nouveaux fichiers.

```
touch test
```

- **mkdir** : il crée un ou plusieurs répertoires, s'ils n'existent pas déjà. L'option **-p** créera des répertoires parents selon les besoins.

```
mkdir storage
mkdir -p storage01
```

- **cp** : il copie des fichiers et des répertoires. L'option **-r/-R** est utilisée pour copier les répertoires de manière récursive.

```
cp test test01
cp test test02
cp test test01 storage/
cp -r storage storage_bkp
```

- **mv** : il déplace ou renomme des fichiers ou des répertoires.

```
mv test test03
mv test03 storage/
mv storage01 storage01_bkp
```

- **rm** : il supprime des fichiers ou des répertoires. L'option **-r/-R** supprime les répertoires et leur contenu de manière récursive. L'option **-f** supprime l'invite lors de la suppression de fichiers/répertoires.

```
rm test01
rm -r storage
```

- **rmdir** : il supprime des répertoires vides.

```
rmdir storage01
```

- **ls** : il liste le contenu du répertoire. Les options courantes incluent **-a** pour afficher tous les fichiers (y compris les fichiers cachés) et **-l** pour utiliser le format de liste longue.

```
ls storage01_bkp/
ls -la storage01_bkp/
```

- **pwd** : il affiche le nom du répertoire courant.

```
pwd
```

- **cd** : il change le répertoire de travail. Certains caractères spéciaux incluent : le répertoire de travail courant (**.**), le répertoire parent (**..**), le répertoire de travail précédent (**-**), le répertoire personnel de l'utilisateur (**~**).

```
cd .
cd ..
cd -
cd ~
```

- **cat** : il concaténe des fichiers et affiche le contenu sur la sortie standard.

```
cat test02
```

- **vi** : éditeur d'affichage visuel. Un utilitaire commun d'édition de text Linux. Peut également être utilisé pour créer des fichiers.