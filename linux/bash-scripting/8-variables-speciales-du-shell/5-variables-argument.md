# Arguments : `$@` vs `$*`

Dans un script Bash, on accède à chaque argument par sa **position** (`$1`, `$2`…). Mais quand le **nombre d'arguments varie**, les variables spéciales **`$@`** et **`$*`** simplifient la logique.

### 1. Paramètres positionnels : `$1`, `$2`…

Bash affecte chaque argument à une variable numérotée :

```bash
#!/usr/bin/env bash
firstarg=$1
secondarg=$2

echo "First argument: ${firstarg}"
echo "Second argument: ${secondarg}"
```

```bash
$ ./simple-args.sh "arg1"
First argument: arg1
Second argument:

$ ./simple-args.sh "arg1" "arg2"
First argument: arg1
Second argument: arg2
```

Un argument manquant donne une **chaîne vide** (sans erreur). Quand le nombre d'arguments est **imprévisible**, les indexer un par un devient pénible → `$@` et `$*`.

### 2. Regrouper tous les arguments : `$@` et `$*`

Les deux contiennent **tous** les arguments positionnels :

```bash
#!/usr/bin/env bash
packaged_args1="$@"
packaged_args2="$*"

echo "Using \$@: ${packaged_args1}"
echo "Using \$*: ${packaged_args2}"
```

```bash
$ ./simple-args2.sh arg1 arg2 arg3
Using $@: arg1 arg2 arg3
Using $*: arg1 arg2 arg3
```

À l'affichage, aucune différence… mais elle apparaît lors de l'**itération**.

> En affectant à une **variable simple** (`var="$@"`), on perd de toute façon la séparation des arguments : tout devient une seule chaîne (ShellCheck SC2124). Pour conserver les arguments séparés, utiliser un **tableau** :
> ```bash
> args=("$@")
> echo "${#args[@]} arguments, le 2e est : ${args[1]}"
> ```

### 3. Itérer avec une boucle `for`

Deux scripts qui parcourent leurs arguments :

```bash
#!/usr/bin/env bash
echo "Number of arguments: $#"
echo "All arguments: $@"
for arg in "$@"; do
  echo "Argument: $arg"
done
```

```bash
#!/usr/bin/env bash
echo "Number of arguments: $#"
echo "All arguments: $*"
for arg in "$*"; do
  echo "Argument: $arg"
done
```

```bash
$ ./atsign-example1.sh one two three
Number of arguments: 3
All arguments: one two three
Argument: one
Argument: two
Argument: three

$ ./star-example1.sh one two three
Number of arguments: 3
All arguments: one two three
Argument: one two three
```

**Analogie des canettes de soda :**
- `"$@"` range chaque canette dans **son propre compartiment** → arguments **séparés** ;
- `"$*"` verse tout le soda dans **une grande bouteille** → arguments **fusionnés** en une seule chaîne.

### 4. L'importance des guillemets

Toujours mettre `$@` et `$*` **entre guillemets** :
- `"$@"` → chaque argument est développé **séparément** ;
- `"$*"` → tous les arguments sont **joints en une seule chaîne**, séparés par le **premier caractère de `IFS`** (espace par défaut).

**Sans guillemets**, les deux se comportent **de la même façon** :

```bash
#!/usr/bin/env bash
print_section_header() {
  local title="$1"
  echo "==============================="
  echo "= Section ${title} ="
  echo "==============================="
}

print_section_header "1: \$@"
echo "--> Output of \$@: $@"
echo "Looping \$@ without quotes:"
for arg in $@; do
  echo "$arg"
done

print_section_header "2: \$*"
echo "--> Output of \$*: $*"
echo "Looping \$* without quotes:"
for arg in $*; do
  echo "$arg"
done
```

```bash
$ ./special-shell-noquotes.sh one two three
===============================
= Section 1: $@ =
===============================
--> Output of $@: one two three
Looping $@ without quotes:
one
two
three
===============================
= Section 2: $* =
===============================
--> Output of $*: one two three
Looping $* without quotes:
one
two
three
```

> Le vrai danger apparaît avec des **arguments contenant des espaces** : sans guillemets, ils sont **redécoupés** (et soumis au globbing).
> ```bash
> $ ./script.sh "mon fichier.txt" autre.txt
>
> for a in $@;   →  [mon] [fichier.txt] [autre.txt]   ❌ 3 éléments
> for a in "$*"; →  [mon fichier.txt autre.txt]       ❌ 1 élément
> for a in "$@"; →  [mon fichier.txt] [autre.txt]     ✅ 2 éléments
> ```
> Seul **`"$@"`** respecte exactement les arguments d'origine.

### 5. Modifier `IFS`

Changer `IFS` modifie la façon dont **`"$*"`** joint les arguments :

```bash
#!/usr/bin/env bash
IFS=','

echo "Output of \$@: $@"
echo "Output of \$*: $*"
```

```bash
$ ./modified-ifs-v1.sh one two three
Output of $@: one two three
Output of $*: one,two,three
```

`$@` n'est **pas** affecté (les arguments restent séparés et `echo` les affiche avec des espaces), alors que `$*` utilise la **virgule** comme séparateur.

Pour redécouper ensuite, il faut une itération **sans guillemets** :

```bash
#!/usr/bin/env bash
IFS='_'
args_at="$@"
args_star="$*"

print_section_header() {
  local title="$1"
  echo "==============================="
  echo "= Section ${title} ="
  echo "==============================="
}

print_section_header "1: \$@"
echo "--> \$@: $@"
echo "Looping over args_at:"
for arg in $args_at; do
  echo "$arg"
done

print_section_header "2: \$*"
echo "--> \$*: $*"
echo "Looping over args_star:"
for arg in $args_star; do
  echo "$arg"
done
```

> Résultat attendu avec `./script.sh one two three` :
> - `args_star="$*"` → `one_two_three` → redécoupé sur `_` → **`one`, `two`, `three`** ;
> - `args_at="$@"` → en Bash, l'affectation joint les arguments avec des **espaces** → `one two three` → aucun `_` à découper → **une seule itération** `one two three`.
>
> D'où l'intérêt d'un **tableau** plutôt que de jongler avec `IFS`.

> Usage pratique de `"$*"` + `IFS` : construire une chaîne avec un séparateur.
> ```bash
> join_by_comma() { local IFS=","; echo "$*"; }
> join_by_comma a b c     # a,b,c
> ```

### 6. Compatibilité avec les anciennes versions de Bash

Certaines versions **antérieures à Bash 4.0** traitent différemment les affectations **non quotées**. Par exemple sous Bash 3 :

```bash
#!/usr/bin/env bash
IFS=','
args_at=$@
echo "--> \$@: ${args_at}"
for arg in $args_at; do
  echo "$arg"
done
```

Mettre l'affectation **entre guillemets** garantit un comportement cohérent :

```bash
#!/usr/bin/env bash
IFS=','
args_at="$@"
echo "--> \$@: $@"
for arg in $args_at; do
  echo "$arg"
done
```

> Le comportement de `var=$@` / `var="$@"` avec un `IFS` modifié a varié selon les versions de Bash et n'est pas défini par POSIX. Règle simple pour éviter le problème : **ne jamais stocker `$@` dans une variable simple** → `args=("$@")`.

### 7. Récapitulatif : `$@` vs `$*`

| Variable | Entre guillemets | Sans guillemets | Usage |
|---|---|---|---|
| `$@` | `"$@"` → chaque argument **séparé** | Redécoupé sur `IFS` + globbing | **Boucler** sur les arguments, les **transmettre** à une autre commande/fonction |
| `$*` | `"$*"` → **une seule chaîne** (jointe avec le 1er car. de `IFS`) | Redécoupé sur `IFS` + globbing | Construire **un message** / une chaîne unique |

> Correction : la leçon associe `$*` à « passer tous les arguments à une autre commande ou fonction ». C'est en réalité **`"$@"`** qu'il faut utiliser pour **relayer** les arguments sans les altérer :
> ```bash
> wrapper() { command_reelle "$@"; }      # ✅ arguments transmis à l'identique
> log() { echo "[$(date +%T)] $*"; }      # ✅ "$*" pour un message lisible
> ```

### 8. Conclusion

- `"$@"` pour **préserver chaque argument**.
- `"$*"` pour **regrouper** les arguments en **une seule chaîne** avec un délimiteur personnalisable.
- **Toujours entre guillemets**, pour un comportement cohérent entre versions et éviter le découpage en mots.

### À retenir

- `$1`, `$2`… = arguments positionnels ; `$#` = nombre ; argument absent = chaîne vide.
- `"$@"` = **chaque argument séparé**, espaces internes respectés → la forme à utiliser dans 95 % des cas (boucles, relais vers une autre commande).
- `"$*"` = **une seule chaîne**, jointe avec le **1er caractère de `IFS`** → messages, jointure (`IFS=","; echo "$*"`).
- Sans guillemets, `$@` et `$*` sont identiques… et dangereux (arguments avec espaces redécoupés, globbing).
- `IFS` n'affecte pas `"$@"`, seulement `"$*"` et les expansions non quotées.
- Ne pas stocker `$@` dans une variable simple : utiliser un **tableau** `args=("$@")` puis `"${args[@]}"`.
- Mnémotechnique : `@` = « **a**rguments **à** part », `*` = « tout en un ».

### Liens utiles

- [GNU Bash – Special Parameters (`$@`, `$*`)](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)
- [GNU Bash – Arrays](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)
- [GNU Bash – Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [ShellCheck SC2124 – affecter `$@` à une variable simple](https://www.shellcheck.net/wiki/SC2124)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
