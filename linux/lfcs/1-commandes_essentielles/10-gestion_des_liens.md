# Créer et gérer des liens physiques et logiciels

En tant qu'administrateur, comment pouvons-nous gérer le besoin qu'un fichier soit accessible à deux endroits en même temps ?

- Préréquis

```
cd ~
mkdir links
cd links
mkdir data
echo "This file is named info.txt" > info.txt
echo "This file is named details.txt" > data/details.txt
```

### Lien physique

- Pointeur direct vers le fichier
- Ne peut être qu'un fichier
- Partage le même inode que la source
- Doit être sur le même système de fichiers
- Tant que le lien physique existe, les données existent

Créeons un lien physique du fichier **info.txt**

```
cd ~/links
```

```
ln info.txt infohardlink
```

Si nous consultons l'inode de chacun de ces deux fichiers, nous constaterons qu'ils sont identiques.

```
ls -li
```

Si nous modifions le fichier lien physique, la modification sera immédiatement réflectée sur le fichier originel.

```
vi infohardlink
```

```
This file is named info.txt

Updated from infohardlink
```

```
cat info.txt
```

Si nous supprimons le fichier originel alors le fichier lien physique ne sera pas supprimé et il conservera toutes les données.

```
rm info.txt
ls -lhF
```

```
cat infohardlink
```

Les liens physiques sont très utiles lorsqu'on souhaite sauvegarder les fichiers de configuration de peur qu'ils ne soient supprimer par erreur.

### Lien logiciel (lien symbolique)

- Une redirection vers un fichier (comme raccourci ou alias)
- Peut être un fichier ou un répertoire
- Possède un inode unique
- Peut être sur un autre système de fichiers ou sur un partage monté
- Si le fichier source est supprimé, le lien symbolique est rompu

```
cd ~/links/data
```

Créeons un lien symbolique du fichier **details.txt**

```
ln -s details.txt detailssoftlink
```

```
cat detailssoftlink
```

L'option **-s** permet de préciser qu'il faudrait créer un lien symbolique.

```
ls -lhF
```

Créeons un lien symbolique du fichier **details.txt** dans le repertoire **links** parent de **data**.

```
cd ../
```

```
ln -s data/details.txt newsoftlink
```

```
ls -lhF
```

```
cat newsoftlink
```

Supprimons le fichier original **details.txt** situé dans le repertoire **data**

```
rm data/details.txt
```

```
ls -lhF
ls -lhF data
```

En listant les 2 répertoires des liens symboliques, nous constatons une coloration rouge indiquant la rupture du lien symbolique. En plus si nous essayons de lister le contenu de ce lien symbolique alors le système affichera un message d'erreur indiquant l'absence du fichier.

```
cat newsoftlink
```

Créons un lien symbolique du repertoire **data**

```
cd ~/links
```

```
ln -s data mysoftlink
```

```
ls -lhF
```

```
ls -lhF data
ls -lhF mysoftlink
```

Nous constatons que les deux repertoires contiennent le même contenu...