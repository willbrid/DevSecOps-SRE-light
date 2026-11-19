# Variable spéciale $#

Après `$?` (code de sortie de la dernière commande), voici **`$#`** : le **nombre de paramètres positionnels** passés à un **script** ou à une **fonction**. Le vérifier **dès le début** évite les comportements inattendus et rend les scripts plus fiables.

### 1. Pourquoi `$#` est important

Les scripts dépendent souvent d'arguments fournis par l'utilisateur. Si le script attend un certain nombre d'entrées et en reçoit **aucune** (ou **trop**), il peut échouer **silencieusement** ou produire des résultats faux. Vérifier `$#` permet de :
- **valider** les entrées avant la logique critique ;
- afficher un **message d'usage** clair ;
- **sortir tôt** en cas de mauvaise utilisation.

> Toujours valider les paramètres positionnels pour éviter les erreurs silencieuses et faciliter la maintenance.

### 2. Utilisation de base de `$#`

`count-args.sh` :

```bash
#!/usr/bin/env bash
echo "Number of arguments: $#"
```

Exécutions avec différents nombres d'arguments :

```bash
$ ./count-args.sh
Number of arguments: 0

$ ./count-args.sh alpha
Number of arguments: 1

$ ./count-args.sh alpha beta
Number of arguments: 2

$ ./count-args.sh ""
Number of arguments: 1
```

> - Une **chaîne vide** `""` compte comme **un** argument.
> - Les guillemets regroupent : `./count-args.sh "alpha beta"` → **1** argument.
> - Dans une **fonction**, `$#` compte les arguments **de la fonction**, pas ceux du script :
>   ```bash
>   f() { echo "f a reçu $# argument(s)"; }
>   f a b c     # f a reçu 3 argument(s)
>   ```

### 3. Paramètres positionnels absents

Par défaut, un paramètre positionnel **non défini** donne une **chaîne vide**, **sans erreur** :

```bash
#!/usr/bin/env bash
echo "First: '${1}'"
echo "Second: '${2}'"
```

```bash
$ ./show-params.sh hello
First: 'hello'
Second: ''
$ echo $?
0
```

Sans validation, le script **continue avec des données manquantes**, ce qui provoque des échecs plus loin.

> Autres protections possibles :
> ```bash
> set -u                                    # erreur si une variable non définie est utilisée
> steps="${1:?Usage: $0 <steps>}"           # message + arrêt si $1 absent ou vide
> name="${2:-default}"                      # valeur par défaut si $2 absent
> ```

### 4. Guard clauses avec `$#`

Valider `$#` en début de script pour imposer l'usage attendu :

| Motif | Description | Exemple |
|---|---|---|
| `[[ $# -ne N ]]` | Nombre **exact** | `if [[ $# -ne 1 ]]; then echo "Usage: $0 <arg>" >&2; exit 1; fi` |
| `[[ $# -lt N ]]` | **Au moins** N | `if [[ $# -lt 1 ]]; then echo "Need at least one arg" >&2; exit 1; fi` |
| `[[ $# -lt MIN \|\| $# -gt MAX ]]` | **Entre** MIN et MAX | `if [[ $# -lt 1 \|\| $# -gt 2 ]]; then echo "Expect 1–2 args" >&2; exit 1; fi` |

#### Nombre exact d'arguments

```bash
#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <arg>" >&2
  exit 1
fi

echo "Argument received: $1"
exit 0
```

#### Nombre minimum d'arguments

```bash
#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
  echo "Error: At least one argument is required." >&2
  exit 1
fi

echo "Received $# argument(s)."
```

#### Plage d'arguments

```bash
#!/usr/bin/env bash
readonly MIN=1
readonly MAX=2

if [[ $# -lt $MIN || $# -gt $MAX ]]; then
  echo "Usage: $0 <arg1> [arg2]" >&2
  echo "Provide between $MIN and $MAX arguments." >&2
  exit 1
fi

echo "Arguments are within the expected range."
```

> Convention des messages d'usage : `<arg>` = **obligatoire**, `[arg]` = **facultatif**.
> Alternative arithmétique : `(( $# < 1 || $# > 2 ))`.

### 5. Exemple concret : calcul des calories en marchant

#### Version défaillante

```bash
#!/usr/bin/env bash
steps=${1}
cal_per_step=0.04
calories=$(echo "${steps} * ${cal_per_step}" | bc)
echo "Calories burned for ${steps} steps: ${calories}"
```

Sans argument : `bc` reçoit ` * 0.04` → erreur de syntaxe… mais le script renvoie **0** :

```bash
$ ./calorie.sh
(standard_in) 1: syntax error
$ echo $?
0
```

> Pourquoi 0 ? Le code de sortie d'un script est celui de sa **dernière commande** : ici le `echo`, qui a réussi.

> Un script qui continue après une erreur peut **masquer** des échecs critiques. Toujours combiner guard clauses et gestion d'erreurs stricte.

#### Version améliorée avec `set -e` et `terminate()`

```bash
#!/usr/bin/env bash
set -e

CL_ARGS_ERROR=155
CAL_PER_STEP=0.04

terminate() {
  local msg="$1"
  local code="${2:-160}"
  echo "Error: $msg" >&2
  exit "$code"
}

# Guard clause : exactement un argument attendu
if [[ $# -ne 1 ]]; then
  terminate "Please provide exactly one argument (number of steps)" "$CL_ARGS_ERROR"
fi

steps=$1
calories=$(echo "$steps * $CAL_PER_STEP" | bc)
echo "Calories burned for $steps steps: $calories"
exit 0
```

#### Utilisation

```bash
$ ./calorie.sh
Error: Please provide exactly one argument (number of steps)
$ echo $?
155

$ ./calorie.sh 10000
Calories burned for 10000 steps: 400.00
$ echo $?
0
```

> Améliorations possibles :
> - Vérifier que l'argument est bien un **nombre** (sinon `./calorie.sh abc` passe la guard clause) :
>   ```bash
>   [[ $1 =~ ^[0-9]+$ ]] || terminate "Steps must be a positive integer" 156
>   ```
> - Vérifier que `bc` est installé : `command -v bc >/dev/null || terminate "bc is required" 157`.
> - Déclarer les constantes avec `readonly`.
> - Préférer des codes personnalisés entre **3 et 125** (au-delà de 128 = mort par signal).

### 6. Récapitulatif des variables

| Variable | Description | Exemple |
|---|---|---|
| `$?` | Code de sortie de la dernière commande | `echo $?` |
| `$#` | Nombre de paramètres positionnels | `if [[ $# -ne 1 ]]; then … fi` |
| `$1`, `$2`… | Paramètres positionnels (1er, 2ᵉ…) | `echo "First: $1"` |



### À retenir

- `$#` = **nombre d'arguments** du script (ou de la fonction en cours).
- `""` compte pour **un** argument ; `"a b"` aussi.
- Un paramètre absent (`$2`) vaut une **chaîne vide sans erreur** → valider avec `$#`, `set -u` ou `${1:?msg}`.
- Guard clauses : `-ne N` (exact), `-lt N` (minimum), `-lt MIN || -gt MAX` (plage).
- Messages d'usage sur **stderr** (`>&2`), avec `$0` pour le nom du script ; `<obligatoire>` `[facultatif]`.
- Le code de sortie d'un script = celui de sa **dernière commande** → une erreur au milieu peut être masquée.
- Combinaison robuste : guard clause sur `$#` + validation du **contenu** (regex) + `set -e` + fonction `terminate` avec code dédié.

### Liens utiles

- [GNU Bash – Special Parameters (`$#`, `$?`, `$@`…)](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)
- [GNU Bash – Shell Parameter Expansion (`${1:?}`, `${1:-}`)](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
