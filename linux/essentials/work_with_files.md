# Travailler avec les fichiers

**- Preparation de l'espace de travail**
```
mkdir working
cd working
wget http://www.gutenberg.org/files/11/11-0.txt
```

NB: L'instruction du wget téléchargera un fichier nommé : 11-0.txt dans le répertoire **working**.

**- Afficher le contenu du fichier**
```
cat 11-0.txt
```

**- Afficher une partie du fichier et scroller pour afficher les autres parties**
```
less 11-0.txt
```

NB: Il faut utiliser les touches sup et inf pour naviguer. Pour sortir, il faut utiliser la touche q .

**- Afficher les 10 premières lignes du fichier**
```
head 11-0.txt
```

NB: L'option **-n** permet d'afficher les **x** premières lignes (10 par défaut).
```
head -n 20 11-0.txt
```

**- Rechercher la chaine "Alice" dans le fichier 11-0.txt**
```
grep Alice 11-0.txt
```

NB: Cette rechercher respecte la casse. Pour faire une recherche sans respecter la casse, on a :
```
grep -i Alice 11-0.txt
```

**- Rechercher dans un fichier délimité par la virgule**
NB: Créer le fichier nommé **names.csv** et y mettre le contenu :
```
"Thomas","Morrison","25","Hairdresser"
"Alexia","Richards","23","Florist"
"Luke","Henderson","29","Biochenist"
```

```
cut -f 3 -d "," names.csv
```

L'option **-f** représente le numéro de colonne et l'option **-d** représente le délimiteur.<br>
Un exemple pour avoir afficher plusieurs colonnes :
```
cut -f 1,3 -d "," names.csv
```