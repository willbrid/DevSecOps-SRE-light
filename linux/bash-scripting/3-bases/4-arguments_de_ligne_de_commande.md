# Arguments de ligne de commande

Les arguments en ligne de commande rendent les scripts **flexibles et réutilisables** : au lieu de coder des valeurs en dur, on les fournit **au moment de l'exécution**.

### 1. Les paramètres positionnels

Quand on lance un script avec des arguments :

```bash
$ ./myscript.sh foo bar baz
```

Dans le script, chaque argument est accessible via `$1`, `$2`, `$3`… :

```bash
#!/bin/bash
echo "First argument: $1"
echo "Second argument: $2"
echo "Third argument: $3"
```

Sortie :

```bash
First argument: foo
Second argument: bar
Third argument: baz
```

> Toujours **mettre les paramètres entre guillemets** pour gérer correctement les espaces et caractères spéciaux :
> ```bash
> echo "User provided: $1"
> ```

> Au-delà de 9, il faut des accolades : `${10}`, `${11}`… (`$10` serait interprété comme `$1` suivi de `0`).


### 2. Exemple pratique : cloner un dépôt et compter les fichiers

Version **codée en dur** :

```bash
#!/bin/bash

git clone git@github.com:kodedkloud/kodekloud-advanced-shell-scripting.git
find . -type f | wc -l
```

Ça fonctionne, mais il faut **modifier le script** pour chaque nouvelle URL de dépôt.

### 3. Paramétrer le script

En utilisant `$1`, l'URL est passée au lancement :

```bash
#!/bin/bash

# Cloner le dépôt passé en 1er argument
git clone "$1"

# Compter les fichiers du dépôt cloné
find . -type f | wc -l
```

Exécution :

```bash
$ ./clone-and-count.sh git@github.com:kodedkloud/kodekloud-advanced-shell-scripting.git
```

Le script peut maintenant cloner **n'importe quel dépôt**.

### 4. Variables spéciales courantes

| Variable | Description | Exemple de sortie |
||||
| `$0` | Nom du script | `./myscript.sh` |
| `$1`, `$2`, … | 1er, 2e, … argument | `apple banana` |
| `$#` | Nombre total d'arguments | `3` |
| `$@` | Tous les arguments, chacun comme un mot séparé | `apple banana cherry` |
| `$*` | Tous les arguments en une seule chaîne (`"$*"` les concatène) | `apple banana cherry` |

Exemple :

```bash
#!/bin/bash
echo "Script name: $0"
echo "Number of arguments: $#"
echo "All arguments (\$@): $@"
```

```bash
$ ./myscript.sh apple banana cherry
Script name: ./myscript.sh
Number of arguments: 3
All arguments ($@): apple banana cherry
```

> La différence entre `$@` et `$*` se voit **entre guillemets** :
> - `"$@"` → `"apple" "banana" "cherry"` (3 mots distincts, respecte les espaces internes)
> - `"$*"` → `"apple banana cherry"` (1 seule chaîne)
>
> Dans une boucle, on utilise presque toujours `for arg in "$@"`.

### 5. Taille maximale des arguments (`ARG_MAX`)

Les systèmes Unix limitent la **taille totale** des arguments d'une commande. Pour la connaître :

```bash
$ getconf ARG_MAX
1048576
```

Sur la plupart des distributions Linux, cette limite est de l'ordre du **Mio** (souvent 2 Mio sur les systèmes récents), largement suffisant pour des dizaines de milliers de petits arguments.

> Dépasser `ARG_MAX` provoque l'erreur **« Argument list too long »**. Pour les traitements en masse, utiliser `xargs` ou lire les données depuis un fichier.

Exemple de contournement avec `xargs` :

```bash
find . -name "*.log" -print0 | xargs -0 rm
```

### 6. Parcourir les arguments avec `shift`

`shift` **supprime `$1`** et décale tous les autres paramètres d'un cran (`$2` devient `$1`, etc.) et `$#` diminue de 1. Pratique quand on ne connaît pas le nombre d'arguments à l'avance :

```bash
#!/bin/bash

# Boucle sur tous les arguments
while [ $# -gt 0 ]; do
  echo "Current argument: $1"
  shift
done
```

```bash
$ ./shift-example.sh arg1 arg2 arg3
Current argument: arg1
Current argument: arg2
Current argument: arg3
```

> `shift n` décale de `n` positions d'un coup (utile pour une option suivie de sa valeur, ex. `-o fichier`).

### À retenir

- `$1`, `$2`… = arguments positionnels ; `${10}` et au-delà nécessitent des accolades.
- `$0` = nom du script, `$#` = nombre d'arguments.
- `"$@"` conserve chaque argument séparément ; `"$*"` les fusionne en une seule chaîne.
- **Toujours mettre les variables entre guillemets** (`"$1"`, `"$@"`).
- Paramétrer un script évite de le modifier à chaque nouvelle valeur.
- `getconf ARG_MAX` donne la limite de taille des arguments ; au-delà → « Argument list too long » → utiliser `xargs`.
- `shift` consomme `$1` et décale le reste : combiné à `while [ $# -gt 0 ]`, il permet de traiter un nombre inconnu d'arguments.

### Liens utiles

- [Bash Reference Manual (GNU)](https://www.gnu.org/software/bash/manual/bash.html)
- [man getconf](https://man7.org/linux/man-pages/man1/getconf.1.html)
- [man find](https://man7.org/linux/man-pages/man1/find.1.html)
- [man wc](https://man7.org/linux/man-pages/man1/wc.1.html)
