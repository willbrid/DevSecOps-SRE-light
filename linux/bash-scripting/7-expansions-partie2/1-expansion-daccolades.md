# Expansion d'accolades

L'**expansion d'accolades** génère des chaînes ou des arguments en évaluant des expressions placées entre `{}`. Contrairement aux **globs**, qui **sélectionnent** des fichiers existants, les accolades **créent du nouveau texte**, et ce **avant** toutes les autres expansions (chemins, paramètres…).

Comme elles sont traitées **en premier**, elles permettent de générer en une seule commande des listes de noms de fichiers, de paramètres ou d'autres chaînes.

### 1. Plages de base

Les plages **alphabétiques** et **numériques** génèrent des séquences avec très peu de syntaxe :

```bash
# Séquence alphabétique : a, b, c
touch sample{a..c}
ls
# Séquence numérique : 1, 2, 3
touch sample{1..3}
ls
# Séquence numérique décroissante
echo {3..1}
# → 3 2 1
```

| Type | Syntaxe | Résultat |
||||
| Plage alphabétique | `{a..z}` | a b c … z |
| Plage numérique | `{1..5}` | 1 2 3 4 5 |

> Résultat des deux `touch` : `sample1 sample2 sample3 samplea sampleb samplec`.
> Les plages décroissantes fonctionnent aussi pour les lettres : `{e..a}` → `e d c b a`.

### 2. Exemple : identifiants par département

Créer des identifiants pour le Marketing (**MKT**), les Ventes (**SL**) et le Développement (**DEV**), chacun avec un suffixe de **001 à 004** :

```bash
touch {MKT,SL,DEV}{001..004}
ls
# → DEV001 DEV002 DEV003 DEV004 MKT001 MKT002 MKT003 MKT004 SL001 SL002 SL003 SL004
```

- `{MKT,SL,DEV}` → chaque code de département ;
- `{001..004}` → quatre suffixes numériques ;
- combinés → **12 identifiants** (3 × 4) en une seule commande.

> Les **zéros initiaux** sont conservés (`001`, pas `1`) car le premier nombre de la plage est écrit avec des zéros (Bash 4.0+).
> Ici on crée des **fichiers** ; pour créer de vrais comptes utilisateurs, on combinerait avec une boucle :
> ```bash
> for u in {MKT,SL,DEV}{001..004}; do
>     sudo useradd "$u"
> done
> ```

### 3. Liste séparée par des virgules

Les **virgules** permettent des listes arbitraires ; chaque élément remplace les accolades :

```bash
echo file{alpha,beta,gamma}.txt
# → filealpha.txt filebeta.txt filegamma.txt
```

> Pratiques courantes :
> ```bash
> mkdir -p projet/{src,docs,tests}
> cp config.yaml{,.bak}          # = cp config.yaml config.yaml.bak (élément vide)
> mv rapport.{txt,md}            # = mv rapport.txt rapport.md
> ```

### 4. Plage numérique

Générer rapidement une série de noms numérotés :

```bash
echo file{1..5}.txt
# → file1.txt file2.txt file3.txt file4.txt file5.txt
```

### 5. Accolades combinées (produit cartésien)

Plusieurs accolades à la suite produisent **toutes les combinaisons** :

```bash
echo {a,b}{1,2,3}
# → a1 a2 a3 b1 b2 b3
```

Chaque élément du premier ensemble (`a`, `b`) est associé à chaque élément du second (`1`, `2`, `3`).

> Précision : ce sont des accolades **juxtaposées**. Une **imbrication** place des accolades **à l'intérieur** d'autres :
> ```bash
> echo {a,b{1,2},c}
> # → a b1 b2 c
> mkdir -p app/{src/{models,views},tests}
> # → app/src/models  app/src/views  app/tests
> ```

### 6. Plage avec pas (Bash 4.0+)

Un **pas** permet de sauter des éléments : `{début..fin..pas}`.

> Nécessite **Bash 4.0 ou plus**. Vérifier avec `bash --version`.

```bash
echo file{1..10..2}.txt
# → file1.txt file3.txt file5.txt file7.txt file9.txt
```

> Autres exemples : `{0..100..25}` → `0 25 50 75 100` ; `{a..z..5}` → `a f k p u z` ; `{10..1..3}` → `10 7 4 1`.

### 7. Préfixe et suffixe

Entourer l'expansion de texte fixe :

```bash
echo pre-{A..C}-post
# → pre-A-post pre-B-post pre-C-post
```

### 8. Utilisation dans les scripts

Les accolades s'intègrent naturellement aux boucles, conditions et fonctions :

```bash
#!/usr/bin/env bash
for i in {1..3}; do
  touch "report_${i}.log"
done
ls
# → report_1.log report_2.log report_3.log
```

> Piège majeur : les accolades étant développées **avant** les variables, une plage avec variable **ne fonctionne pas** :
> ```bash
> n=3
> echo {1..$n}          # → {1..3}   (texte littéral, pas de séquence)
> ```
> Alternatives :
> ```bash
> for ((i=1; i<=n; i++)); do echo "$i"; done
> for i in $(seq 1 "$n"); do echo "$i"; done
> ```

> Autres règles :
> - **Pas d'expansion entre guillemets** : `echo "{a,b}"` → `{a,b}` ; mais on peut quoter une partie : `echo "pre-"{a,b}` → `pre-a pre-b`.
> - **Pas d'espace** dans les accolades : `{a, b}` n'est pas développé.
> - Il faut **au moins une virgule ou une plage** : `{a}` reste `{a}`.
> - Fonctionne même si **aucun fichier** n'existe (contrairement aux globs).

### 9. Synthèse et bonnes pratiques

- Les accolades sont développées **avant** toutes les autres expansions → idéal pour **générer des arguments**.
- Plages numériques pour des **séries de fichiers** ou des ressources versionnées.
- Accolades combinées/imbriquées pour des données **multi-dimensionnelles**.
- Les plages avec **pas** nécessitent **Bash 4.0+**.

Maîtriser l'expansion d'accolades réduit la saisie répétitive, automatise les opérations en masse et rend les scripts plus concis et lisibles.

### À retenir

- `{a,b,c}` = **liste** ; `{1..5}`, `{a..e}` = **plage** ; `{1..10..2}` = plage avec **pas** (Bash 4+).
- Les accolades **génèrent** du texte (même si rien n'existe) ; les globs **sélectionnent** des fichiers existants.
- Développées **en premier** → `{1..$n}` ne marche pas : utiliser `for ((…))` ou `seq`.
- Juxtaposition = **produit cartésien** : `{a,b}{1,2}` → `a1 a2 b1 b2`.
- Imbrication possible : `{a,b{1,2}}` → `a b1 b2`.
- Zéros conservés : `{001..004}`.
- Préfixe/suffixe : `pre-{A..C}-post` ; raccourcis utiles : `cp f{,.bak}`, `mkdir -p p/{src,docs}`.
- Ni guillemets autour, ni espaces dedans ; au moins une virgule ou `..`.
- Non POSIX : spécifique à Bash/Zsh/Ksh.

### Liens utiles

- [GNU Bash – Brace Expansion](https://www.gnu.org/software/bash/manual/html_node/Brace-Expansion.html)
- [GNU Bash – Shell Expansions](https://www.gnu.org/software/bash/manual/html_node/Shell-Expansions.html)
- [Advanced Bash-Scripting Guide – Brace Expansion](https://tldp.org/LDP/abs/html/brace.html)
