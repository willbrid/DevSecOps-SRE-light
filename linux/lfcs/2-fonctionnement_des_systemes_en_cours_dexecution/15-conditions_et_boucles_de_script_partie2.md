# Conditions et boucles de script, partie 2 - For/While/Until

L'automatisation des tâches n'est pas toujours simple. Dans certains cas, un script a besoin de flexibilité pour évaluer les critères et choisir la bonne option.

### La boucle For

Une boucle **for** se répétera un nombre spécifique de fois, déterminé par le script ou par la saisie de l'utilisateur.

Exemples

- Exécuter le contenu d'une boucle **for** à partir d'un compteur

```
vi $HOME/countFor.sh
```

```
#!/bin/bash
for timer in 0 1 2 3 4 5
do
  echo "Count Up: " $timer
done
```

```
chmod +x $HOME/countFor.sh
```

```
cd $HOME && ./countFor.sh
```

- Exécuter le contenu d'une boucle **for** à partir du nombre de lignes d'un fichier

```
vi $HOME/listofurls.txt
```

```
https://www.yahoo.com/
https://www.google.com/
```

```
vim $HOME/forurlcheck.sh
```

```
#!/bin/bash

for url in $(cat $HOME/listofurls.txt)
do
  curl "$url" >> webpage_combined_for.html
done
```

### La boucle while

Une boucle **while** se répétera si la condition évaluée est VRAIE. Si l'évaluation échoue lors de la première vérification, la boucle ne démarrera jamais.

Exemples

- Exécuter le contenu d'une boucle **while** à partir d'un compteur

```
vi $HOME/countWhile.sh
```

```
#!/bin/bash

timer=0

while [ $timer -le 5 ]
do
  echo "Count Up: " $timer
  ((timer++))
done
```

```
chmod +x $HOME/countWhile.sh
```

```
cd $HOME && ./countWhile.sh
```

- Exécuter le contenu d'une boucle **while** à partir du nombre de lignes d'un fichier

```
vi $HOME/whileurlcheck.sh
```

```
#!/bin/bash

while read url
do
  curl "$url" >> webpage_combined_while.html
done < $HOME/listofurls.txt
```

```
chmod +x $HOME/whileurlcheck.sh
```

```
cd $HOME && ./whileurlcheck.sh
```

### La boucle until

Une boucle **until** se répétera si la condition évaluée est FALSE. Si l'évaluation échoue lors de la première vérification, la boucle ne démarrera jamais.

Exemples

- Exécuter le contenu d'une boucle **until** à partir d'un compteur


```
vi $HOME/countUntil.sh
```

```
#!/bin/bash

timer=0

until [ $timer -gt 5 ]
do
  echo "Count Up: " $timer
  ((timer++))
done
```

```
chmod +x $HOME/countUntil.sh
```

```
cd $HOME && ./countUntil.sh
```

- Incrémenter la taille d'un fichier jusqu'à la limite 1024

```
vi $HOME/untilSize.sh
```

```
#!/bin/bash
FILENAME=`basename "$0"`
echo $FILENAME
TMP_FILE="./tmp1"
TARGET_FILE="./target"
cat $FILENAME > $TARGET_FILE
FILESIZE=0

# Augmenter la taille du fichier jusqu'à 1 KB
until [ $FILESIZE -gt 1024 ]
do
  # Ajouter ce fichier au contenu du fichier cible
  cp $TARGET_FILE $TMP_FILE
  cat $TMP_FILE >> $TARGET_FILE

  FILESIZE=`du $TARGET_FILE | awk '{ print $1 }'`
  echo "Filesize: $FILESIZE"

  sleep 1
done

echo "La nouvelle taille du fichier cible a atteint 1 KB."
```

```
chmod +x $HOME/untilSize.sh
```

```
cd $HOME && ./untilSize.sh
```