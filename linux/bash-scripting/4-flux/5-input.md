# Input

En scripting shell, l'**entrée** (`Input`) désigne toute donnée fournie à un programme ou au shell, soit **interactivement** (clavier/terminal), soit **non interactivement** (depuis un autre programme ou un fichier). Unix expose les E/S sous forme de **descripteurs de fichiers numérotés** :

| fd | Nom | Usage typique |
||||
| **0** | stdin | Source d'entrée par défaut (le terminal en session interactive) |
| **1** | stdout | Sortie standard (résultats normaux) |
| **2** | stderr | Sortie d'erreur (diagnostics, erreurs) |

Ce modèle vient du principe Unix **« tout est fichier »** : un programme lit et écrit de la même façon, que la source/destination soit un terminal, un fichier ou un autre processus.

### 1. Deux formes d'entrée : interactive vs redirigée

- **Entrée standard (fd 0)** : en général le clavier/terminal.
- **Entrée via pipes ou fichiers** : le shell relie le stdout (fd 1) d'un processus au stdin (fd 0) d'un autre avec `|`, ou envoie un fichier vers une commande avec `<`.

Opérateurs courants :

| Opérateur | Rôle |
|||
| `>` | Rediriger la sortie vers un fichier |
| `<` | Alimenter l'entrée d'un script ou d'une commande avec un fichier |
| `\|` | Pipe anonyme : stdout de gauche → stdin de droite |

Les **pipes nommés (FIFO)**, créés avec `mkfifo`, sont des objets du système de fichiers distincts : ce n'est pas la même chose qu'une redirection `<` / `>`.

> Exemple de FIFO :
> ```bash
> mkfifo mon_pipe
> cat mon_pipe &          # lecteur en attente
> echo "bonjour" > mon_pipe
> # bonjour
> rm mon_pipe
> ```

### 2. Commandes qui lisent/écrivent par défaut

- `echo`, `ls` produisent leur résultat sur **stdout**.
- Certaines commandes, comme `wc` **sans argument de fichier**, lisent sur **stdin** : elles **attendent la saisie** si stdin est le terminal, ou consomment les données d'un pipe/fichier.

**Exemple interactif avec `wc`** :

```bash
$ wc
Juan Carlos
^D
1 2 11
```

Résultat : **1 ligne, 2 mots, 11 octets** (retour à la ligne inclus). `Ctrl+D` (`^D`) signale la fin de l'entrée (EOF).

**Même entrée via un pipe** :

```bash
$ echo "Juan Carlos" | wc
1 2 11
```

`echo` écrit sur son stdout, et le shell relie ce stdout au stdin de `wc` grâce au pipe.

### 3. Détecter si stdin est un terminal

Le test `-t` vérifie si un descripteur est **associé à un terminal**. Utile pour qu'un script se comporte différemment en mode interactif ou non.

```bash
#!/usr/bin/env bash

if [[ -t 0 ]]; then
  echo "Input passed through Keyboard"
  read -r input
  echo "You typed: $input"
else
  echo "Input entered from a file or pipeline"
  read -r input
  echo "Received: $input"
fi
```

Définition du test :

```text
-t file_descriptor
        Vrai si le fichier correspondant au descripteur est ouvert et associé à un terminal.
```

Exécutions :

```bash
$ ./input_fd.sh
Input passed through Keyboard
hello
You typed: hello

$ echo "Pipeline" | ./input_fd.sh
Input entered from a file or pipeline
Received: Pipeline

$ cat input.txt
Passing input through a file

$ ./input_fd.sh < input.txt
Input entered from a file or pipeline
Received: Passing input through a file
```

> Applications pratiques : afficher un prompt seulement en interactif, désactiver les couleurs si `[[ ! -t 1 ]]` (sortie redirigée vers un fichier ou un pipe), refuser de lancer un script sans données en entrée.

### 4. D'où vient l'entrée d'un pipe ?

L'entrée reçue via un pipe est le **stdout (fd 1)** du processus producteur, rendu disponible comme **stdin (fd 0)** du processus récepteur.

```bash
$ echo "Output" | test -t 1 && echo "Output received"
Output received
```

La leçon précise que l'évaluation de `test -t` dans un pipeline dépend de la façon dont le shell configure les descripteurs, mais le principe reste : **un pipe relie stdout → stdin**.

> Cet exemple est trompeur : `test -t 1` teste le **stdout** de `test`, qui est toujours le terminal ici ; il serait vrai **même sans le pipe**. Pour vraiment observer l'effet du pipe, il faut tester **fd 0** :
> ```bash
> $ echo "x" | test -t 0 || echo "stdin vient d'un pipe"
> stdin vient d'un pipe
> $ echo "x" | [[ -t 1 ]] ; ls | { [[ -t 1 ]] || echo "stdout de ls part dans un pipe"; }
> ```

### 5. Alimenter stdin avec un fichier

`<` envoie le contenu d'un fichier sur le stdin d'une commande :

```bash
$ wc < input.txt
 1  5 29
$ cat input.txt
Passing input through a file
```

> Différence subtile : `wc input.txt` affiche le **nom du fichier** dans le résultat (wc ouvre lui-même le fichier), alors que `wc < input.txt` ne l'affiche pas (c'est le shell qui ouvre le fichier, wc ne voit qu'un flux).

### 6. Vue « appels système » avec `strace`

Tracer les appels système montre les lectures/écritures sur chaque descripteur. Par exemple, `read(0, ...)` = lecture sur stdin.

> `strace` nécessite souvent les droits root pour tracer d'autres processus. Utiliser `sudo` avec prudence, uniquement sur des systèmes que vous contrôlez.

**Tracer les lectures** du shell courant :

```bash
$ sudo strace -Tfp $$ 2>&1 | grep -E '^read' &
[1] 80081
read(0, "H", 1) = 1 <0.000014>
read(0, "e", 1) = 1 <0.000012>
read(0, "l", 1) = 1 <0.000014>
...
```

**Tracer lectures et écritures** pour voir l'écho du terminal :

```bash
$ sudo strace -Tfp $$ 2>&1 | grep -E 'read|write' &
[1] 80117
read(0, "H", 1)            = 1 <0.000015>
write(2, "H", 1)           = 1 <0.000064>
read(0, "e", 1)            = 1 <0.000014>
write(2, "e", 1)           = 1 <0.000058>
...
```

Interprétation :
- `read(0, …)` : octets lus sur **stdin** (les frappes clavier, une par une).
- `write(2, …)` : Bash **réaffiche chaque touche** sur le terminal via **fd 2** (la ligne de commande interactive est gérée par readline, qui écrit sur stderr).
- `write(1, …)` / `write(2, …)` : sortie des commandes sur stdout/stderr.

### 7. Exercice final : modifier un fichier sur place avec un descripteur personnalisé

Ouvrir un fichier sur le **fd 3**, avancer la position de lecture, puis **écraser un seul caractère**, sans fichier temporaire :

```bash
$ echo "will will@willbrid.com" > email_file.txt
$ exec 3<> email_file.txt           # ouvre email_file.txt en lecture/écriture sur le fd 3
$ read -n 4 <&3                     # lit 4 octets → la position est sur l'espace
$ echo -n "." >&3                   # écrit un point à la position courante (remplace l'espace)
$ exec 3>&-                         # ferme le fd 3
$ cat email_file.txt
will@willbrid.com
```

Explications :
- `exec 3<> fichier` : ouvre le fichier sur le **fd 3** en **lecture et écriture** (`<>`), sans le tronquer.
- `read -n 4 <&3` : lit 4 octets (`Juan`) et avance le **pointeur de position** juste avant l'espace (le texte lu va dans `$REPLY`).
- `echo -n "." >&3` : écrit `.` à la position courante, ce qui **remplace** l'espace (`-n` évite d'ajouter un retour à la ligne qui écraserait un caractère de plus).
- `exec 3>&-` : ferme le fd 3.

Cela montre comment faire des E/S « bas niveau » avec des descripteurs non standards (≥ 3), sans éditeur externe ni fichier intermédiaire.

> On ne peut que **remplacer** des octets, pas en insérer ou en supprimer : écrire une chaîne plus longue écraserait les caractères suivants.

### 8. Synthèse

- Différence entre la notion générale d'**entrée** et l'**entrée standard** (fd 0).
- Les pipes (`|`) et redirections (`<`, `>`) relient processus et fichiers.
- `-t FD` détecte si un descripteur est un terminal.
- `strace` permet d'observer les `read`/`write` au niveau système.
- Les descripteurs personnalisés permettent de modifier un fichier sur place.

### À retenir

- **stdin = fd 0** ; il peut venir du **clavier**, d'un **pipe** (`|`) ou d'un **fichier** (`<`).
- Un pipe relie le **stdout** de la commande de gauche au **stdin** de celle de droite.
- Commandes sans argument (`wc`, `cat`, `sort`…) lisent stdin ; en interactif, terminer avec **Ctrl+D** (EOF).
- `[[ -t 0 ]]` → stdin est un terminal (interactif) ; `[[ -t 1 ]]` → stdout est un terminal.
- `cmd fichier` vs `cmd < fichier` : dans le 2ᵉ cas, c'est le shell qui ouvre le fichier.
- FIFO (`mkfifo`) = pipe **nommé** sur le disque, distinct de `|`.
- `strace … | grep read` : `read(0, …)` = lecture clavier ; en interactif, Bash fait l'écho via `write(2, …)`.
- `exec 3<> f` ouvre en lecture/écriture ; `read -n N <&3` déplace la position ; `>&3` écrit à cette position ; `exec 3>&-` ferme.

### Liens utiles

- [Bash – Conditional Expressions (`-t`, `-f`, `-z`…)](https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html)
- [GNU Bash – Redirections (`<>`, `exec`, `>&`)](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
- [man mkfifo (pipes nommés)](https://man7.org/linux/man-pages/man3/mkfifo.3.html)
- [strace – site officiel](https://strace.io/)
- [POSIX – spécifications Open Group](https://pubs.opengroup.org/onlinepubs/9699919799/)
