# awk bash hybride

Ce contenu montre comment **combiner awk et Bash** pour traiter des fichiers texte délimités. On compare un script **awk pur** à un **hybride Bash/awk**, puis on construit progressivement un **outil réutilisable d'analyse des salaires**.

### 1. Pourquoi des hybrides Bash-awk ?

- Les scripts **awk purs** sont concis pour le traitement de texte.
- Intégrer awk dans **Bash** apporte de la **flexibilité** : variables, options, arguments en ligne de commande.
- Les **shebangs** (`#!/usr/bin/env …`) permettent de lancer les scripts directement.

#### Script awk pur (`salary.awk`)

```bash
#!/usr/bin/env awk -f
BEGIN {
    FS = "|"
}
{
    print $2, $3
}
```

#### Script Bash intégrant awk (`print_names.sh`)

```bash
#!/usr/bin/env bash
awk -F "|" '{
    print $2, $3
}'
```

Exécution du script Bash :

```bash
chmod +x print_names.sh
./print_names.sh < employees.txt
```

Ou appel direct d'awk avec le fichier de programme :

```bash
awk -f salary.awk employees.txt
```

> Rappel : `#!/usr/bin/env awk -f` échoue souvent sous Linux → préférer `#!/usr/bin/awk -f` ou `#!/usr/bin/env -S awk -f`.

### 2. La source de données

`employees.txt` utilise `|` comme séparateur :

| Colonne | Champ | Description |
|---|---|---|
| 1 | Employee ID | Identifiant unique |
| 2 | First name | Prénom |
| 3 | Last name | Nom |
| 4 | Department | Service |
| 5 | Job title | Poste |
| 6 | Email | E-mail |
| 7 | Salary | Salaire annuel (USD) |

Séparateur à définir avec `-F` ou `FS` pour découper sur `|`.

#### Seuils de salaire

| Variable | Critère |
|---|---|
| `high_salary` | Salaire **≥ 90 000** (hauts salaires) |
| `low_salary` | Salaire **≤ 65 000** (augmentations potentielles) |

### 3. Étape 1 : one-liner de base

Prénom, nom et salaire de **tous** les employés :

```bash
awk -F "|" '{ print $2, $3, $7 }' employees.txt
```

```text
Kriti Shreshtha 60000
Rajasekar Vasudevan 75000
Debbie Miller 80000
Enrique Rivera 65000
Feng Lin 90000
Andy Luscomb 95000
Mark Crocker 85000
Jing Ma 100000
```

### 4. Étape 2 : filtrer par tranche de salaire

Les seuils sont passés avec `-v` :

```bash
awk -F "|" \
    -v high_salary=90000 \
    -v low_salary=65000 \
    '$7 >= high_salary || $7 <= low_salary {
        print $2, $3, $7
    }' employees.txt
```

Affiche hauts **et** bas salaires dans un même flux :

```text
Kriti Shreshtha 60000
Enrique Rivera 65000
Feng Lin 90000
Andy Luscomb 95000
Jing Ma 100000
```

### 5. Étape 3 : ajouter un en-tête avec `BEGIN`

En-tête affiché **une seule fois** :

```bash
awk -F "|" \
    -v high_salary=90000 \
    -v low_salary=65000 \
    -v header="==== Salary Adjustments ====" \
    'BEGIN { print header }
     $7 >= high_salary || $7 <= low_salary {
         print $2, $3, $7
     }' employees.txt
```

### 6. Étape 4 : encapsuler dans un script Bash (`salary.sh`)

Pour la lisibilité et la réutilisation :

```bash
#!/usr/bin/env bash

awk -F "|" \
  -v high_salary=90000 \
  -v low_salary=65000 \
  -v header="==== Salary Adjustments ====" '
BEGIN {
  print header
}
$7 >= high_salary || $7 <= low_salary {
  print $2, $3, $7
}
' < employees.txt
```

```bash
chmod +x salary.sh
./salary.sh
```

- Les `\` en fin de ligne permettent d'écrire une option par ligne (aucun espace après le `\`).
- Le programme awk tient entre deux apostrophes, sur plusieurs lignes.

### 7. Étape 5 : sections « à augmenter » / « à baisser » (`salary-v2.sh`)

Un en-tête différent pour les hauts et les bas salaires :

```bash
#!/usr/bin/env bash

awk -F "|" \
  -v high_salary=90000 \
  -v low_salary=65000 \
  -v up_header="===== Needs to be adjusted up =====" \
  -v down_header="===== Needs to be adjusted down =====" '
$7 >= high_salary {
  print down_header
  print $2, $3, $7
}
$7 <= low_salary {
  print up_header
  print $2, $3, $7
}
' < employees.txt
```

> Défaut : l'en-tête est **répété pour chaque employé** concerné (une paire motif/action est évaluée pour chaque ligne).

### 8. Étape 6 : un seul en-tête par groupe (`salary-v3.sh`)

Des **drapeaux** (*flags*) internes à awk évitent de répéter les en-têtes :

```bash
#!/usr/bin/env bash

awk -F "|" \
  -v high_salary=90000 \
  -v low_salary=65000 \
  -v up_header="===== Needs to be adjusted up =====" \
  -v down_header="===== Needs to be adjusted down =====" '
$7 <= low_salary {
  if (!printed_up_header) {
    print up_header
    printed_up_header = 1
  }
  print $2, $3, $7
}
$7 >= high_salary {
  if (!printed_down_header) {
    print down_header
    printed_down_header = 1
  }
  print $2, $3, $7
}
' < employees.txt
```

- Une variable awk non initialisée vaut `0` / chaîne vide → `!printed_up_header` est **vrai** au premier passage.
- Après l'affichage, on la met à `1` : l'en-tête n'est plus réaffiché.

Sortie :

```text
===== Needs to be adjusted up =====
Kriti Shreshtha 60000
Enrique Rivera 65000
===== Needs to be adjusted down =====
Feng Lin 90000
Andy Luscomb 95000
Jing Ma 100000
```

> imite : les lignes sont toujours affichées **dans l'ordre du fichier**. Le résultat n'est bien groupé ici que parce que les bas salaires apparaissent **avant** les hauts dans `employees.txt`. Si un bas salaire apparaissait après « Jing », il s'afficherait **sous l'en-tête « down »**.
> Version robuste : **accumuler** puis tout afficher dans `END` :
> ```bash
> awk -F'|' -v high_salary=90000 -v low_salary=65000 '
> $7 <= low_salary  { up   = up   $2 " " $3 " " $7 "\n" }
> $7 >= high_salary { down = down $2 " " $3 " " $7 "\n" }
> END {
>   if (up)   printf "===== Needs to be adjusted up =====\n%s", up
>   if (down) printf "===== Needs to be adjusted down =====\n%s", down
> }' employees.txt
> ```

### 9. Étape 7 : paramétrer avec des arguments (`salary-v4.sh`)

L'utilisateur peut **surcharger les seuils** au lancement :

```bash
#!/usr/bin/env bash

readonly UP_HEADER="===== Needs to be adjusted up ====="
readonly DOWN_HEADER="===== Needs to be adjusted down ====="

high_salary="${1:-90000}"
low_salary="${2:-65000}"

awk -F "|" \
  -v high_salary="$high_salary" \
  -v low_salary="$low_salary" \
  -v up_header="$UP_HEADER" \
  -v down_header="$DOWN_HEADER" '
$7 >= high_salary {
  if (!printed_down_header) {
    print down_header
    printed_down_header = 1
  }
  print $2, $3, $7
}
$7 <= low_salary {
  if (!printed_up_header) {
    print up_header
    printed_up_header = 1
  }
  print $2, $3, $7
}
' < employees.txt
```

- `${1:-90000}` : 1ᵉʳ argument, ou **90000** par défaut ;
- `${2:-65000}` : 2ᵉ argument, ou **65000** par défaut ;
- les constantes Bash (`readonly`) sont transmises à awk via `-v`.

Valeurs par défaut :

```bash
chmod +x salary-v4.sh
./salary-v4.sh
```

Seuils personnalisés (haut puis bas) :

```bash
./salary-v4.sh 80000 60000
```

> Pistes d'amélioration combinant les leçons précédentes :
> ```bash
> #!/usr/bin/env bash
> set -euo pipefail
>
> readonly SCRIPT_NAME=${0##*/}
> readonly DATA_FILE="${DATA_FILE:-employees.txt}"
>
> high_salary="${1:-90000}"
> low_salary="${2:-65000}"
>
> # Guard clauses
> [[ $high_salary =~ ^[0-9]+$ && $low_salary =~ ^[0-9]+$ ]] \
>   || { echo "Usage: $SCRIPT_NAME [high_salary] [low_salary] (entiers)" >&2; exit 10; }
> (( low_salary < high_salary )) \
>   || { echo "low_salary doit être inférieur à high_salary" >&2; exit 11; }
> [[ -r $DATA_FILE ]] || { echo "Fichier introuvable : $DATA_FILE" >&2; exit 12; }
>
> awk -F'|' -v high_salary="$high_salary" -v low_salary="$low_salary" '…' "$DATA_FILE"
> ```

### 10. Prochaines étapes

Notions vues :
- awk pur vs hybrides Bash/awk ;
- `-v` pour passer des variables à awk ;
- en-têtes avec `BEGIN` et drapeaux internes ;
- paramétrage par arguments en ligne de commande.

À pratiquer : adapter ces scripts à d'autres formats, nombres de champs ou filtres plus complexes.

### À retenir

- **Hybride Bash + awk** : Bash gère arguments, valeurs par défaut, validation ; awk gère le traitement des lignes.
- Passer les valeurs du shell à awk avec **`-v var="$bash_var"`** (jamais par concaténation dans le programme).
- Motif `cond1 || cond2 { action }` pour filtrer sur une plage.
- `BEGIN { }` = en-tête unique ; une action par ligne sinon.
- **Drapeaux** (`if (!flag) { …; flag = 1 }`) : afficher un en-tête une seule fois (variables awk initialisées à 0).
- Les lignes restent dans **l'ordre du fichier** → pour un vrai regroupement, accumuler et afficher dans **`END`**.
- `${1:-défaut}` pour des arguments optionnels ; valider les entrées (regex, cohérence haut/bas, fichier lisible).
- Écriture lisible : une option `-v` par ligne avec `\`, programme awk multiligne entre apostrophes.

### Liens utiles

- [GNU Awk User's Guide](https://www.gnu.org/software/gawk/manual/)
- [GNU Awk – Using Shell Variables in Programs](https://www.gnu.org/software/gawk/manual/html_node/Using-Shell-Variables.html)
- [GNU Awk – BEGIN/END](https://www.gnu.org/software/gawk/manual/html_node/BEGIN_002fEND.html)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
