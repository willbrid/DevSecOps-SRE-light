# Tableaux : ajouter, remplacer, insérer

Ce contenu montre comment gérer efficacement les tableaux Bash : **ajouter**, **remplacer** et **insérer** des éléments. Les tableaux stockent des **listes ordonnées** de valeurs, ce qui rend les scripts plus puissants et flexibles.

### 1. Ajouter des éléments manuellement

On peut ajouter un élément en indiquant **directement le prochain index**. Ça fonctionne, mais il faut **connaître ou calculer** la taille actuelle du tableau :

```bash
#!/usr/bin/env bash

course_sections=("Introduction" "Coding Standards" "Refresher")
course_sections[3]="Streams"
echo "${course_sections[@]}"
```

```bash
$ ./declare7.sh
Introduction Coding Standards Refresher Streams
```

Même chose avec un tableau `servers` :

```bash
#!/usr/bin/env bash

declare -a servers=("server1" "server2" "server3")
servers[3]="server4"
echo "${servers[@]}"
```

```bash
$ ./adding.sh
server1 server2 server3 server4
```

> Compter les index à la main est **source d'erreurs** dans les gros scripts : un mauvais index **écrase** un élément existant. Mieux vaut laisser Bash calculer l'index.

### 2. Ajouter efficacement grâce à l'expansion de paramètres

`${#array[@]}` renvoie le **nombre d'éléments**. Comme les index commencent à 0, cette valeur correspond au **prochain index libre** :

```bash
#!/usr/bin/env bash

declare -a servers=("server1" "server2" "server3")
# Ajouter au prochain index libre
servers[${#servers[@]}]="server4"
echo "${servers[@]}"
```

```bash
$ ./sample2.sh
server1 server2 server3 server4
```

L'index est calculé automatiquement (3 éléments → index 3), ce qui évite d'écraser un élément par erreur.

> Limite : si le tableau est **creux** (après un `unset`), le nombre d'éléments ne correspond plus au prochain index libre :
> ```bash
> servers=("s1" "s2" "s3")
> unset 'servers[0]'                # reste : [1]=s2 [2]=s3 → 2 éléments
> servers[${#servers[@]}]="s4"      # écrit à l'index 2 → écrase s3 ❌
> ```
> **Méthode recommandée** : l'opérateur `+=`, qui ajoute toujours **après le dernier index** :
> ```bash
> servers+=("server4")              # ✅ simple et sûr
> servers+=("server5" "server6")    # plusieurs éléments d'un coup
> ```

### 3. Remplacer un élément à un index précis

Affecter une valeur à un index **existant** remplace sa valeur actuelle :

```bash
#!/usr/bin/env bash

declare -a servers=("server1" "server2" "server3")
servers[1]="serverx"
echo "${servers[@]}"
```

```bash
$ ./array-manipulation3.sh
server1 serverx server3
```

#### Attention : affectation scalaire vs tableau

Sans crochets, Bash traite l'affectation comme une **variable simple** et modifie l'**index 0** :

```bash
#!/usr/bin/env bash

declare -a servers=("server1" "server2" "server3")
servers="replaced value"
echo "${servers[@]}"
```

```bash
$ ./array-manipulation4.sh
replaced value server2 server3
```

> `servers="x"` équivaut à `servers[0]="x"` : les autres éléments **restent**. Pour remplacer tout le tableau : `servers=("x")`.

### 4. Insérer un élément au milieu

Pour insérer un élément à une position donnée **en décalant** les suivants, on reconstruit le tableau avec des **tranches** (*slicing*) :

```bash
#!/usr/bin/env bash

declare -a servers=("server1" "server2" "server3")

# Insérer "server1.5" à l'index 1
servers=(
  "${servers[@]:0:1}"
  "server1.5"
  "${servers[@]:1}"
)

echo "${servers[@]}"
```

```bash
$ ./array-manipulation2.sh
server1 server1.5 server2 server3
```

Décomposition :
- `"${servers[@]:0:1}"` → les éléments **avant** le point d'insertion (ici 1 élément à partir de l'index 0) ;
- `"server1.5"` → le **nouvel** élément ;
- `"${servers[@]:1}"` → les éléments **restants**, à partir de l'index 1.

> Les **guillemets** autour des tranches sont indispensables pour préserver les éléments contenant des espaces.

> Version générique avec une variable de position :
> ```bash
> pos=2
> new="server2.5"
> servers=( "${servers[@]:0:pos}" "$new" "${servers[@]:pos}" )
> ```
> Insérer **au début** : `servers=("server0" "${servers[@]}")`.
>
> Supprimer un élément **en décalant** les suivants (même principe) :
> ```bash
> servers=( "${servers[@]:0:1}" "${servers[@]:2}" )   # retire l'index 1
> ```
> (`unset 'servers[1]'` supprime aussi l'élément, mais **sans** renuméroter les index.)

### 5. Comparaison des méthodes

| Méthode | Description | Exemple |
|---|---|---|
| Index manuel | Affectation à un index explicite ; risque d'erreur | `servers[3]="server4"` |
| Expansion de paramètres | Ajout au prochain index libre (si tableau non creux) | `servers[${#servers[@]}]="server4"` |
| Tranches (*slicing*) | Insertion à n'importe quelle position | `servers=( "${servers[@]:0:i}" "new" "${servers[@]:i}" )` |
| Affectation directe | Remplace l'index 0 (souvent inattendu) | `servers="replaced value"` |
| **`+=` (recommandé pour ajouter)** | Ajout en fin de tableau, toujours sûr | `servers+=("server4")` |

### À retenir

- Ajouter en fin : **`arr+=("x")`** (méthode la plus sûre) ; `arr[${#arr[@]}]="x"` fonctionne seulement si le tableau n'est pas creux.
- Index manuel (`arr[3]="x"`) : risque d'**écraser** un élément existant.
- Remplacer : `arr[i]="nouveau"`.
- `arr="x"` (sans crochets ni parenthèses) = `arr[0]="x"` ; les autres éléments restent.
- Insérer à la position `i` : `arr=( "${arr[@]:0:i}" "new" "${arr[@]:i}" )` → les suivants sont **décalés**.
- Supprimer en décalant : `arr=( "${arr[@]:0:i}" "${arr[@]:i+1}" )` ; `unset 'arr[i]'` ne renumérote pas.
- Toujours mettre les expansions de tableau **entre guillemets**.

### Liens utiles

- [GNU Bash – Arrays](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)
- [GNU Bash – Shell Parameter Expansion (tranches `${arr[@]:début:longueur}`)](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [BashGuide – Arrays (Wooledge)](https://mywiki.wooledge.org/BashGuide/Arrays)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
- [Kubernetes – What is Kubernetes?](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)
