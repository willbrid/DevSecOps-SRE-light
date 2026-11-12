# Les sous-shells

La substitution de commande `$(…)` capture la sortie d'une commande, mais pour cela elle lance un **sous-shell** : un **processus enfant** distinct du shell principal.

```bash
#!/usr/bin/env bash
file_count=$(find . -type f | wc -l)
```

- Les affectations faites dans le sous-shell **n'affectent pas** les variables du shell parent.
- Créer un processus a un **léger coût** en performance par rapport à une exécution directe dans le shell parent.

> Abuser de substitutions complexes dans des boucles serrées peut dégrader les performances. Mesurer et optimiser si nécessaire.

```bash
#!/usr/bin/env bash
var="a"
subshell=$( var="b" )
echo "$var"        # toujours "a"
echo "$subshell"   # vide : var="b" a été fait dans le sous-shell, sans rien afficher
```

Un sous-shell est un **processus enfant** lancé par le shell parent : il **hérite** de son environnement, mais ses modifications **ne remontent pas** au parent.

> Précision : un sous-shell `( )` ou `$( )` est une **copie** (fork) du shell courant. Il hérite de **toutes** les variables, même **non exportées**, ainsi que des fonctions. C'est différent d'un **script enfant** (`bash autre.sh` ou `./autre.sh`), qui ne reçoit que les variables **exportées**.
> ```bash
> x="local"
> ( echo "$x" )           # local   → visible dans le sous-shell
> bash -c 'echo "$x"'     # (vide)  → pas visible dans un nouveau bash, sauf export x
> ```

### 1. Syntaxe du sous-shell

Des commandes entre **parenthèses** s'exécutent dans un sous-shell :

```bash
#!/usr/bin/env bash
current_env="shell"
(
  echo "This is running in a ${current_env}"
)
```

```plaintext
$ ./subshell-v0.sh
This is running in a shell
```

Preuve de l'isolation :

```bash
#!/usr/bin/env bash
current_env="a"
(
  current_env="b"
  echo "Inside subshell: $current_env"
)
echo "Outside subshell: $current_env"
```

```plaintext
$ ./subshell-v1.sh
Inside subshell: b
Outside subshell: a
```

> Ne pas confondre avec les **accolades** `{ }`, qui regroupent des commandes **dans le shell courant** (pas d'isolation, pas de nouveau processus) :
> ```bash
> current_env="a"
> { current_env="b"; }        # espace après { et ; avant } obligatoires
> echo "$current_env"         # b
> ```

### 2. Substitution de commande avec un sous-shell

Combiner sous-shell et `$(…)` pour récupérer sa **sortie** sans toucher au parent :

```bash
#!/usr/bin/env bash
current_env="a"

subsh_var=$(
  current_env="b"
  echo "$current_env"
)

echo "Parent environment: $current_env"
echo "Subshell output: $subsh_var"
```

```plaintext
$ ./subshell-v2.sh
Parent environment: a
Subshell output: b
```

Les **erreurs** du sous-shell s'affichent quand même dans le terminal (seul stdout est capturé) :

```bash
#!/usr/bin/env bash
subsh_var=$(
  echo "Output"
  ls -fakeoption
)
```

```plaintext
$ ./subshell-v2-stderr.sh
ls: unrecognized option '--fakeoption'
```

> `"Output"` est capturé dans `subsh_var` (non affiché) ; seul le message d'erreur (stderr) apparaît. Pour capturer aussi l'erreur : `ls -fakeoption 2>&1`.
> (Selon la version de `ls`, le message peut différer, ex. `ls: invalid option -- 'e'`, car `-fakeoption` est lu comme une suite d'options courtes.)

### 3. Organisation des commandes dans un sous-shell

Entre parenthèses, on peut :
- écrire les commandes sur **plusieurs lignes** ;
- les séparer par des **points-virgules** `;` ;
- les relier par des **pipes** `|` ;
- les enchaîner avec `&&` ou `||`.

```bash
# Lignes séparées
(
  command1
  command2
  command3
)

# Points-virgules
(command1; command2; command3)

# Pipes
(command1 | command2 | command3)

# Opérateur ET
(command1 && command2 && command3)

# Opérateur OU
(command1 || command2)
```

> Usage pratique : rediriger la sortie de **plusieurs commandes** d'un coup :
> ```bash
> (date; uptime; df -h) > rapport.txt
> ```

### 4. Cas d'usage courants

#### 4.1 Changer temporairement de répertoire

Exécuter des commandes dans un autre dossier **sans modifier** le répertoire courant :

```bash
#!/usr/bin/env bash
# Mettre à jour et compiler dans /home/user/project
(cd /home/user/project && git pull && make)
```

Exemple interactif :

```bash
$ pwd
/home/user/workspace
$ (cd /tmp && ls)
file_in_tmp
$ pwd
/home/user/workspace
```

> Même principe pour isoler des options ou variables temporaires :
> ```bash
> (set -e; export DEBUG=1; ./build.sh)   # set -e et DEBUG ne fuient pas dans le shell courant
> (umask 077; touch secret.txt)          # umask restrictif seulement ici
> ```

#### 4.2 Étapes de pipeline Jenkins

Dans un pipeline Jenkins, chaque étape `sh` s'exécute dans **son propre processus shell**. Cette isolation explique certaines différences quand des scripts tournent en CI/CD.

> Conséquence typique : un `cd` ou un `export` dans une étape `sh` **n'est pas conservé** pour l'étape suivante. Il faut regrouper les commandes dans une même étape ou utiliser `dir('…') { }` / `withEnv([…])`. Même logique pour les étapes `run:` de GitHub Actions / GitLab CI.

### 5. Vérifier les PID

| Variable | Description |
|||
| `$$` | PID du shell **parent** (du script) |
| `$BASHPID` | PID du processus Bash **courant** (y compris dans un sous-shell) |

```bash
#!/usr/bin/env bash
parent_pid=$$

(
  echo "Inside subshell: PID=$BASHPID"
)

echo "Outside subshell: PID=$parent_pid"
```

```plaintext
$ ./subshell-v5.sh
Inside subshell: PID=12345
Outside subshell: PID=12344
```

> Piège : dans un sous-shell, `$$` renvoie **toujours le PID du parent**, pas celui du sous-shell :
> ```bash
> echo "$$ $BASHPID"          # 12344 12344
> ( echo "$$ $BASHPID" )      # 12344 12345  ← $$ inchangé, $BASHPID différent
> ```
> D'où l'intérêt de `$BASHPID` pour prouver qu'on est dans un autre processus.

### 6. Remonter une valeur vers le shell parent

Un sous-shell ne peut pas modifier directement les variables du parent : on passe par un **fichier temporaire** ou un autre mécanisme de communication inter-processus :

```bash
#!/usr/bin/env bash
tmpfile="/tmp/$$.tmp"
counter=1

# Initialiser le compteur
echo "$counter" > "$tmpfile"

# Incrémenter dans le sous-shell
(
  new_count=$(( $(<"$tmpfile") + 1 ))
  echo "$new_count" > "$tmpfile"
)

# Lire la valeur mise à jour
counter=$(<"$tmpfile")
echo "Counter after subshell: $counter"

# Nettoyage
rm "$tmpfile"
```

```plaintext
$ ./subshell-v6.sh
Counter after subshell: 2
```

Utile dans les scripts, les boucles et les jobs CI/CD pour récupérer des données d'un sous-shell.

> Améliorations recommandées :
> ```bash
> tmpfile=$(mktemp)                  # nom unique et sûr (au lieu de /tmp/$$.tmp, prévisible)
> trap 'rm -f "$tmpfile"' EXIT       # nettoyage garanti, même en cas d'erreur
> ```
> Et souvent, le plus simple reste de **récupérer la sortie** :
> ```bash
> counter=1
> counter=$( echo $(( counter + 1 )) )
> echo "$counter"    # 2
> ```

> Piège fréquent (non présent dans la leçon) : chaque côté d'un **pipe** s'exécute aussi dans un sous-shell :
> ```bash
> count=0
> printf "a\nb\nc\n" | while read -r line; do (( count++ )); done
> echo "$count"      # 0 !  → la boucle était dans un sous-shell
>
> # Solution : redirection au lieu du pipe (boucle dans le shell courant)
> count=0
> while read -r line; do (( count++ )); done < <(printf "a\nb\nc\n")
> echo "$count"      # 3
> ```

### À retenir

- Sous-shell = **processus enfant** (fork) : créé par `( … )`, `$( … )`, les pipes, `&`.
- Il **hérite** de tout (variables même non exportées, fonctions), mais ses changements **ne remontent pas** (variables, `cd`, `set`, `exit`).
- `( … )` = sous-shell isolé ; `{ …; }` = groupe dans le **shell courant**.
- `(cd dir && cmd)` : changer de dossier temporairement sans affecter le shell courant.
- `$$` = PID du shell principal (même dans un sous-shell) ; `$BASHPID` = PID réel du processus courant.
- Récupérer une valeur : **stdout** via `$( )`, code de retour, ou fichier temporaire (`mktemp` + `trap`).
- Piège : `cmd | while read …` → variables perdues ; utiliser `done < <(cmd)` ou `done < fichier`.
- En CI/CD (Jenkins, GitLab, GitHub Actions), chaque étape shell est isolée : `cd`/`export` non conservés.
- Chaque sous-shell coûte un processus : attention dans les boucles.

### Liens utiles

- [GNU Bash – Command Grouping ( ) et { }](https://www.gnu.org/software/bash/manual/html_node/Command-Grouping.html)
- [GNU Bash – Command Substitution](https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html)
- [GNU Bash – Bash Variables ($BASHPID…)](https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html)
- [BashFAQ 024 – Variables perdues dans une boucle avec pipe (Wooledge)](https://mywiki.wooledge.org/BashFAQ/024)
- [Advanced Bash-Scripting Guide – Subshells](https://tldp.org/LDP/abs/html/subshells.html)
