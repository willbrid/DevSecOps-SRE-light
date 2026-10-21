# Clause de garde

La **clause de garde** est une technique simple qui consiste à **vérifier les préconditions dès le début** et à **quitter immédiatement** si elles ne sont pas remplies (*fail fast*). Résultat : moins d'imbrication, un chemin principal (le cas de succès) **plat et lisible**, et un script plus facile à maintenir.

### 1. Pourquoi éviter l'imbrication profonde ?

Une vérification simple reste lisible :

```bash
#!/bin/bash

# Vérifier si un fichier existe
if [[ -e myfile.txt ]]; then
    echo "File exists"
else
    echo "File does not exist"
fi
```

Mais dès qu'on enchaîne plusieurs conditions (utilisateur admin, fichier existant, fichier non vide), on obtient une **pyramide de `if`** :

```bash
#!/bin/bash

if [[ "${USER_NAME}" == "admin" ]]; then
    if [[ -e "${FILE_PATH}" ]]; then
        if [[ -s "${FILE_PATH}" ]]; then
            run_process
        else
            echo "File exists but is empty"
        fi
    else
        echo "File does not exist"
    fi
else
    echo "User is not admin"
fi

exit 0
```

Problèmes : le flux est difficile à suivre, chaque message d'erreur est éloigné de la condition qui le provoque, et la lecture/le débogage demandent plus d'effort.

### 2. Utiliser des clauses de garde pour échouer vite

On **inverse les conditions** (avec `!` ou `!=`) et on **sort immédiatement** en cas d'échec. Le traitement principal se retrouve à la fin, sans indentation :

```bash
#!/bin/bash
readonly FILE_PATH="/home/ubuntu/guard_clause/file.txt"
readonly USER_NAME="admin"

run_process() {
    echo "running process..."
}

if [[ "${USER_NAME}" != "admin" ]]; then
    echo "User is not admin"
    exit 1
fi

if [[ ! -e "${FILE_PATH}" ]]; then
    echo "File does not exist"
    exit 1
fi

if [[ ! -s "${FILE_PATH}" ]]; then
    echo "File exists but is empty"
    exit 1
fi

run_process

exit 0
```

Chaque condition est **autonome** : vérification → message → `exit 1`. Une fois toutes les clauses de garde passées, la suite peut **supposer** que tout est valide.

Bénéfices :
- ✅ Meilleure **lisibilité**
- ✅ **Moins d'imbrication** de conditions
- ✅ Prévention des **bugs difficiles à trouver**

> Rappel des tests de fichiers : `-e` existe, `-f` fichier régulier, `-d` répertoire, `-s` existe **et** non vide, `-r`/`-w`/`-x` lisible/modifiable/exécutable.

### 3. clause de garde minimale

```bash
if [[ ! -f ${file} ]]; then
    exit 1
fi
```

Le code qui suit ne s'exécute que si le fichier existe.

### 4. Exemple pratique : exiger un argument

Clause de garde très courante : vérifier qu'un argument obligatoire a bien été fourni avant de continuer.

```bash
#!/bin/bash

if [[ -z "${1}" ]]; then
    echo "Usage: $0 <git-repository-url>"
    exit 1
fi

git_url="${1}"

git clone "${git_url}"

exit 0
```

- `-z` = chaîne vide (l'inverse est `-n` = chaîne non vide).
- `$0` affiche le nom du script dans le message d'usage.

Conseils :
- Pour plusieurs options ou des options facultatives, préférer **`getopts`** ou une bibliothèque de parsing.
- Utiliser `$#`, `$@` et les paramètres positionnels pour des vérifications robustes, par ex. :
  ```bash
  [[ $# -ne 1 ]] && { echo "Usage: $0 <url>" >&2; exit 1; }
  ```

### 5. Clauses de garde en une ligne (court-circuit)

Les opérateurs logiques du shell permettent d'écrire des clauses de garde très concises :

| Opérateur | Usage | Exemple |
||||
| `\|\|` (OU) | Exécute la partie droite **si la gauche échoue** → échec rapide | `[[ -f "file.txt" ]] \|\| echo "file does not exist"` |
| `&&` (ET) | Exécute la partie droite **seulement si la gauche réussit** | `[[ -n "${1}" ]] && echo "argument provided: $1"` |

Pour exécuter **plusieurs commandes** à droite (message + sortie), on les **regroupe avec des accolades** :

```bash
[[ -f "file.txt" ]] || { echo "file does not exist"; exit 1; }
```

> Syntaxe des accolades : **espace après `{`** et **`;` avant `}`**.
> Ne pas utiliser de parenthèses `( … )` à la place : elles lancent un **sous-shell**, et le `exit` ne quitterait que ce sous-shell, pas le script.

### À retenir

- **clause de garde** = vérifier les préconditions **en début de script** et **sortir immédiatement** si elles échouent.
- On **inverse la condition** (`!`, `!=`, `-z`) pour tester le cas d'erreur plutôt que le cas de succès.
- Chaque clause de garde : test → message d'erreur → `exit 1` (code non nul = échec).
- Le chemin principal reste **plat**, en fin de script, et peut supposer que tout est valide.
- Clause de garde classique pour un argument : `[[ -z "$1" ]]` + message `Usage: $0 …`.
- Version courte : `condition || { echo "erreur"; exit 1; }` — accolades, pas parenthèses.
- `&&` = exécuter si succès ; `||` = exécuter si échec.
- Bonne pratique : envoyer les messages d'erreur sur **stderr** avec `>&2`.

### Liens utiles

- [Bash Reference Manual (GNU)](https://www.gnu.org/software/bash/manual/)
- [Bash – Conditional Expressions (`-e`, `-f`, `-s`, `-z`…)](https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html)
- [Shell Scripting Tutorial – bonnes pratiques](https://www.shellscript.sh/)
- [Documentation Git – git clone](https://git-scm.com/docs/git-clone)
