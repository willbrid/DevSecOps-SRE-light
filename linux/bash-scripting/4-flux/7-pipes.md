# Pipes

En Bash, les **pipes** permettent d'envoyer la sortie d'une commande vers une autre, pour construire des traitements puissants **sans fichiers intermédiaires**. Deux types principaux :

| Type | Symbole / commande | Description |
||||
| **Pipe nommé** | `mkfifo` / FIFO | Crée un fichier spécial persistant servant de point de communication entre processus |
| **Pipe anonyme** | `\|` | Enchaîne des commandes à la volée : stdout de l'une → stdin de la suivante |

### 1. Pipes nommés (FIFO)

Les pipes nommés (ou **FIFO**, *First In, First Out*) sont des fichiers spéciaux créés avec `mkfifo`. Les processus communiquent à travers un **chemin de fichier**. Ce contenu rapproche aussi de cette notion les redirections `<` et `>`, qui relient l'entrée/la sortie standard à des fichiers (« piping basé sur des fichiers »).

Exemple avec redirection d'entrée **et** de sortie. `abc.txt` contient cinq lettres non triées :

```bash
$ sort < abc.txt > abc_sorted.txt
$ cat abc_sorted.txt
a
b
c
d
e
```

- `< abc.txt` : envoie le contenu de `abc.txt` sur le stdin de `sort`.
- `> abc_sorted.txt` : écrit le résultat trié dans `abc_sorted.txt`.
- `cat abc_sorted.txt` : affiche la liste triée.

> Précision : cet exemple utilise de simples **redirections de fichiers**, pas un vrai pipe nommé. Une vraie FIFO se crée avec `mkfifo` et apparaît avec le type `p` dans `ls -l` :
> ```bash
> $ mkfifo mon_pipe
> $ ls -l mon_pipe
> prw-r--r-- 1 user user 0 ... mon_pipe
>
> # Terminal 1 : le lecteur attend
> $ cat < mon_pipe
>
> # Terminal 2 : l'écrivain envoie les données
> $ echo "bonjour via FIFO" > mon_pipe
>
> # Terminal 1 affiche : bonjour via FIFO
> $ rm mon_pipe
> ```
> Une FIFO **ne stocke rien sur le disque** : l'écriture bloque tant qu'aucun lecteur n'est connecté, et inversement. Utile pour faire communiquer deux processus **indépendants** (lancés séparément).

### 2. Pipes anonymes

Le symbole `|` envoie directement la sortie d'une commande en entrée de la suivante, **sans créer de fichier**.

**command1 → `|` → command2 → écran**

#### Exemple : filtrer et trier une liste

`animals.txt` contient des noms non triés, avec des doublons :

```bash
$ cat animals.txt
Frog
Cheetah
Elephant
Giraffe
Antelope
Bear
Deer
Iguana
Jaguar
Hippopotamus
Ostrich
Frog
Cheetah
Elephant
Giraffe
Antelope
Bear
Deer
Iguana
Jaguar
Hippopotamus
```

**Étape 1** : garder les noms contenant « a » (sans tenir compte de la casse) :

```bash
$ cat animals.txt | grep -i "a"
Cheetah
Elephant
Giraffe
Antelope
Bear
Iguana
Jaguar
Hippopotamus
Cheetah
Elephant
Giraffe
Antelope
Bear
Iguana
Jaguar
Hippopotamus
```

**Étape 2** : garder les noms contenant « o » et trier :

```bash
$ cat animals.txt | grep -i "o" | sort
Antelope
Antelope
Frog
Frog
Hippopotamus
Hippopotamus
Ostrich
```

- `cat animals.txt` : lit la liste.
- `grep -i "o"` : garde les lignes contenant « o » (insensible à la casse).
- `sort` : trie le résultat.

On peut **allonger le pipeline** en ajoutant d'autres commandes après chaque `|`, chaque étape transformant les données à la suite.

> Remarques :
> - Malgré la formulation « further filter », l'étape 2 ne reprend **pas** le filtre sur « a » (d'où `Frog` et `Ostrich`). Pour combiner les deux : `grep -i "a" animals.txt | grep -i "o" | sort`.
> - Pour supprimer les doublons : `… | sort -u` ou `… | sort | uniq`. Pour compter : `… | sort | uniq -c`.
> - `cat fichier | grep` peut s'écrire `grep motif fichier` (un processus de moins).

### 3. Les erreurs dans un pipeline

Par défaut, un pipeline ne transmet que **stdout**. Les erreurs (**stderr**) s'affichent directement dans le terminal, et le pipeline continue.

```bash
$ ls -z | echo "Hello world"
Hello world
ls: unknown option -- z
Try 'ls --help' for more information
```

Les erreurs ne passent **pas** d'une commande à l'autre. Pour les inclure dans le pipeline, utiliser `2>&1`.

> Compléments utiles (non présents dans la leçon) :
> ```bash
> # Inclure stderr dans le pipe
> ls -z 2>&1 | grep -i "option"
> ls -z |& grep -i "option"        # raccourci Bash équivalent
>
> # Code de retour : par défaut, celui de la DERNIÈRE commande seulement
> false | true; echo $?            # 0 (l'échec de false est masqué)
>
> # pipefail : le pipeline échoue si UNE commande échoue
> set -o pipefail
> false | true; echo $?            # 1
>
> # Codes de retour de chaque étape
> ls -z | sort; echo "${PIPESTATUS[@]}"   # 2 0
> ```
> Toutes les commandes d'un pipeline tournent **en parallèle** : c'est pourquoi l'ordre d'affichage de `Hello world` et du message d'erreur peut varier.

### À retenir

- **Pipe anonyme `|`** : stdout de gauche → stdin de droite, sans fichier, le temps de la commande.
- **Pipe nommé (FIFO)** : créé avec `mkfifo`, fichier spécial (type `p`) qui relie deux processus indépendants ; rien n'est stocké sur disque.
- `cmd < entrée > sortie` = redirections de fichiers (≠ FIFO).
- Un pipeline = une **chaîne de montage** : chaque étape filtre/transforme les données.
- Seul **stdout** traverse le pipe ; stderr va au terminal → `2>&1 |` ou `|&` pour l'inclure.
- `$?` d'un pipeline = code de la **dernière** commande ; `set -o pipefail` pour détecter un échec n'importe où ; `${PIPESTATUS[@]}` pour le détail.
- Combos classiques : `grep … | sort | uniq -c | sort -rn`.

### Liens utiles

- [GNU Bash – Pipelines](https://www.gnu.org/software/bash/manual/html_node/Pipelines.html)
- [GNU Bash – Redirections](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
- [man mkfifo](https://linux.die.net/man/1/mkfifo)
- [GNU grep – documentation](https://www.gnu.org/software/grep/manual/grep.html)
- [GNU sort – documentation](https://www.gnu.org/software/coreutils/manual/html_node/sort-invocation.html)
