# Conditions et boucles de script, partie 1 - Opérateurs/If

L'automatisation des tâches n'est pas toujours simple. Dans certains cas, un script a besoin de flexibilité pour évaluer les critères et choisir la bonne option.

### Opérateurs

Les opérateurs sont utilisés pour évaluer, combiner ou effectuer une action sur les informations (opérandes) fournies. Il existe plusieurs types d'opérateurs (y compris les tests booléens, de chaîne et de fichier), parmi lesquels :

- Les opérateurs arithmétiques exécutent des fonctions mathématiques traditionnelles telles que **+** (addition), **-** (soustraction), **\*** (multiplication), **/** (division) et **%** (modulo)

```
cd ~
vi op-arithmetic.sh
```

```
#!/bin/bash

#Lire les données de l'utilisateur
#clear
echo
read -p 'Entrez un nombre pour a : ' a
read -p 'Entrez un nombre pour b : ' b
echo
echo "Opérateurs arithmétiques"
echo
echo Addition : $((a)) plus $((b)) egal $((a + b))
echo Soustraction : $((a)) moins $((b)) egal $((a - b))
echo Multiplication : $((a)) fois $((b)) egal $((a * b))
echo Division : $((a)) divise par $((b)) egal $((a / b))
echo Modulo : $((a)) modulo $((b)) egal $((a % b))
echo Incrémentation : $((a)) incrémenter de 1 \(++$((a))\) egal $((++a))
echo Décrémentation : $((b)) décrémenter de 1 \(--$((b))\) egal $((--b))
echo
```

```
chmod +x op-arithmetic.sh
```

```
./op-arithmetic.sh
```

- Les opérateurs relationnels sont utilisés pour comparer la relation entre les opérandes numériques et renvoie vrai ou faux. Les opérateurs sont **-eq** (égal), **-ne** (différent de), **-gt** (supérieur à), **-lt** (inférieur à), **-ge** (supérieur ou égal à) et **-le** (inférieur ou égal à)

```
cd ~
vi op-relational.sh
```

```
#!/bin/bash

#Lire les données de l'utilisateur
#clear
echo
read -p 'Entrez un nombre pour a : ' a
read -p 'Entrez un nombre pour b : ' b
echo
echo "opérateurs relationnels avec des entiers"
echo
if [ $((a)) -eq $((b)) ]; then
  echo Est ce que $((a)) est égal à $((b)) ?
  echo $((a)) est égal à $((b))
else
  echo Est ce que $((a)) est égal à $((b)) ?
  echo $((a)) n\'est pas égal à $((b))
fi
if [ $((a)) -ne $((b)) ]; then
  echo Est ce que $((a)) est différent de $((b)) ?
  echo $((a)) est différent de $((b))
else
  echo Est ce que $((a)) est différent de $((b)) ?
  echo $((a)) n\'est pas différent de $((b))
fi
if [ $((a)) -gt $((b)) ]; then
  echo Est ce que $((a)) est supérieur à $((b)) ?
  echo $((a)) est supérieur à $((b))
else
  echo Est ce que $((a)) est supérieur à $((b)) ?
  echo $((a)) n\'est pas supérieur à $((b))
fi
if [ $((a)) -lt $((b)) ]; then
  echo Est ce que $((a)) est inférieur à $((b)) ?
  echo $((a)) est inférieur à $((b))
else
  echo Est ce que $((a)) est inférieur à $((b)) ?
  echo $((a)) n\'est pas inférieur à $((b))
fi
if [ $((a)) -ge $((b)) ]; then
  echo Est ce que $((a)) est supérieur ou égal à $((b)) ?
  echo $((a)) est supérieur ou égal à $((b))
else
  echo Est ce que $((a)) est supérieur ou égal à $((b)) ?
  echo $((a)) n\'est pas supérieur ou égal à $((b))
fi
if [ $((a)) -le $((b)) ]; then
  echo Est ce que $((a)) est inférieur ou égal à $((b)) ?
  echo $((a)) est inférieur ou égal à $((b))
else
  echo Est ce que $((a)) est inférieur ou égal à $((b)) ?
  echo $((a)) n\'est pas inférieur ou égal à $((b))
fi
echo
```

```
chmod +x op-relational.sh
```

```
./op-relational.sh
```

### Exemples de scripts

- Recherche de l'existence d'un repertoire

```
vi ifdircheck.sh
```

```
#!/bin/bash

echo
read -p "Entrez un chemin de répertoire à rechercher : " DIRECTORY
if [ -d $DIRECTORY ]; then
  echo "Le repertoire ($DIRECTORY) exite."
else
  echo "Le repertoire ($DIRECTORY) n'exite pas."
fi
echo
```

```
chmod +x ifdircheck.sh
```

```
./ifdircheck.sh
```

- Recherche de l'existence d'un fichier


```
vi iffilecheck.sh
```

```
#!/bin/bash

echo
read -p "Entrez un chemin de fichier à rechercher : " FILE
if [ -f $FILE ]; then
  echo "Le fichier ($FILE) exite."
else
  echo "Le fichier ($FILE) n'exite pas."
fi
echo
```

```
chmod +x iffilecheck.sh
```

```
./iffilecheck.sh
```

- Utilisation de **elif**

```
vi ifelif.sh
```

```
#!/bin/bash

echo
read -p "Entrez un nombre entre 1 et 100 : " a
echo
if [ $a -ge 75 ]; then
  echo $a "est supérieur ou égal à 75"
elif [ $a -ge 50 ]; then
  echo $a "est supérieur ou égal à 50"
else
  echo $a "est inférieur ou égal à 50"
fi
echo
```

```
chmod +x ifelif.sh
```

```
./ifelif.sh
```