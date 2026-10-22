# Stdout et stderr

La sortie d'un programme est un **flux de données** qui circule comme dans un tuyau vers le terminal. Savoir **capturer, séparer et rediriger** ces flux est essentiel pour diagnostiquer les problèmes et écrire des scripts fiables.

### 1. stdout vs stderr : les bases

Une commande comme `ls` écrit ses résultats normaux sur la **sortie standard (stdout)**. Les options modifient le contenu ou le format de cette sortie :

```bash
$ ls
Documents  noshebang.sh  test.sh

$ ls -l
total 8
-rw-rw-r-- 1 ubuntu ubuntu 0 Mar 12 17:14 Documents
-rwxrwxr-x 1 ubuntu ubuntu 46 Mar  4 08:54 noshebang.sh
-rw-rw-r-- 1 ubuntu ubuntu 1 Mar 12 17:14 test.sh
```

Avec une option invalide, le message part sur la **sortie d'erreur (stderr)** :

```bash
$ ls -j
ls: invalid option -- 'j'
Try 'ls --help' for more information.
```

À l'écran, les deux flux **se ressemblent**, mais ce sont deux flux **différents** qu'on peut traiter séparément.

#### Programmes silencieux en cas de succès

Certaines commandes n'affichent **rien** quand tout va bien, comme `mv` (sauf en mode verbeux) :

```bash
$ mv file.txt renamedfile.txt      # aucune sortie stdout par défaut

$ mv -v file.txt renamedfile.txt
file.txt -> renamedfile.txt
```

En cas d'échec, `mv` écrit sur stderr :

```bash
$ mv file.txt file2.txt
mv: cannot stat 'file.txt': No such file or directory
```

> Pour savoir si une commande silencieuse a réussi : `echo $?` (0 = succès).

### 2. Rappel sur les redirections

Par défaut, `>` (écraser) et `>>` (ajouter) ne redirigent **que stdout**. Les erreurs ne sont pas capturées sans redirection explicite de stderr.

```bash
$ echo "hello" > file.txt         # écrase file.txt avec "hello"
$ cat file.txt
hello

$ echo "hello again" >> file.txt  # ajoute "hello again" à la fin
$ cat file.txt
hello
hello again
```

Avec une commande qui produit une erreur, `>` ne capture rien :

```bash
$ ls -j > file.txt
$ cat file.txt
# file.txt est vide : ls -j a écrit sur stderr, pas sur stdout
```

> Le message d'erreur s'affiche quand même dans le terminal, et `file.txt` a été **vidé** (le `>` tronque le fichier avant même l'exécution de la commande).

Pour capturer stderr, il faut rediriger le **descripteur 2** :

```bash
$ ls -j 2> file.txt
$ cat file.txt
ls: invalid option -- 'j'
Try 'ls --help' for more information.
```

#### Pourquoi `2>` ?

Les processus Unix utilisent des **descripteurs de fichiers numériques** :

- `0` → stdin (entrée standard)
- `1` → stdout (sortie standard)
- `2` → stderr (sortie d'erreur)

On peut les écrire explicitement : `1>` redirige stdout, `2>` redirige stderr.

#### stdout et stderr dans deux fichiers séparés

Commande en erreur :

```bash
$ ls -z > stdout.txt 2> stderr.txt

$ cat stderr.txt
ls: invalid option -- 'z'
Try 'ls --help' for more information.

$ cat stdout.txt
# vide : ls -z n'a produit que du stderr
```

Commande réussie :

```bash
$ ls > stdout.txt 2> stderr.txt

$ cat stdout.txt
Documents
noshebang.sh
test.sh

$ cat stderr.txt
# vide : aucune erreur
```

### 3. Fusionner les flux (et l'importance de l'ordre)

- `2>&1` → envoie stderr **là où va actuellement** stdout.
- `1>&2` (ou `>&2`) → envoie stdout **là où va actuellement** stderr.

**L'ordre des redirections compte.** On redirige d'abord stdout, puis on pointe stderr vers stdout :

```bash
# Correct : stdout vers all.txt, puis stderr vers la même destination
$ command > all.txt 2>&1
```

Si on inverse (`2>&1 > all.txt`) :
1. stderr est d'abord copié vers la destination **actuelle** de stdout → le terminal ;
2. puis stdout est redirigé vers `all.txt`.

Résultat : stderr **reste sur le terminal**.

> Le shell lit les redirections **de gauche à droite**, et `2>&1` copie la destination de stdout **au moment où il est lu**, pas « pour toujours ».

Règle simple : **`commande > fichier 2>&1`** — stdout d'abord, puis stderr vers 1.

> Usage courant de `>&2` dans un script : envoyer ses propres messages d'erreur sur stderr :
> ```bash
> echo "Erreur : fichier introuvable" >&2
> exit 1
> ```

### 4. Référence rapide des opérateurs

| Opérateur | Effet | Exemple |
||||
| `> file` | stdout → `file` (écrase) | `echo hi > out.txt` |
| `>> file` | stdout → `file` (ajoute) | `echo more >> out.txt` |
| `1> file` | Identique à `> file` (stdout explicite) | `ls 1> out.txt` |
| `2> file` | stderr → `file` | `ls -z 2> err.txt` |
| `2>&1` | stderr → destination actuelle de stdout | `cmd > all.txt 2>&1` |
| `&> file` (Bash) | stdout **et** stderr → `file` (raccourci) | `cmd &> all.txt` |

Résumé texte :

```text
> file.txt        # (par défaut) stdout -> file.txt
1> file.txt       # stdout -> file.txt (explicite)
>> file.txt       # ajouter stdout -> file.txt

2> file.txt       # stderr -> file.txt

>&1               # rediriger le flux vers le descripteur 1 (stdout)
>&2               # rediriger le flux vers le descripteur 2 (stderr)
```

### 5. Conclusion

- stdout et stderr sont deux flux distincts (**fd 1** et **fd 2**).
- `>` et `>>` agissent sur **stdout** par défaut.
- `2>` capture stderr ; `2>&1` fusionne stderr dans stdout (attention à l'ordre).
- Bien séparer ou fusionner les flux facilite le **débogage** et la **fiabilité** des scripts.

Étape suivante : appliquer ces modèles dans les pipelines et les scripts pour journaliser la sortie, capturer les erreurs et automatiser de façon robuste.

### À retenir

- **stdout = fd 1** (résultats), **stderr = fd 2** (erreurs) ; identiques à l'écran mais indépendants.
- `>` / `>>` = stdout uniquement ; `2>` / `2>>` = stderr.
- `>` **vide le fichier** avant l'exécution, même si la commande n'écrit rien sur stdout.
- Fusion correcte : `cmd > fichier 2>&1` ou `cmd &> fichier` (Bash). `cmd 2>&1 > fichier` laisse stderr au terminal.
- Les redirections sont lues **de gauche à droite** ; `2>&1` copie la destination de stdout à cet instant.
- Dans un script, écrire ses messages d'erreur avec `echo "…" >&2`.
- Certaines commandes (`mv`, `cp`, `rm`) sont silencieuses en cas de succès : vérifier avec `$?` ou l'option `-v`.
- Séparer les flux : `cmd > out.log 2> err.log` ; ignorer les erreurs : `cmd 2> /dev/null`.

### Liens utiles

- [GNU Bash – Redirections](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
