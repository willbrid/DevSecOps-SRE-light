# Globs : échappement

Dans le shell, les caractères spéciaux `?`, `*` et `[ ]` sont interprétés par le moteur de **globbing** pour faire correspondre des noms de fichiers. Les **précéder d'un antislash** (`\`) ou les **mettre entre guillemets** force le shell à les traiter comme des **caractères littéraux**.

- `\` désactive le globbing pour **le caractère suivant** ;
- les guillemets le désactivent pour **toute la chaîne**.

On contrôle ainsi précisément la création et l'affichage des fichiers.

### 1. Créer des fichiers d'exemple

Des fichiers dont le nom ne diffère que par la première lettre :

```bash
$ touch sail hail mail fail tail
$ ls
fail hail mail sail tail
```

### 2. `?` joker vs `?` littéral

#### 2.1 `?` comme joker

`?` correspond à exactement un caractère. Tentative de création d'un fichier `?ail` **sans échappement** :

```bash
$ touch ?ail
$ ls
fail hail mail sail tail
```

Aucun nouveau fichier : le shell a **développé** `?ail` en `fail hail mail sail tail` avant d'appeler `touch`.

> Ce qui s'est réellement exécuté : `touch fail hail mail sail tail` → la commande a seulement **mis à jour la date de modification** des fichiers existants.
> Piège : si **aucun** fichier ne correspondait, Bash aurait laissé le motif littéral et créé un fichier `?ail`. Le résultat dépend donc du contenu du répertoire → toujours échapper quand on veut un nom littéral.

#### 2.2 Échapper `?` pour un nom littéral

```bash
$ touch \?ail
$ ls
?ail fail hail mail sail tail
```

### 3. Lister un fichier commençant par `?`

On retrouve le fichier `?ail` en **échappant** ou en **quotant** le motif :

```bash
$ ls \?ail
?ail

$ ls "?ail"
?ail
```

Les deux méthodes désactivent le globbing et ciblent le nom **exact**.

> Sans échappement, `ls ?ail` afficherait les **6** fichiers (`?ail` compris, puisque `?` correspond aussi au caractère `?`).

### 4. Mélanger littéraux et jokers

```bash
$ touch hail fail mail \?ail
$ touch hailTwo failTwo mailTwo \?ailTwo
$ ls
?ail ?ailTwo fail failTwo hail hailTwo mail mailTwo
```

Lister tous les fichiers commençant par un `?ail` **littéral** :

```bash
$ ls \?ail*
?ail  ?ailTwo
```

`\?` = `?` littéral ; `*` reste un **joker** pour n'importe quelle suite.

> Les jokers non échappés peuvent correspondre à des fichiers inattendus. **Toujours vérifier** le motif avec `echo` ou `ls` avant une commande destructrice :
> ```bash
> echo rm ?ail*     # → rm ?ail ?ailTwo fail failTwo hail hailTwo mail mailTwo  😱
> echo rm \?ail*    # → rm ?ail ?ailTwo                                      ✅
> ```

> Avec des guillemets, seule la partie quotée devient littérale :
> ```bash
> ls "?ail"*        # équivalent à \?ail*
> ```

### 5. Un seul motif pour plusieurs fichiers

Fichiers `Pail`, `Pail*` et `PailTwo` :

```bash
$ touch Pail Pail* PailTwo
$ ls
Pail Pail* PailTwo
```

Les sélectionner tous :

```bash
$ ls Pail*
Pail Pail* PailTwo
```

`*` développe zéro ou plusieurs caractères après `Pail`.

> Remarque : `touch Pail Pail* PailTwo` n'a créé un fichier `Pail*` que **par chance**. Le shell développe les globs **avant** d'exécuter `touch` : comme aucun fichier ne commençait encore par `Pail`, le motif est resté littéral. Si `Pail` existait déjà, `Pail*` aurait été remplacé par `Pail` et aucun fichier `Pail*` n'aurait été créé. Forme correcte :
> ```bash
> touch Pail 'Pail*' PailTwo     # ou Pail\*
> ```
> Pour ne cibler **que** le fichier nommé `Pail*` :
> ```bash
> ls Pail\*      # Pail*
> rm 'Pail*'     # supprime uniquement ce fichier
> ```

### 6. Tableau récapitulatif

| Caractère | Rôle de joker | Forme échappée | Exemple |
|||||
| `?` | Un seul caractère | `\?` | `touch \?file` |
| `*` | Zéro ou plusieurs caractères | `\*` | `ls Pail\*` |
| `[` `]` | Ensemble de caractères | `\[` `\]` | `ls \[abc\]*` |

> Différences entre les méthodes de protection :
> | Méthode | Effet |
> |||
> | `\x` | protège **un seul** caractère |
> | `'…'` | tout est **littéral** (ni globs, ni variables, ni `\`) |
> | `"…"` | pas de globs, mais `$var`, `$(…)` et `\` restent interprétés |
>
> Éviter de créer des fichiers avec `?`, `*`, `[`, des espaces… : ils compliquent tous les scripts. Pour nettoyer un fichier mal nommé : `rm -i -- *ail` puis répondre au cas par cas, ou `rm './?ail'`.

### 7. Synthèse

- Un antislash `\` ou des guillemets **désactivent le globbing** (caractère suivant ou chaîne entière).
- Sans échappement, `?`, `*`, `[ ]` agissent comme **jokers**.
- On peut **combiner** littéraux échappés et jokers pour des opérations précises (`\?ail*`).

### À retenir

- Le shell développe les globs **avant** d'exécuter la commande : `touch ?ail` touche les fichiers existants au lieu d'en créer un.
- Si aucun fichier ne correspond, le motif reste **littéral** → comportement qui dépend du répertoire : toujours échapper pour un nom littéral.
- `\?`, `\*`, `\[` → caractère littéral ; `'?ail'` ou `"?ail"` → chaîne littérale.
- Mélange possible : `\?ail*` = `?` littéral + `*` joker.
- `ls Pail*` = tout ce qui commence par `Pail` ; `ls Pail\*` = uniquement le fichier nommé `Pail*`.
- Toujours tester avec `echo` ou `ls` avant `rm`/`mv`.
- Éviter les caractères spéciaux dans les noms de fichiers.

### Liens utiles

- [GNU Bash – Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
- [GNU Bash – Quoting](https://www.gnu.org/software/bash/manual/html_node/Quoting.html)
- [Wooledge – Globbing](https://mywiki.wooledge.org/Globbing)
