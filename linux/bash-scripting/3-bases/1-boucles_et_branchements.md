# Boucles et branchements

Dans l'interpréteur de commandes, il existe trois types de boucles (`while`, `until` et `for`) et trois types d'exécution conditionnelle (`if`, `case`, et les opérateurs conditionnels `&&` et `||`, qui signifient respectivement **ET** et **OU**). À l'exception de `for` et `case`, le comportement est déterminé par le statut d'une commande.

### Statut final

On peut tester directement le statut d'une commande à l'aide des mots-clés shell `while`, `until` et `if`, ou des opérateurs de contrôle `&&` et `||`. Le code de sortie est stocké dans le paramètre spécial `$?`.

Si la commande s'est exécutée avec succès (ou si la valeur est `true`), `$?` vaut **zéro**. En cas d'échec, `$?` contient un entier positif compris entre **1** et **255** inclus. Une commande ayant échoué renvoie généralement **1**. Les codes de sortie **0** et non nuls sont respectivement appelés `true` et `false`.

### Tests dans l'expression

Les expressions sont jugées vraies ou fausses par la commande `test` (ou `[...]`) ou par l'un des deux mots réservés non standard du shell : `[[` et `((`. La commande `test` compare les **chaînes de caractères**, les **entiers** et **divers attributs de fichiers** ; `((` teste les **expressions arithmétiques**, et `[[...]]` fait la même chose que `test` avec la possibilité **supplémentaire** de comparer des **expressions régulières**.

- **Tests sur les fichiers**

**Bash** propose plusieurs opérateurs pour tester l’état d’un fichier. L’option `-e` (ou la non standard `-a`) permet de vérifier si un fichier existe. Pour déterminer le type de fichier, on peut utiliser `-f` pour un fichier ordinaire, `-d` pour un répertoire, et `-h` ou `-L` pour un lien symbolique. D’autres opérateurs existent également pour contrôler des types de fichiers particuliers ou vérifier leurs permissions.

```
# tester si le fichier est un fichier régulier
test -f /etc/hosts

# tester si le fichier est un lien symbolique
test -h /etc/os-release

# tester si le fichier peut-être exécuté
[ -x "/usr/bin/ls" ]

# tester si le fichier existe et n'est pas vide
[[ -s "/etc/hosts" ]]
```

- **Tests sur les entiers**

La comparaison entre entiers utilise les opérateurs : <br>
--- `-eq` (**égale à**), <br>
--- `-ne` (**différent de**), <br>
--- `-gt` (**superieur à**), <br>
--- `-lt` (**inférieur à**), <br>
--- `-ge` (**supérieur ou égal à**), <br>
--- `-le` (**inférieur ou égal à**)

```
# tester si 1 est égal à 1
test 1 -eq 1

# tester si 3 est égal à 2
[ 3 -eq 2 ]

# tester si 1 est différent de 1
[ 3 -ne 2 ]

# tester si 3 est supérieur à 1
[[ 3 -gt 2 ]]

# tester si 3 est supérieur égal à 3
[[ 3 -ge 3 ]]
```

- **Test sur les chaines de caractères**

Une chaîne de caractères est une suite de **zéro** ou **plusieurs caractères**, pouvant contenir **tout caractère** sauf **NUL**. On peut comparer des chaînes pour vérifier leur égalité, leur inégalité, leur présence (vide ou non vide) ou encore leur ordre alphabétique en Bash.
L’opérateur `=` permet de tester si deux chaînes sont identiques, tandis que `!=` vérifie qu’elles diffèrent. <br>
Bash accepte également `==` comme test d’égalité, mais cet opérateur n’est pas standard et son usage est déconseillé.

```
name1="willbrid"
name2="willbrid"

# tester si la chaine name1 est égale à la chaine name2
test "$name1" = "$name2"

# tester si la chaine name1 est différente de la chaine name2
[ "$name1" != "$name2" ]

# tester si la chaine name1 est vide
[ -z "$name1" ]

# test si la chaine name2 est non vide
test -n "$name2"
```

L'option `-z` permet de tester si une chaine est vide alors que l'option `-n` permet de tester si une chaine est non vide.

Les symboles **supérieur à** `>` et **inférieur à** `<` sont utilisés dans bash pour comparer les positions lexicales des chaînes de caractères et doivent être échappés pour éviter qu'ils ne soient interprétés comme des opérateurs de redirection.

```
str1="abc"
str2="def"

test "$str1" \< "$str2"
test "$str1" \> "$str2"
```

Le test est généralement utilisé en combinaison avec `if` ou les opérateurs conditionnels `&&` et `||`.

- **Test avec `[[ ... ]]`**

L’expression `[[ ... ]]` permet, tout comme la commande `test` (ou son équivalent `[ ... ]`), d’évaluer des conditions dans un script **Bash**.
Cependant, `[[` n’est pas une commande, mais fait partie de la syntaxe propre du shell. Cela signifie qu’elle est interprétée directement par **Bash**, sans passer par les règles classiques d’exécution d’une commande.

Contrairement à `test`, la structure `[[ ... ]]` n’applique pas la séparation des mots, ni l’expansion des **jokers** (**globbing**) entre les crochets. Cela évite de nombreuses erreurs liées à des variables contenant des espaces ou des caractères spéciaux. Par exemple, une comparaison comme `[[ $fichier = *.txt ]]` fonctionnera sans risque d’expansion indésirable du motif `*.txt`.

La structure `[[ ... ]]` prend en charge tous les opérateurs de test, mais ajoute aussi des fonctionnalités plus puissantes, comme la comparaison de chaînes par expressions rationnelles avec l’opérateur `=~`.

Cependant, `[[ ... ]]` n’est pas définie dans la norme **POSIX**, ce qui la rend non portable vers d’autres shells (comme **dash** ou **sh**).
Pour garantir la compatibilité entre systèmes, il est donc préférable d’utiliser `test` ou `[ ... ]` lorsque les fonctionnalités avancées de `[[ ... ]]` ne sont pas nécessaires.

|Fonction|[ ... ] ou test |  [[ ... ]]  |
|--------|----------------|--------------
`Type`|Commande POSIX|Syntaxe interne à Bash
`Séparation des mots`|Oui|Non
`Globbing`|Oui|Non
`Expressions régulières (=~)`|Non supporté|Oui
`Nécessité de guillemets`|Oui, souvent obligatoire|Pas nécessaire dans la plupart des cas
`Portabilité`|POSIX|Bash seulement

Le **globbing** (ou **file name expansion** ou **génération de nom de fichier**) est le processus par lequel le shell remplace automatiquement certains motifs contenant des caractères spéciaux (`*, ?, [ ], {}`) par la liste des fichiers correspondants dans le système de fichiers. Pour le désactiver on exécute la commande `set -f`.

```
wordname="hello"

[[ $wordname =~ h[aeiou] ]]

[[ $wordname =~ h[sdfghjkl] ]]
```

**Quelques exemples**

|   |[ ... ] ou test |  [[ ... ]]  |
|---|----------------|--------------
`<` | `[ a \< b ]` | `[[ a < b ]]`
`&& \|\|` | `[ a = a ] && [ b = b ] [ a = a ] \|\| [ b = b ]` | `[[ a = a && b = b ]] [[ a = a \|\| b = b ]]`
`()` | `{ [ a = a ] \|\| [ a = b ]; } && [ a = b ]` | `[[ (a = a \|\| a = b) && a = b ]]`
`split+glob` | `x='a b'; [ "$x" = 'a b' ]` | `x='a b'; [[ $x = 'a b' ]]`
`=` | `case ab in (a?) echo match; esac` | `[[ ab = a? ]] [[ ab == a? ]] (correspondance de modèles)`
`=~` | `printf 'ab\n' \| grep -Eq 'ab?'` | `[[ ab =~ ab? ]] (expression régulière)`

- **Test avec `(( ... ))`**

La syntaxe non standard `((expression arithmétique))` renvoie `false` si l'expression arithmétique est égale à zéro, et `true` sinon. Son équivalent portable utilise `test` et la syntaxe POSIX pour les opérations arithmétiques du shell :

```
test $((a - 2)) -ne 0
```

Cependant, comme `((expression))` relève de la syntaxe du shell et non d'une commande intégrée, `expression` n'est pas interprétée de la même manière que les arguments d'une commande.

```
if ((total > max)); then ... ; fi
```

Donc à l’intérieur de `(( ))` :

--- pas de séparation des mots (word splitting) <br>
--- pas d’expansion des glob patterns (*, ?, etc.) <br>
--- pas besoin de $ devant une variable pour l’utiliser <br>
--- les valeurs sont automatiquement traitées comme des nombres

Le shell interprète `(( ))` comme du calcul brut, pas comme une commande avec des arguments. Donc à l'intérieur ce sont des **expressions arithmétiques**.

### Exécution conditionnelle

Les constructions conditionnelles permettent à un script de décider s'il doit exécuter un bloc de code ou de sélectionner lequel de deux ou plusieurs blocs exécuter.

- **if**

La commande `if` de base évalue une liste d'une ou plusieurs commandes et exécute une liste si l'exécution de `<liste de conditions>` réussit.

```
if <list de condition>
then
  <instructions>
fi

if <list de condition>; then
  <instructions>
fi
```

`<liste de condition>` est généralement construite avec : `test`, `[]` ou `[[]]` .

Exemple :

```
read filename
if [[ -z $filename ]]; then
  printf "no name entered" >&2
fi
```

En utilisant le mot-clé `else`, un ensemble d'instructions peut être exécuté si la `<liste de conditions>` échoue.

```
printf "Enter a number greather than 7: "
read number
if (( number < 7 )); then
  printf "%d is too small \n" "$number" >&2
  exit 1
else
  printf "you entered %d\n" "$number"
fi
```

Il est possible de spécifier plusieurs conditions à l'aide du mot-clé `elif`, de sorte que si le premier test échoue, le second est évalué.

```
printf "Enter a number between 7 and 17: "
read number
if (( number < 7 )); then
  printf "%d is too small \n" "$number" >&2
  exit 1
elif (( number > 17 )); then
  printf "%d is too big \n" "$number" >&2
  exit 1
else
  printf "you entered %d\n" "$number"
fi
```
