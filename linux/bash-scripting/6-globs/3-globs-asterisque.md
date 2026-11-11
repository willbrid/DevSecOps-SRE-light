# Globs : astérisque

L'astérisque (`*`) est un joker très puissant des shells Unix (et de nombreux langages) : il correspond à **n'importe quelle suite de caractères, y compris aucune**. Dans les globs de chemins, il permet de sélectionner des fichiers selon un **préfixe**, une **extension** ou une **sous-chaîne** quelconque.

Le maîtriser permet d'accélérer les opérations sur les fichiers, d'automatiser des tâches et de gagner en efficacité en ligne de commande.

### 1. Fonctionnement de `*`

- `*` correspond à **zéro ou plusieurs caractères** dans un nom de fichier ou un segment de chemin.
- Il ne traverse **pas** le séparateur de chemin `/`, sauf avec les globs récursifs (`**` en Bash, avec `shopt -s globstar`).
- Mettre le glob **entre guillemets** quand on veut transmettre le motif **littéral** à une commande au lieu de laisser le shell le développer.

Exemple donné dans la leçon pour empêcher l'expansion par le shell :

```bash
grep "TODO" "*.txt"
```

Ici, `grep` reçoit le motif `*.txt` tel quel au lieu de la liste des fichiers.

> Correction : cet exemple **ne fonctionne pas**. `grep` n'interprète pas les globs dans ses noms de fichiers : il cherche un fichier nommé littéralement `*.txt` → `grep: *.txt: No such file or directory`. Ici, il faut **laisser le shell développer** :
> ```bash
> grep "TODO" *.txt
> ```
> Quoter un glob n'a de sens que pour les commandes qui **interprètent elles-mêmes** le motif :
> ```bash
> find . -name "*.txt"            # find fait sa propre correspondance (y compris dans les sous-dossiers)
> grep -r "TODO" --include="*.txt" .
> ```
> Sans guillemets, `find . -name *.txt` serait développé par le shell avant d'arriver à `find` (erreur ou résultat faux s'il y a des `.txt` dans le dossier courant).

### 2. Exemple 1 : fichiers avec un préfixe commun

```bash
$ ls
report.txt  report.docx  report.pdf  image1.jpg  backup2.tar.gz  1.log2.log
```

Lister tous les fichiers commençant par `report.`, quelle que soit l'extension :

```bash
$ ls report.*
report.txt  report.docx  report.pdf
```

- `report.` est pris **littéralement** (point compris).
- `*` couvre n'importe quelle extension (y compris vide : un fichier `report.` serait inclus).

> Différence : `report*` inclurait aussi `report_old.txt` ou `report` (sans point).

### 3. Exemple 2 : une extension précise

```bash
$ ls
report.py   report.pdf   notes.docx   notes.pdf   image1.jpg   config.pdf   log2.log
```

Lister uniquement les PDF :

```bash
$ ls *.pdf
report.pdf  notes.pdf  config.pdf
```

- `*` correspond à n'importe quel nom avant l'extension.
- `.pdf` filtre sur cette extension exacte.

> Les globs sont **sensibles à la casse** : `*.pdf` n'inclut pas `SCAN.PDF`. Solutions : `*.[pP][dD][fF]` ou `shopt -s nocaseglob`.

### 4. Exemple 3 : un préfixe, des suffixes variables

```bash
$ ls
notes.pdf   image1.jpg   image2.jpeg   image3.png   script.sh   backup1.tar.gz
```

Sélectionner tous les fichiers commençant par `image`, quelle que soit l'extension :

```bash
$ ls image*
image1.jpg  image2.jpeg  image3.png
```

- `image` est le préfixe fixe.
- `*` prend tout ce qui suit : `.jpg`, `.jpeg`, `.png`…

> Combinaisons possibles (non présentes dans la leçon) :
> ```bash
> ls *backup*          # contient "backup" n'importe où
> ls image*.jp*g       # image1.jpg, image2.jpeg
> ls *.tar.gz          # archives compressées
> ls */*.yaml          # .yaml dans les sous-dossiers directs (1 niveau)
> shopt -s globstar
> ls **/*.yaml         # .yaml dans toute l'arborescence
> ```

### 5. Motifs `*` courants

| Motif | Description | Exemple de résultat |
||||
| `report.*` | Commence par `report.` | `report.txt`, `report.pdf` |
| `*.pdf` | Se termine par `.pdf` | `notes.pdf`, `config.pdf` |
| `image*` | Commence par `image` | `image1.jpg`, `image2.jpeg` |
| `*` | Tous les fichiers du répertoire courant | Tous les fichiers **visibles** |

> Rappels :
> - `*` seul **n'inclut pas** les fichiers cachés (`.env`, `.git`) → `shopt -s dotglob` ou `.*`.
> - Aucun fichier correspondant → le motif reste **littéral** (`ls *.xyz` → erreur « No such file ») ; `shopt -s nullglob` pour une liste vide.
> - Tester avant une action destructrice : `echo rm *.log`.
> - Si un nom de fichier commence par `-`, il peut être pris pour une option : utiliser `rm -- *` ou `rm ./*`.

### À retenir

- `*` = **zéro ou plusieurs** caractères (≠ `?` = exactement un).
- `*` ne traverse pas les `/` ; récursif avec `**` + `shopt -s globstar`.
- Motifs clés : `préfixe*`, `*.ext`, `préfixe.*`, `*mot*`.
- C'est le **shell** qui développe le glob, avant d'appeler la commande.
- Guillemets autour du glob **uniquement** pour les commandes qui gèrent le motif elles-mêmes (`find -name "*.txt"`, `--include="*.txt"`) ; `grep "x" "*.txt"` ne marche pas.
- Sensible à la casse (`nocaseglob` pour l'ignorer) ; fichiers cachés exclus (`dotglob`) ; motif littéral si aucun résultat (`nullglob`).
- Sécurité : `echo` avant `rm`, et `--` ou `./*` contre les noms commençant par `-`.

### Liens utiles

- [GNU Bash – Filename Expansion](https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html)
- [GNU Bash – Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
- [Advanced Bash-Scripting Guide – Globbing](https://tldp.org/LDP/abs/html/globbingref.html)
- [Bash Beginners Guide – Shell Pattern Matching (TLDP)](https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_03_02.html)
