# Variable $0

En Bash, le paramètre spécial **`$0`** contient le **nom (et le chemin)** utilisé pour **invoquer** le script. Savoir le manipuler permet de :
1. récupérer le **nom** ou le **chemin complet** du script tel qu'il a été appelé ;
2. déterminer le **répertoire absolu** où se trouve le script.

### 1. Récupérer le nom d'invocation du script

`$0` affiche **exactement** la façon dont le script a été appelé :

```bash
#!/usr/bin/env bash
echo "$0"
```

Enregistré sous `show-zero.sh` :

```bash
$ ./show-zero.sh
./show-zero.sh

$ # S'il est dans le PATH :
$ show-zero.sh
/usr/local/bin/show-zero.sh
```

> Autres cas :
> ```bash
> $ bash show-zero.sh          # → show-zero.sh
> $ /home/user/show-zero.sh    # → /home/user/show-zero.sh
> $ source show-zero.sh        # → -bash ou bash (nom du shell, pas du script !)
> ```
> Pour un script destiné à être **sourcé**, utiliser **`${BASH_SOURCE[0]}`**, qui contient toujours le chemin du fichier en cours.
> Dans une **fonction**, `$0` reste le nom du **script** (le nom de la fonction est dans `${FUNCNAME[0]}`).

### 2. Extraire uniquement le nom de fichier (basename)

Avec l'**expansion de paramètres** :

```bash
#!/usr/bin/env bash
readonly SCRIPT_NAME=${0##*/}
echo "${SCRIPT_NAME}"
```

```bash
$ ./show-zero.sh
show-zero.sh
```

`${0##*/}` supprime le **plus long préfixe** correspondant à `*/`, donc tout jusqu'au **dernier** `/` (équivalent de `basename "$0"`, sans lancer de processus).

### 3. Messages d'usage dynamiques avec `SCRIPT_NAME`

Intégrer le nom du script dans l'aide garantit un message **toujours exact**, même si le fichier est **renommé** :

```bash
#!/usr/bin/env bash
readonly SCRIPT_NAME=${0##*/}

usage() {
  cat <<USAGE
Usage: ${SCRIPT_NAME} <name>

Greet a user by name.

Arguments:
  name       The name to greet.

Options:
  -h, --help Show this help message and exit.
USAGE
}

# Afficher l'aide
usage
```

Sortie :

```bash
$ ./show-zero.sh
Usage: show-zero.sh <name>

Greet a user by name.

Arguments:
  name       The name to greet.

Options:
  -h, --help Show this help message and exit.
```

> Le **heredoc** (`cat <<USAGE … USAGE`) affiche un bloc multiligne ; comme le délimiteur n'est pas quoté, `${SCRIPT_NAME}` est bien **développé**.

### 4. Sorties propres avec une fonction `terminate`

Centraliser l'affichage des erreurs et les **codes de sortie personnalisés** :

```bash
#!/usr/bin/env bash
readonly SCRIPT_NAME=${0##*/}
readonly ERR_MISSING_ARG=155

usage() {
  cat <<USAGE
Usage: ${SCRIPT_NAME} <name>

Greet a user by name.

Options:
  -h, --help Show this help message and exit.
USAGE
}

terminate() {
  echo "Error: ${1}" >&2
  exit "${2:-1}"
}

# Vérification du nombre d'arguments
if [[ $# -ne 1 ]]; then
  usage
  terminate "Missing argument" "$ERR_MISSING_ARG"
fi

# Option d'aide
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

name="$1"
echo "Hello, ${name}! Welcome!"
exit 0
```

Exécutions (aide abrégée ici) :

```bash
$ ./greet.sh
Usage: greet.sh <name>
...
Error: Missing argument
$ echo $?
155

$ ./greet.sh --help
Usage: greet.sh <name>
...
$ echo $?
0

$ ./greet.sh Alice
Hello, Alice! Welcome!
```

> Pour un parsing d'options plus avancé (options courtes et longues), utiliser **`getopts`**.

> Bonnes pratiques :
> - En cas d'**erreur**, envoyer l'aide sur **stderr** (`usage >&2`) ; avec `--help`, sur **stdout** (c'est la sortie demandée).
> - Le message `Missing argument` est trompeur si l'utilisateur en a fourni **trop** : préférer `"Expected exactly 1 argument, got $#"`.
> - Codes personnalisés de préférence entre **3 et 125**.

### 5. Trouver le répertoire du script (`WORK_DIR`)

Les **chemins relatifs codés en dur** cassent dès qu'on lance le script depuis un autre dossier (ils sont relatifs au **répertoire courant**, pas au script). Solution : calculer le répertoire du script :

```bash
#!/usr/bin/env bash
readonly WORK_DIR=$(dirname "$(readlink -f "$0")")
```

- `readlink -f "$0"` → chemin **absolu canonique** du script (en suivant les **liens symboliques**) ;
- `dirname` → extrait le **répertoire parent**.

On peut ensuite référencer les fichiers **relativement au script** :

```bash
cd "${WORK_DIR}/../assets"
cd "${WORK_DIR}/subdir"
# ...autres tâches
```

> Sur **macOS**, `readlink -f` peut ne pas exister : installer `coreutils` (`brew install coreutils`) ou utiliser `realpath`.

> Variantes robustes :
> ```bash
> # Fonctionne aussi quand le script est sourcé
> WORK_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
>
> # Sans readlink (portable, ne résout pas les liens symboliques)
> WORK_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
>
> # Utiliser des chemins absolus plutôt que cd
> source "${WORK_DIR}/lib/common.sh"
> config="${WORK_DIR}/config/app.conf"
> ```
> ShellCheck (SC2155) conseille de séparer déclaration et affectation pour ne pas masquer un échec : `WORK_DIR=$(…); readonly WORK_DIR`.

### 6. Tableau récapitulatif

| Élément | Rôle | Exemple |
|---|---|---|
| `$0` | Comment le script a été invoqué | `echo "$0"` |
| `${0##*/}` | Nom du script seul (basename) | `SCRIPT_NAME=${0##*/}` |
| Heredoc d'usage | Insérer `SCRIPT_NAME` dans l'aide | `cat <<USAGE …` |
| `terminate()` | Uniformiser erreurs et codes de sortie | `terminate "message" 42` |
| `readlink -f` + `dirname` | Répertoire absolu du script (`WORK_DIR`) | `WORK_DIR=$(dirname "$(readlink -f "$0")")` |

Ces modèles rendent les scripts plus **prévisibles**, **portables** et **conviviaux**.

### À retenir

- `$0` = nom/chemin **tel qu'il a été tapé** pour lancer le script (`./x.sh`, `/usr/local/bin/x.sh`, `x.sh`…).
- Script **sourcé** → `$0` = nom du shell ; utiliser `${BASH_SOURCE[0]}`.
- `${0##*/}` = nom du script seul → à utiliser dans les messages d'usage (reste juste si le fichier est renommé).
- Aide en heredoc (`cat <<USAGE`) ; sur stderr en cas d'erreur, stdout avec `--help` (exit 0).
- `terminate "msg" code` : message sur stderr + code personnalisé.
- `WORK_DIR=$(dirname "$(readlink -f "$0")")` → chemins relatifs **au script**, pas au répertoire courant ; macOS : `realpath` / coreutils.
- Pour des options complexes : `getopts`.

### Liens utiles

- [GNU Bash – Special Parameters (`$0`)](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)
- [GNU Bash – Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [GNU Bash – Bash Variables (`BASH_SOURCE`, `FUNCNAME`)](https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html)
- [man readlink](https://man7.org/linux/man-pages/man1/readlink.1.html)
- [GNU Bash – getopts (Bourne Shell Builtins)](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html)
- [BashFAQ 028 – Trouver l'emplacement du script (Wooledge)](https://mywiki.wooledge.org/BashFAQ/028)
