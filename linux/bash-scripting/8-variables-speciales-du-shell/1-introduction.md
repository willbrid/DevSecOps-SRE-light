# Introduction

Le scripting shell repose sur le **retour d'information** : savoir si chaque étape a réussi, échoué ou nécessite un traitement particulier. Les **variables spéciales du shell** donnent accès à des informations sur l'**environnement du shell**, les **arguments** de la ligne de commande, les **identifiants de processus**, etc. Les utiliser rend les scripts plus **robustes** et plus **maintenables**.

### 1. Le code de sortie en Bash

Chaque commande renvoie un **code de sortie** (*exit status*) :
- `0` = **succès** ;
- toute valeur **non nulle** = **échec**.

La variable spéciale **`$?`** contient toujours le code de sortie de la **dernière commande exécutée** :

```bash
$ ls /nonexistent
ls: cannot access '/nonexistent': No such file or directory
$ echo $?
2
$ echo "Listing current directory:"
$ ls
KodeKloud_introduction
$ echo $?
0
```

> Lire `$?` **immédiatement** après la commande : chaque nouvelle commande (même un `echo`) écrase sa valeur.

> Pour le réutiliser plus tard, le sauvegarder :
> ```bash
> grep -q "ERROR" app.log
> status=$?
> echo "Recherche terminée"
> if [ "$status" -eq 0 ]; then echo "Erreurs trouvées"; fi
> ```
> Le plus souvent, on teste directement la commande : `if grep -q "ERROR" app.log; then …`

### 2. Les variables spéciales courantes

Paramètres spéciaux **POSIX** les plus utilisés :

| Variable | Description | Exemple |
||||
| `$*` | Tous les paramètres positionnels en **un seul mot** | `echo "Args: $*"` |
| `$#` | **Nombre** de paramètres positionnels | `echo "Count: $#"` |
| `$0` | **Nom** du script ou du shell | `echo "Script: $0"` |
| `$!` | **PID** de la dernière commande lancée en **arrière-plan** | `sleep 30 &` puis `echo $!` |
| `$-` | **Options** actives du shell, sous forme de chaîne | `echo "Options: $-"` |

Ces variables se mettent à jour **dynamiquement** selon le contexte d'exécution du script.

> `$*` **sans guillemets** subit le découpage en mots et le globbing. Mettre des guillemets, ou utiliser **`$@`** quand il faut **préserver les limites** de chaque argument.

> Compléments :
> | Variable | Description |
> |||
> | `$?` | Code de sortie de la dernière commande |
> | `$@` | Tous les arguments, **chacun séparé** (`"$@"` = la forme à utiliser dans les boucles) |
> | `$1` … `$9`, `${10}` | Arguments positionnels |
> | `$$` | PID du shell / du script courant |
> | `$_` | Dernier argument de la commande précédente |
>
> Exemple de `$-` :
> ```bash
> $ echo $-
> himBHs
> # h = hashall, i = interactif, m = contrôle des jobs, B = brace expansion, H = historique (!), s = lit stdin
> $ set -e; echo $-     # le "e" (errexit) apparaît
> ```
> Utile pour tester si le shell est **interactif** : `[[ $- == *i* ]] && echo "interactif"`.
>
> Différence `"$*"` / `"$@"` :
> ```bash
> # ./demo.sh "un deux" trois
> for a in "$*"; do echo "[$a]"; done   # [un deux trois]           → 1 seul élément
> for a in "$@"; do echo "[$a]"; done   # [un deux] [trois]         → 2 éléments, espaces respectés
> ```

### 3. Cas d'usage pratiques

#### 3.1 Valider les arguments

```bash
if [ $# -lt 2 ]; then
  echo "Usage: $0 <source> <destination>"
  exit 1
fi
```

Si moins de 2 arguments sont fournis, le script affiche son mode d'emploi (avec son propre nom via `$0`) et s'arrête.

> Variante plus robuste : message sur stderr et `[[ ]]` :
> ```bash
> [[ $# -lt 2 ]] && { echo "Usage: $0 <source> <destination>" >&2; exit 1; }
> ```

#### 3.2 Journaliser le nom du script

```bash
echo "[$(date)] Starting backup script: $0"
```

> `$0` contient le chemin **tel qu'il a été appelé** (`./backup.sh`, `/opt/scripts/backup.sh`…). Pour le nom seul : `${0##*/}`.

#### 3.3 Surveiller un job en arrière-plan

```bash
long_running_task &
bg_pid=$!
wait $bg_pid
echo "Job $bg_pid finished with status $?"
```

- `&` lance la tâche en arrière-plan ;
- `$!` récupère **immédiatement** son PID ;
- `wait $bg_pid` attend la fin de ce processus précis ;
- `$?` contient alors le **code de sortie de la tâche** (renvoyé par `wait`).

> Exemple avec plusieurs jobs en parallèle :
> ```bash
> sleep 2 & pid1=$!
> sleep 3 & pid2=$!
> wait "$pid1"; echo "Job 1 : $?"
> wait "$pid2"; echo "Job 2 : $?"
> ```

### À retenir

- `$?` = code de sortie de la **dernière** commande (0 = succès) ; à lire ou sauvegarder **immédiatement**.
- `$#` = nombre d'arguments ; `$0` = nom du script ; `$1`, `$2`… = arguments.
- `"$@"` = arguments **séparés** (recommandé) ; `"$*"` = arguments **en une seule chaîne**.
- `$!` = PID du dernier job en **arrière-plan** → `wait $!` puis `$?` donne son code de sortie.
- `$$` = PID du script ; `$-` = options du shell (`*i*` → interactif).
- Toujours **quoter** les variables spéciales qui contiennent des arguments.
- Usages typiques : validation des arguments (`$#` + `$0`), logs (`$0`), suivi de jobs (`$!` + `wait`).

### Liens utiles

- [GNU Bash – Special Parameters](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)
- [GNU Bash – Job Control Builtins (wait)](https://www.gnu.org/software/bash/manual/html_node/Job-Control-Builtins.html)
- [POSIX – Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- [Shell Scripting Tutorial](https://www.shellscript.sh/)
