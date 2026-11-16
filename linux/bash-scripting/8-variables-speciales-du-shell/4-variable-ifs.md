# Variable IFS

**`IFS`** (*Internal Field Separator*) est une variable spéciale du shell qui définit **comment Bash (et les shells POSIX) découpe les chaînes en champs** (*fields*).

Contrairement aux variables d'environnement (réglages statiques, globaux au système), une variable de shell comme `IFS` est **dynamique** et limitée à la **session de shell**. Bien la gérer améliore la **portabilité** : le script se comporte de la même façon sur tous les systèmes.

Par défaut, `IFS` contient **espace, tabulation et retour à la ligne**, ce qui influence de nombreuses tâches courantes : parcourir une liste de fichiers, analyser la sortie d'une commande…

### 1. Séparateurs par défaut

| Séparateur | Séquence d'échappement | Description |
||||
| Espace | `<espace>` | Découpe sur les espaces |
| Tabulation | `\t` | Découpe sur les tabulations |
| Retour à la ligne | `\n` | Découpe sur les retours à la ligne |

> Pour voir la valeur réelle de `IFS` (invisible avec un simple `echo`) :
> ```bash
> $ printf '%q\n' "$IFS"
> $' \t\n'
> ```

### 2. IFS par défaut en action

```bash
#!/usr/bin/env bash
elements="alpha beta gamma"
for element in ${elements}; do
  echo "${element} is now separated from the elements list"
done
```

Sortie :

```text
alpha is now separated from the elements list
beta is now separated from the elements list
gamma is now separated from the elements list
```

Comme `${elements}` n'est **pas entre guillemets**, il est découpé sur les espaces : chaque mot devient une itération.

> Avec `"${elements}"` (entre guillemets), **aucun découpage** : une seule itération avec `alpha beta gamma`.

### 3. Redéfinir IFS avec le quoting ANSI-C

Pour définir **explicitement** `IFS` avec espace, tabulation et retour à la ligne :

```bash
IFS=$' \t\n'
```

La syntaxe **`$'…'`** (quoting **ANSI-C**, qui commence par un **dollar**) demande à Bash d'interpréter les **séquences d'échappement** (`\t`, `\n`…) à l'intérieur des apostrophes. On obtient ainsi les **vrais** caractères tabulation et retour à la ligne.

> Sans le `$`, `IFS=' \t\n'` contiendrait les caractères littéraux `\`, `t`, `n` → découpage complètement faux.
> Autres usages : `echo $'ligne1\nligne2'`, `IFS=$'\n'` (découper uniquement sur les retours à la ligne).

### 4. Changer le séparateur de champs

Si les données utilisent un autre délimiteur, comme `:`, il faut modifier `IFS`. Sans modification, la chaîne reste **intacte** :

```bash
#!/usr/bin/env bash
elements="one:two:three"
for element in ${elements}; do
  echo "${element} is now separated from the elements list"
done
```

Sortie :

```text
one:two:three is now separated from the elements list
```

Avec `IFS` défini sur `:` :

```bash
#!/usr/bin/env bash
IFS=":"
elements="one:two:three"
for element in ${elements}; do
  echo "${element} is now separated from the elements list"
done
```

Sortie :

```text
one is now separated from the elements list
two is now separated from the elements list
three is now separated from the elements list
```

> Modifier `IFS` **globalement** affecte toutes les commandes suivantes du script. Toujours le **restaurer** après un changement temporaire.

> Bonnes pratiques pour limiter la portée du changement :
> ```bash
> # 1. Sauvegarder / restaurer
> old_IFS="$IFS"
> IFS=":"
> # … traitement …
> IFS="$old_IFS"
>
> # 2. IFS limité à une seule commande (le plus propre) : ne s'applique qu'à read
> IFS=":" read -r user pass uid gid rest <<< "root:x:0:0:root:/root:/bin/bash"
> echo "$user $uid"     # root 0
>
> # 3. Découper directement dans un tableau
> IFS=":" read -ra dirs <<< "$PATH"
> for d in "${dirs[@]}"; do echo "$d"; done
>
> # 4. Dans une fonction : local IFS
> split() { local IFS=","; echo $1; }
> ```

### 5. IFS et chaînes littérales

`IFS` ne s'applique que lors de l'**expansion** (variables, substitution de commande). Une chaîne **littérale** entre guillemets n'est pas découpée :

```bash
#!/usr/bin/env bash
IFS=":"
for element in "one:two:three"; do
  echo "${element} is a value"
done
```

Sortie :

```text
one:two:three is a value
```

Pas d'expansion de variable → `IFS` n'a **aucun effet**.

> Même sans guillemets, `for e in one:two:three` ne serait pas découpé : le découpage par `IFS` ne concerne que le **résultat d'une expansion** (`$var`, `$(cmd)`, `$((…))`), jamais le texte écrit directement dans le script.

### 6. Modifier IFS en mode interactif

```bash
$ IFS=","
$ val="apple,banana,cherry"
$ set -- ${val}
$ echo $1
apple
$ echo $2
banana
$ echo $3
cherry
```

`set -- ${val}` **remplace les paramètres positionnels** (`$1`, `$2`, `$3`…) du shell par les morceaux de `val`.

> `--` évite que des valeurs commençant par `-` soient prises pour des options de `set`.
> Penser à restaurer `IFS` ensuite (`IFS=$' \t\n'` ou `unset IFS`), sinon les commandes interactives suivantes peuvent se comporter bizarrement.

### 7. Restaurer IFS et cas de la chaîne vide

**1. Restaurer la valeur par défaut**

```bash
IFS=$' \t\n'
```

Fonctionne en Bash, Zsh et KornShell (les shells plus anciens peuvent nécessiter une autre syntaxe).

> Alternative portable : `unset IFS` → le shell se comporte alors **comme avec la valeur par défaut**.

**2. IFS vide**

```bash
IFS=''
```

Quand `IFS` est **vide**, **aucun découpage** n'a lieu : chaque expansion reste une **seule chaîne**.

> Différence importante :
> | Valeur | Effet |
> |||
> | `IFS=$' \t\n'` | Découpage par défaut |
> | `unset IFS` | Comme la valeur par défaut |
> | `IFS=''` | **Aucun** découpage |
>
> Application directe (vue dans la leçon *Input*) : `while IFS= read -r line` → `IFS` vide **pour `read` uniquement**, ce qui **préserve les espaces en début et fin de ligne**.

> Autres comportements utiles :
> - Le **premier caractère** de `IFS` sert à **joindre** les éléments avec `"$*"` :
>   ```bash
>   arr=(a b c)
>   (IFS=","; echo "${arr[*]}")    # a,b,c
>   ```
> - Séparateurs **blancs** (espace, tab, newline) : plusieurs à la suite comptent pour **un seul**. Séparateurs **non blancs** (`:`, `,`) : `a::b` donne un **champ vide** entre les deux `:`.

### À retenir

- `IFS` définit les caractères utilisés pour **découper** le résultat des expansions **non quotées**.
- Valeur par défaut : **espace, tabulation, retour à la ligne** (`$' \t\n'`).
- `$'…'` (ANSI-C) est nécessaire pour écrire `\t` et `\n` réels.
- `IFS` n'agit que sur les **expansions** (`$var`, `$(cmd)`) non quotées ; ni sur le texte littéral, ni sur `"$var"`.
- Changer `IFS` globalement est risqué : **sauvegarder/restaurer**, ou limiter à une commande (`IFS=: read …`), ou `local IFS` dans une fonction.
- Découper proprement : `IFS=":" read -ra arr <<< "$chaine"`.
- `set -- $var` remplace `$1`, `$2`… par les morceaux.
- Restaurer : `IFS=$' \t\n'` ou `unset IFS` ; `IFS=''` = aucun découpage (`while IFS= read -r line`).
- Le 1er caractère de `IFS` sert de séparateur pour `"$*"` / `"${arr[*]}"`.

### Liens utiles

- [GNU Bash – Word Splitting](https://www.gnu.org/software/bash/manual/html_node/Word-Splitting.html)
- [GNU Bash – ANSI-C Quoting](https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html)
- [GNU Bash – Bourne Shell Variables (IFS)](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Variables.html)
- [Wooledge – IFS](https://mywiki.wooledge.org/IFS)
- [POSIX – Shell Command Language (Field Splitting)](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
