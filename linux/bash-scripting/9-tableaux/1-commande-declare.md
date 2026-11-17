# Commande intégrée `declare`

La commande intégrée **`declare`** (alias **`typeset`**) permet d'attribuer des **attributs** et des **types** aux variables. Bash est **dynamiquement typé**, mais `declare` permet d'imposer un type (entier), de créer des variables **en lecture seule** et de définir des **tableaux**.

### 1. Les types de données en Bash

Bash propose deux types fondamentaux :
1. **Chaîne** (*string*)
2. **Entier** (*integer*)

```bash
# Affectation d'une chaîne
name="John Doe"
echo "$name"   # John Doe

# Affectation d'un entier
count=10
echo "$count"  # 10
```

> Précision : en interne, **toutes** les variables Bash sont stockées comme des **chaînes**. `count=10` stocke la chaîne `"10"` ; c'est le **contexte** (arithmétique `$(( ))`, `-eq`…) qui la traite comme un nombre. Bash ne gère **pas les décimaux** en arithmétique (`$(( 5 / 2 ))` → `2`) : utiliser `bc` ou `awk` pour les flottants.

### 2. Variables à typage dynamique

Bash détermine le « type » **à l'exécution**, selon le contexte :

```bash
#!/usr/bin/env bash
var="10"
echo $(( var + 1 ))   # 11
```

Une variable peut même **changer de type** en cours de route :

```bash
#!/usr/bin/env bash
i="42"
echo $(( i + 8 ))   # 50

i="hello"
echo "$i"           # hello
```

> Le typage dynamique signifie que Bash interprète les valeurs à l'exécution : **aucune erreur** de type n'est détectée à l'avance.

### 3. Imposer un entier avec `declare -i`

Pour obtenir un comportement d'**entier** (imitant un typage statique) :

```bash
#!/usr/bin/env bash
declare -i num=5
echo $(( num + 2 ))   # 7

num="not a number"
echo "$num"           # 0
```

> Correction : avec `-i`, toute valeur affectée est **évaluée comme une expression arithmétique** :
> ```bash
> declare -i num
> num="3 + 4"      ; echo "$num"   # 7       → calculé
> num=hello        ; echo "$num"   # 0       → "hello" est lu comme un NOM de variable (vide → 0)
> hello=42
> num=hello        ; echo "$num"   # 42      → valeur de la variable hello !
> num="not a number"               # ❌ erreur : syntax error in expression
> num+=5           ; echo "$num"   # 47      → += fait une addition (pas une concaténation)
> ```
> `declare -i` n'est donc **pas une validation** : pour vérifier qu'une saisie est numérique, utiliser une regex : `[[ $val =~ ^-?[0-9]+$ ]]`.

### 4. Autres options de `declare`

| Option | Description | Exemple |
|---|---|---|
| `-i` | Entier | `declare -i counter=100` |
| `-r` | Lecture seule | `declare -r PI=3.1415` |
| `-u` | Convertit la valeur en **majuscules** | `declare -u animal="dog"` → `DOG` |
| `-l` | Convertit la valeur en **minuscules** | `declare -l word="HELLO"` → `hello` |

> Autres options très utiles :
> | Option | Description |
> |---|---|
> | `-a` | Tableau indexé |
> | `-A` | Tableau associatif |
> | `-x` | **Exporte** la variable (équivalent d'`export`) |
> | `-p` | **Affiche** la déclaration d'une variable (`declare -p num`) |
> | `-n` | **Nameref** : référence vers une autre variable (Bash 4.3+) |
> | `-g` | Variable **globale** même déclarée dans une fonction |
> | `-f` / `-F` | Liste les fonctions (corps / noms seulement) |
>
> `+` retire un attribut : `declare +i num`.
> `declare` **dans une fonction** crée une variable **locale** (comme `local`), sauf avec `-g`.

#### Lecture seule (`-r`)

```bash
#!/usr/bin/env bash
declare -r VERSION="1.0.0"
echo "$VERSION"
VERSION="2.0.0"  # Erreur : readonly variable
```

> Précision : Bash affiche `VERSION: readonly variable` et l'affectation **échoue** (code 1). Selon le contexte, le script peut **continuer** (mode Bash par défaut) ou s'arrêter (avec `set -e` ou en mode POSIX). Dans tous les cas, la valeur **n'est pas modifiée**, et l'attribut ne peut **pas être retiré** (`unset` échoue aussi).
> `readonly VERSION="1.0.0"` est équivalent à `declare -r`.

#### Conversion de casse (`-u`, `-l`)

```bash
#!/usr/bin/env bash
declare -u upper
declare -l lower

upper="Bash Rocks"
lower="Bash Rocks"

echo "$upper"  # BASH ROCKS
echo "$lower"  # bash rocks
```

La conversion s'applique **automatiquement à chaque affectation**.

> Utile pour normaliser une saisie : `declare -l answer; read -r answer; [[ $answer == yes ]]` accepte `YES`, `Yes`… (Bash 4+).
> Sans `declare` : `${var^^}` (majuscules) et `${var,,}` (minuscules).

### 5. Les tableaux : `declare -a` et `declare -A`

Bash gère les tableaux **indexés** et **associatifs** :

```bash
#!/usr/bin/env bash

# Tableau indexé
declare -a fruits=("apple" "banana" "cherry")
echo "${fruits[1]}"    # banana

# Tableau associatif
declare -A colors
colors[sky]=blue
colors[rose]=red
echo "${colors[rose]}" # red
```

| Type | Déclaration | Accès |
|---|---|---|
| Tableau indexé | `declare -a arr` | `${arr[index]}` |
| Tableau associatif | `declare -A map` | `${map[clé]}` |

> - Les index commencent à **0** (`fruits[1]` = 2ᵉ élément).
> - `declare -a` est **facultatif** (`fruits=(…)` suffit), mais **`declare -A` est obligatoire** pour un tableau associatif.
> - Les tableaux associatifs nécessitent **Bash 4+** (absent du Bash 3.2 de macOS).
>
> Opérations courantes :
> ```bash
> echo "${fruits[@]}"      # tous les éléments
> echo "${#fruits[@]}"     # nombre d'éléments : 3
> fruits+=("date")         # ajouter un élément
> echo "${!colors[@]}"     # toutes les clés : sky rose
>
> for key in "${!colors[@]}"; do
>     echo "$key → ${colors[$key]}"
> done
>
> declare -p colors        # afficher le contenu complet (débogage)
> ```

### À retenir

- `declare` (= `typeset`) attribue des **attributs** aux variables ; Bash reste fondamentalement « tout chaîne ».
- `-i` : la valeur est **évaluée arithmétiquement** (`"3+4"` → 7, un mot = nom de variable, `+=` additionne) → ce n'est **pas** une validation.
- `-r` (= `readonly`) : modification refusée, attribut irréversible.
- `-u` / `-l` : conversion automatique en majuscules / minuscules (Bash 4+).
- `-a` tableau indexé (index à partir de 0) ; `-A` tableau associatif (**obligatoire**, Bash 4+).
- `-x` exporte, `-p` affiche la déclaration, `-g` force le global dans une fonction ; `+X` retire un attribut.
- `declare` dans une fonction = variable **locale**.
- Pas de flottants en arithmétique Bash → `bc` / `awk`.

### Liens utiles

- [GNU Bash – Bash Builtins (`declare`, `typeset`, `readonly`)](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)
- [GNU Bash – Arrays](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)
- [GNU Bash – Shell Arithmetic](https://www.gnu.org/software/bash/manual/html_node/Shell-Arithmetic.html)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [KornShell – documentation (`typeset`)](https://www.kornshell.com/doc/sections/toc.html)
