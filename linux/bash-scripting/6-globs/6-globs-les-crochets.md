# Globs : les crochets

En globbing, `*` correspond à n'importe quelle chaîne et `?` à un seul caractère. Les **crochets** `[ ]` définissent une **classe de caractères** : ils correspondent à **un seul caractère** choisi dans un **ensemble** ou une **plage**.

### 1. Correspondre à une plage de caractères

```bash
$ ls
fileA fileB fileC fileD fileE
```

Sélectionner uniquement `fileA`, `fileB` et `fileC` avec une plage :

```bash
$ ls file[A-C]
fileA fileB fileC
```

`[A-C]` correspond à une lettre majuscule de A à C. Le tiret `-` définit une plage qui doit aller **du plus petit au plus grand** :

```bash
$ ls file[C-A]
ls: cannot access 'file[C-A]': No such file or directory
```

(Plage invalide → aucune correspondance → le motif reste littéral.)

#### Exemples courants

| Motif | Correspond à | Description |
||||
| `file[A-C]` | fileA, fileB, fileC | Majuscules A à C |
| `file[a-c]` | filea, fileb, filec | Minuscules a à c |
| `file[1-3]` | file1, file2, file3 | Chiffres 1 à 3 |
| `file[ACE]` | fileA, fileC, fileE | Lettres précises A, C, E |

> Rappel : quelle que soit la longueur de ce qu'il contient, un `[…]` correspond toujours à **un seul** caractère.

### 2. Classes négatives (exclusion)

Un `!` ou un `^` **au début** des crochets exclut les caractères ou plages indiqués :

```bash
$ ls
fileA fileB fileC fileD fileE

$ ls file[^A-C]
fileD fileE

$ ls file[!A-C]
fileD fileE
```

> En Bash, `!` et `^` fonctionnent tous les deux. Les shells **POSIX** exigent `!` → le préférer dans les scripts portables.

Les crochets sont des caractères spéciaux du shell servant à créer des expressions glob qui correspondent aux caractères qu'ils contiennent.

### 3. Lister des caractères précis

Pour des noms non consécutifs comme `fileA`, `fileC` et `fileE`, on les liste simplement :

```bash
$ ls file[ACE]
fileA fileC fileE
```

### 4. Sensibilité à la casse

Le globbing Bash est **sensible à la casse**. Avec des fichiers en majuscules et en minuscules :

```bash
$ touch filea fileb filec filed filee
$ ls
fileA fileB fileC fileD fileE filea fileb filec filed filee
```

Seulement les minuscules :

```bash
$ ls file[a-c]
filea fileb filec
```

Supprimer les minuscules **et** les majuscules de a à e en combinant les plages :

```bash
$ rm file[a-eA-E]
$ ls
fileD fileE
```

Ce contenu conseille de lister les plages dans l'ordre voulu (`a-e` avant `A-E`).

> Corrections :
> - `[a-eA-E]` correspond à **a, b, c, d, e, A, B, C, D, E** : la commande supprime donc les **10 fichiers**, y compris `fileD` et `fileE`. Le `ls` suivant ne les affiche plus (le dossier est vide, d'où la suite de la leçon qui recrée des fichiers).
> - L'**ordre** des plages dans les crochets **n'a aucune importance** : `[a-eA-E]` = `[A-Ea-e]`.
> - Toujours vérifier avant `rm` : `echo rm file[a-eA-E]`.

> Les plages comme `[a-z]` peuvent dépendre de la **locale** (sur d'anciennes versions/configurations, `[a-z]` incluait des majuscules). Pour un résultat fiable, utiliser les **classes POSIX** :
> ```bash
> ls file[[:lower:]]     # minuscules
> ls file[[:upper:]]     # majuscules
> ls file[[:digit:]]     # chiffres
> ls file[[:alnum:]]     # lettres et chiffres
> ```

### 5. Plages numériques et négation

Les plages de chiffres fonctionnent de la même manière :

```bash
$ touch file1 file2 file3 file4 file5
$ ls file[1-3]
file1 file2 file3

$ ls file[4-5]
file4 file5

$ ls file[^1-3]
file4 file5

$ ls file[!1-3]
file4 file5
```

> `file[^1-3]` exclut 1, 2, 3 mais accepterait **n'importe quel autre caractère** (lettres comprises). Le résultat n'est `file4 file5` que parce que les fichiers lettres ont été supprimés juste avant.

> Les crochets ne gèrent **qu'un caractère** : `[1-12]` = « 1 à 1, ou 2 » (soit `1` ou `2`), pas « 1 à 12 ». Pour plusieurs chiffres : `file[0-9][0-9]` ou `file{1..12}` (accolades).

### 6. Plusieurs classes à la suite

On peut **enchaîner** les classes pour contraindre plusieurs positions. Pour `filea1`, `filea2`, `fileb1`, `fileb2` :

```bash
$ touch filea1 filea2 filea3 fileb1 fileb2 fileb3

$ ls file[a-b][1-2]
filea1 filea2 fileb1 fileb2
```

- `[a-b]` → une lettre (a ou b) ;
- `[1-2]` → un chiffre (1 ou 2).

Avec seulement `[1-2]`, il manque la position de la lettre → aucune correspondance :

```bash
$ ls file[1-2]
ls: cannot access 'file[1-2]': No such file or directory
```

### 7. Caractères littéraux dans les crochets

À l'intérieur des crochets, les caractères spéciaux du glob **perdent leur sens** :

```bash
$ ls file[a][*]
ls: cannot access 'file[a][*]': No such file or directory
```

`[*]` correspond à une **étoile littérale** : le motif cherche le fichier `filea*`, qui n'existe pas.

Pour utiliser `*` comme joker, il faut le placer **hors des crochets** :

```bash
$ ls filea*
filea1 filea2 filea3
```

Ou contraindre les deux positions :

```bash
$ ls file[a][1-3]
filea1 filea2 filea3
```

> Astuce : `[*]`, `[?]` sont une autre façon d'**échapper** ces caractères (équivalent de `\*`, `\?`).
> Cas particuliers dans les crochets :
> - `]` littéral → le placer **en premier** : `[]ab]` ;
> - `-` littéral → le placer **en premier ou en dernier** : `[-ab]` ou `[ab-]` ;
> - `!` ou `^` littéral → **ne pas** le placer en premier : `[a!]`.

### 8. Globbing vs création de fichiers

Les globs **correspondent** à des fichiers existants ; ils n'**inventent pas** de noms. Si aucun fichier ne correspond, le motif est pris **littéralement** :

```bash
$ touch ?ail
$ ls
'?ail'
```

(Les apostrophes sont ajoutées par `ls` pour signaler un caractère spécial dans le nom.)

Pour **générer** une série de noms, utiliser l'**expansion d'accolades** plutôt qu'un glob.

> Le globbing ne crée pas de fichiers, il ne fait que les sélectionner. Pour créer des fichiers en série : accolades ou boucle.
> ```bash
> touch file{A..E}         # fileA fileB fileC fileD fileE
> touch file{1..5}.txt
> touch file{a,b}{1,2}     # filea1 filea2 fileb1 fileb2
> ```
> | | Accolades `{}` | Crochets `[]` |
> ||||
> | Rôle | **Génère** du texte | **Sélectionne** des fichiers existants |
> | Si rien n'existe | Fonctionne quand même | Motif laissé littéral |
> | Exemple | `touch file{1..3}` | `ls file[1-3]` |

### À retenir

- `[…]` = **un seul caractère** parmi un ensemble (`[ACE]`) ou une plage (`[A-C]`, `[1-3]`).
- Plage du **plus petit au plus grand** (`[C-A]` invalide) ; plusieurs plages combinables : `[a-eA-E]` (ordre sans importance).
- Négation : `[!…]` (POSIX, recommandé) ou `[^…]` (Bash).
- Sensible à la casse ; classes POSIX fiables : `[[:lower:]]`, `[[:upper:]]`, `[[:digit:]]`.
- Plusieurs positions = plusieurs classes : `file[a-b][1-2]`.
- Dans les crochets, `*` et `?` sont **littéraux** ; `]` en premier, `-` en premier/dernier pour les rendre littéraux.
- `[1-12]` ≠ 1 à 12 (un seul caractère).
- Les globs **sélectionnent**, les accolades **génèrent** (`touch file{1..5}`).
- Toujours tester avec `echo`/`ls` avant `rm`.

### Liens utiles

- [GNU Bash – Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
- [GNU Bash – Brace Expansion](https://www.gnu.org/software/bash/manual/html_node/Brace-Expansion.html)
- [man 7 glob](https://man7.org/linux/man-pages/man7/glob.7.html)
- [Advanced Bash-Scripting Guide – Globbing](https://tldp.org/LDP/abs/html/globbingref.html)
