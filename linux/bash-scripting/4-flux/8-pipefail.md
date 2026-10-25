# Pipefail

Ce contenu explique comment les shells gèrent les **pipelines**, pourquoi certaines **erreurs peuvent être masquées**, et comment forcer un arrêt anticipé avec **`set -o pipefail`**, avec les bonnes pratiques de scripting robuste.

### 1. Fonctionnement d'un pipeline

Avec `|`, le **stdout** de chaque commande alimente le **stdin** de la suivante. Mais si une commande du milieu écrit sur **stderr**, l'erreur part directement dans le terminal… et **le reste du pipeline continue** de s'exécuter.

### 2. Comportement sans `pipefail`

```bash
$ sort somefile.txt | uniq | cat file.txt
sort: cannot read somefile.txt: No such file or directory
hello
```

Ce qui se passe :
- `sort` échoue (code de sortie ≠ 0) et affiche une erreur ;
- `uniq` s'exécute quand même (sans entrée) et réussit ;
- `cat file.txt` affiche son contenu.

Bien que `sort` ait échoué, le **code de sortie final du pipeline est `0`** : l'erreur est **masquée**.

> Par défaut, le code de sortie d'un pipeline est **celui de la dernière commande** uniquement.

### 3. Vérifier le code de sortie

```bash
$ sort somefile.txt | uniq
sort: cannot read somefile.txt: No such file or directory
$ echo $?
0
```

Malgré l'échec, on obtient `0`. Les opérateurs logiques se comportent donc de façon inattendue :

```bash
$ sort somefile.txt | uniq && echo "Won't stop on error"
sort: cannot read somefile.txt: No such file or directory
Won't stop on error
```

Le `echo` s'exécute car le pipeline renvoie `0`.

> Pour voir le code de **chaque** étape : `echo "${PIPESTATUS[@]}"` juste après le pipeline (ex. `2 0`).

### 4. Activer `pipefail`

Avec `pipefail`, le pipeline renvoie un code **non nul si n'importe quelle commande échoue** :

```bash
#!/usr/bin/env bash
set -o pipefail

sort somefile.txt | uniq && echo "This won't print"
echo "Exit status: $?"
```

Enregistré sous `set-pipefail.sh` :

```bash
$ ./set-pipefail.sh
sort: cannot read somefile.txt: No such file or directory
Exit status: 2
```

Avec `pipefail` :
- le pipeline renvoie le code de la **commande en échec la plus à droite** ;
- les branches `&&` qui suivent sont **ignorées** en cas d'erreur.

> Toutes les commandes du pipeline **s'exécutent quand même** : `pipefail` change seulement le **code de retour**, il n'interrompt pas le pipeline en cours.

### 5. Options shell courantes

| Option | Description | Par défaut |
||||
| `pipefail` | Le pipeline échoue si une commande échoue | désactivée |
| `errexit` | Quitte le script dès qu'une commande renvoie un code ≠ 0 (`set -e`) | désactivée |
| `noclobber` | Empêche d'écraser un fichier avec `>` (`set -C`) | désactivée |

Une option par ligne pour plus de clarté :

```bash
set -o errexit
set -o pipefail
set -o noclobber
```

> Forme compacte très répandue en tête de script : `set -euo pipefail` (`-u` = erreur si une variable non définie est utilisée).
> Voir les options actives : `set -o` ; désactiver une option : `set +o pipefail`.
> Avec `noclobber`, on peut forcer l'écrasement ponctuellement avec `>|` : `echo "x" >| file.txt`.

### 6. Ajouter une clause de garde

Combiner `pipefail` avec une sortie immédiate en cas d'échec :

```bash
#!/usr/bin/env bash
set -o pipefail

sort somefile.txt | uniq || exit 80
```

Si une étape du pipeline échoue, le script s'arrête immédiatement avec le code **80**.

> Choisir un code de sortie non nul **qui a du sens** pour le script, et éviter les codes réservés : `1` (erreur générale), `2` (mauvais usage), `126` (non exécutable), `127` (commande introuvable), `128+n` (tué par le signal n, ex. 130 = Ctrl+C). Plage valide : **0 à 255**.

### 7. Combiner `pipefail` avec d'autres options

Script qui empêche l'écrasement de fichiers et détecte les erreurs de pipeline :

```bash
#!/usr/bin/env bash
set -o noclobber
set -o pipefail

echo "First line" > file.txt
echo "Second line" > file.txt      # Échoue à cause de noclobber
sort somefile.txt | uniq || exit 100

echo "This line never runs"
exit 0
```

Exécution :

```bash
$ ./set-pipefail3.sh
$ cat file.txt
First line
```

- La 2ᵉ redirection échoue (`cannot overwrite existing file`) : `file.txt` garde `First line`.
- Le pipeline `sort … | uniq` échoue → grâce à `pipefail` + la clause de garde, le script sort avec le code **100**.

> Précision : l'échec du `echo` (noclobber) **n'arrête pas** le script à lui seul, car `errexit` n'est pas activé. C'est le **pipeline** + `|| exit 100` qui provoque la sortie. Avec `set -o errexit` en plus, le script se serait arrêté dès la 2ᵉ redirection.
> À noter aussi : `file.txt` doit ne pas exister au premier lancement ; au second lancement, la **première** redirection échouerait aussi.

### À retenir

- Sans `pipefail`, `$?` d'un pipeline = code de la **dernière** commande → les erreurs intermédiaires sont **masquées**.
- `set -o pipefail` → le pipeline renvoie le code de la commande en échec **la plus à droite** (0 seulement si tout réussit).
- `pipefail` ne stoppe pas les commandes en cours, il change le **code de retour** ; combiné à `&&`, `||` ou `set -e`, il permet d'arrêter le script.
- `${PIPESTATUS[@]}` donne le code de chaque étape du dernier pipeline.
- `errexit` (`set -e`) = arrêt à la première erreur ; `noclobber` (`set -C`) = pas d'écrasement avec `>` (forcer avec `>|`).
- Idiome robuste : `set -euo pipefail` en début de script.
- Guard clause : `pipeline || exit CODE`, avec un code personnalisé (éviter 1, 2, 126, 127, 128+).

### Liens utiles

- [GNU Bash – The Set Builtin (pipefail, errexit, noclobber…)](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- [GNU Bash – Pipelines](https://www.gnu.org/software/bash/manual/html_node/Pipelines.html)
- [GNU Bash – Bourne Shell Builtins](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html)
- [Advanced Bash-Scripting Guide – Exit Codes With Special Meanings](https://tldp.org/LDP/abs/html/exitcodes.html)
- [Stack Overflow – What does set -o pipefail do?](https://stackoverflow.com/questions/54577587)
