# Comparer et manipuler le contenu des fichiers et utiliser la redirection d'entrée-sortie [Part1]

### Commande cat

Utiliser cette commande pour afficher le contenu d'un fichier.

```
cat filename.txt
```

### Commande more, less, sort

- Utilitaires Linux similaires, utilisés pour contrôler l'affichage du contenu des fichiers
- Peut être utilisé sur un fichier directement ou sur la sortie d'une autre commande

**more** est un filtre pour parcourir le texte un **écran à la fois**.

```
more filename.txt
```

```
cat filename.txt | more
```

**Less** est un programme similaire à **more**, mais il a beaucoup plus de fonctionnalités. **Less** n'a pas besoin de lire l'intégralité du fichier d'entrée avant de démarrer, donc avec des fichiers d'entrée volumineux, il démarre plus rapidement que les éditeurs de texte comme **vi**.

```
less filename.txt
```

```
less -N filename.txt
```

```
less +F filename.txt
```

```
cat filename.txt | less
```

Une fois le fichier ouvert, nous pouvons utiliser la syntaxe **/pattern** pour rechercher vers l'avant dans le fichier la **N-ième** ligne contenant le **pattern**. **N** est par défaut égal à 1. Le **pattern** est une expression régulière, telle qu'elle est reconnue par la bibliothèque d'expressions régulières fournie par notre système. La recherche commence à la première ligne affichée (mais les options **-a** et **-j** peuvent changer cela). <br>
L'option **-N** permet d'afficher les numéros de lignes du fichier. <br>
L'option **+F** permet suivre les nouvelles lignes du fichier en **realtime**.

**sort** : permet de trier les lignes des fichiers texte.

```
cat filename.txt | sort
```

```
sort filename.txt
```

```
sort -r filename.txt
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