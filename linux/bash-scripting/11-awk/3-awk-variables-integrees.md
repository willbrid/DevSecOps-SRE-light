# Variables intégrées

> Fichiers d'exemple : [exemples/3-awk-variables-integrees/](exemples/3-awk-variables-integrees/) (lancer les commandes depuis ce répertoire).

Ce contenu montre comment utiliser les **variables intégrées** d'awk pour analyser et manipuler efficacement du texte :
- les variables **positionnelles** (`$1`, `$2`…) ;
- **`NR`** (numéro d'enregistrement) ;
- **`NF`** (nombre de champs) ;
- **`$NF`** (dernier champ) ;
- **`FILENAME`**.

Fichier d'exemple **size.txt**, généré à partir de `df -h` :

```bash
df -h > size.txt
```

### 1. Variables positionnelles

Par défaut, awk découpe chaque ligne sur les **espaces**. On affiche des champs précis avec `$1`, `$2`, `$3`… :

```bash
awk '{ print $1, $2, $3 }' abc.txt
```

- `$1` → 1ʳᵉ colonne
- `$2` → 2ᵉ colonne
- `$3` → 3ᵉ colonne

`abc.txt` :

```text
abc def ghi
jkl mno pqr
stu vwx yz
```

```bash
awk '{ print $1 }' abc.txt
# Sortie :
abc
jkl
stu

awk '{ print $2 }' abc.txt
# Sortie :
def
mno
vwx

awk '{ print $3 }' abc.txt
# Sortie :
ghi
pqr
yz
```

> `$0` = la **ligne entière**. Un champ inexistant (ex. `$9` sur une ligne de 3 champs) donne une **chaîne vide**, sans erreur.


### 2. `NR` : numéro d'enregistrement

`NR` contient le **numéro de la ligne** en cours. Utile pour **numéroter** ou **filtrer** des lignes :

```bash
awk '{ print NR, $1, $4 }' size.txt
```

```text
1 Filesystem Avail
2 udev 1.8G
3 tmpfs 356M
4 /dev/sda1 9.3G
5 tmpfs 1.8G
6 tmpfs 5.0M
7 tmpfs 1.8G
8 /dev/sdb1 360G
9 tmpfs 366M
```

(`print` sépare les champs par un **seul** espace, `OFS` : l'alignement des colonnes de `df -h` n'est pas conservé.)

Afficher uniquement l'espace disponible de la **8ᵉ ligne** :

```bash
awk 'NR == 8 { print $4 }' size.txt
# Sortie :
360G
```

(La valeur dépend évidemment du système.)

> Filtres courants avec `NR` :
> ```bash
> awk 'NR > 1' size.txt             # tout sauf l'en-tête
> awk 'NR >= 2 && NR <= 4' size.txt # lignes 2 à 4
> awk 'NR % 2 == 0' size.txt        # lignes paires
> awk 'END { print NR }' size.txt   # nombre total de lignes
> ```
> Avec **plusieurs fichiers**, `NR` continue de compter d'un fichier à l'autre, alors que **`FNR`** repart à 1 pour chaque fichier :
> ```bash
> awk 'FNR == 1 { print FILENAME ": " $0 }' a.txt b.txt   # 1re ligne de chaque fichier
> ```

### 3. `NF` : nombre de champs

`NF` contient le **nombre de champs** de la ligne en cours. Pratique pour repérer des **incohérences** dans les données :

```bash
awk '{ print NF }' size.txt
```

```text
7
6
6
6
6
6
6
6
6
```

La ligne d'en-tête a **7** champs car « Mounted on » est découpé en **deux** champs.

> Usages pratiques :
> ```bash
> awk 'NF' fichier.txt              # supprime les lignes vides (NF = 0 → faux)
> awk 'NF != 6' size.txt            # repérer les lignes « anormales »
> ```

### 4. Combiner `NR` et `NF`

Numéro de ligne et nombre de champs :

```bash
awk '{ print NR, NF }' size.txt
```

```text
1 7
2 6
3 6
4 6
5 6
6 6
7 6
8 6
9 6
```

Avec du texte :

```bash
awk '{ print "Line", NR, "has", NF, "fields" }' size.txt
```

```text
Line 1 has 7 fields
Line 2 has 6 fields
Line 3 has 6 fields
Line 4 has 6 fields
Line 5 has 6 fields
Line 6 has 6 fields
Line 7 has 6 fields
Line 8 has 6 fields
Line 9 has 6 fields
```

### 5. `$NF` : le dernier champ

`$NF` désigne directement le **dernier champ** de chaque ligne (`NF` = nombre de champs → `$NF` = champ n° NF) :

```bash
awk '{ print $NF }' size.txt
```

```text
on
/dev
/run
/
/dev/shm
/run/lock
/sys/fs/cgroup
/data
/run/user/1000
```

(1ʳᵉ ligne : `on`, à cause de « Mounted on ».)

> Avant-dernier champ : **`$(NF-1)`** (parenthèses obligatoires ; `$NF-1` calculerait « dernier champ moins 1 »).
> ```bash
> awk 'NR > 1 { print $(NF-1), $NF }' size.txt   # Use% et point de montage
> ```

### 6. `FILENAME` : nom du fichier courant

`FILENAME` contient le nom du fichier en cours de traitement (**vide** si l'entrée vient de stdin) :

```bash
awk '{ print FILENAME, $1 }' size.txt
```

```text
size.txt Filesystem
size.txt udev
size.txt tmpfs
size.txt /dev/sda1
size.txt tmpfs
size.txt tmpfs
size.txt tmpfs
size.txt /dev/sdb1
size.txt tmpfs
```

Via un **pipe**, `FILENAME` est vide :

```bash
df -h | awk '{ print FILENAME, $1 }'
# Sortie :
 Filesystem
 udev
 tmpfs
 ...
```

(D'où l'espace en début de ligne : `FILENAME` vide + séparateur `OFS`.)

> `FILENAME` est aussi vide dans le bloc `BEGIN` (aucun fichier n'est encore ouvert).

### 7. Tableau récapitulatif

| Variable | Description | Exemple |
|---|---|---|
| `$1`, `$2`… | Champs positionnels | `awk '{ print $2 }' file.txt` |
| `NR` | Numéro de la ligne courante (cumulé sur tous les fichiers) | `awk '{ print NR }' file.txt` |
| `NF` | Nombre de champs de la ligne | `awk '{ print NF }' file.txt` |
| `$NF` | Dernier champ de la ligne | `awk '{ print $NF }' file.txt` |
| `FILENAME` | Nom du fichier traité (vide sur stdin) | `awk '{ print FILENAME }' file.txt` |

> Autres variables intégrées utiles :
> | Variable | Description | Défaut |
> |---|---|---|
> | `$0` | Ligne entière | — |
> | `FNR` | Numéro de ligne **dans le fichier courant** | — |
> | `FS` | Séparateur de champs en entrée | espaces/tabulations |
> | `OFS` | Séparateur de champs en sortie | espace |
> | `RS` | Séparateur d'enregistrements (lignes) en entrée | `\n` |
> | `ORS` | Séparateur d'enregistrements en sortie | `\n` |

### 8. Séparateurs de champs personnalisés

Si les données utilisent un autre délimiteur, option **`-F`** :

```bash
awk -F, '{ print $1, $NF }' data.csv
```

> Toujours **quoter** l'argument de `-F` s'il contient des caractères spéciaux : `awk -F'|' '...' file.txt`.

> Autres exemples :
> ```bash
> awk -F: '{ print $1, $NF }' /etc/passwd        # utilisateur et shell
> awk -F'\t' '{ print $2 }' data.tsv             # tabulation
> awk -F'[,;]' '{ print $1 }' mix.txt            # virgule OU point-virgule (regex)
> awk 'BEGIN { FS="," } { print $2 }' data.csv   # équivalent de -F, via FS
> ```
> `-F,` ne gère pas les **CSV complexes** (virgules à l'intérieur de champs entre guillemets) : utiliser un outil dédié (`csvkit`, `mlr`) ou `gawk --csv` (gawk 5.3+).

### À retenir

- `$1`, `$2`… champs ; `$0` ligne entière ; champ absent = chaîne vide.
- `NR` = numéro de ligne (cumulé) ; `FNR` = numéro dans le fichier courant.
- `NR == n` pour une ligne précise, `NR > 1` pour sauter l'en-tête, `END { print NR }` pour compter.
- `NF` = nombre de champs ; `awk 'NF'` supprime les lignes vides.
- `$NF` = dernier champ ; `$(NF-1)` = avant-dernier (parenthèses !).
- `FILENAME` = fichier courant (vide sur stdin et dans `BEGIN`).
- `-F` / `FS` = séparateur d'entrée (accepte une regex) ; `OFS` = séparateur de sortie ; quoter `-F'|'`.
- Attention aux en-têtes avec espaces (« Mounted on ») qui décalent le nombre de champs.

### Liens utiles

- [GNU Awk – Built-in Variables](https://www.gnu.org/software/gawk/manual/html_node/Built_002din-Variables.html)
- [GNU Awk – Field Separators](https://www.gnu.org/software/gawk/manual/html_node/Field-Separators.html)
- [GNU Awk Manual](https://www.gnu.org/software/gawk/manual/)
- [The AWK Programming Language (Aho, Kernighan, Weinberger)](https://www.cs.princeton.edu/~bwk/btl.mirror/)
- [Sed & Awk (O'Reilly) – chapitre awk](https://docstore.mik.ua/orelly/unix3/awk/ch02_01.htm)
