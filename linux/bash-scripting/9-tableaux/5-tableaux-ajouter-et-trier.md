# Tableaux : ajouter et trier

### 1. Ajouter des éléments avec `+=`

L'opérateur `+=` ajoute **un ou plusieurs** éléments **à la fin** d'un tableau existant :

```bash
#!/usr/bin/env bash
declare -a array=("One" "Two" "Three")
echo "Original array: ${array[@]}"

# Ajouter trois éléments
array+=("Four" "Five" "Six")
echo "After appending: ${array[@]}"
```

`example2.sh` :

```bash
$ chmod +x example2.sh
$ ./example2.sh
Original array: One Two Three
After appending: One Two Three Four Five Six
```

> Les **parenthèses** sont indispensables : `array+="Four"` concatène au 1er élément (`OneFour`).

### 2. Trier un tableau avec `printf` et `sort`

Bash n'a **pas de tri intégré** pour les tableaux, mais on peut utiliser la commande Unix **`sort`**. Comme `sort` attend **un élément par ligne**, on utilise `printf "%s\n"` qui **réutilise le format** pour chaque argument :

```bash
# Exemple : trier des lettres
printf "%s\n" d a g h i f | sort
```

Sortie :

```plain
a
d
f
g
h
i
```

> `printf "%s\n" "d" "a" "g"` produit bien **une ligne par argument** : les guillemets n'empêchent rien. Ce qu'il ne faut **pas** faire, c'est mettre **tous** les éléments dans **une seule** chaîne (`printf "%s\n" "d a g"` → une seule ligne). Avec un tableau, il faut au contraire **toujours** quoter : `"${array[@]}"` (chaque élément reste un argument distinct, même s'il contient des espaces).

Même méthode pour un tableau de nombres :

```bash
#!/usr/bin/env bash
declare -a nums=(4 2 0 6 8 1)

# Un élément par ligne, puis tri
printf "%s\n" "${nums[@]}" | sort
```

`sort_numbers.sh` :

```bash
$ chmod +x sort_numbers.sh
$ ./sort_numbers.sh
0
1
2
4
6
8
```

> Par défaut, `sort` trie de façon **lexicographique** (comme du texte). Ça marche ici car tous les nombres ont **un seul chiffre**, mais :
> ```bash
> printf "%s\n" 10 2 33 4 | sort      # 10 2 33 4   ❌ ("1" < "2" < "3" < "4")
> printf "%s\n" 10 2 33 4 | sort -n   # 2 4 10 33   ✅ tri numérique
> ```
> Options utiles de `sort` :
> | Option | Effet |
> |---|---|
> | `-n` | Tri **numérique** |
> | `-r` | Ordre **inverse** |
> | `-u` | Supprime les **doublons** |
> | `-V` | Tri de **versions** (`1.9` < `1.10`) |
> | `-h` | Tailles « humaines » (`2K` < `1M`) |
> | `-f` | Ignore la casse |
> | `-k2` | Trie selon la **2ᵉ colonne** |

### 3. Afficher le tableau non trié et trié

Pour comparer, on capture la sortie triée dans un **nouveau tableau** via la substitution de commande :

```bash
#!/usr/bin/env bash
declare -a nums=(4 2 0 6 8 1)

# Afficher le tableau non trié
echo "Unsorted array: ${nums[@]}"

# Trier et capturer dans un nouveau tableau
sorted_nums=($(printf "%s\n" "${nums[@]}" | sort))

# Afficher le tableau trié
echo "Sorted array: ${sorted_nums[@]}"
```

`sort_ex2.sh` :

```bash
$ chmod +x sort_ex2.sh
$ ./sort_ex2.sh
Unsorted array: 4 2 0 6 8 1
Sorted array: 0 1 2 4 6 8
```

Le tableau d'origine reste **inchangé** ; le résultat trié est dans `sorted_nums`.

> `arr=($(…))` découpe la sortie sur **tous les espaces** et applique le **globbing** : un élément `"New York"` deviendrait deux éléments, et un `*` serait remplacé par les fichiers du dossier (ShellCheck SC2207). Méthode robuste :
> ```bash
> readarray -t sorted_nums < <(printf "%s\n" "${nums[@]}" | sort -n)
> # ou : mapfile -t sorted_nums < <(…)
> ```
> - `-t` retire le retour à la ligne de chaque élément ;
> - `< <(…)` (substitution de processus) évite le sous-shell d'un pipe, donc le tableau reste disponible.
>
> Exemple avec des espaces :
> ```bash
> cities=("Paris" "New York" "Berlin")
> readarray -t sorted < <(printf "%s\n" "${cities[@]}" | sort)
> printf "[%s]\n" "${sorted[@]}"     # [Berlin] [New York] [Paris]
> ```
> Trier **sur place** : `readarray -t nums < <(printf "%s\n" "${nums[@]}" | sort -n)`.

### 4. Synthèse

| Tâche | Commande |
|---|---|
| Ajouter des éléments | `array+=("item1" "item2")` |
| Trier un tableau (affichage) | `printf "%s\n" "${array[@]}" \| sort` |
| Capturer le résultat trié | `sorted=( $(printf "%s\n" "${array[@]}" \| sort) )` |
| Capturer (méthode robuste) | `readarray -t sorted < <(printf "%s\n" "${array[@]}" \| sort)` |

### À retenir

- `arr+=("a" "b")` ajoute des éléments en fin de tableau (parenthèses obligatoires).
- Pas de tri natif en Bash → `printf "%s\n" "${arr[@]}" | sort` (une ligne par élément).
- **Toujours** quoter `"${arr[@]}"` ; c'est mettre tous les éléments dans **une seule** chaîne qui empêche le découpage en lignes.
- `sort` est **lexicographique** par défaut → `sort -n` pour les nombres, `-r` inverse, `-u` sans doublons, `-V` versions.
- Récupérer le résultat dans un tableau : préférer `readarray -t arr < <(…)` à `arr=($(…))` (espaces et globs).
- Le tableau d'origine n'est pas modifié, sauf si on réaffecte le résultat dans la même variable.

### Liens utiles

- [GNU Bash – Arrays](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)
- [GNU Bash – Bash Builtins (`readarray` / `mapfile`)](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)
- [GNU Bash – Process Substitution `<(…)`](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)
- [man sort](https://man7.org/linux/man-pages/man1/sort.1.html)
- [ShellCheck SC2207 – préférer mapfile à `arr=($(…))`](https://www.shellcheck.net/wiki/SC2207)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
