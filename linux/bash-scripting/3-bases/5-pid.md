# Pid

Un script shell est un fichier de commandes et de constructions de programmation qui automatise des tâches. Chaque fois qu'un nouveau processus démarre, le **noyau lui attribue un identifiant unique : le PID** (Process ID). Il sert à inspecter, contrôler ou arrêter ce processus.

### 1. Shell parent et processus enfants

Analogie : le shell parent est un **chef en cuisine**. Chaque commande qu'il donne mobilise un **employé** (un processus) qui a son propre identifiant (PID). Le chef peut vérifier, arrêter ou relancer n'importe quel employé, comme on contrôle les processus en ligne de commande.

- Le **shell parent** lance des **processus enfants** pour exécuter les commandes.
- Ces enfants peuvent à leur tour lancer leurs propres enfants.
- Chaque processus possède un **PID** et un **PPID** (Parent PID) qui pointe vers le processus qui l'a lancé.

> Variables utiles : `$$` = PID du shell courant, `$PPID` = PID de son parent, `$!` = PID du dernier processus lancé en arrière-plan.

### 2. TTY : le terminal attaché à la session

Une session de terminal est rattachée à un **TTY** (`teletypewriter`). Le **session leader** (le shell parent) gère ce TTY. Les processus enfants restent normalement associés au même TTY, qui apparaît dans la liste des processus.

```bash
# Lister les processus et chercher bash
$ ps -ef | grep bash
501 29898 27796 0 11:00PM ttys007 0:00.01 bash
501 29928 29898 0 11:00PM ttys007 0:00.00 grep bash

# Afficher le TTY du terminal courant
$ tty
/dev/ttys007
```

Chaque onglet ou fenêtre de terminal a généralement **son propre TTY** et son propre processus bash :

```bash
# Onglet 1
$ tty
/dev/ttys000

$ ps -ef | grep bash
501 87852 87851 0 8:32PM ttys000 0:00.76 -bash

# Onglet 2
$ tty
/dev/ttys001

$ ps -ef | grep bash
501 8561 8560 0 12:36AM ttys001 0:00.04 -bash
```

> Colonnes de `ps -ef` : **UID, PID, PPID, C, STIME, TTY, TIME, CMD**.

### 3. Observer la chaîne de PID avec un script

Script de test qui dort 3 minutes pour avoir le temps d'observer :

```bash
# script.sh
#!/bin/bash
sleep 180
```

Le rendre exécutable et le lancer **au premier plan** :

```bash
$ chmod +x script.sh
$ ./script.sh
```

Pendant l'exécution au premier plan, le shell est **bloqué**. Le script a son propre PID, et son PPID pointe vers le shell :

```bash
$ ps -ef | grep script.sh
501 8689 87852 0 12:36AM ttys000 0:00.00 /bin/bash ./script.sh
501 87852 87851 0 8:32PM ttys000 0:00.77 -bash
```

La commande `sleep` dans le script crée elle aussi un processus enfant :

```bash
$ ps -ef | grep sleep
501 8690 8689 0 12:36AM ttys000 0:00.00 sleep 180
```

Chaîne parent-enfant :

**shell (parent, 87852) → script (enfant, 8689) → sleep (petit-enfant, 8690)**

### 4. Arrière-plan (`&`) et détachement (`nohup`)

Pour ne pas bloquer le terminal, on lance le script **en arrière-plan** avec `&` :

```bash
$ ./script.sh &
[1] 8862
```

`[1]` = numéro de job, `8862` = PID.

Un job en arrière-plan reste **lié au TTY** du shell. Si on ferme le terminal, il reçoit généralement **SIGHUP** et s'arrête.

Pour qu'il survive à la fermeture du terminal, on le **détache** avec `nohup`, qui ignore SIGHUP et redirige la sortie vers `nohup.out` par défaut :

```bash
$ nohup ./script.sh &
[1] 9028
appending output to nohup.out

$ ps -ef | grep script.sh
501 9028 1      0 12:39AM ??      0:00.00 /bin/bash ./script.sh
```

- Le **PPID peut devenir 1** (le processus est « adopté » par init/systemd une fois le shell parent fermé).
- Le TTY devient **`??`** : le processus n'est plus attaché à un terminal.

> Alternatives à `nohup` :
> - `setsid ./script.sh` → démarre dans une **nouvelle session**
> - `./script.sh &` puis `disown` → retire le job du contrôle du shell interactif

### 5. Builtins vs commandes externes

Toutes les commandes ne créent pas de nouveau processus :

- Les **builtins** du shell (`cd`, `export`, `read`…) s'exécutent **dans le shell courant**, sans nouveau PID.
- Certaines commandes existent aussi en **binaire externe** ; appeler le binaire (ex. `/usr/bin/…`) crée alors un nouveau processus.

| Méthode d'exécution | Nouveau PID ? | Exemple |
||||
| Par nom (recherche dans le `PATH`) | Oui, pour le binaire trouvé | `ls`, `cat` |
| Par chemin absolu | Oui | `/usr/bin/cat file.txt` |
| Depuis le répertoire courant | Oui (chemin explicite) | `./script.sh` |
| Builtin du shell | **Non**, exécuté dans le shell | `cd`, `export`, `read` |

Binaire appelé par nom vs par chemin absolu (même résultat, chacun dans un nouveau processus) :

```bash
$ cat file.txt
Hello World!

$ /usr/bin/cat file.txt
Hello World!
```

> Pour savoir si une commande est un builtin : `type cd` → *cd is a shell builtin* ; `type -a echo` liste toutes ses variantes (builtin + binaire).

> Pourquoi `cd` est un builtin : s'il tournait dans un processus enfant, il changerait le répertoire de l'enfant, pas celui du shell.

### 6. Inspecter les processus : `ps` et `top`

- **`ps`** (*process status*) : instantané des processus.
- **`top`** / **`htop`** (*table of processes*) : vue en temps réel.

`ps -ef` affiche tous les détails (utilisateur, PID, PPID, TTY, temps, commande) :

```bash
$ ps -ef | grep bash
501 87852 87851 0  8:32PM ttys000 0:00.77 -bash
501 8561  8560  0 12:36AM ttys001 0:00.04 -bash
```

> Les options et la sortie de `ps` varient selon les systèmes (Linux, macOS, BSD).

### 7. Arrêter un processus : `kill` et les signaux

`kill` envoie un **signal** à un PID. Par défaut : **SIGTERM (15)**, une demande d'arrêt « polie ». Si le processus refuse de s'arrêter, **SIGKILL (9)** le termine immédiatement.

| Signal | Numéro | Signification |
||||
| SIGTERM | 15 | Demande d'arrêt propre (par défaut) |
| SIGKILL | 9 | Arrêt forcé immédiat (ne peut pas être intercepté) |
| SIGHUP | 1 | « Hangup » – souvent envoyé à la fermeture du terminal |

```bash
# Envoyer SIGTERM (par défaut)
$ kill 99838

# Formes explicites
$ kill -15 99838
$ kill -TERM 99838

# Forcer l'arrêt avec SIGKILL
$ kill -9 99838
$ kill -KILL 99838
```

> Bonne pratique : toujours essayer **SIGTERM d'abord** (le processus peut nettoyer ses fichiers temporaires, fermer ses connexions…), puis SIGKILL en dernier recours. `kill -l` liste tous les signaux.

### 8. Tracer les appels système : `strace`

Sur Linux, `strace` trace les appels système d'un processus. Options utiles :

- `-T` : temps passé dans chaque appel système
- `-f` : suivre les processus enfants
- `-p <pid>` : s'attacher à un processus existant

```bash
$ strace -T -f -p 99838
```

Cette commande s'attache au PID 99838, affiche ses appels système avec leur durée et suit ses enfants.

> Sur macOS et autres Unix, `strace` n'existe souvent pas : alternatives `dtruss`, `truss` ou `ktrace` (souvent avec `sudo`).

### À retenir

- Chaque processus a un **PID** unique et un **PPID** (PID du parent).
- Chaîne typique : **shell → script → commandes du script**.
- `$$` = PID du shell courant, `$PPID` = PID du parent, `$!` = PID du dernier job en arrière-plan.
- `tty` affiche le terminal courant ; chaque onglet a son propre TTY.
- `&` lance en arrière-plan mais le processus reste lié au terminal (tué par **SIGHUP** à la fermeture).
- `nohup cmd &` (ou `setsid`, `disown`) détache le processus : PPID → 1, TTY → `??`, sortie dans `nohup.out`.
- Les **builtins** (`cd`, `export`, `read`) ne créent **pas** de nouveau PID ; les binaires externes, si. Vérifier avec `type`.
- `ps -ef` = instantané ; `top`/`htop` = temps réel.
- `kill PID` = SIGTERM (15, propre) ; `kill -9 PID` = SIGKILL (forcé) ; SIGHUP = 1.
- `strace -T -f -p PID` pour déboguer un processus au niveau système (Linux).

### Liens utiles

- [man tty](https://man7.org/linux/man-pages/man1/tty.1.html)
- [man ps](https://man7.org/linux/man-pages/man1/ps.1.html)
- [man nohup](https://man7.org/linux/man-pages/man1/nohup.1.html)
- [man kill](https://man7.org/linux/man-pages/man1/kill.1.html)
- [strace – site officiel](https://strace.io/)
