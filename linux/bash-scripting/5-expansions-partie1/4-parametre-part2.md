# Expansion de paramètres Part2

### 1. Les limites des préfixes/suffixes fixes

Sous Linux, on manipule souvent des chemins et des extensions :

| Composant | Exemple 1 | Exemple 2 | Exemple 3 |
|||||
| **Préfixe** (chemin) | `/home/my_username/` | `/home/my_username/` | `/usr/bin/` |
| **Nom** | `text_file` | `text_file2` | `app.py` |
| **Suffixe** (extension) | `.txt` | `.txt` | `.py` |

Un suffixe fixe comme `${var%.txt}` ne fonctionne **que** si le fichier se termine par `.txt` :

```bash
$ var="/home/my_username/text_file.txt"
$ echo "${var%.txt}"
/home/my_username/text_file

$ var="/home/my_username/text_file2.txt"
$ echo "${var%.txt}"
/home/my_username/text_file2

$ var="/usr/bin/app.py"
$ echo "${var%.txt}"
/usr/bin/app.py
```

Le `.py` reste intact. Pour des extensions **quelconques**, il faut des **jokers**.

### 2. Utiliser les jokers pour les cas généraux

En ajoutant `*` au motif, on supprime **tout jusqu'à** (ou **à partir de**) un délimiteur : espace, slash, point…

#### Supprimer le premier mot

`${var#* }` supprime le **plus court** préfixe correspondant : tout jusqu'au **premier espace** inclus.

```bash
export position1="Senior Cloud Architect"
export position2="Senior DevOps Engineer"
export position3="Associate Frontend Engineer"
export position4="Junior Software Developer"

echo "${position1#* }"   # Cloud Architect
echo "${position2#* }"   # DevOps Engineer
echo "${position3#* }"   # Frontend Engineer
echo "${position4#* }"   # Software Developer
```

#### Supprimer le dernier mot

`${var% *}` supprime le **plus court** suffixe correspondant : du **dernier espace** jusqu'à la fin.

```bash
echo "${position1% *}"   # Senior Cloud
echo "${position2% *}"   # Senior DevOps
echo "${position3% *}"   # Associate Frontend
echo "${position4% *}"   # Junior Software
```

> Avec les versions « longues » :
> ```bash
> echo "${position1##* }"  # Architect   → garde seulement le dernier mot
> echo "${position1%% *}"  # Senior      → garde seulement le premier mot
> ```

> Toujours associer `*` à un **caractère littéral** (espace, `/`, `.`…).

### 3. Manipuler des noms de fichiers Unix

```bash
my_text_file="/home/my_username/text_file.txt"
my_python_file="/usr/bin/app.py"
```

- **Préfixe** : chemin du répertoire
- **Nom** : nom du fichier
- **Suffixe** : extension

#### Supprimer les répertoires

- `${var#*/}` : supprime jusqu'au **premier** `/`
- `${var##*/}` : supprime jusqu'au **dernier** `/` (plus long préfixe) → équivalent de `basename`

```bash
echo "${my_text_file#*/}"    # home/my_username/text_file.txt
echo "${my_python_file#*/}"  # usr/bin/app.py

echo "${my_text_file###*/}"   # text_file.txt
echo "${my_python_file###*/}" # app.py
```

> Avec un chemin absolu, `#*/` ne retire que le `/` initial (le plus court motif `*/` est simplement `/`).

#### Supprimer l'extension

`%` (plus court suffixe) ou `%%` (plus long suffixe). Avec **un seul point**, les deux donnent le même résultat :

```bash
echo "${my_text_file%.*}"   # /home/my_username/text_file
echo "${my_text_file%%.*}"  # /home/my_username/text_file

echo "${my_python_file%.*}"   # /usr/bin/app
echo "${my_python_file%%.*}"  # /usr/bin/app
```

> La différence apparaît avec **plusieurs points** :
> ```bash
> archive="backup.tar.gz"
> echo "${archive%.*}"     # backup.tar   → retire seulement la dernière extension
> echo "${archive%%.*}"    # backup       → retire tout depuis le premier point
>
> # Piège : un point dans un nom de dossier
> f="/home/jean.dupont/notes.txt"
> echo "${f%%.*}"          # /home/jean   ❌
> echo "${f%.*}"           # /home/jean.dupont/notes ✅
> ```
> D'où la règle : **`%` pour les extensions**.

> Combinaison utile : nom sans chemin ni extension
> ```bash
> name="${my_text_file###*/}"   # text_file.txt
> echo "${name%.*}"            # text_file
> ```

### 4. Choisir le bon opérateur

| Opérateur | Description | Usage |
||||
| `${var#…}` | Supprime le **plus court préfixe** | Jusqu'au **premier** délimiteur |
| `${var##…}` | Supprime le **plus long préfixe** | Jusqu'au **dernier** délimiteur |
| `${var%…}` | Supprime le **plus court suffixe** | Depuis le **dernier** délimiteur |
| `${var%%…}` | Supprime le **plus long suffixe** | Depuis le **premier** délimiteur |

- **Plus court suffixe** (`%`) → pour les **extensions**.
- **Plus long préfixe** (`##`) → pour les **chemins de répertoires**.

Avec ces quatre opérateurs, on adapte la manipulation à n'importe quelle donnée délimitée : noms de fichiers, chemins, mots…

> Exemple pratique (contexte Kubernetes/Docker) :
> ```bash
> image="docker.io/library/nginx:1.27.2"
> echo "${image###*/}"      # nginx:1.27.2   → sans registre
> echo "${image###*:}"      # 1.27.2         → le tag
> repo="${image%:*}"       # docker.io/library/nginx
> echo "${repo##*/}"       # nginx          → nom seul
>
> pod="pod/nginx-7d9f8c6b5-x2k4p"
> echo "${pod#*/}"         # nginx-7d9f8c6b5-x2k4p
> ```

### À retenir

- Un suffixe/préfixe **fixe** (`%.txt`) ne marche que pour ce cas précis ; les **jokers** (`%.*`) généralisent.
- **Simple** (`#`, `%`) = plus **court** ; **double** (`###`, `%%`) = plus **long**.
- `#` agit au **début**, `%` à la **fin**.
- `${var#* }` = sans le 1er mot ; `${var% *}` = sans le dernier mot ; `${var###* }` = dernier mot ; `${var%% *}` = premier mot.
- `${path##*/}` = **basename** ; `${path%/*}` = **dirname**.
- `${file%.*}` = sans la **dernière** extension (recommandé) ; `${file%%.*}` = sans **toutes** (attention aux points dans les dossiers).
- Toujours associer `*` à un **délimiteur littéral** ; `${var###*}` / `${var%%*}` → chaîne vide, `${var#*}` / `${var%*}` → inchangé.

### Liens utiles

- [GNU Bash – Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [GNU Bash – Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
- [Kubernetes – What is Kubernetes?](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)
- [Docker Hub](https://hub.docker.com/)
