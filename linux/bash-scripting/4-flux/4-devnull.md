# devnull

Rediriger **stderr vers stdout** est un idiome shell très puissant pour **capturer** ou **supprimer** toute la sortie d'une commande en un seul endroit.

```bash
2>&1
```

### 1. Redirection de base avec `>`

Un simple `>` envoie un descripteur de fichier (fd) vers un fichier :

```bash
$ ls > stdout.txt
```

- **À gauche** de `>` : le fd source (par défaut **1**, stdout).
- **À droite** de `>` : la destination (souvent un nom de fichier).

On peut préciser le fd explicitement :

```bash
$ ls 1>stdout.txt    # identique à `ls > stdout.txt`
$ ls 2>stderr.txt    # redirige stderr (fd 2) vers stderr.txt
```

Sans numéro devant `>`, Bash suppose **`1`** (stdout).

> Pas d'espace entre le numéro et `>` : `2>` fonctionne, mais `2 >` passerait `2` comme **argument** à la commande.

### 2. Fusionner stdout et stderr avec `&>`

Raccourci Bash pour capturer **les deux flux** d'un coup :

```bash
$ ls -z &> all-logs.txt
$ cat all-logs.txt
ls: cannot access '-z': No such file or directory
```

En Bash, `&> fichier` équivaut à `> fichier 2>&1`.

> `&>` est **spécifique à Bash** (pas POSIX). Dans un script `#!/bin/sh`, utiliser `> fichier 2>&1`. Version en ajout : `&>> fichier`.

### 3. Dupliquer un descripteur avec `>&n`

Quand `&` est **à droite** de `>`, on ne vise pas un fichier mais un **autre descripteur** :

```bash
$ echo "warning" >&2    # envoie stdout (fd 1) vers stderr (fd 2)
```

C'est différent de `&> file.txt`, qui écrit stdout **et** stderr dans un fichier.

> Le `&` sert à distinguer le **descripteur** 2 d'un **fichier nommé** « 2 » : `>2` créerait un fichier appelé `2`, alors que `>&2` vise stderr.

### 4. Rediriger un flux vers un autre avec `n>&m`

On peut diriger un fd vers un autre :

**stdout → stderr :**

```bash
$ echo "warning" >&2
```

**stderr → stdout :**

```bash
$ ls -z 2>&1
ls: cannot access '-z': No such file or directory
```

> **L'ordre compte** quand on combine des redirections : rediriger **stdout d'abord**, puis stderr vers stdout.

> Précision : `n>&m` fait de `n` une **copie** de `m` (n pointe là où pointe m à cet instant). Ce n'est pas un échange des deux flux.

### 5. Envoyer les deux flux dans un fichier

```bash
$ ls -z > file.txt 2>&1
```

1. `> file.txt` envoie stdout (fd 1) vers `file.txt`.
2. `2>&1` envoie stderr (fd 2) là où pointe **maintenant** stdout, donc aussi `file.txt`.

### 6. Tout jeter avec `/dev/null`

Pour qu'une commande ne produise **aucune sortie**, on redirige les deux flux vers `/dev/null`, le « trou noir » des systèmes Unix :

```bash
> /dev/null 2>&1
```

`/dev/null` est un **fichier spécial** qui **supprime tout ce qu'on y écrit** (et renvoie une fin de fichier immédiate si on le lit).

À utiliser pour les données :
- ✅ **dont on n'a pas besoin** ;
- ✅ **qui ne doivent pas être enregistrées**.

> Exemples d'usage courants (non présents dans la leçon) :
> ```bash
> # Tester si une commande existe, sans rien afficher
> if command -v docker > /dev/null 2>&1; then
>     echo "docker est installé"
> fi
>
> # Masquer seulement les erreurs (ex. "Permission denied")
> find / -name "*.conf" 2> /dev/null
>
> # Tâche cron silencieuse
> 0 3 * * * /opt/scripts/backup.sh > /dev/null 2>&1
> ```
> On ne perd pas le résultat : le **code de retour** (`$?`) reste disponible même si la sortie est jetée.

### 7. Tableau récapitulatif

| Opérateur | Rôle | Exemple |
||||
| `>fichier` | stdout (fd 1) → fichier | `ls > out.txt` |
| `2>fichier` | stderr (fd 2) → fichier | `ls -z 2>err.txt` |
| `&>fichier` | stdout + stderr → fichier (Bash) | `cmd &>all.txt` |
| `n>&m` | fd n → même destination que fd m | `echo "err" >&2` |
| `2>&1` | stderr → destination de stdout | `cmd >out.txt 2>&1` |
| `> /dev/null 2>&1` | Jeter stdout et stderr | `some_command > /dev/null 2>&1` |

### À retenir

- Sans numéro, `>` agit sur **fd 1** (stdout) ; `2>` cible stderr.
- `&` **à droite** de `>` = descripteur (`>&2`), pas un fichier.
- `n>&m` = « n va là où va m **en ce moment** » (copie, pas échange).
- Fusion vers un fichier : `cmd > f 2>&1` (POSIX) ou `cmd &> f` (Bash).
- **Ordre** : stdout d'abord, puis `2>&1`.
- `/dev/null` absorbe tout ce qu'on y écrit : `> /dev/null 2>&1` = commande totalement silencieuse.
- `2> /dev/null` masque uniquement les erreurs ; `$?` reste utilisable même avec la sortie jetée.
- Messages d'erreur d'un script : `echo "…" >&2`.

### Liens utiles

- [GNU Bash – Redirections](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
- [Stack Overflow – What is /dev/null?](https://stackoverflow.com/questions/1146320/what-is-dev-null)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
