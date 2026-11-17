# Tableaux indexés

Les **tableaux** Bash permettent de stocker **plusieurs valeurs** dans une collection **indexée**, avec un **accès direct** à n'importe quel élément (premier, milieu, dernier) via son **index**.

Les tableaux Bash sont **indexés à partir de 0** : le 1er élément est à l'index `0`, le 2ᵉ à l'index `1`, etc.

### 1. Pourquoi utiliser des tableaux ?

- **Accès direct** à un élément → moins de boucles et de conditions ;
- **Scripts plus clairs** pour gérer des listes de serveurs, de fichiers, de configurations ;
- **Plus efficace** qu'une liste dans une chaîne qu'il faut découper manuellement.

Comparaison avec une itération sur une chaîne :

```bash
#!/usr/bin/env bash

servers="server1 server2 server3"
for server in ${servers}; do
  if [[ "$server" == "server2" ]]; then
    server="${server}.willbrid.com"
  fi
  echo "$server"
done
```

Sortie :

```bash
server1
server2.willbrid.com
server3
```

On examine **chaque** élément. Un tableau évite ce détour.

> Équivalent avec un tableau :
> ```bash
> servers=("server1" "server2" "server3")
> servers[1]="${servers[1]}.willbrid.com"   # accès direct à l'index 1
> printf '%s\n' "${servers[@]}"
> ```

### 2. Déclarer un tableau

#### 2.1 Affectation par index

```bash
#!/usr/bin/env bash

course_sections[0]="Introduction"
course_sections[1]="Coding Standards"
course_sections[2]="Refresher"

echo "${course_sections[0]}"   # Introduction
echo "${course_sections[1]}"   # Coding Standards
echo "${course_sections[2]}"   # Refresher
```

> Les index n'ont pas besoin d'être **consécutifs** (tableau « creux ») : `arr[0]=a; arr[10]=b` → 2 éléments seulement.

#### 2.2 Initialisation en une ligne

```bash
#!/usr/bin/env bash

declare -a course_sections=("Introduction" "Coding Standards" "Refresher")
echo "${course_sections[@]}"   # Introduction Coding Standards Refresher
```

`declare -a` est **facultatif** :

```bash
course_sections=("Intro" "Middle" "End")
```

> Pas de virgules ni d'espaces autour du `=` : les éléments sont séparés par des **espaces**, et ceux qui contiennent des espaces doivent être **entre guillemets**.

### 3. Accéder aux éléments

| Opération | Syntaxe | Exemple |
|---|---|---|
| Un élément | `${array[index]}` | `${course_sections[1]}` → Coding Standards |
| Tous les éléments | `${array[@]}` | tous les éléments |
| Nombre d'éléments | `${#array[@]}` | nombre d'éléments |
| Tous les index (clés) | `${!array[@]}` | liste des index valides |
| Tranche (*slice*) | `${array[@]:début:longueur}` | sous-ensemble |

#### Tous les éléments

```bash
#!/usr/bin/env bash

sections=("Intro" "Body" "Conclusion")
echo "${sections[@]}"  # Intro Body Conclusion
```

> Exemples complémentaires :
> ```bash
> sections=("Intro" "Body" "Conclusion")
> echo "${#sections[@]}"        # 3
> echo "${!sections[@]}"        # 0 1 2
> echo "${sections[@]:1:2}"     # Body Conclusion   (à partir de l'index 1, 2 éléments)
> echo "${sections[-1]}"        # Conclusion        (dernier élément, Bash 4.3+)
> echo "${#sections[1]}"        # 4                 (longueur de "Body")
> echo "$sections"              # Intro             ⚠️ sans index = élément 0 seulement
> ```
> Les accolades sont **obligatoires** : `$sections[1]` affiche `Intro[1]`.

### 4. Guillemets : préserver les espaces

Sans guillemets, l'expansion est **redécoupée** sur les espaces :

```bash
#!/usr/bin/env bash

sections=("Coding Standards" "Best Practices")

# Sans guillemets
for s in ${sections[@]}; do
  echo "$s"
done

# Avec guillemets
for s in "${sections[@]}"; do
  echo "$s"
done
```

Sortie (complète) :

```plaintext
Coding
Standards
Best
Practices

Coding Standards
Best Practices
```

- Sans guillemets → **4** itérations (chaque mot séparé) ❌
- Avec guillemets → **2** itérations (éléments intacts) ✅

> Toujours **quoter** `"${array[@]}"` dans les boucles et les commandes pour préserver les éléments contenant des espaces.

> `"${arr[@]}"` vs `"${arr[*]}"` : même logique que `"$@"` / `"$*"` → `[@]` garde les éléments séparés, `[*]` les fusionne en une chaîne (avec le 1er caractère de `IFS`).

### 5. Modifier un tableau

#### Ajouter un élément

```bash
#!/usr/bin/env bash

sections=("Intro" "Methods")
sections+=("Conclusion")
echo "${sections[@]}"  # Intro Methods Conclusion
```

> Ne pas oublier les **parenthèses** : `sections+="Conclusion"` **concatène** au 1er élément (`IntroConclusion`).

#### Écraser le tableau

La leçon indique qu'affecter une chaîne remplace l'index `0` tout en conservant le type tableau :

```bash
#!/usr/bin/env bash

sections=("A" "B" "C")
sections="NewSection"
echo "${sections[@]}"  # NewSection
```

> Correction : `sections="NewSection"` ne remplace **que l'index 0**, les autres éléments **restent** :
> ```bash
> sections=("A" "B" "C")
> sections="NewSection"
> echo "${sections[@]}"   # NewSection B C
> ```
> Pour **vraiment** remplacer tout le tableau :
> ```bash
> sections=("NewSection")        # nouveau tableau d'un seul élément
> ```

> Autres modifications :
> ```bash
> unset 'sections[1]'            # supprime l'élément d'index 1 (les index ne sont PAS renumérotés)
> unset sections                 # supprime tout le tableau
> sections=("${sections[@]}")    # « recompacte » les index après des unset
>
> # Remplir un tableau depuis un fichier ou une commande (une ligne = un élément)
> readarray -t lines < servers.txt
> mapfile -t pods < <(kubectl get pods -o name)
> ```

### À retenir

- Tableau = collection **indexée à partir de 0** ; accès direct `${arr[i]}` (accolades obligatoires).
- Déclaration : `arr=("a" "b c" "d")` ou `arr[0]="a"` ; `declare -a` facultatif.
- `${arr[@]}` tous les éléments ; `${#arr[@]}` le nombre ; `${!arr[@]}` les index ; `${arr[@]:1:2}` une tranche ; `${arr[-1]}` le dernier.
- `$arr` sans index = **élément 0** uniquement.
- Toujours **`"${arr[@]}"`** entre guillemets pour préserver les espaces.
- Ajouter : `arr+=("x")` (parenthèses !).
- `arr="x"` ne remplace que l'index 0 ; pour tout remplacer : `arr=("x")`.
- `unset 'arr[i]'` supprime un élément sans renuméroter ; `readarray -t` / `mapfile -t` pour charger des lignes.

### Liens utiles

- [GNU Bash – Arrays](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)
- [GNU Bash – Bash Builtins (`readarray` / `mapfile`)](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)
- [BashGuide – Arrays (Wooledge)](https://mywiki.wooledge.org/BashGuide/Arrays)
- [Kubernetes – Documentation](https://kubernetes.io/docs/)
- [Docker Hub](https://hub.docker.com/)
- [Terraform Registry](https://registry.terraform.io/)
