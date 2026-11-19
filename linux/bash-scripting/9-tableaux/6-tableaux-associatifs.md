# Tableaux associatifs

Les **tableaux associatifs** sont des structures de données qui utilisent des **clés nommées** (des chaînes) pour accéder directement à une valeur. Ce contenu montre comment les **déclarer**, y **accéder**, les **modifier** et les **parcourir**.

### 1. Tableau indexé vs tableau associatif

**Analogie** : un tableau indexé est une **commode à tiroirs numérotés** (à partir de 0) ; un tableau associatif est une commode à **tiroirs étiquetés**, qu'on ouvre **par leur nom**.

| Type | Indexation | Déclaration |
|---|---|---|
| Tableau indexé | Numérique, à partir de 0 | `declare -a arr=(...)` |
| Tableau associatif | Clés de type chaîne | `declare -A arr=(...)` |

#### Exemple : tableau indexé (les chaussettes)

```bash
#!/usr/bin/env bash
declare -a chest_drawer=("shirts" "sports clothing" "socks" "jeans")
echo "${chest_drawer[2]}"
```

```bash
$ ./socks.sh
socks
```

Il faut **savoir** que les chaussettes sont dans le tiroir n° 2.

### 2. Vérifier la version de Bash

Les tableaux associatifs nécessitent **Bash 4.0+** :

```bash
$ echo $BASH_VERSION
5.2.15(1)-release
```

> Avant Bash 4.0, les tableaux associatifs ne fonctionnent pas. Attention notamment à **macOS**, livré avec **Bash 3.2** (installer un Bash récent via Homebrew).

> Vérification dans un script :
> ```bash
> (( BASH_VERSINFO[0] >= 4 )) || { echo "Bash 4+ requis" >&2; exit 1; }
> ```

### 3. Déclarer un tableau associatif et y accéder

`declare -A` définit un tableau associatif. On récupère les chaussettes **par leur nom** :

```bash
#!/usr/bin/env bash
declare -A chest_drawer=(
  ["shirts"]="T-Shirts and polo shirts"
  ["sports"]="All sorts of Sports Clothing here"
  ["socks"]="Formal and everyday socks"
  ["jeans"]="Jeans, and some casual dress shorts"
)

echo "${chest_drawer["socks"]}"
```

```bash
$ ./associative-v1.sh
Formal and everyday socks
```

> **`declare -A` est obligatoire**. Sans lui, Bash crée un tableau **indexé** et évalue la clé comme une **expression arithmétique** : `socks` (variable inexistante) vaut `0`, et toutes les clés écrasent l'**index 0** :
> ```bash
> drawer[socks]="chaussettes"
> drawer[jeans]="jeans"
> declare -p drawer        # declare -a drawer=([0]="jeans")  ❌
> ```

### 4. Analogie : contacts d'urgence

Numéros abrégés par service :

```bash
#!/usr/bin/env bash
declare -A emergency_contacts=(
  ["Fire Department"]="555-0001"
  ["Police Department"]="555-0002"
  ["Hospital"]="555-0003"
)

echo "${emergency_contacts["Fire Department"]}"
```

```bash
$ ./emergency.sh
555-0001
```

Les clés peuvent contenir des **espaces** (à condition d'être entre guillemets).

### 5. Le concept clé / valeur

Un tableau associatif associe des **clés** (identifiants) à des **valeurs** (les données manipulées).

> Chaque clé est **unique** et **sensible à la casse** : `"Mark"` ≠ `"mark"`.

### 6. Exemple : adresses e-mail

```bash
#!/usr/bin/env bash
declare -A email_addresses=(
  ["Mark"]="mark@email.com"
  ["Kriti"]="kriti@email.com"
  ["Feng"]="feng@email.com"
)

echo "${email_addresses["Mark"]}"
```

```bash
$ ./email-1.sh
mark@email.com
```

### 7. Ajouter des éléments

On affecte une valeur à une **nouvelle clé** entre crochets :

```bash
#!/usr/bin/env bash
declare -A email_addresses=(
  ["Mark"]="mark@email.com"
  ["Kriti"]="kriti@email.com"
  ["Feng"]="feng@email.com"
)

# Ajouter des contacts
email_addresses["Andy"]="andy@email.com"
email_addresses["Rajasekar"]="rajasekar@email.com"

echo "${email_addresses[@]}"
```

```bash
$ ./email-3.sh
mark@email.com rajasekar@email.com ...
```

> Les tableaux associatifs sont **non ordonnés** : l'ordre d'affichage/de parcours n'est **pas** l'ordre d'insertion et peut varier.

> Ajout de plusieurs paires d'un coup (Bash 4+) :
> ```bash
> email_addresses+=( ["Lea"]="lea@email.com" ["Tom"]="tom@email.com" )
> ```

### 8. Remplacer une valeur

Réaffecter une clé **existante** met à jour sa valeur (une clé ne peut pas exister deux fois) :

```bash
#!/usr/bin/env bash
declare -A email_addresses=(
  ["Mark"]="mark@email.com"
  ["Kriti"]="kriti@email.com"
  ["Feng"]="feng@email.com"
  ["Rajasekar"]="rajasekar@email.com"
)

echo "Before: ${email_addresses[@]}"
email_addresses["Feng"]="feng2@email.com"
echo "After:  ${email_addresses[@]}"
```

```bash
$ ./email-4.sh
Before: kriti@email.com ...
After:  kriti@email.com ... feng2@email.com
```

### 9. Supprimer des éléments

`unset` supprime une clé ou le tableau entier :

```bash
#!/usr/bin/env bash
declare -A email_addresses=( ... )

# Supprimer un élément
unset email_addresses["Kriti"]

# Supprimer tout le tableau
unset email_addresses
```

> Bonnes pratiques :
> ```bash
> unset 'email_addresses[Kriti]'   # quoter pour éviter l'interprétation comme glob
> email_addresses=()               # vider en conservant la variable (et l'attribut -A)
> ```
> Après `unset email_addresses`, l'attribut `-A` est perdu : il faut refaire `declare -A` avant de réutiliser la variable.

### 10. Lister les clés et les valeurs

- **Clés** : `${!array[@]}`
- **Valeurs** : `${array[@]}`

```bash
#!/usr/bin/env bash
declare -A email_addresses=( ... )

echo "Keys:   ${!email_addresses[@]}"
echo "Values: ${email_addresses[@]}"
```

> Autres opérations utiles :
> ```bash
> echo "${#email_addresses[@]}"                 # nombre de paires
>
> # Tester si une clé existe (Bash 4.3+)
> if [[ -v email_addresses["Mark"] ]]; then echo "Mark existe"; fi
> # Alternative compatible : ${map[key]+défini}
> [[ ${email_addresses["Mark"]+x} ]] && echo "Mark existe"
>
> declare -p email_addresses                    # afficher tout le contenu (débogage)
> ```
> Tester `[[ -n ${map[key]} ]]` ne distingue pas une clé **absente** d'une clé **vide**.

### 11. Parcourir avec une boucle `for`

On boucle sur les **clés**, puis on accède à chaque valeur :

```bash
#!/usr/bin/env bash
declare -A email_addresses=( ... )

for key in "${!email_addresses[@]}"; do
  echo "$key's email is ${email_addresses[$key]}"
done
```

```bash
$ ./email-8.sh
Kriti's email is kriti@email.com
...
```

> Mettre `"${!email_addresses[@]}"` **entre guillemets** pour gérer correctement les clés contenant des espaces (ex. `"Fire Department"`).

> Parcourir dans l'**ordre alphabétique** des clés :
> ```bash
> while IFS= read -r key; do
>     echo "$key → ${email_addresses[$key]}"
> done < <(printf '%s\n' "${!email_addresses[@]}" | sort)
> ```

> Exemple concret (contexte infra) :
> ```bash
> declare -A ports=( ["http"]=80 ["https"]=443 ["ssh"]=22 )
> for svc in "${!ports[@]}"; do
>     echo "Service $svc → port ${ports[$svc]}"
> done
> ```

### À retenir

- Tableau associatif = paires **clé → valeur**, clés de type **chaîne**, **uniques** et **sensibles à la casse**.
- **Bash 4.0+** requis (macOS : Bash 3.2 par défaut).
- **`declare -A` obligatoire** ; sans lui, les clés sont traitées comme des index numériques (tout tombe sur `[0]`).
- Accès : `${map[clé]}` ; ajout/modification : `map[clé]=valeur` ; ajout multiple : `map+=([k1]=v1 [k2]=v2)`.
- **Non ordonné** : trier les clés avec `sort` si l'ordre compte.
- `${!map[@]}` = clés ; `${map[@]}` = valeurs ; `${#map[@]}` = nombre de paires.
- Supprimer : `unset 'map[clé]'` ; vider : `map=()` ; supprimer la variable : `unset map`.
- Tester une clé : `[[ -v map[clé] ]]` (4.3+) ou `${map[clé]+x}`.
- Boucle : `for k in "${!map[@]}"; do … "${map[$k]}"; done` (guillemets obligatoires).

### Liens utiles

- [GNU Bash – Arrays (indexés et associatifs)](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)
- [GNU Bash – Bash Conditional Expressions (`-v`)](https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html)
- [BashGuide – Associative Arrays (Wooledge)](https://mywiki.wooledge.org/BashGuide/Arrays#Associative_Arrays)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
