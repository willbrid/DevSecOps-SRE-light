# Comparer et manipuler le contenu des fichiers et utiliser la redirection d'entrée-sortie [Part2]

### Commande diff

- Compare deux fichiers ou répertoires ligne par ligne
- Plusieurs options pour ignorer, filtrer la comparaison
- La sortie peut être affichée au format **ed**, en **mode contextuel**, ou au format **unifié**

```
diff filename1.csv filename2.csv
```

Au format **ed** (format par défaut), supposons que nous avons le résultat suivant :

```
26c26
< Dennis Eckersley,6
---
> Dennis Eckersley,16
87a88
> Nolan Ryan,8
121d121
< Tony Perez,7
```

La sortie par défaut de la commande **diff** est au format **ed**.

- Au niveau de la première ligne, **26c26**, le premier **26** indique la ligne **26** du premier fichier. Le **c** signifie **changement** et le deuxième **26** signifie la ligne **26** dans le deuxième fichier. 
- Au niveau de la deuxième ligne, qui est **"< Dennis Eckersley,6"**, le symbole **inférieur à** indique qu’il s’agit de la valeur du premier fichier. 
- La troisième ligne est composée de 3 tirets. Ceci est simplement un indicateur que nous passons au deuxième fichier. 
- La quatrième ligne suivante est **"> Dennis Eckersley, 16 ans"**. Le symbole **supérieur à** indique qu’il s’agit de la valeur du deuxième fichier. 
- Donc, si nous revenons à la première ligne, **26c26**, cela signifie que nous devons modifier la ligne 26 du premier fichier pour qu'elle corresponde à la ligne 26 du deuxième fichier.
- Au niveau de la cinquième ligne qui est **87a88**. La valeur **87** indique la ligne **87** du premier fichier. Le **a** signifie **ajouter** et la valeur **88** indique la ligne **88** dans le deuxième fichier. 
- La sixième ligne suivante **"> Nolan Ryan,8"** indique qu’il s’agit de la valeur du deuxième fichier. 
- Donc, cette action **87a88** signifie qu'après la ligne **87** du premier fichier, nous devons ajouter la ligne **88** du deuxième fichier. 
- La septième ligne est **121d121**. Le premier **121** indique la ligne **121** du premier fichier. Le **d** signifie **supprimer**. Le deuxième **121** indique la ligne **121** dans le deuxième fichier. Donc, si nous revenons à la première ligne, **121d121**, cela signifie que nous devons supprimer la ligne **121** du premier fichier afin de faire correspondre à la ligne 121 du deuxième fichier. La ligne **"< Tony Perez,7"** est la ligne du premier fichier que nous devons supprimer.

```
diff -c filename1.csv filename2.csv
```

L'option **-c** permet d'activer l'affichage en mode **contextuel**.

En mode **contextuel**, supposons que nous avons le résultat suivant :

```
*** filename1.csv	2023-02-08 07:51:11.628970643 +0100
--- filename2.csv	2023-02-08 07:05:45.547135317 +0100
***************
*** 23,29 ****
  Chipper Jones,8
  Craig Biggio,7
  Dave Winfield,12
! Dennis Eckersley,6  
  Don Drysdale,9
  Duke Snider,8
  Earl Averill,6
--- 23,29 ---
  Chipper Jones,8
  Craig Biggio,7
  Dave Winfield,12
! Dennis Eckersley,6
  Don Drysdale,9
  Duke Snider,8
  Earl Averill,6
***************
*** 85,90 ****
--- 85,91 ---
  Mike Schmidt,12
  Nellie Fox,15
  Nolan Ryan,8
+ Nolan Ryan,8
  Orlando Cepeda,11
  Ozzie Smith,15
  Paul Molitor,7
***************
*** 118,124 ****
  Tom Glavine,10
  Tom Seaver,12
  Tony Gwynn,15
- Tony Perez,7
  Trevor Hoffman,7
  Vladimir Guerrero,9
  Wade Boggs,12
--- 119,124 ---
```

- En regardant la première ligne, les 3 astérisques représenteront le premier fichier. A la deuxième ligne, les 3 tirets représenteront le deuxième fichier.
- La ligne suivante n'est qu'un séparateur. 
- La ligne suivante commence par 3 astérisques.
cela indique que nous sommes dans le premier fichier. **23,29** indique que nous regardons les lignes 23-29. Ceci est suivi du contenu de ces lignes du premier fichier. Le **!** indique que cette valeur doit être modifiée.
- Si nous continuons vers le bas, la ligne qui commence par 3 tirets indique le contenu du deuxième fichier. Nous pouvons également voir qu'il y a un point d'exclamation dans cette section. Alors, que signifient ces 2 points d’exclamation ? Cela signifie que nous devons accéder au premier fichier, modifier la ligne avec un point d'exclamation pour qu'elle corresponde à la ligne du deuxième fichier qui a un point d'exclamation.
- En continuant la liste, nous avons un autre saut de ligne puis nous arrivons à une ligne qui commence par 3 astérisques indiquant le premier fichier. Et ceci est suivi de **85,90** - cela signifie que nous comparons les lignes **85** à **90** pour le contexte. 
- La ligne suivante comporte 3 tirets : cela indique le deuxième fichier. Et puis **85,91** indique que nous utilisons les lignes **85** à **91** pour la comparaison du contexte. Si nous faisons défiler la liste, nous pouvons voir qu'il y a un **+** à côté de la deuxième instance de **"Nolan Ryan"**. Cela signifie que nous devons ajouter cette instance au premier fichier pour que les 2 soient identiques. 
- Et en descendant vers la dernière section ici, nous voyons la ligne qui commence par 3 astérisques. cela indique le premier fichier, et nous regardons les lignes **118** à **124** à titre de comparaison.
Si nous faisons défiler vers le bas, nous pouvons voir qu'il y a un tiret **-** devant l'entrée de **"Tony Perez"**. Le tiret indique une valeur qui doit être supprimée. Si on continue vers le bas, on voit les 3 tirets indiquant le deuxième fichier, et on voit qu'il n'y a aucune ligne référencée pour le deuxième fichier. Cela signifie donc que nous devons supprimer la ligne indiquant **"Tony Perez"** du premier fichier, afin qu'elle corresponde au deuxième fichier.

```
diff folder1 folder2
```

La comparaison des repertoires est similaire à celle des fichiers. Supposons que nous avons le résultat suivant :

```
Only in folder2/: ._basic-list.txt
Only in folder2/: ._category-list.csv
Only in folder2/: basic-list.txt
diff folder1/category-list.csv folder2/category-list.csv
86a87
> Misc. Stuff,Everywhere
Only in folder1/: groceries-list.txt
Only in folder1/: nano.txt
Only in folder1/: shopping-list.txt
Only in folder1/: sorted.txt
Only in folder1/: touch.txt
```

- Ainsi, les 3 premières lignes disent **Only in**, et c'est notre répertoire **folder2**. Cela signifie que ces 3 fichiers n'existent qu'à l'emplacement **folder2**.
- La ligne suivante indique une fonctionnalité intéressante offerte par la commande **diff**. Lors d'une comparaison de répertoires, il comparera en fait les fichiers d'un répertoire aux fichiers correspondants du deuxième répertoire et générera un rapport sur les différences éventuelles. Il a trouvé 1 différence dans le fichier **category-list.csv**. 
- Et puis après la comparaison des fichiers, il a continué avec une comparaison de répertoires et a trouvé des fichiers uniques au répertoire **folder1** qui n'existaient pas dans le répertoire **folder2**.

### Commande comm

- Comparer deux fichiers triés ligne par ligne.
- La sortie est affichée en 3 colonnes, unique au fichier **file1**, unique au fichier **file2**, et identique dans les deux fichiers.

```
comm filename1.csv filename2.csv
```

### Commande cmp

Compare deux fichiers, octet par octet, et renvoie la position (ou numéro de ligne) de la première différence.

```
cmp filename1.csv filename2.csv
```