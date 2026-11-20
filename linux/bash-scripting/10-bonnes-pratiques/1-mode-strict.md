# Mode strict

Bash est très flexible pour l'automatisation, mais son comportement par défaut peut **masquer des échecs**. Contrairement aux langages qui ont une vraie gestion d'exceptions, Bash **continue l'exécution** même quand une commande échoue, et renvoie souvent un code de sortie **trompeur de 0**.

Le **mode strict** permet au script :
- d'**échouer vite** (*fail fast*) ;
- de détecter les **variables non définies** ;
- de gérer correctement les **erreurs dans les pipelines**.

### 1. Activer le mode strict

Trois options forment le cœur du mode strict :

| Option | Effet |
|---|---|
| `set -e` | Quitte immédiatement si une commande renvoie un code **non nul** |
| `set -u` | Traite les variables **non définies** comme une **erreur** et quitte |
| `set -o pipefail` | Un pipeline renvoie le code d'erreur d'une commande en échec (pas seulement celui de la dernière) |

Combinées en une seule ligne :

```bash
set -euo pipefail
```

> `pipefail` renvoie le code de la commande en échec **la plus à droite** (la **dernière** qui a échoué) ; le pipeline renvoie 0 seulement si toutes réussissent.

> Variante répandue (« unofficial bash strict mode ») qui ajoute un `IFS` plus sûr :
> ```bash
> set -euo pipefail
> IFS=$'\n\t'      # ne plus découper sur les espaces
> ```

### 2. Rappel : opérateurs `||` et `&&`

Ils enchaînent des commandes selon leur **code de sortie** :

- `command1 && command2` → `command2` s'exécute **seulement si** `command1` **réussit** (code 0) ;
- `command1 || command2` → `command2` s'exécute **seulement si** `command1` **échoue** (code ≠ 0).

> Exemple : `mkdir -p build && cd build || exit 1`

### 3. L'option `set -e`

Sans `set -e`, une commande en échec **n'arrête pas** le script :

```bash
#!/usr/bin/env bash
ehco "Hello World"
exit 0
```

```bash
$ ./safe.sh
./safe.sh: line 3: ehco: command not found
$ echo $?
0
```

Le `exit 0` final **masque** l'erreur.

Avec `set -e`, le script s'arrête et **conserve le code** de la commande en échec :

```bash
#!/usr/bin/env bash
set -e
ehco "Hello World"
exit 0
```

```bash
$ ./safe.sh
./safe.sh: line 4: ehco: command not found
$ echo $?
127
```

Codes de sortie réservés courants :

| Code | Description |
|---|---|
| 0 | Succès |
| 1 | Erreur générale |
| 2 | Mauvaise utilisation d'un built-in du shell |
| 127 | Commande introuvable |

> Autres : 126 (non exécutable), 128+n (tué par le signal n, ex. 130 = Ctrl+C).

> `set -e` **ne se déclenche pas** quand une commande échoue :
> - dans la condition d'un `if`, `while`, `until` ;
> - à gauche d'un `&&` ou d'un `||` ;
> - précédée de `!` ;
> - au milieu d'un pipeline (sans `pipefail`).
>
> Pour **autoriser** volontairement un échec : `grep "x" fichier || true`.


### 4. L'option `set -u`

Par défaut, une variable non définie vaut une **chaîne vide**. Avec `set -u`, c'est une **erreur** :

```bash
#!/usr/bin/env bash
set -u

name="JuanCarlos"
echo "My full name is ${name} ${last_name}. Nice to meet you."
exit 0
```

```bash
$ ./unset-variable.sh
./unset-variable.sh: line 4: last_name: unbound variable
$ echo $?
1
```

> Toujours **initialiser** les variables ou **tester leur existence** pour éviter des arrêts inattendus.

> Avec `set -u`, utiliser une **valeur par défaut** pour les variables optionnelles :
> ```bash
> echo "Nom : ${last_name:-inconnu}"       # pas d'erreur, valeur par défaut
> debug="${DEBUG:-false}"                  # variable d'environnement optionnelle
> first_arg="${1:-}"                       # argument facultatif (sinon erreur si absent)
> ```
> Ce mode attrape aussi les **fautes de frappe** (`$nmae` au lieu de `$name`), particulièrement dangereuses avec des commandes comme `rm -rf "$dir/"`.

### 5. L'option `set -o pipefail`

Par défaut, un pipeline ne renvoie que le code de sa **dernière** commande, ce qui peut cacher des échecs :

```bash
#!/usr/bin/env bash
cat non-existent-file.txt | sort | uniq
exit 0
```

```bash
$ ./pipefail-v1.sh
cat: non-existent-file.txt: No such file or directory
$ echo $?
0
```

`cat` échoue (message sur **stderr**), mais `sort` et `uniq` réussissent sur une entrée vide → le pipeline renvoie **0**.

Pour détecter une erreur **n'importe où** dans le pipeline, on combine les trois options et on gère l'échec explicitement :

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly PIPE_ERROR=156

terminate() {
  local -r msg="$1"
  local -r code="${2:-160}"
  echo "$msg" >&2
  exit "$code"
}

cat non-existent-file.txt | sort || \
  { terminate "Error in piped command" "$PIPE_ERROR"; }

exit 0
```

```bash
$ ./pipefail_v4.sh
cat: non-existent-file.txt: No such file or directory
Error in piped command
$ echo $?
156
```

Fonctionnement :
- grâce à `pipefail`, le pipeline renvoie le code d'échec de `cat` ;
- le pipeline est **à gauche d'un `||`** : `set -e` ne coupe donc pas le script, c'est le `||` qui prend la main ;
- `terminate` affiche un message clair sur **stderr** et sort avec un **code dédié** (156) ;
- `local -r` : variables **locales** et **en lecture seule** dans la fonction.

> Codes personnalisés : de préférence entre **3 et 125** (au-delà de 128 = mort par signal).

> Pour savoir **où** un script s'arrête en mode strict, ajouter un `trap` :
> ```bash
> trap 'echo "Erreur ligne $LINENO (code $?)" >&2' ERR
> ```

### 6. Conclusion

Avec le mode strict activé (`-e`, `-u`, `-o pipefail`), les scripts :
- **échouent vite** en cas d'erreur ;
- **refusent** les variables non initialisées ;
- **détectent** les pipelines cassés.

Résultat : une automatisation plus **fiable** et plus **maintenable**.

### À retenir

- Mode strict = **`set -euo pipefail`** en tête de script (jamais dans un shell interactif).
- `-e` : arrêt à la première commande en échec, avec **son** code de sortie (un `exit 0` final ne masque plus rien).
- `-e` ne s'applique pas dans `if`/`while`, à gauche de `&&`/`||`, après `!` → échec volontairement toléré : `cmd || true`.
- `-u` : variable non définie = erreur (`unbound variable`) → `${var:-défaut}`, `${1:-}` pour l'optionnel.
- `pipefail` : le pipeline échoue si **une** commande échoue (code de la plus à droite en échec).
- Gestion explicite : `pipeline || { terminate "msg" CODE; }` avec un code dédié.
- Bonus : `IFS=$'\n\t'` et `trap '…$LINENO…' ERR` pour le débogage.

### Liens utiles

- [GNU Bash – The Set Builtin (`-e`, `-u`, `pipefail`)](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- [GNU Bash – Exit Status](https://www.gnu.org/software/bash/manual/bash.html#Exit-Status)
- [BashFAQ 105 – Pourquoi `set -e` ne fait pas toujours ce qu'on attend](https://mywiki.wooledge.org/BashFAQ/105)
- [Unofficial Bash Strict Mode (Aaron Maxwell)](http://redsymbol.net/articles/unofficial-bash-strict-mode/)
- [ShellCheck – analyse statique de scripts](https://www.shellcheck.net/)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
