# Tableaux : supprimer des éléments

Deux cas de suppression courants :
- supprimer **un élément précis** d'un tableau ;
- supprimer **tous** les éléments (vider/supprimer le tableau).

Les deux se font avec la commande intégrée **`unset`** :
- `unset array[index]` → supprime **un** élément ;
- `unset array` → supprime **toute** la variable tableau.

### 1. Supprimer un élément précis

Supprimer l'élément d'index 1 (le 2ᵉ élément) :

```bash
unset servers[1]
```

Exemple : supprimer l'index `1` puis afficher les éléments restants :

```bash
#!/usr/bin/env bash
declare -a servers=("server1" "server2" "server3")

unset servers[1]

# Afficher les éléments restants
echo "${servers[@]}"
```

```bash
$ ./removing.sh
server1 server3
```

Fonctionnement :
- `unset servers[1]` supprime l'élément d'**index 1**. Bash **ne renumérote pas** les éléments restants : le tableau devient **creux** (*sparse*).
- `"${servers[@]}"` affiche les valeurs des index **existants**, dans l'ordre croissant : on a l'impression que les éléments ont été décalés, mais ce n'est **pas** le cas.

> Bonne pratique : **quoter** l'argument d'`unset` :
> ```bash
> unset 'servers[1]'
> ```
> Sans guillemets, `servers[1]` est aussi un **motif glob** (« `servers` suivi du caractère `1` ») : si un fichier nommé `servers1` existe dans le répertoire courant, le shell remplace l'argument par ce nom de fichier et `unset` ne supprime pas l'élément voulu.

### 2. Accès par index après `unset`

Après suppression de l'index `1`, cet index renvoie une **chaîne vide**, tandis que les autres gardent leur valeur :

```bash
#!/usr/bin/env bash
declare -a servers=("server1" "server2" "server3")

unset servers[1]

# Accès à des index précis
echo "servers[0]: ${servers[0]}"
echo "servers[1]: ${servers[1]}"  # vide (supprimé)
echo "servers[2]: ${servers[2]}"  # contient toujours server3

# Expansion complète
echo "All elements: ${servers[@]}"
```

```bash
$ ./removing_indices.sh
servers[0]: server1
servers[1]:
servers[2]: server3
All elements: server1 server3
```

> Pour **voir les trous** et vérifier l'état réel du tableau :
> ```bash
> echo "${!servers[@]}"    # 0 2        → index existants (le 1 a disparu)
> echo "${#servers[@]}"    # 2          → nombre d'éléments
> declare -p servers       # declare -a servers=([0]="server1" [2]="server3")
> ```
> Conséquence : après un `unset`, `${#servers[@]}` (2) ne correspond plus au prochain index libre (3) → utiliser `servers+=("x")` pour ajouter.

> **Renuméroter** (supprimer les trous) :
> ```bash
> servers=("${servers[@]}")
> declare -p servers       # declare -a servers=([0]="server1" [1]="server3")
> ```

### 3. Supprimer tout le tableau

Supprimer la variable tableau et **tous** ses éléments :

```bash
unset servers
```

Exemple :

```bash
#!/usr/bin/env bash
declare -a servers=("server1" "server2" "server3")

unset servers

# N'affiche rien : le tableau n'existe plus
echo "All elements after unset: ${servers[@]}"
```

```bash
$ ./removing_all.sh
All elements after unset:
```

> Différence entre **supprimer** et **vider** :
> ```bash
> unset servers     # la variable n'existe plus (attributs perdus, ex. declare -A)
> servers=()        # la variable existe toujours, mais vide (0 élément)
> ```
> Avec `set -u`, `"${servers[@]}"` sur une variable **inexistante** peut provoquer une erreur (selon la version de Bash) ; un tableau vidé avec `()` est plus sûr.

### 4. Référence rapide

| Opération | Commande | Effet |
|---|---|---|
| Supprimer un élément | `unset 'array[index]'` | Supprime uniquement cet index ; le tableau peut devenir creux |
| Supprimer tout le tableau | `unset array` | Supprime la variable et tous ses éléments |
| Afficher tous les éléments | `echo "${array[@]}"` | Valeurs existantes, dans l'ordre croissant des index |

> Compléments utiles :
> | Opération | Commande |
> |---|---|
> | Vider sans supprimer la variable | `array=()` |
> | Supprimer le **dernier** élément | `unset 'array[-1]'` (Bash 4.3+) |
> | Voir les index existants | `echo "${!array[@]}"` |
> | Renuméroter | `array=("${array[@]}")` |
> | Supprimer en décalant (index `i`) | `array=("${array[@]:0:i}" "${array[@]:i+1}")` |
> | Supprimer une clé d'un tableau associatif | `unset 'map[cle]'` |
>
> Supprimer **par valeur** (toutes les occurrences) :
> ```bash
> for i in "${!servers[@]}"; do
>     [[ ${servers[i]} == "server2" ]] && unset 'servers[i]'
> done
> servers=("${servers[@]}")    # renuméroter ensuite
> ```

### 5. Synthèse

- `unset array[index]` supprime **un** élément ; les index restants sont **conservés** (pas de renumérotation automatique).
- `unset array` supprime **toute** la variable tableau.
- Inspecter des index précis (`${array[1]}`) permet de repérer les emplacements supprimés.
- `"${array[@]}"` affiche les valeurs existantes dans l'ordre et **masque** les trous.

Insérer et supprimer des données sont les **opérations de base** sur un tableau.

### À retenir

- `unset 'arr[i]'` → supprime l'élément `i` **sans renuméroter** (tableau creux) ; toujours **quoter** (risque de glob).
- `unset arr` → supprime la variable ; `arr=()` → la vide en la conservant.
- `"${arr[@]}"` cache les trous ; `${!arr[@]}` montre les index réels ; `declare -p arr` montre tout.
- Après un `unset`, `${#arr[@]}` ≠ prochain index → ajouter avec `arr+=("x")`.
- Renuméroter : `arr=("${arr[@]}")`.
- Dernier élément : `unset 'arr[-1]'` (Bash 4.3+).
- Supprimer par valeur : boucle sur `"${!arr[@]}"` + `unset`, puis renuméroter.

### Liens utiles

- [GNU Bash – Arrays (unset, tableaux creux)](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)
- [GNU Bash – Bourne Shell Builtins (`unset`)](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html)
- [Advanced Bash-Scripting Guide – Arrays](https://tldp.org/LDP/abs/html/arrays.html)
- [BashGuide – Arrays (Wooledge)](https://mywiki.wooledge.org/BashGuide/Arrays)
