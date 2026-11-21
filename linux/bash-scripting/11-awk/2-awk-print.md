# awk print

Awk est un langage spécialisé pour le **traitement de texte**. Ce contenu présente sa **syntaxe**, la structure **motif → action** et l'instruction **`print`** pour extraire et formater des données.

### 1. Syntaxe générale

```bash
awk [options] [programme] [fichier...]
```

| Option | Description |
|---|---|
| `-F fs` | Définit le **séparateur de champs** en entrée (`fs`) |
| `-v var=valeur` | Affecte une **variable awk** avant l'exécution du programme |
| `-f fichier` | Lit le **programme awk** depuis un fichier |
| `programme` | Programme awk fourni directement, **entre guillemets** |
| `fichier...` | Un ou plusieurs fichiers d'entrée ; sinon lecture sur **stdin** |

> Toujours **quoter** le programme pour que le shell le transmette tel quel à awk.

> En pratique, utiliser **des apostrophes** (`'…'`) : entre **guillemets doubles**, le shell remplace lui-même `$1`, `$2`… par les arguments **du script** avant qu'awk ne les voie :
> ```bash
> awk "{ print $2 }" abc.txt    # ❌ $2 développé par le shell (souvent vide → print toute la ligne)
> awk '{ print $2 }' abc.txt    # ✅
> ```
> Pour utiliser une **variable du shell** dans awk : `-v`.
> ```bash
> seuil=80
> df -h | awk -v max="$seuil" 'NR > 1 && $5+0 > max { print $6 }'
> ```

## 2. Structure motif → action

Un programme awk est une suite de paires **motif / action** :

```text
pattern { action }
```

- Sans **motif**, l'**action** s'exécute sur **chaque** ligne.
- Le bloc `{ … }` est le **bloc d'action** (commandes `print`, boucles, conditions…).

Exemple : une session interactive qui ne fait **rien** de l'entrée :

```bash
awk '{}'
```

On tape des lignes, puis **Ctrl+D** pour terminer l'entrée :

```bash
$ awk '{}'
hello world
^D
$
```

> Sans guillemets, le shell peut interpréter les accolades et caractères spéciaux : **toujours quoter** les blocs d'action.

> Rappel : avec un motif mais **sans** action, awk affiche la ligne (`print $0`) :
> ```bash
> awk 'NR == 2' abc.txt      # affiche la 2e ligne
> ```

### 3. L'instruction `print`

Dans le bloc d'action, `print` envoie ses arguments (champs, chaînes littérales, variables) sur la **sortie standard**.

#### Accéder aux champs

Par défaut, awk découpe chaque ligne sur les espaces en champs `$1`, `$2`… `$NF` :

```bash
$ awk '{ print $2 }'
abc def ghi
jkl mno pqr
^D
def
mno
```

(En interactif, chaque résultat s'affiche juste après la saisie de la ligne.)

#### Lire un fichier

On place le nom du fichier **après** le programme.

`abc.txt` :

```text
abc def ghi
jkl mno pqr
xy yz uv
```

```bash
awk '{ print $3 }' abc.txt
```

Sortie :

```text
ghi
pqr
uv
```

#### Afficher des chaînes littérales

On peut mélanger champs et texte fixe :

```bash
awk '{ print "Line:", $1, "->", $NF }' abc.txt
```

Sortie :

```text
Line: abc -> ghi
Line: jkl -> pqr
Line: xy -> uv
```

#### Plusieurs expressions

Les expressions séparées par des **virgules** sont jointes avec le **séparateur de sortie** `OFS` (espace par défaut) :

```bash
awk '{ print "Hello", "World" }' abc.txt
```

Sortie (une fois **par ligne** du fichier) :

```text
Hello World
Hello World
Hello World
```

> Virgule ou pas virgule :
> ```bash
> awk '{ print $1, $2 }' abc.txt     # abc def   → séparés par OFS
> awk '{ print $1 $2 }'  abc.txt     # abcdef    → concaténés (pas de séparateur)
> awk '{ print $1 "-" $2 }' abc.txt  # abc-def
> ```
> Changer le séparateur de sortie :
> ```bash
> awk -v OFS=";" '{ print $1, $2, $3 }' abc.txt   # abc;def;ghi
> awk 'BEGIN { OFS="," } { $1=$1; print }' abc.txt  # abc,def,ghi (convertit toute la ligne)
> ```
> (`$1=$1` force awk à reconstruire `$0` avec le nouvel `OFS`.)
>
> Pour un formatage précis (largeur, alignement, décimales) : **`printf`** (pas de retour à la ligne automatique) :
> ```bash
> awk '{ printf "%-5s | %s\n", $1, $3 }' abc.txt
> # abc   | ghi
> # jkl   | pqr
> # xy    | uv
> ```

### 4. Sources d'entrée : fichiers, redirection, pipe

**Fichier** :

```bash
awk '{ print $0 }' data.txt
```

**Entrée standard par redirection** :

```bash
awk '{ print $0 }' < data.txt
```

**Pipe depuis une autre commande** :

```bash
cat data.txt | awk '{ print $1 }'
```

> `$0` = la ligne **entière**. Le `cat … |` est inutile quand awk peut lire le fichier lui-même ; le pipe est utile pour la sortie **d'une commande** :
> ```bash
> ps aux | awk 'NR > 1 { print $2, $11 }'
> kubectl get pods --no-headers | awk '{ print $1 }'
> ```
> awk accepte aussi **plusieurs fichiers** : `awk '{ print FILENAME, $1 }' a.txt b.txt` (`FILENAME` = fichier en cours).


### 5. Synthèse

- **Structure** : `awk [options] [motif-action] [fichier...]`
- **Motif-action** : `motif { action }`
- **Champs** : `$1`, `$2`, … `$NF`
- **Chaînes littérales** : affichées telles quelles entre guillemets
- **Séparateurs** : en entrée (`FS`, `-F`) et en sortie (`OFS`)
- **Mode interactif** : sans fichier ; terminer avec **Ctrl+D**, annuler avec **Ctrl+C**

### À retenir

- `awk 'programme' fichier` ; sans fichier → lit **stdin** (pipe, redirection, clavier).
- Programme **entre apostrophes** `'…'` ; variables du shell → `-v var="$valeur"`.
- `motif { action }` : sans motif = toutes les lignes ; sans action = `print $0`.
- `print $1, $2` → séparés par **OFS** (espace) ; `print $1 $2` → **concaténés**.
- Texte fixe et champs se mélangent : `print "Line:", $1`.
- `$0` = ligne entière, `$NF` = dernier champ.
- Changer la sortie : `-v OFS=","` (+ `$1=$1` pour reformater toute la ligne) ; formatage fin : `printf`.
- Options : `-F` (séparateur d'entrée), `-v` (variable), `-f` (programme dans un fichier).

### Liens utiles

- [GNU Awk User's Guide](https://www.gnu.org/software/gawk/manual/gawk.html)
- [GNU Awk – Print (print, OFS)](https://www.gnu.org/software/gawk/manual/html_node/Printing.html)
- [GNU Awk – Printf](https://www.gnu.org/software/gawk/manual/html_node/Printf.html)
- [Grymoire – Awk tutorial (Bruce Barnett)](https://www.grymoire.com/Unix/Awk.html)
- [Advanced Bash-Scripting Guide – Awk (TLDP)](https://tldp.org/LDP/abs/html/awk.html)
