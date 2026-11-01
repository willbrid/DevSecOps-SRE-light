# Introduction

Ce contenu présente les principales **expansions** des shells (Bash, Zsh…) :
- **expansion d'accolades** (*brace expansion*)
- **expansion de paramètres** (*parameter expansion*)
- **substitution de commande** (*command substitution*)
- **génération de noms de fichiers** (*globbing*)

Elles permettent de **générer des séquences**, **extraire des sous-chaînes**, **capturer la sortie d'une commande** et **sélectionner plusieurs fichiers** d'un coup, ce qui simplifie scripts et lignes de commande.

> L'**expansion d'accolades n'est pas POSIX** (elle existe dans Bash, Zsh, Ksh, pas dans `dash`/`sh`). Les trois autres le sont, au moins dans leurs formes de base.

### 1. Tableau des types d'expansion

| Type | Description | Exemple |
||||
| **Accolades** | Génère des chaînes à partir d'une liste ou d'une plage | `echo {A,B,C}` → `A B C` |
| **Paramètres** | Manipule la valeur d'une variable (sous-chaînes, valeurs par défaut…) | `${var###*/}` → supprime le plus long préfixe `*/` |
| **Substitution de commande** | Insère la sortie d'une commande dans une autre | `echo "Date: $(date +%F)"` |
| **Noms de fichiers (globs)** | Sélectionne des fichiers avec des jokers | `ls *.txt` → tous les `.txt` |

> Ordre dans lequel Bash applique les expansions : **accolades → tilde (`~`) → paramètres/variables, arithmétique `$(( ))`, substitution de commande → découpage en mots → noms de fichiers (globs) → suppression des guillemets**.

### 2. Expansion d'accolades

Génère rapidement des chaînes arbitraires. C'est un mécanisme **purement textuel** : ni variables, ni globs.

```bash
# Génère A, B, C
echo {A,B,C}

# Génère les nombres de 1 à 5
echo {1..5}
```

> Les accolades **ne doivent pas être entre guillemets** : `echo "{A,B}"` affiche littéralement `{A,B}`.

> Exemples supplémentaires (non présents dans la leçon) :
> ```bash
> echo {1..10..2}             # 1 3 5 7 9        (pas de 2)
> echo {01..05}               # 01 02 03 04 05   (zéros conservés)
> echo {a..e}                 # a b c d e
> echo file{1..3}.txt         # file1.txt file2.txt file3.txt
> mkdir -p projet/{src,docs,tests}
> cp config.yaml{,.bak}       # = cp config.yaml config.yaml.bak
> ```
> Les variables ne marchent pas dans une plage : `{1..$n}` ne fonctionne pas → utiliser `seq 1 "$n"` ou `for ((i=1; i<=n; i++))`.

### 3. Expansion de paramètres

Permet d'**examiner ou transformer** la valeur d'une variable **sans appeler de commande externe** (donc rapide).

#### Expansion simple

```bash
USER_HOME=$HOME
echo "Your home directory is: $USER_HOME"
```

#### Supprimer le chemin (garder le nom de fichier)

`###*/` supprime le **plus long préfixe** correspondant à `*/`, c'est-à-dire tout jusqu'au **dernier** `/` :

```bash
#!/usr/bin/env bash

some_script="/usr/bin/my_script.sh"
# Supprime la plus longue correspondance de '*/' au début
echo "${some_script###*/}"
```

Sortie :

```bash
$ ./expansions.sh
my_script.sh
```

> Toujours **mettre les expansions entre guillemets** (`"${var}"`) pour éviter le découpage en mots et le globbing inattendus.

> Formes les plus utiles :
> ```bash
> pathname="/usr/bin/my_script.sh"
>
> echo "${pathname###*/}"     # my_script.sh   → ### : plus long préfixe supprimé (≈ basename)
> echo "${pathname#*/}"      # usr/bin/my_script.sh → # : plus court préfixe
> echo "${pathname%/*}"      # /usr/bin       → % : plus court suffixe (≈ dirname)
> echo "${pathname%.*}"      # /usr/bin/my_script → retire l'extension
> echo "${pathname###*.}"     # sh             → l'extension seule
>
> echo "${#pathname}"        # 21             → longueur
> echo "${pathname:5:3}"     # bin            → sous-chaîne (position 5, 3 caractères)
> echo "${pathname/bin/sbin}"  # remplace la 1re occurrence ; // pour toutes
>
> echo "${NAME:-invité}"   # valeur par défaut si NAME vide/non définie
> : "${PORT:=8080}"        # assigne 8080 si PORT vide/non définie
> echo "${TOKEN:?manquant}" # erreur et arrêt si TOKEN vide/non définie
> ```

### 4. Substitution de commande

Capture le **stdout** d'une commande et l'insère dans une autre commande ou une variable :

```bash
current_date=$(date +%Y-%m-%d)
echo "Today is $current_date"
```

> Remarques :
> - Ancienne syntaxe : `` `date` `` (backticks). Préférer `$(…)`, plus lisible et **imbricable** : `$(dirname "$(readlink -f "$0")")`.
> - Les **retours à la ligne finaux** sont supprimés automatiquement.
> - La commande s'exécute dans un **sous-shell** (les variables qu'elle modifie ne remontent pas).
> - Ne pas confondre avec l'**arithmétique** `$(( 2 + 3 ))` → `5`.

### 5. Génération de noms de fichiers (globbing)

Les **jokers** permettent de sélectionner des fichiers :

```bash
# Lister tous les fichiers .log
ls *.log

# Correspondance récursive dans les sous-répertoires
shopt -s globstar
echo **/*.md
```

> Précision : `**` récursif dépend de l'option **`globstar`** (Bash 4+). `extglob` est une **autre** option qui active des motifs étendus comme `!(*.log)` (tout sauf les `.log`).

> Jokers de base :
> | Motif | Correspond à |
> |||
> | `*` | n'importe quelle suite de caractères (sauf fichiers cachés `.xxx`) |
> | `?` | exactement **un** caractère |
> | `[abc]` / `[a-z]` | un caractère de l'ensemble / de la plage |
> | `[!abc]` | un caractère **hors** de l'ensemble |
>
> ```bash
> ls file?.txt        # file1.txt, fileA.txt…
> ls [0-9]*.log       # fichiers .log commençant par un chiffre
> ```
> Si aucun fichier ne correspond, Bash laisse le motif **tel quel** (`*.log` littéral). Option `shopt -s nullglob` pour obtenir une liste vide à la place.
> Les globs ne sont **pas** interprétés entre guillemets : `ls "*.log"` cherche un fichier nommé `*.log`.

### À retenir

- 4 expansions principales : **accolades**, **paramètres**, **substitution de commande**, **globs**.
- Accolades `{A,B}`, `{1..5}`, `{1..10..2}` : génération de texte pure, **pas entre guillemets**, pas de variables dans les plages, non POSIX.
- Paramètres : `${var###*/}` (basename), `${var%/*}` (dirname), `${var%.*}` (sans extension), `${#var}` (longueur), `${var:-défaut}`.
- `#` = supprime au **début**, `%` = à la **fin** ; simple = plus court, double = plus long.
- Substitution de commande : `$(cmd)` (préférer aux backticks), exécutée dans un sous-shell.
- Globs : `*`, `?`, `[…]` ; `**` récursif avec `shopt -s globstar` ; `extglob` pour `!(…)` ; `nullglob` si aucun résultat.
- Toujours **guillemets** autour des expansions de variables (`"$var"`, `"$(cmd)"`).

### Liens utiles

- [GNU Bash – Shell Expansions](https://www.gnu.org/software/bash/manual/html_node/Shell-Expansions.html)
- [GNU Bash – Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [GNU Bash – Filename Expansion (globs)](https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html)
- [GNU Bash – The Shopt Builtin (globstar, extglob, nullglob)](https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html)
