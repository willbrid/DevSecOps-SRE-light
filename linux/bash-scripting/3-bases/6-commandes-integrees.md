# Commandes intégrées

Chaque fois qu'un script appelle un **binaire externe**, le shell crée (*fork*) un nouveau processus, ce qui ajoute de la **latence** et consomme du **CPU/de la mémoire**. Bash limite ce coût grâce aux **commandes intégrées** (built-ins), qui s'exécutent **dans le processus du shell lui-même**. Les privilégier accélère nettement les scripts et réduit la consommation de ressources.

### 1. L'analogie du chef

Le shell est un **chef en cuisine**. S'il déléguait chaque petite tâche (éplucher, remuer, dresser) à un commis, la perte de temps serait énorme. Il s'occupe donc lui-même des tâches courantes et ne fait appel à de l'aide que pour les tâches spécialisées.

- **Built-in** → le chef le fait lui-même, instantanément.
- **Binaire externe** → il faut mobiliser un « commis » (un nouveau processus).

### 2. Catégories de commandes

| Catégorie | Description | Exemples |
||||
| **Built-in** | Implémentée dans le shell ; s'exécute sans fork | `cd`, `echo`, `true` |
| **Binaire externe** | Fichier sur le disque ; l'appeler déclenche un `fork` puis un `execve` | `/bin/ls`, `/usr/bin/cat` |

```bash
$ ls
file1.txt  file2.txt

$ echo "Hello, world!"
Hello, world!
```

`ls` est un binaire externe chargé depuis le disque ; `echo` est traité directement par le shell.

> Rappel : `fork` duplique le processus du shell, puis `execve` remplace cette copie par le programme demandé.

### 3. Distinguer built-in et binaire externe

La commande `type` (elle-même un built-in = primitive du shell) indique comment une commande est implémentée :

```bash
$ type echo
echo is a shell builtin

$ type cat
cat is /usr/bin/cat
```

`which` ou `command -v` existent aussi, mais **`type` est le plus précis** : il distingue built-in, mot-clé (*keyword*), fonction, alias et binaire.

> `which` ne cherche que dans le `PATH` : il ignore les built-ins et peut donc induire en erreur. `type -a echo` affiche **toutes** les variantes (built-in + binaires).

### 4. Gains de performance

#### Benchmark : `true` vs `/usr/bin/true`

`true` ne fait que renvoyer un code de sortie `0`. Comparaison entre la version intégrée et le binaire :

```bash
$ time true
real    0m0.000s
user    0m0.000s
sys     0m0.000s

$ time /usr/bin/true
real    0m0,004s
user    0m0,000s
sys     0m0,002s
```

#### Temps d'exécution comparés

| Commande | Built-in (real) | Externe `/usr/bin` (real) |
||||
| `true` | 0.000s | 0m0,004s |
| `echo` | 0.000s | 0m0,005s |

Les **built-ins** démarrent et se terminent plus vite, ce qui fait une **grosse différence dans les boucles** (des milliers d'appels).

> Le chiffre de 0m0,005s pour `/usr/bin/echo` est probablement dû à un premier appel « à froid » (cache disque vide) ; en temps normal on est plutôt de l'ordre de quelques millisecondes. L'écart reste néanmoins réel et se cumule à chaque itération.

### 5. Vérifier l'absence de fork avec `strace`

Pour prouver qu'un built-in ne crée pas de processus, on trace les appels système `execve` du shell :

**1. Trouver le PID du shell**

```bash
$ pgrep -o bash
56120
```

(`-o` = le plus ancien processus correspondant)

**2. Attacher `strace` et filtrer sur `execve`**

```bash
sudo strace -Tfp $(pgrep -o bash) 2>&1 | grep execve &
```

**3. Dans ce shell, lancer un built-in puis un binaire externe**

```bash
$ echo "Hello"
Hello
# Aucun appel execve pour echo

$ cat file.txt
[pid 56147] execve("/usr/bin/cat", ["cat","file.txt"], 0x... ) = 0 <0.000186>
Hello, world!
```

Seul `cat` déclenche un `execve` (avec un **nouveau PID** 56147) : `echo` s'exécute bien **dans le shell**.

### 6. Built-ins ayant un équivalent externe

Beaucoup de built-ins existent aussi sous forme de binaire sur le disque :

```bash
$ which echo
/bin/echo

$ type /bin/echo
/bin/echo is /bin/echo

$ type echo
echo is a shell builtin
```

Comparaison de performance :

```bash
$ time /usr/bin/echo "Test"
$ time echo "Test"
# real 0m0.000s
```

Le `echo` intégré est instantané comparé à `/usr/bin/echo`.

> Quand on tape simplement `echo`, Bash utilise **le built-in en priorité**. Le binaire n'est utilisé que si on l'appelle par son **chemin** (`/usr/bin/echo`) ou via `env echo`.
> Ordre de résolution : **alias → mot-clé → fonction → built-in → binaire du `PATH`**.

### 7. Lister les built-ins et les mots-clés

**Lister les commandes intégrées :**
```bash
$ compgen -b
```

**Lister les mots-clés du shell :**
```bash
$ compgen -k
```

**Vérifier si un mot est un mot-clé :**
```bash
$ type time
time is a shell keyword
```

Les **mots-clés** (`time`, `if`, `for`, `while`, `[[`…) sont interprétés par le parseur du shell et **ne créent pas de processus**. Les confondre avec des binaires externes peut provoquer des comportements inattendus.

> Exemple : le mot-clé `time` et le binaire `/usr/bin/time` n'ont pas la même sortie ni les mêmes options (`/usr/bin/time -v` donne la mémoire max, etc.).

### À retenir

- Binaire externe = **fork + execve** → latence et ressources ; built-in = exécuté **dans le shell**, sans nouveau processus.
- `type cmd` est la référence pour savoir si une commande est un built-in, un mot-clé, une fonction ou un binaire ; `which` ignore les built-ins.
- `type -a cmd` montre toutes les versions disponibles d'une commande.
- Bash utilise le **built-in en priorité** ; le binaire n'est appelé que via son chemin complet.
- Les built-ins sont surtout avantageux **dans les boucles** (gain multiplié par le nombre d'itérations).
- `strace -f -p PID | grep execve` permet de vérifier qu'aucun processus n'est créé.
- `compgen -b` liste les built-ins, `compgen -k` les mots-clés.
- Les mots-clés (`if`, `for`, `time`, `[[`) ne créent pas de processus ; `time` (mot-clé) ≠ `/usr/bin/time` (binaire).

### Liens utiles

- [Bash – Built-in Commands (GNU)](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)
- [Bash – Shell Grammar / mots-clés (GNU)](https://www.gnu.org/software/bash/manual/html_node/Shell-Grammar.html)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [strace – site officiel](https://strace.io/)
- [Bash Pitfalls (Wooledge)](https://mywiki.wooledge.org/BashPitfalls)
