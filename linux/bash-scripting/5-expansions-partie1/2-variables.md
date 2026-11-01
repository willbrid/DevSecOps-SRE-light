# Variables

L'**expansion de variables** permet de **récupérer et manipuler** la valeur d'une variable Bash avec la syntaxe `$`. C'est indispensable pour l'automatisation, le traitement de texte et la flexibilité des scripts.

### 1. Introduction

Une variable peut contenir un nom de fichier, un chemin, un nombre, une chaîne… L'expansion de paramètres permet de :
- **accéder** au contenu d'une variable ;
- effectuer des **opérations sur les chaînes** ;
- fournir des **valeurs par défaut** ;
- calculer des **longueurs**, etc.

```bash
filename="file.txt"
number=100
string="Hello World"
command_output=$(ls)

dir_path="/path/to/directory"
greeting="Hello"
name="User"
echo "$greeting, $name! Welcome to $dir_path"
```

> **Pas d'espace autour du `=`** : `name="User"` ✅ ; `name = "User"` ❌ (Bash cherche une commande `name`).

### 2. Expansion de base

Quand le shell voit `$nom_variable`, il la remplace par sa valeur :

```bash
name="John Doe"
echo $name
# Sortie :
# John Doe
```

Les **accolades** délimitent clairement le nom de la variable :

```bash
name="John Doe"
echo "Hello, ${name}"
# Sortie :
# Hello, John Doe
```

Les noms de variables sont **sensibles à la casse** et peuvent contenir **lettres, chiffres et underscores** :

```bash
# Invalide :
# Valide :
name_user="John Doe"
```

> Exemples valides et invalides :
> ```bash
> name_user="ok"     # ✅
> _tmp="ok"          # ✅ peut commencer par _
> user2="ok"         # ✅ chiffre autorisé, mais pas en 1re position
> 2user="ko"         # ❌ commence par un chiffre
> user-name="ko"     # ❌ tiret interdit
> user name="ko"     # ❌ espace interdit
> ```
> Convention : **MAJUSCULES** pour les variables d'environnement/constantes (`PATH`, `HOME`), **minuscules** pour les variables locales du script (évite d'écraser une variable système par erreur).

### 3. Utiliser les accolades

Les accolades `{}` servent à **lever les ambiguïtés** et donnent accès aux **fonctions avancées** d'expansion.

#### Éviter les ambiguïtés

Sans accolades, le texte collé à la variable est pris comme faisant partie du nom :

```bash
#!/usr/bin/env bash
height=170

# Faux : le shell cherche une variable 'heightcm'
echo "Your height is: $heightcm"

# Correct : les accolades isolent 'height'
echo "Your height is: ${height}cm"
# Sortie :
# Your height is: 170cm
```

> Le premier `echo` affiche `Your height is: ` (vide), sans erreur : une variable non définie vaut une chaîne vide. Pour détecter ce genre de faute de frappe : `set -u`.

#### Valeurs par défaut

Fournir une valeur de secours si la variable est **non définie ou vide** :

```bash
#!/usr/bin/env bash
echo "Hello, ${name:-Unknown}"
# Si 'name' n'est pas définie :
# Sortie :
# Hello, Unknown
```

> `${var:-default}` permet de référencer **sans risque** une variable qui peut ne pas exister.

> Variantes :
> | Syntaxe | Effet |
> |||
> | `${var:-def}` | renvoie `def` si `var` vide **ou** non définie (sans modifier `var`) |
> | `${var-def}` | renvoie `def` seulement si `var` **non définie** (vide = conservé) |
> | `${var:=def}` | renvoie `def` **et l'assigne** à `var` |
> | `${var:?msg}` | affiche `msg` sur stderr et **quitte** le script si vide/non définie |
> | `${var:+alt}` | renvoie `alt` si `var` **est** définie et non vide |

### 4. Opérateurs d'expansion de paramètres

| Type | Syntaxe | Description |
||||
| Valeur par défaut | `${var:-default}` | `default` si `var` est non définie ou vide |
| Extraction de sous-chaîne | `${var:offset:length}` | Extrait `length` caractères à partir de `offset` |
| Remplacement | `${var/motif/remplacement}` | Remplace la **première** occurrence de `motif` |
| Longueur | `${#var}` | Nombre de caractères de la valeur |

### 5. Manipulation de chaînes

#### Extraction de sous-chaîne

À partir d'une **position** (qui commence à **0**) et d'une **longueur** :

```bash
#!/usr/bin/env bash
name="John Doe"
echo "Hello, ${name:0:4}"
# Sortie :
# Hello, John
```

> Autres formes :
> ```bash
> echo "${name:5}"      # Doe       → de la position 5 jusqu'à la fin
> echo "${name: -3}"    # Doe       → 3 derniers caractères (espace obligatoire avant -)
> echo "${name:0:-4}"   # John      → tout sauf les 4 derniers (Bash 4.2+)
> ```
> `${name:-3}` (sans espace) est interprété comme une **valeur par défaut**, pas comme un offset négatif.

#### Remplacement de sous-chaîne

Remplace la **première** occurrence d'un motif :

```bash
#!/usr/bin/env bash
path="/home/user/file.txt"
echo "${path/file/data}"
# Sortie :
# /home/user/data.txt
```

> Variantes :
> ```bash
> text="a-b-c-d"
> echo "${text/-/_}"     # a_b-c-d   → 1re occurrence
> echo "${text//-/_}"    # a_b_c_d   → toutes les occurrences
> echo "${text/#a/X}"    # X-b-c-d   → seulement au début
> echo "${text/%d/X}"    # a-b-c-X   → seulement à la fin
> echo "${text//-}"      # abcd      → supprimer (remplacement vide)
> ```
> Changement de casse (Bash 4+) : `${var^^}` majuscules, `${var,,}` minuscules, `${var^}` première lettre en majuscule.

### 6. Longueur d'une variable

```bash
#!/usr/bin/env bash
name="John Doe"
echo "${#name}"
# Sortie :
# 8
```

(L'espace compte comme un caractère.)

### 7. Guillemets et découpage en mots

Sans guillemets, une expansion subit le **découpage en mots** (*word splitting*) sur les espaces. Avec guillemets, la valeur reste **un seul bloc**.

```bash
#!/usr/bin/env bash
readonly SERVERS="server1 server2 server3"

# Itérer sur chaque nom d'hôte (sans guillemets) :
for server in $SERVERS; do
  echo "${server}.kodekloud.com"
done
# Sortie :
# server1.kodekloud.com
# server2.kodekloud.com
# server3.kodekloud.com

# Avec guillemets : une seule chaîne
for server in "$SERVERS"; do
  echo "${server}.kodekloud.com"
done
# Sortie :
# server1 server2 server3.kodekloud.com
```

> Toujours mettre les expansions entre guillemets, **sauf** si on veut explicitement le découpage en mots.

> Meilleure pratique pour une liste : un **tableau**, qui évite de dépendre du découpage (et des globs) :
> ```bash
> servers=("server1" "server2" "server3")
> for server in "${servers[@]}"; do
>   echo "${server}.kodekloud.com"
> done
> ```
> Exemple de piège sans guillemets :
> ```bash
> file="mon rapport.txt"
> rm $file      # ❌ tente de supprimer "mon" ET "rapport.txt"
> rm "$file"    # ✅
> ```

### À retenir

- `$var` ou `${var}` → remplacé par la valeur ; **pas d'espace** autour de `=` à l'affectation.
- Noms : lettres, chiffres, `_`, **pas de chiffre en premier**, sensibles à la casse.
- Accolades obligatoires si du texte est collé : `${height}cm`.
- Valeur par défaut : `${var:-def}` ; assigner : `${var:=def}` ; erreur si absente : `${var:?msg}`.
- Sous-chaîne : `${var:offset:longueur}` (offset depuis 0) ; fin : `${var: -3}` (espace !).
- Remplacement : `${var/a/b}` (1re), `${var//a/b}` (toutes).
- Longueur : `${#var}`.
- **Guillemets par défaut** (`"$var"`) ; sans guillemets → découpage en mots + globs. Pour une liste, préférer un **tableau** `"${arr[@]}"`.
- `set -u` pour détecter les variables non définies (fautes de frappe).

### Liens utiles

- [GNU Bash – Shell Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [Advanced Bash-Scripting Guide – Quoting Variables](https://tldp.org/LDP/abs/html/quotingvar.html)
