# Substitution de commande

La **substitution de commande** permet de **capturer la sortie d'une commande** et de l'**insérer dans une autre** (ou dans une variable). Elle améliore la lisibilité des scripts et permet de manipuler des données **dynamiques**.

### 1. Rappel : l'expansion de variables

`$` suivi du nom de la variable renvoie sa valeur. Les accolades `{}` évitent les ambiguïtés, les guillemets empêchent le découpage en mots et le globbing.

```bash
name="John"
echo "${name}"
# Sortie : John
```

> Toujours mettre les expansions entre guillemets (`"${var}"`) pour préserver les espaces et éviter un globbing inattendu.

### 2. Qu'est-ce que la substitution de commande ?

Le shell exécute la commande dans un **sous-shell** et **remplace** la commande par sa **sortie standard (stdout)**. Deux syntaxes :

| Syntaxe | Description |
|||
| `$( ... )` | Forme **recommandée** ; imbrication facile |
| `` `...` `` | **Obsolète** ; moins lisible, difficile à imbriquer |

#### Exemple : compter les fichiers en ligne de commande

```bash
$ ls
DEV001  DEV002  DEV003  DEV004  MKT001  MKT002  MKT003  MKT004  command-substitution.sh
$ find . -type f | wc -l
9
```

#### Avec `$( ... )`

`command-substitution.sh` :

```bash
#!/usr/bin/env bash
file_count=$(find . -type f | wc -l)
echo "Total files: ${file_count}"
```

```bash
$ chmod +x command-substitution.sh
$ ./command-substitution.sh
Total files: 9
```

#### Avec les backticks (obsolète)

```bash
#!/usr/bin/env bash
file_count=`find . -type f | wc -l`
echo "Total files: ${file_count}"
```

> Les backticks compliquent l'imbrication et nuisent à la lisibilité. Toujours préférer `$( ... )`.

> Exemple d'imbrication :
> ```bash
> # Dossier contenant le script, quel que soit l'endroit d'où on le lance
> script_dir=$(dirname "$(readlink -f "$0")")
>
> # Équivalent avec backticks : il faut échapper les backticks internes
> script_dir=`dirname \`readlink -f "$0"\``
> ```

### 3. Accepter un répertoire en argument

Exiger que l'utilisateur indique le répertoire cible (guard clause) :

```bash
#!/usr/bin/env bash
if [[ -z "${1}" ]]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

file_count=$(find "${1}" -type f | wc -l)
echo "Files in ${1}: ${file_count}"
```

```bash
$ ./command-substitution-v2.sh .
Files in .: 9
```

### 4. Moment d'exécution

La substitution est exécutée **une seule fois, au moment de l'affectation**. Si les fichiers changent ensuite, la valeur stockée **ne bouge pas** tant qu'on ne la recalcule pas.

```bash
#!/usr/bin/env bash
if [[ -z "${1}" ]]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

file_count=$(find "${1}" -type f | wc -l)
echo "Initial count: ${file_count}"

touch samplefile
echo "After touch: ${file_count}"
```

```bash
$ ./command-substitution-v3.sh .
Initial count: 9
After touch: 9
```

En relançant le script, le comptage est mis à jour (le fichier `samplefile` existe désormais) :

```bash
$ ./command-substitution-v3.sh .
Initial count: 10
After touch: 10
```

> La variable contient un **instantané**, pas une « formule ». Pour une valeur toujours à jour, utiliser une **fonction** :
> ```bash
> count_files() { find "${1}" -type f | wc -l; }
> echo "Avant : $(count_files .)"
> touch autrefichier
> echo "Après : $(count_files .)"
> ```

### 5. Portée du sous-shell

La substitution s'exécute dans un **sous-shell** : les variables modifiées à l'intérieur **n'affectent pas** le shell parent.

```bash
#!/usr/bin/env bash
if [[ -z "${1}" ]]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

dir=${1}
file_count=$(find "${dir}" -type f | wc -l)

sub_output=$(
  dir="/some/other/dir"
  echo "Dir in subshell: ${dir}"
)

echo "Dir in parent shell: ${dir}"
echo "${sub_output}"
```

```plaintext
$ ./command-substitution-v4.sh /usr/bin
Dir in parent shell: /usr/bin
Dir in subshell: /some/other/dir
```

Un **sous-shell** est un **processus enfant** du shell parent : il **hérite** de son environnement, mais ses modifications **ne remontent pas** au parent.

> Le seul moyen de récupérer une information du sous-shell est sa **sortie** (stdout) ou son **code de retour** :
> ```bash
> result=$(grep -q "error" app.log; echo $?)   # stdout
> if output=$(some_command); then …            # le if teste le code de retour de some_command
> ```

### 6. Performances

Chaque substitution **crée un nouveau processus**. C'est négligeable dans la plupart des scripts, mais à éviter dans les **boucles intensives**.

> Ne pas placer de substitutions coûteuses dans des boucles serrées. Alternatives : `readarray`/`mapfile`, opérations de chaînes intégrées.

> Exemples d'optimisation :
> ```bash
> # Lent : un processus basename par fichier
> for f in /var/log/*.log; do name=$(basename "$f"); done
> # Rapide : expansion de paramètres, aucun processus
> for f in /var/log/*.log; do name="${f##*/}"; done
>
> # Lire un fichier : $(< fichier) évite de lancer cat
> content=$(< config.txt)
>
> # Charger des lignes dans un tableau en une fois
> readarray -t lines < config.txt
> ```

### 7. Mentions honorables

| Usage | Exemple |
|||
| Capturer **stderr** | `files=$(ls -j 2>&1)` |
| Capturer un **horodatage** | `current_date=$(date)` |

```bash
echo "Errors: ${files}"
echo "Today's date: ${current_date}"
```

> Par défaut, `$(…)` ne capture **que stdout** ; `2>&1` est nécessaire pour inclure les erreurs.

> Comportements à connaître :
> - Les **retours à la ligne finaux** sont supprimés automatiquement.
> - Toujours **quoter** le résultat : `echo "$(ls -l)"` conserve les retours à la ligne, `echo $(ls -l)` les remplace par des espaces.
> - Ne pas confondre avec l'**arithmétique** `$(( 2 + 3 ))`.
> - Exemple Kubernetes :
>   ```bash
>   pod=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
>   kubectl logs "$pod"
>   ```

### À retenir

- `$(commande)` remplace la commande par son **stdout** ; préférer `$( )` aux backticks (lisibilité, imbrication).
- Exécutée **une seule fois** à l'affectation : la variable est un **instantané** (utiliser une fonction pour recalculer).
- S'exécute dans un **sous-shell** : hérite de l'environnement, mais les modifications **ne remontent pas**.
- Seul **stdout** est capturé ; ajouter `2>&1` pour stderr.
- Retours à la ligne finaux supprimés ; **guillemets** autour pour garder la mise en forme.
- Chaque substitution = un processus : éviter dans les boucles, préférer `${var##*/}`, `$(< fichier)`, `readarray`.
- `$(( ))` = arithmétique, ≠ `$( )`.

### Liens utiles

- [GNU Bash – Command Substitution](https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
- [ShellCheck – SC2006 : préférer $(...) aux backticks](https://www.shellcheck.net/wiki/SC2006)
