# sed print

sed est un **éditeur de flux** puissant pour transformer du texte en ligne de commande. Ce contenu montre comment utiliser la commande **`p`** (*print*) pour **afficher des lignes de façon sélective**, **contrôler l'affichage automatique** et intégrer sed dans des **pipelines**. Comprendre le modèle d'entrée/sortie de sed est indispensable pour filtrer des logs ou extraire des enregistrements.

### 1. Rappel : le modèle d'E/S Unix

| Type d'E/S | Description | Exemple |
|---|---|---|
| Sortie par défaut | Les commandes écrivent dans le terminal (stdout) | `ls` |
| Entrée par défaut | Les commandes lisent des fichiers, ou stdin si aucun n'est indiqué | `grep "pattern" file.txt` |
| Pipes (`\|`) | La sortie d'une commande devient l'entrée de la suivante | `echo "data" \| sed 'p'` |
| Entrée interactive | Lecture au clavier jusqu'à EOF (Ctrl+D) ou interruption | `sed 'p'` |

### 2. Comportement par défaut de sed

Par défaut, sed lit le texte sur **stdin** ou dans les fichiers indiqués, applique le script, puis écrit **chaque ligne** sur **stdout**.

```bash
sed 'p'
```

lit stdin et applique la commande `p` à **chaque** ligne.

Exemple :

```bash
echo "Hello from sed" | sed 'p'
```

Sortie :

```bash
Hello from sed
Hello from sed
```

Pourquoi deux fois ?
1. sed lit chaque ligne dans l'**espace de travail** (*pattern space*) ;
2. la commande `p` l'**affiche** immédiatement ;
3. comme l'**affichage automatique** n'est pas désactivé, sed affiche **à nouveau** la ligne à la fin du traitement.

#### Syntaxe

```text
sed [OPTION]... {script-only-if-no-other-script} [input-file]...
```

- `OPTION` : options (`-n`, `-i`, `-E`…) ;
- `script` : les commandes sed (ici `p`), **entre apostrophes** ;
- `input-file` : fichier(s) d'entrée, **après** le script (sinon stdin).

### 3. sed avec des pipes et des fichiers

#### Entrée par pipe

```bash
echo "This line prints twice" | sed 'p'
```

```text
This line prints twice
This line prints twice
```

#### Lecture d'un fichier

```bash
echo "File line example" > sample.txt
sed 'p' sample.txt
```

```text
File line example
File line example
```

Ici, `sample.txt` **remplace stdin** comme source d'entrée.

### 4. Cibler des lignes précises (adresses)

sed accepte des **adresses** (numéros de ligne, motifs…) pour appliquer une commande à certaines lignes seulement.

```bash
# Créer un fichier d'exemple
echo "first line"  > file_sample.txt
echo "second line" >> file_sample.txt
echo "third line"  >> file_sample.txt

# Afficher la 2e ligne en double
sed '2p' file_sample.txt
```

```text
first line
second line
second line
third line
```

La ligne 2 correspond à l'adresse `2p` : elle est affichée par la commande **puis** par l'affichage automatique ; les autres lignes ne passent que par l'affichage automatique.

> Toujours mettre le script sed entre **apostrophes** (`'…'`) pour que le shell n'interprète pas les caractères spéciaux.

### 5. Désactiver l'affichage automatique : `-n`

Pour n'afficher **que** les lignes explicitement demandées, option **`-n`** (*quiet*) :

```bash
sed -n '2p' file_sample.txt
```

```text
second line
```

> Oublier `-n` avec `p` provoque des **lignes en double**.

> Types d'adresses utiles avec `-n … p` :
> ```bash
> sed -n '2,4p' fichier            # lignes 2 à 4
> sed -n '$p' fichier              # dernière ligne
> sed -n '3,$p' fichier            # de la ligne 3 à la fin
> sed -n '/ERROR/p' app.log        # lignes contenant ERROR (≈ grep ERROR)
> sed -n '/START/,/END/p' app.log  # du 1er "START" au "END" suivant
> sed -n '1~2p' fichier            # lignes impaires (GNU : début~pas)
> sed -n '$=' fichier              # nombre de lignes (≈ wc -l)
> ```
> Sur un très gros fichier, `sed -n '5{p;q}'` affiche la ligne 5 puis **quitte** (`q`) sans lire la suite.

### 6. Exemple réel : filtrer une sortie de commande

```bash
df -h
```

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       7.7G  2.9G  4.9G  38% /
devtmpfs        486M     0  486M   0% /dev
tmpfs           490M     0  490M   0% /dev/shm
...
```

Extraire la **3ᵉ ligne** :

```bash
df -h | sed -n '3p'
```

```text
tmpfs           490M     0  490M   0% /dev/shm
```

> Équivalents : `df -h | awk 'NR == 3'` ou `df -h | head -3 | tail -1`.
> Sauter l'en-tête : `df -h | sed -n '2,$p'` (ou `sed '1d'`).

### 7. Travailler sur un fichier de données

`employees.txt`, enregistrements délimités par `|` :

| N° | Champ | Description |
|---|---|---|
| 1 | Record Number | Identifiant de l'employé |
| 2 | First Name | Prénom |
| 3 | Last Name | Nom |
| 4 | Department | Service |
| 5 | Job Title | Poste |
| 6 | Email | E-mail professionnel |
| 7 | Salary | Salaire annuel (USD) |

Afficher uniquement le **5ᵉ enregistrement** :

```bash
sed -n '5p' employees.txt
```

```text
5|Feng|Lin|Sales|Sales Manager|feng.lin@company.com|90000
```

> Autres extractions :
> ```bash
> sed -n '/|IT|/p' employees.txt       # employés du service IT
> sed -n '2,4p' employees.txt          # enregistrements 2 à 4
> ```
> sed travaille sur des **lignes** ; pour extraire des **champs** (ex. prénom = champ 2), awk est plus adapté : `awk -F'|' 'NR == 5 { print $2 }' employees.txt`.

### 8. Synthèse

- sed lit **stdin** ou les fichiers indiqués par défaut.
- Script entre **apostrophes** pour éviter l'interprétation par le shell.
- **Adresses** (ex. `2p`) pour cibler des lignes précises.
- **`-n`** désactive l'affichage automatique pour un contrôle précis.
- Les fichiers d'entrée se placent **après** le script.

Prochaines leçons :
- `d` : **supprimer** des lignes
- `s` : **substituer** du texte
- `i` : **insérer** du texte

### À retenir

- sed lit chaque ligne dans le **pattern space**, applique le script, puis l'**affiche automatiquement**.
- `p` affiche la ligne **en plus** de l'affichage automatique → doublons sans `-n`.
- **`sed -n 'Np'`** = afficher uniquement la ligne N (équivalent `awk 'NR == N'`).
- Adresses : `N`, `N,M`, `$`, `N,$`, `/regex/`, `/début/,/fin/`, `début~pas` (GNU).
- `sed -n '/motif/p'` ≈ `grep motif` ; `sed -n '$='` ≈ `wc -l`.
- `q` pour quitter tôt sur les gros fichiers : `sed -n '5{p;q}'`.
- Syntaxe : `sed [options] 'script' [fichiers]`, script toujours **quoté**.

### Liens utiles

- [GNU sed Manual](https://www.gnu.org/software/sed/manual/)
- [GNU sed – Addresses (sélection des lignes)](https://www.gnu.org/software/sed/manual/html_node/Addresses-overview.html)
- [GNU sed – Command-Line Options (`-n`)](https://www.gnu.org/software/sed/manual/html_node/Command_002dLine-Options.html)
- [GNU sed – Execution Cycle (pattern space)](https://www.gnu.org/software/sed/manual/html_node/Execution-Cycle.html)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
