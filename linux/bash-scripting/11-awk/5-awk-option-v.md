# awk option v

L'option **`-v`** définit des **variables awk avant l'exécution** du programme. Déclarer les variables ainsi permet de **séparer la configuration de la logique**, rend les one-liners plus **lisibles** et les scripts/pipelines plus **réutilisables**.

### 1. Exemple simple : `-v` avec un bloc `BEGIN`

On définit `var` avant l'exécution et on l'affiche dans un bloc **`BEGIN`**, exécuté **avant** toute lecture de l'entrée :

```bash
$ awk -v var="Hello, World!" 'BEGIN { print var }'
Hello, World!
```

Pas de fichier, pas de saisie : `BEGIN` suffit, awk se termine aussitôt.

### 2. Placement et comportement

- `-v` est une **option** de la commande `awk`, placée avec les autres options (avant le programme).
- Il est recommandé de placer **`-F` avant `-v`** quand les deux sont utilisés (portabilité, clarté).
- **`BEGIN`** s'exécute avant tout traitement : initialisation, affichage d'en-têtes, tâches sans données d'entrée.
- **Sans `BEGIN`** (ex. `{ print var }`), awk lit l'entrée (fichiers ou stdin) et exécute l'action pour **chaque ligne**. Terminer la saisie interactive avec **Ctrl+D**.

> Pour les valeurs de configuration susceptibles de changer (seuils, préfixes, noms de fichiers), les passer avec `-v` plutôt que de les **coder en dur** : même programme, réglages différents.

> L'ordre `-F` / `-v` n'est pas imposé par POSIX : toutes les options doivent simplement précéder le programme. Garder un ordre constant reste une bonne habitude.

#### Exemple : afficher la variable pour chaque ligne lue (stdin)

```bash
$ awk -v var="Hello, World!" '{ print var }'
passing input ........................
Hello, World!
passing input again ........................
Hello, World!
^D
```

Chaque ligne saisie déclenche l'action (le contenu de la ligne est ignoré, seule `var` est affichée).

### 3. Jeu de données : `employees.txt`

Fichier délimité par des **pipes**, avec les champs :
1. ID
2. Prénom
3. Nom
4. Service
5. Poste
6. E-mail
7. Salaire

```bash
$ cat employees.txt
1|Kriti|Shreshtha|Finance|Financial Analyst|kriti.shreshtha@company.com|60000
2|Rajasekar|Vasudevan|Finance|Senior Accountant|rajasekar.vasudevan@company.com|75000
3|Debbie|Miller|IT|Software Developer|debbie.miller@company.com|80000
4|Enrique|Rivera|Marketing|Marketing Specialist|enrique.rivera@company.com|65000
5|Feng|Lin|Sales|Sales Manager|feng.lin@company.com|90000
6|Andy|Luscomb|IT|IT Manager|andy.luscomb@company.com|95000
7|Mark|Crocker|HR|HR Manager|mark.crocker@company.com|85000
8|Jing|Ma|Engineering|Engineering Manager|jing.ma@company.com|100000
```

### 4. Exemple : préfixer les prénoms

`-F "|"` pour le séparateur et `-v prefix="…"` pour un texte affiché avant le prénom (`$2`) :

```bash
$ awk -F "|" -v prefix="Employee's First Name: " '{ print prefix, $2 }' employees.txt
Employee's First Name: Kriti
Employee's First Name: Rajasekar
Employee's First Name: Debbie
Employee's First Name: Enrique
Employee's First Name: Feng
Employee's First Name: Andy
Employee's First Name: Mark
Employee's First Name: Jing
```

- `-v prefix="…"` définit une variable utilisable dans le programme ;
- `-F "|"` découpe sur le pipe → `$2` = prénom ;
- `prefix` est utilisée dans l'action pour **chaque** ligne.

> Détail : `prefix` se termine déjà par un espace **et** la virgule ajoute `OFS` (un espace) → la sortie réelle contient **deux espaces** (`Name:  Kriti`). Pour un seul espace : `print prefix $2` (concaténation) ou retirer l'espace final du préfixe.

### 5. Filtrer sur un champ numérique (salaire)

Employés gagnant **90 000 ou plus** (salaire = `$7`) :

```bash
$ awk -F "|" '$7 >= 90000' employees.txt
5|Feng|Lin|Sales|Sales Manager|feng.lin@company.com|90000
6|Andy|Luscomb|IT|IT Manager|andy.luscomb@company.com|95000
8|Jing|Ma|Engineering|Engineering Manager|jing.ma@company.com|100000
```

(Motif sans action → la ligne entière est affichée.)

#### Paramétrer le seuil avec `-v`

Le seuil devient un **paramètre**, sans modifier le programme :

```bash
$ awk -F "|" -v high_salary="90000" '$7 >= high_salary' employees.txt
5|Feng|Lin|Sales|Sales Manager|feng.lin@company.com|90000
6|Andy|Luscomb|IT|IT Manager|andy.luscomb@company.com|95000
8|Jing|Ma|Engineering|Engineering Manager|jing.ma@company.com|100000
```

Seulement les **prénoms** des hauts salaires :

```bash
$ awk -F "|" -v high_salary="90000" '$7 >= high_salary { print $2 }' employees.txt
Feng
Andy
Jing
```

> Intérêt principal : passer une **variable du shell** proprement, sans bricoler les guillemets :
> ```bash
> seuil=90000
> awk -F'|' -v high_salary="$seuil" '$7 >= high_salary { print $2 }' employees.txt
>
> # ❌ À éviter : injecter la variable dans le programme
> awk -F'|' '$7 >= '"$seuil"' { print $2 }' employees.txt
> ```

### 6. Plusieurs variables

Un **`-v` par variable**. Employés gagnant **≤ 65 000** ou **≥ 90 000** :

```bash
$ awk -F "|" -v high_salary="90000" -v low_salary="65000" \
    '$7 >= high_salary || $7 <= low_salary { print $2 }' employees.txt
Kriti
Enrique
Feng
Andy
Jing
```

> Choisir des **noms de variables explicites** (`high_salary`, `low_salary`, `prefix`) : ils indiquent immédiatement le **but** du programme.

> Combiner avec un filtre texte :
> ```bash
> awk -F'|' -v dept="IT" '$4 == dept { print $2, $3, $7 }' employees.txt
> # Debbie Miller 80000
> # Andy Luscomb 95000
> ```

### 7. Synthèse et bonnes pratiques

| Sujet | Recommandation | Exemple |
|---|---|---|
| Déclaration | `-v nom=valeur` avant l'exécution | `awk -v threshold=100 '…' file` |
| Séparateur | Placer `-F` avant `-v` | `awk -F "\|" -v n=1 '…'` |
| Plusieurs variables | Un `-v` par variable | `-v a=1 -v b=2` |
| Comparaisons numériques | Les valeurs numériques entre guillemets fonctionnent : awk convertit en nombre | `-v n="90000"` |
| Initialisation | `BEGIN` pour le démarrage ; sans `BEGIN` → traitement des lignes | `BEGIN { print "Header" }` |

Chaque `-v` définit une variable **avant** le démarrage d'awk. Un nom identique à une variable **intégrée** peut la **masquer/modifier** → choisir des noms parlants pour éviter les collisions.

> Compléments :
> - Certaines variables intégrées se règlent **volontairement** avec `-v` : `-v OFS=','`, `-v FS=':'` (équivalent de `-F:`).
> - `-v` **interprète les séquences d'échappement** : `-v sep='\t'` donne une vraie tabulation, mais un chemin Windows `C:\temp` serait altéré. Pour une valeur brute : `ENVIRON` :
>   ```bash
>   MYPATH='C:\temp' awk 'BEGIN { print ENVIRON["MYPATH"] }'
>   ```
> - Une affectation placée **après** le programme (`awk '…' var=1 fichier`) n'est appliquée qu'au moment de lire ce fichier → **non disponible dans `BEGIN`**, contrairement à `-v`.

### À retenir

- `-v nom=valeur` définit une variable awk **avant** l'exécution, disponible dans `BEGIN`, les motifs et les actions.
- Sépare **configuration** et **logique** : seuils, préfixes, filtres passés en paramètre.
- Un `-v` par variable ; noms **explicites** ; attention à ne pas écraser une variable intégrée (sauf `OFS`, `FS` volontairement).
- Variables du shell → `-v var="$shell_var"` plutôt que de les concaténer dans le programme.
- `BEGIN { }` = avant la lecture ; `{ }` = pour chaque ligne ; motif seul (`$7 >= x`) = affiche les lignes correspondantes.
- `print a, b` ajoute `OFS` ; `print a b` concatène (attention aux doubles espaces).
- `-v` interprète `\t`, `\n`… ; valeur brute → `ENVIRON["VAR"]`.

### Liens utiles

- [GNU Awk – Command-Line Options (`-v`)](https://www.gnu.org/software/gawk/manual/html_node/Options.html)
- [GNU Awk – Assigning Variables on the Command Line](https://www.gnu.org/software/gawk/manual/html_node/Assignment-Options.html)
- [GNU Awk User's Guide](https://www.gnu.org/software/gawk/manual/gawk.html)
- [Grymoire – Awk tutorial](https://www.grymoire.com/Unix/Awk.html)
