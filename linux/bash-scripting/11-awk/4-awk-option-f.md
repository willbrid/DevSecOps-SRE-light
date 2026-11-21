# awk option F

L'option **`-F`** permet de **personnaliser le séparateur de champs** d'awk. Par défaut, awk découpe les lignes sur les **espaces**, mais `-F` permet d'utiliser **n'importe quel caractère** ou **expression régulière** comme délimiteur.

```bash
usage: awk [-F fs] [-v var=value] [-f progfile | 'prog'] [file ...]
```

### 1. Découpage par défaut

Par défaut, awk considère tout **espace blanc** comme séparateur :

```bash
$ df -h
```

```text
Filesystem      Size  Used Avail Use% Mounted on
udev            1.8G     0  1.8G   0% /dev
tmpfs           366M  9.7M  356M   3% /run
...
```

Quand les données utilisent un autre délimiteur (virgule, deux-points, pipe…), il faut **changer** ce comportement.

### 2. Changer le séparateur avec `-F`

Avec les deux-points (`:`) comme séparateur (fichier `sizeV1.txt` = sortie de `df -h` avec des `:` entre les colonnes) :

```bash
$ awk -F ":" '{ print $1 }' sizeV1.txt
```

```text
Filesystem
udev
tmpfs
/dev/sda1
...
```

Le 2ᵉ champ :

```bash
$ awk -F ":" '{ print $2 }' sizeV1.txt
```

```text
Size
1.8G
366M
...
```

Champs 1 et 5 :

```bash
$ awk -F ":" '{ print $1, $5 }' sizeV1.txt
```

```text
Filesystem Use%
udev 0%
tmpfs 3%
...
```

Avec un pipe :

```bash
$ cat sizeV1.txt | awk -F ":" '{ print $2 }'
```

> En sortie, les champs restent séparés par un **espace** (`OFS`), quel que soit `-F`. Pour garder le même séparateur : `awk -F: -v OFS=: '{ print $1, $5 }'`.

> Exemple classique : `/etc/passwd`
> ```bash
> awk -F: '{ print $1, $7 }' /etc/passwd          # utilisateur et shell
> awk -F: '$3 >= 1000 { print $1 }' /etc/passwd   # utilisateurs « humains »
> ```

### 3. Pourquoi quoter ou échapper le séparateur

Certains caractères (`|`, `&`, `*`, `<`, `>`, `;`…) ont une **signification spéciale pour le shell**.

> Toujours **quoter** ou **échapper** le séparateur pour éviter que le shell l'interprète.

**Incorrect :**

```bash
awk -F | '{ print $1 }' employees.txt
```

Échec : le `|` est pris pour un **pipe** par le shell.

**Correct :**

```bash
awk -F "|" '{ print $1 }' employees.txt
# ou
awk -F \| '{ print $1 }' employees.txt
```

> Encadrer le caractère de **guillemets** pour qu'il soit pris littéralement (les **apostrophes** `-F'|'` marchent aussi, et sont encore plus sûres).

> Deux niveaux d'interprétation à connaître :
> 1. **Le shell** : il faut protéger `|`, `;`, `&`, `*`… → guillemets.
> 2. **awk** : un séparateur d'**un seul caractère** (autre que l'espace) est pris **littéralement** ; un séparateur de **plusieurs caractères** est une **expression régulière**.
> ```bash
> awk -F'|' …            # ✅ un seul caractère → littéral
> awk -F'||' …           # ❌ regex « vide OU vide » → résultat inattendu
> awk -F'\\|\\|' …       # ✅ deux pipes littéraux (ou -F'[|][|]')
> awk -F'[,;]' …         # ✅ virgule OU point-virgule
> awk -F', *' …          # ✅ virgule suivie d'espaces éventuels
> ```
> Cas particulier : `-F' '` (un espace) = comportement **par défaut** (suites d'espaces/tabulations).

### 4. Séparateurs courants

| Séparateur | Sens pour le shell | Cas d'usage |
|---|---|---|
| `:` | Aucun | `/etc/passwd` |
| `,` | Aucun | Export CSV |
| `\|` | Pipe (à protéger) | Sorties de bases de données |
| `\t` | Tabulation (écrire `'\t'`) | Fichiers TSV |
| `=` | Affectation (à protéger selon la leçon) | Fichiers clé=valeur |

> Précisions :
> - `\t` : écrire `-F'\t'` (awk interprète la séquence d'échappement).
> - `=` n'a **pas** de sens particulier pour le shell à cet endroit : `-F=` fonctionne tel quel.
>   ```bash
>   awk -F= '/^PORT/ { print $2 }' app.conf     # PORT=8080 → 8080
>   ```
> - Quoter **systématiquement** reste une bonne habitude, quel que soit le caractère.

### 5. Exemple : traiter la sortie d'une base de données

Script `db.sh` qui exécute une requête PostgreSQL dans un conteneur Docker, en nettoyant chaque champ avec `trim` :

```bash
#!/usr/bin/env bash
docker_run() {
  docker exec -i employees_db psql -U postgres -d employees -tAQ <<EOF
SELECT
  trim(id_employee::text),
  trim(first_name),
  trim(last_name),
  trim(area),
  trim(job_title),
  trim(email),
  trim(salary::text)
FROM "employee";
EOF
}
docker_run > employees.txt
exit 0
```

- `docker exec -i` : exécute `psql` dans le conteneur `employees_db`, avec **stdin** ouvert (pour recevoir la requête) ;
- la requête SQL est envoyée via un **heredoc** ;
- `-t` : uniquement les lignes de résultat (pas d'en-tête ni de pied) ; `-A` : sortie **non alignée**, champs séparés par `|` par défaut.

Résultat :

```bash
$ cat employees.txt
```

```text
1|Kriti|Shreshtha|Finance|Financial Analyst|kriti.shreshtha@company.com|60000
...
```

Extraire les prénoms (champ 2) :

```bash
$ awk -F "|" '{ print $2 }' employees.txt
```

```text
Kriti
Rajasekar
Debbie
...
```

> Aller plus loin avec le même fichier :
> ```bash
> awk -F'|' '$4 == "Finance" { print $2, $3 }' employees.txt          # employés du service Finance
> awk -F'|' '{ s += $7 } END { print "Masse salariale :", s }' employees.txt
> awk -F'|' -v OFS=',' '{ print $2, $3, $6 }' employees.txt > export.csv   # conversion en CSV
> ```
> (`psql -F ';'` permet aussi de choisir un autre séparateur directement à la source.)

### À retenir

- `-F sep` change le séparateur d'entrée (défaut : suites d'espaces/tabulations) ; équivalent : `BEGIN { FS="sep" }`.
- **Quoter** le séparateur : `-F'|'`, `-F":"` ; sans guillemets, `|`, `;`, `&`, `*` sont interprétés par le shell.
- Un séparateur d'**un caractère** = littéral ; **plusieurs caractères** = **regex** (`-F'[,;]'`, `-F'\\|\\|'`).
- Tabulation : `-F'\t'` ; espace simple `-F' '` = comportement par défaut.
- La sortie utilise `OFS` (espace par défaut) → `-v OFS=','` pour un autre séparateur.
- Cas typiques : `/etc/passwd` (`:`), CSV (`,`), sorties SQL `psql -tA` (`|`), fichiers `clé=valeur` (`=`).

### Liens utiles

- [GNU Awk – Field Separators](https://www.gnu.org/software/gawk/manual/html_node/Field-Separators.html)
- [GNU Awk – Command-Line Options](https://www.gnu.org/software/gawk/manual/html_node/Options.html)
- [GNU Awk Manual](https://www.gnu.org/software/gawk/manual/)
- [man awk](https://man7.org/linux/man-pages/man1/awk.1p.html)
- [PostgreSQL – psql](https://www.postgresql.org/docs/current/app-psql.html)
