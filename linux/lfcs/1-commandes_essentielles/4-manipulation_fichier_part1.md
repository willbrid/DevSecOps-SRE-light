# Comparer et manipuler le contenu des fichiers et utiliser la redirection d'entrée-sortie [Part1]

Pour effectuer les tests, 

- générons le fichier **bigfile.txt** de 100000 lignes avec la commande ci-dessous :

```
for i in {1..100000}; do echo "This is line $i" >> bigfile.txt; done
```

- générons le fichier **bigfile_with_duplicated_line.txt**

```
for i in {1..10000}; do echo "This is line $i" >> bigfile_with_duplicated_line.txt; ((i % 2 == 0)) && echo "This is line $i" >> bigfile_with_duplicated_line.txt; done
```

### Commande cat et tac

**cat** permet d'afficher le contenu d'un fichier du haut vers le bas.

```
cat bigfile.txt
```

**tac** permet d'afficher le contenu d'un fichier du bas vers le haut.

```
tac bigfile.txt
```

### Commande tail et head

**tail** permet d'afficher par défaut les 10 dernières lignes du contenu d'un fichier

```
tail bigfile.txt
```

si nous voulons afficher les 20 dernières lignes du contenu d'un fichier 

```
tail -n 20 bigfile.txt
```

**head** permet d'afficher par défaut les 10 premières lignes du contenu d'un fichier

```
head bigfile.txt
```

si nous voulons afficher les 20 premières lignes du contenu d'un fichier 

```
head -n 20 bigfile.txt
```

### Commande more, less, sort

- Utilitaires Linux similaires, utilisés pour contrôler l'affichage du contenu des fichiers
- Peut être utilisé sur un fichier directement ou sur la sortie d'une autre commande

**more** est un filtre pour parcourir le texte un **écran à la fois**.

```
more bigfile.txt
```

```
cat bigfile.txt | more
```

**Less** est un programme similaire à **more**, mais il a beaucoup plus de fonctionnalités. **Less** n'a pas besoin de lire l'intégralité du fichier d'entrée avant de démarrer, donc avec des fichiers d'entrée volumineux, il démarre plus rapidement que les éditeurs de texte comme **vi**.

```
less bigfile.txt
```

```
less -N bigfile.txt
```

```
less +F bigfile.txt
```

```
cat bigfile.txt | less
```

Une fois le fichier ouvert, nous pouvons utiliser la syntaxe **/pattern** pour rechercher vers l'avant dans le fichier la **N-ième** ligne contenant le **pattern**. **N** est par défaut égal à 1. Le **pattern** est une expression régulière, telle qu'elle est reconnue par la bibliothèque d'expressions régulières fournie par notre système. La recherche commence à la première ligne affichée (mais les options **-a** et **-j** peuvent changer cela). <br>
L'option **-N** permet d'afficher les numéros de lignes du fichier. <br>
L'option **+F** permet suivre les nouvelles lignes du fichier en **realtime**.

**sort** : permet de trier les lignes des fichiers texte.

```
cat bigfile.txt | sort
```

```
sort bigfile.txt
```

```
sort -r bigfile.txt
```

L'option **-r** permet de trier dans l'ordre inverse.

### Commande touch

Elle permet de créer un fichier. Elle permet de mettre à jour les heures d'accès et de modification de chaque fichier à l'heure actuelle.

```
touch filename.txt
```

### Commande nano

Elle permet de créer un fichier et de l'ouvrir directement en mode édition.

```
nano filename.txt
```

Elle permet aussi d'ouvrir un fichier existant.

```
nano /etc/hosts
```

Une fois le fichier ouvert, nous pouvons : 
- couper une ligne du contenu du fichier : **crtl + k**
- enregistrer le contenu modifié : **crtl + o**

### Commande sed (stream editor)

La commande **sed** consiste à rechercher certaines chaînes de caractères dans un fichier pour les remplacer par d’autres caractères ou chaines de caractères.

```
# Syntaxe
sed 's/source_pattern/destination_pattern/g' filename
```

Par défaut et sans l'option **"-i"** **sed** ne modifie pas le fichier, il affiche son contenu avec la modification apportée. La lettre **g** permet d'indiquer à **sed** de remplacer toutes les occurrences trouvées de **source_pattern** par **destination_pattern**. Sans la lette **g** c'est uniquement la première occurrence qui sera remplacée.

```
sed 's/127.0.0.1/127.0.1.1/g' /etc/hosts
```

Avec l'option **"-i"** (**--in-place**), **sed** va editer le fichier.

```
sed -i 's/This is line/This is line number/g' bigfile.txt
```

Pour ignorer la casse avec **sed** on met **"i"** après le **"g"**

```
sed -i 's/this is line number/this is line/gi' bigfile.txt
```

Pour effectuer une modification uniquement entre les lignes 200 et 3000 du fichier **bigfile.txt**

```
sed -i '200,3000s/This is line/This is line number/g' bigfile.txt
```

### Commande cut

La commande **cut** est utilisée pour extraire des sections de chaque ligne d'un fichier.

```
cut -d ' ' -f 2 bigfile.txt
```

L'option **-d** permet d'indiquer le délimiteur et l'option **-f** le numéro de la colonne.

### Commande uniq

La commande **uniq** supprime les lignes répétées d'un fichier (lignes en doublons).

```
uniq bigfile_with_duplicated_line.txt
```

Affichons les lignes en doublon avec l'option **"-d"**

```
uniq -d bigfile_with_duplicated_line.txt
```

### Commande vim (ViIMproved)

Il s'agit d'une version améliorée du classique vi. Il est très complet, peu gourmand en ressources, et fait très bien la coloration syntaxique.

```
vim bigfile.txt
```

- pour entrer en mode insertion, on saisit la lettre **i**
- pour écrire dans le fichier, on saisit **:w**
- pour écrire et quitter, on saisit **:wq**
- pour quitter sans enregistrer de modification, on saisit **:q!**
- un fichier ouvert avec **vim**, pour aller à droit on saisit **l**, à gauche on saisit **h**, en haut on saisit **k** et en bas on saisit **j**
- pour rechercher par défaut en respectant la casse, on saisit **/pattern**
- pour rechercher par défaut sans respectant la casse, on saisit **/pattern\c**
- pour aller à la ligne **x** on saisit **:x**
- pour copier une ligne entière, on tape la touche **y (yank)** deux fois au debut de la ligne et pour coller la ligne copiée on tape la lettre **p**
- pour couper une ligne entière, on tape la touche **D deux fois**
- pour supprimer les 1000 premières lignes d'un fichier : s'assurer que le curseur se trouve sur la toute première ligne; puis, sans entrer dans le mode insertion, entrer le numéro 1000 et appuyer sur **dd** immédiatement après. Enfin, enregistrer le fichier.