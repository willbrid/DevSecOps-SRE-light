# Printf

Sous Unix, `printf` est une commande **standard POSIX** qui produit une **sortie formatée**. Comparée à `echo`, elle offre un contrôle précis du **format**, de la **largeur des champs**, de l'**alignement** et des **séquences d'échappement**.

La leçon présente `printf` comme un **exécutable externe** (donc un léger coût de performance à chaque appel), en échange de ces capacités de formatage.

> Correction importante : en **Bash**, `printf` est aussi un **built-in** (comme `echo`). Il ne crée donc **pas** de nouveau processus :
> ```bash
> $ type printf
> printf is a shell builtin
> $ type -a printf
> printf is a shell builtin
> printf is /usr/bin/printf
> ```
> Le binaire `/usr/bin/printf` existe (coreutils), mais Bash utilise le built-in en priorité (cf. leçon sur les built-ins). Le choix entre `echo` et `printf` est donc une question de **portabilité et de formatage**, pas de performance.


### 1. echo vs printf

`echo` est traité directement par le shell :

```bash
$ echo "Hello, world!"
Hello, world!
```

`printf` :

```bash
$ printf "Hello, printf!\n"
Hello, printf!
```

Différences clés :
- `printf` **n'ajoute pas** de retour à la ligne automatiquement → il faut écrire `\n`.
- `printf` offre un formatage plus riche et un comportement **identique d'un shell à l'autre**.

Capacités mises en avant : ✅ formater le texte précisément ✅ alignement à gauche ✅ alignement à droite.

### 2. Spécificateurs de format

Comme le `printf()` du langage C :

| Spécificateur | Description | Exemple |
||||
| `%s` | Chaîne | `printf "%s\n" "text"` |
| `%d` | Entier signé | `printf "%d\n" 42` |
| `%f` | Nombre à virgule flottante | `printf "%.2f\n" 3.14159` → `3.14` |
| `%o` | Octal | `printf "%o\n" 10` → `12` |
| `%x` / `%X` | Hexadécimal (minuscule/majuscule) | `printf "%x\n" 255` → `ff` |
| `%%` | Signe `%` littéral | `printf "%%\n"` → `%` |

#### Exemple : chaînes et nombres

```bash
#!/usr/bin/env bash
course="Advanced Shell Scripting"
printf "Welcome to the %s\n" "$course"

name="Alice"
age=28
weight=65.2
printf "Name: %s | Age: %d | Weight: %.1f kg\n" \
    "$name" "$age" "$weight"
```

Sortie :

```bash
Welcome to the Advanced Shell Scripting
Name: Alice | Age: 28 | Weight: 65.2 kg
```

- `%.1f` : 1 chiffre après la virgule.
- Les arguments remplacent les spécificateurs **dans l'ordre**.

Autres possibilités : **nombres flottants**, **largeur des entiers**, **alignement**…

> Exemples de largeur et d'alignement :
> ```bash
> printf "|%10s|\n" "droite"     # |    droite|   (largeur 10, aligné à droite)
> printf "|%-10s|\n" "gauche"    # |gauche    |   (- = aligné à gauche)
> printf "|%5d|\n" 42            # |   42|
> printf "|%05d|\n" 42           # |00042|        (complété par des zéros)
> printf "|%8.2f|\n" 3.14159     # |    3.14|
> ```
> Tableau aligné :
> ```bash
> printf "%-10s %5s\n" "POD" "CPU"
> printf "%-10s %5d\n" "nginx" 120 "redis" 45
> # POD          CPU
> # nginx        120
> # redis         45
> ```
> Si on fournit **plus d'arguments** que de spécificateurs, le format est **réutilisé** (d'où les 2 lignes ci-dessus).

### 3. Séquences d'échappement et portabilité

Les shells gèrent les échappements d'`echo` de manière **incohérente** :

```bash
$ echo "Line1\nLine2"
Line1\nLine2
$ echo -e "Line1\nLine2"
Line1
Line2
```

En Bash, `echo` n'interprète pas `\n` sans `-e`, alors que d'autres shells (ex. `dash` = `/bin/sh` sur Ubuntu) l'interprètent toujours… et peuvent même afficher littéralement `-e`.

`printf` interprète `\n`, `\t` et les autres échappements **par défaut**, partout :

```bash
$ printf "Line 1\nLine 2\n"
Line 1
Line 2
```

> Éviter `echo -e` dans les scripts : utiliser `printf` pour un résultat identique sous Bash, Dash, Zsh et autres shells POSIX.

> Bonne pratique : ne **jamais** mettre une variable directement dans le format :
> ```bash
> printf "$var\n"        # ❌ si $var contient "%" ou "\", résultat faussé
> printf "%s\n" "$var"   # ✅
> ```

### 4. Code de retour et comptage de caractères

`printf` renvoie un code de sortie (`0` en cas de succès), et on peut compter les caractères affichés avec `wc -c` :

```bash
#!/usr/bin/env bash
message="Hello, world!"
if printf "%s" "$message"; then
    count=$(printf "%s" "$message" | wc -c)
    echo -e "\nPrinted $count characters successfully."
else
    echo "Error: printf failed with code $?"
fi
```

Sortie :

```text
Hello, world!
Printed 13 characters successfully.
```

- `printf "%s"` sans `\n` → `wc -c` compte exactement les **13** caractères (avec `echo`, on aurait 14 à cause du retour à la ligne).
- Le `\n` au début du `echo -e` sert à revenir à la ligne après le premier `printf`.

> Remarques :
> - L'exemple utilise `echo -e`, que la leçon recommande justement d'éviter ; version cohérente : `printf "\nPrinted %d characters successfully.\n" "$count"`.
> - Alternative sans sous-processus : `${#message}` donne directement la longueur (13).
> - Spécifique Bash : `printf -v var` stocke le résultat dans une variable au lieu de l'afficher :
>   ```bash
>   printf -v date_fmt "%(%Y-%m-%d)T" -1
>   echo "$date_fmt"     # 2026-10-29
>   ```

### À retenir

- `printf` = sortie **formatée**, standard **POSIX**, comportement identique dans tous les shells.
- En Bash, `printf` est un **built-in** (`type printf`) ; `/usr/bin/printf` existe aussi.
- Pas de retour à la ligne automatique : penser au **`\n`**.
- Spécificateurs : `%s` chaîne, `%d` entier, `%f` flottant (`%.2f`), `%o` octal, `%x`/`%X` hexa, `%%` pour `%`.
- Largeur/alignement : `%10s` (droite), `%-10s` (gauche), `%05d` (zéros).
- Format **réutilisé** s'il y a plus d'arguments que de spécificateurs → pratique pour les tableaux.
- Préférer `printf` à `echo -e` pour les échappements (`\n`, `\t`).
- Toujours `printf "%s" "$var"` plutôt que `printf "$var"`.
- `printf -v var …` (Bash) stocke le résultat dans une variable.

### Liens utiles

- [POSIX – printf](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html)
- [GNU Coreutils – printf invocation](https://www.gnu.org/software/coreutils/manual/html_node/printf-invocation.html)
- [GNU Bash – Bash Builtins (printf)](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)
