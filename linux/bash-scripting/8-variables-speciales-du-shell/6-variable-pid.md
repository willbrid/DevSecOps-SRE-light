# Variable PID

En Bash et dans les shells POSIX, les variables spéciales **`$$`** et **`$!`** permettent de gérer les **identifiants de processus (PID)** pour le débogage, l'automatisation et le scripting. Elles ne servent pas tous les jours, mais elles simplifient la gestion des **jobs en arrière-plan**, des **services** et la **surveillance des processus**.

### 1. Rappel : TTY, shell et PID

1. À l'ouverture d'un terminal, celui-ci reçoit un nom de **TTY** (teletype).
2. Un **shell** (ex. Bash) tourne sur ce TTY et joue le rôle de **processus parent**.
3. Toute commande ou script lancé depuis ce shell devient un **processus enfant**.
4. Chaque processus, du shell parent aux jobs en arrière-plan, a un **PID** et un **cycle de vie** (démarrage → exécution → fin).

### 2. Tableau des variables PID

| Variable | Description | Usage typique |
||||
| `$!` | PID du **dernier job lancé en arrière-plan** | Suivre et contrôler des tâches en arrière-plan |
| `$$` | PID du **shell courant** ou du **script** en cours | Le script connaît son propre PID |

### 3. `$!` : récupérer le PID d'un job en arrière-plan

```bash
$ sleep 5 &
[1] 93506
$ echo $!
93506
```

`$!` conserve cette valeur même si on lance ensuite des commandes **au premier plan**, jusqu'au **prochain** job en arrière-plan :

```bash
$ echo "First background PID is $!"
First background PID is 93506

$ echo "Hello" &
[1] 93761
Hello
[1] + done echo "Hello"

$ echo $!
93761
```

> Pour un pipeline en arrière-plan (`cmd1 | cmd2 &`), `$!` contient le PID de la **dernière** commande du pipeline.

#### Stocker `$!` dans un script

Modèle courant : lancer un service en arrière-plan, mémoriser son PID, puis l'arrêter plus tard. Exemple avec un serveur **Apache JMeter** :

```bash
#!/usr/bin/env bash

jmeter_pid=""

start_jmeter() {
  echo "Starting JMeter server..."
  jmeter-server &
  jmeter_pid=$!
}

start_jmeter

# Autres étapes du workflow...
echo "Now running additional setup tasks..."

echo "Stopping JMeter server (PID: $jmeter_pid)"
kill -SIGTERM "$jmeter_pid"
```

- `jmeter-server &` lance le serveur en arrière-plan ;
- `jmeter_pid=$!` capture **immédiatement** son PID (avant tout autre `&`) ;
- `kill -SIGTERM` demande un arrêt **propre** à ce PID précis.

> Toujours vérifier qu'on tue **le bon PID** : arrêter le mauvais processus peut perturber des services critiques.

> Améliorations recommandées :
> ```bash
> # Arrêt garanti à la fin du script, même en cas d'erreur ou de Ctrl+C
> trap 'kill -TERM "$jmeter_pid" 2>/dev/null' EXIT
>
> # Vérifier que le processus tourne encore avant de le tuer
> if kill -0 "$jmeter_pid" 2>/dev/null; then
>     kill -TERM "$jmeter_pid"
>     wait "$jmeter_pid"      # attendre la fin réelle et récupérer son code de sortie
> fi
> ```
> - `kill -0 PID` ne tue rien : il teste seulement si le processus existe.
> - `kill -TERM` est la forme la plus portable (`-SIGTERM` marche en Bash, pas partout).
> - Si `jmeter-server` est un script qui lance lui-même un processus `java`, `$!` est le PID du **script lanceur**, pas forcément celui de Java : vérifier avec `ps --ppid "$jmeter_pid"`.

### 4. `$$` : identifier son shell ou son script

`$$` affiche le PID du **shell courant** ou du **script** :

```bash
$ echo $$
79315
$ ps -p $$ -o pid,cmd
  PID CMD
79315 -bash
```

Un nouvel onglet ou une nouvelle fenêtre de terminal donne un **autre** `$$` :

```bash
$ echo $$
91933
```

#### `$$` dans un script

`print_pid.sh` :

```bash
#!/usr/bin/env bash
echo "This script's PID is $$"
sleep 60
```

Lancement en arrière-plan :

```bash
$ ./print_pid.sh &
[1] 94479
This script's PID is 94479
$ ps --pid 94479,94481 -o pid,ppid,cmd
  PID  PPID CMD
94479 79315 /bin/bash ./print_pid.sh
94481 94479 sleep 60
```

- **94479** = le script lui-même (`$$` dans le script, et `$!` dans le shell qui l'a lancé) ; son parent (**PPID 79315**) est le shell interactif.
- **94481** = le processus enfant `sleep`, dont le parent est le script.

> Usages classiques de `$$` :
> ```bash
> # Fichier PID (pour qu'un autre script puisse arrêter celui-ci)
> echo $$ > /var/run/monscript.pid
>
> # Identifier ses logs quand plusieurs instances tournent
> echo "[$$] Démarrage" >> app.log
> ```
> Pour des fichiers temporaires, préférer `mktemp` à `/tmp/fichier.$$` (nom prévisible).

### 5. `$$` et les sous-shells

```bash
#!/usr/bin/env bash

echo "Parent shell PID: $$"
(
  echo "Inside subshell PID: $$"
)
```

Sortie :

```bash
$ ./subshell_pid.sh
Parent shell PID: 54344
Inside subshell PID: 54344
```

La leçon explique que tous les `$$` affichent la même valeur parce que le sous-shell **partage** le PID du parent.

> Correction : un sous-shell est un **vrai processus distinct**, avec son **propre PID**. Simplement, `$$` n'est **pas mis à jour** dans un sous-shell : il garde volontairement le PID du shell principal. Pour obtenir le PID réel du processus courant, utiliser **`$BASHPID`** :
> ```bash
> echo "Parent : \$\$=$$  BASHPID=$BASHPID"
> ( echo "Sous-shell : \$\$=$$  BASHPID=$BASHPID" )
> # Parent : $$=54344  BASHPID=54344
> # Sous-shell : $$=54344  BASHPID=54345
> ```

### 6. Points clés

- **`$!`** = PID de la **dernière commande lancée en arrière-plan**.
- **`$$`** = PID du **shell courant** ou du **script** en cours.

Ces variables aident à écrire des scripts plus robustes, à automatiser le contrôle des processus et à déboguer des workflows complexes.

### À retenir

- `$!` : PID du dernier job en **arrière-plan** (`&`) ; le capturer **juste après** le `&` (`pid=$!`).
- `$!` reste inchangé tant qu'aucun nouveau job n'est lancé en arrière-plan.
- Modèle service : `cmd & pid=$!` → travail → `kill -TERM "$pid"` → `wait "$pid"` ; idéalement avec `trap … EXIT`.
- `kill -0 "$pid"` teste si le processus existe encore.
- `$$` : PID du shell/script courant ; différent dans chaque terminal ; utile pour fichiers PID et logs.
- Dans un sous-shell, `$$` garde le PID du **parent** ; `$BASHPID` donne le PID **réel**.
- `ps -p PID -o pid,ppid,cmd` pour vérifier la relation parent/enfant.
- Toujours s'assurer de cibler le **bon PID** avant un `kill`.

### Liens utiles

- [GNU Bash – Special Parameters (`$$`, `$!`)](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)
- [GNU Bash – Bash Variables (`$BASHPID`)](https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html)
- [GNU Bash – Job Control Builtins (`wait`, `kill`)](https://www.gnu.org/software/bash/manual/html_node/Job-Control-Builtins.html)
- [man ps](https://man7.org/linux/man-pages/man1/ps.1.html)
- [Apache JMeter](https://jmeter.apache.org/)
