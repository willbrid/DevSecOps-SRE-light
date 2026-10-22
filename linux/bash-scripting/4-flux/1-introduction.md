# Introduction

Un flux est la **circulation de données entre processus**, comme de l'eau dans un tuyau. De même qu'on dévie une rivière avec des vannes, on redirige les flux dans le shell grâce aux **opérateurs de redirection** et aux **pipes**.

Maîtriser les flux est indispensable pour des scripts robustes : capturer la sortie d'une commande, gérer les erreurs, enchaîner des commandes.

### 1. Les flux standards sous Linux

Chaque processus Linux démarre avec **trois descripteurs de fichiers** (*file descriptors*, fd) standards :

| fd | Nom | Rôle | Source / destination par défaut |
|||||
| **0** | `stdin` | Entrée standard (lecture) | Clavier ou pipe |
| **1** | `stdout` | Sortie standard (résultats normaux) | Terminal ou fichier redirigé |
| **2** | `stderr` | Sortie d'erreur (erreurs, diagnostics) | Terminal ou fichier redirigé |

- **stdin (0)** lit généralement depuis le **clavier**.
- **stdout (1)** affiche les **résultats** des commandes.
- **stderr (2)** envoie les **messages d'erreur**.

`stdout` et `stderr` s'affichent tous les deux dans le terminal par défaut, mais ce sont **deux flux distincts** : rediriger l'un n'affecte pas l'autre, sauf si on les combine explicitement.

> Les descripteurs d'un processus sont visibles dans `/proc/<PID>/fd/` (ex. `ls -l /proc/$$/fd`).

### 2. Rediriger les flux

On redirige les flux avec `<`, `>` et les pipes `|` : enregistrer une sortie dans un fichier, lire une entrée depuis un fichier, ou enchaîner des commandes.

Trois concepts :
- **Redirection de sortie** : `>`
- **Redirection d'entrée** : `<`
- **Pipe** : `|`

```bash
# Rediriger stdout vers un fichier
grep "error" logfile.txt > results.txt

# Rediriger stderr vers un fichier
gcc program.c 2> compile_errors.log

# Envoyer stdout ET stderr dans le même fichier
./run_tests.sh > all_output.log 2>&1

# Lire stdin depuis un fichier
sort < unsorted_list.txt

# Envoyer le stdout d'une commande dans le stdin d'une autre
ps aux | grep sshd
```

> **L'ordre des redirections compte** : placer `2>&1` **après** `> fichier`.
> - `cmd > f 2>&1` → stdout va dans `f`, puis stderr est copié **là où pointe stdout** (donc `f`) ✅
> - `cmd 2>&1 > f` → stderr est copié vers le terminal (où pointe stdout à ce moment), puis seul stdout part dans `f` ❌
>
> Raccourci Bash équivalent : `cmd &> fichier`.

> `>` **écrase** le fichier ; `>>` **ajoute** à la fin. Idem pour `2>` / `2>>`.

### 3. Exemples

**Séparer sortie et erreurs** dans deux fichiers :

```bash
ls -l /some/path > listing.txt 2> errors.txt
```

**Enchaîner des commandes** avec des pipes pour filtrer des données :

```bash
cat server.log | grep "WARN" | sort | uniq -c
```

(Compte le nombre d'occurrences de chaque ligne contenant `WARN`.)

> Variante plus efficace, sans `cat` inutile : `grep "WARN" server.log | sort | uniq -c`.
> Ajouter `| sort -rn` à la fin pour classer du plus fréquent au moins fréquent.

**Alimenter un shell** par redirection d'entrée :

```bash
bash < setup_script.sh
```

(Bash lit les commandes du script sur son stdin et les exécute.)

> Pour ignorer complètement une sortie, on la redirige vers `/dev/null` : `cmd 2> /dev/null` (masque les erreurs) ou `cmd &> /dev/null` (masque tout).

### 4. Pour aller plus loin

| Sujet | Description |
|||
| Bash Scripting | Guide complet de la syntaxe Bash |
| Pipelines avancés | Construire des chaînes de commandes complexes |
| Descripteurs de fichiers | Les entrées/sorties bas niveau sous Unix/Linux |

Maîtriser les flux et les redirections fait passer d'un usage basique du shell à une **véritable automatisation**.

### À retenir

- 3 flux standards : **0 = stdin**, **1 = stdout**, **2 = stderr**.
- stdout et stderr vont au terminal par défaut, mais sont **indépendants**.
- `>` redirige stdout (écrase), `>>` ajoute, `2>` redirige stderr, `<` alimente stdin.
- `> fichier 2>&1` (ou `&> fichier`) regroupe stdout et stderr ; **l'ordre compte** : `2>&1` après `>`.
- `|` relie le **stdout** d'une commande au **stdin** de la suivante (stderr n'est **pas** transmis ; utiliser `|&` ou `2>&1 |` pour l'inclure).
- `/dev/null` sert à jeter une sortie.
- Éviter `cat fichier | cmd` quand `cmd fichier` ou `cmd < fichier` suffit.

### Liens utiles

- [GNU Bash – Redirections](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
- [TLDP – Linux Input/Output](https://tldp.org/LDP/intro-linux/html/sect_03_04.html)
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Linux Journal – The Beauty of Pipelines](https://www.linuxjournal.com/content/beauty-pipelines)
- [Opensource.com – Introduction aux descripteurs de fichiers](https://opensource.com/article/18/4/introduction-file-descriptors)
