# Expansion de paramètres Part1

En Bash, l'**expansion de paramètres** permet de **transformer la valeur d'une variable** à l'aide de **motifs** placés dans `${}`.

```bash
#!/usr/bin/env bash
path="/home/user/file.txt"
echo "${path/file.txt/data}"
# Sortie : /home/user/data
```

Ce contenu se concentre sur les **motifs** et sur la **suppression de préfixes et de suffixes**.

### 1. Les motifs (patterns) en Bash

Un **motif** est une suite de caractères que le shell reconnaît pour **comparer** ou **substituer**. On les retrouve dans :
- le **globbing** de fichiers (`*.txt`) ;
- le **traitement de texte** ;
- la **validation de données**.

En Bash, les motifs alimentent l'expansion de paramètres et permettent de transformer une variable **sans outil externe** (`sed`, `cut`, `basename`…).

> Les motifs utilisent les mêmes jokers que les globs : `*` (n'importe quelle suite), `?` (un caractère), `[…]` (un caractère parmi un ensemble).

### 2. Expansion de variable vs expansion de paramètres

Par défaut, `${var}` renvoie simplement sa valeur :

```bash
name="John Doe"
echo "Hello, ${name}"
# Hello, John Doe
```

Dès qu'on ajoute un **opérateur** comme `#` (préfixe) ou `%` (suffixe) dans les accolades, Bash applique une **modification basée sur un motif**.

> Toujours entourer l'expression de **guillemets doubles** (`"${...}"`) pour préserver les espaces et éviter le découpage en mots.

> La variable d'origine **n'est jamais modifiée** : l'expansion produit une **nouvelle valeur**. Pour la conserver : `new="${var#motif}"`.

### 3. Supprimer des préfixes et des suffixes

Bash supprime le **plus court** préfixe ou suffixe correspondant avec :
- `${var#motif}` → au **début** ;
- `${var%motif}` → à la **fin**.

#### Comprendre préfixe et suffixe

Exemple de postes dans une entreprise IT :
- Mid DevOps Engineer
- Jr. Software Engineer
- Sr. DevOps Engineer
- Associate DevOps Engineer

→ les **préfixes** (Associate, Sr., Jr., Mid) indiquent le **niveau** ; le **suffixe** (`Engineer`) indique le **domaine**.

> Application avec l'expansion :
> ```bash
> title="Sr. DevOps Engineer"
> echo "${title#* }"         # DevOps Engineer   → retire le niveau (jusqu'au 1er espace)
> echo "${title% Engineer}"  # Sr. DevOps        → retire le suffixe
> ```

#### Supprimer un préfixe avec `#`

`#` supprime le **plus court motif correspondant au début** de la chaîne (✂️ côté gauche).

**Exemple 1** : retirer le `H` initial :

```bash
greetings="Hello World"
echo "${greetings#H}"
# Sortie : ello World
```

Si le motif n'est **pas au début**, la valeur reste **inchangée** :

```bash
echo "${greetings#e}"
# Sortie : Hello World
```

**Exemple 2** : retirer « Hello » + l'espace :

```bash
echo "${greetings#Hello }"
# Sortie : World
```

Les motifs sont **sensibles à la casse** : `h` ne correspond pas à `H`.

```bash
echo "${greetings#h}"
# Sortie : Hello World
```

#### Supprimer un suffixe avec `%`

`%` supprime le **plus court motif correspondant à la fin** de la chaîne.

**Exemple 1** : retirer le `d` final :

```bash
echo "${greetings%d}"
# Sortie : Hello Worl
```

**Exemple 2** : retirer « rld » à la fin :

```bash
echo "${greetings%rld}"
# Sortie : Hello Wo
```

Si le suffixe ne correspond pas **exactement** (casse comprise), la chaîne reste identique :

```bash
echo "${greetings%world}"
# Sortie : Hello World
```

> La correspondance est **sensible à la casse** : le motif doit respecter exactement les majuscules/minuscules.

### 4. Le « plus court » avec des jokers

La notion de **plus court** n'a vraiment d'importance qu'avec des **jokers** (`*`) : sans joker, il n'y a qu'une seule correspondance possible.

> Exemples :
> ```bash
> greetings="Hello World"
> echo "${greetings#*o}"    #  World    → supprime jusqu'au 1er "o" (plus court)
> echo "${greetings%o*}"    # Hello W   → supprime depuis le dernier "o" (plus court)
>
> file="archive.tar.gz"
> echo "${file%.*}"         # archive.tar  → retire la dernière extension
> echo "${file#*.}"         # tar.gz       → retire le nom jusqu'au 1er point
>
> path="/home/user/file.txt"
> echo "${path%/*}"         # /home/user   → équivalent de dirname
> ```

### 5. Tableau récapitulatif

| Opérateur | Action | Exemple |
||||
| `${var#motif}` | Supprime le **plus court préfixe** correspondant | `${greetings#Hello }` → `World` |
| `${var%motif}` | Supprime le **plus court suffixe** correspondant | `${greetings%rld}` → `Hello Wo` |

Moyen mnémotechnique : **`#` = préfixe** (bleu), **`%` = suffixe** (rouge).

### À retenir

- `${var#motif}` → supprime le **plus court préfixe** ; `${var%motif}` → le **plus court suffixe**.
- Si le motif ne correspond pas **exactement** au début/à la fin, la valeur est **inchangée** (pas d'erreur).
- La correspondance est **sensible à la casse**.
- Les motifs acceptent les jokers `*`, `?`, `[…]` ; « plus court » compte surtout avec `*`.
- La variable d'origine **n'est pas modifiée** ; stocker le résultat si besoin.
- Toujours entre guillemets : `"${var#motif}"`.
- Cas pratiques : `${f%.*}` (sans extension), `${path%/*}` (dossier parent), `${title#* }` (retirer le 1er mot).
- Mnémotechnique : `#` à gauche → **début** ; `%` à droite → **fin**.

### Liens utiles

- [GNU Bash – Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [GNU Bash – Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
