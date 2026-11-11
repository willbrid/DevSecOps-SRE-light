# Introduction

| Symbole | Rôle (rappel) |
|||
| `#` | Supprime le plus court préfixe |
| `##` | Supprime le plus long préfixe |
| `%` | Supprime le plus court suffixe |
| `%%` | Supprime le plus long suffixe |
| `*` | Joker : n'importe quelle suite de caractères |

Les **globs** (aussi appelés *wildcards* ou motifs d'expansion de chemins) sont différents : ils agissent directement sur les **noms de fichiers** et les **chaînes** dans le shell, pas sur la valeur d'une variable.

> Précision : la frontière est plus fine. Les motifs utilisés dans `${var#motif}` **sont** des globs (mêmes jokers `*`, `?`, `[…]`). Ce qui change, c'est **sur quoi** ils s'appliquent :
> - **globbing de fichiers** : `ls *.txt` → comparé aux **fichiers du répertoire** ;
> - **expansion de paramètres** : `${var%.*}` → comparé à la **valeur de la variable** ;
> - **comparaison de chaînes** : `[[ $var == *.txt ]]` et `case` → comparé à une **chaîne**.

### 1. Qu'est-ce qu'un glob ?

Un glob permet de faire correspondre des noms de fichiers/répertoires (ou des chaînes) avec une **syntaxe concise**. Plus simple que les **expressions régulières** (pas de *lookahead*, pas de groupes nommés…), mais suffisant pour la plupart des besoins courants.

| Motif | Correspond à | Exemple |
||||
| `*` | Zéro ou plusieurs caractères | `*.txt` |
| `?` | Exactement **un** caractère | `file?.sh` |
| `[abc]` | Exactement **un** caractère parmi a, b, c | `report[12].pdf` |

> Compléments :
> | Motif | Correspond à | Exemple |
> ||||
> | `[a-z]` / `[0-9]` | Un caractère dans la **plage** | `log[0-9].txt` |
> | `[!abc]` ou `[^abc]` | Un caractère **hors** de l'ensemble | `file[!0-9].sh` |
> | `[[:digit:]]`, `[[:alpha:]]`, `[[:upper:]]` | Classes de caractères POSIX | `*[[:digit:]].log` |
>
> ```bash
> ls *.txt            # tous les .txt
> ls file?.sh         # file1.sh, fileA.sh… (pas file10.sh)
> ls report[12].pdf   # report1.pdf, report2.pdf
> ls log[0-9].txt     # log0.txt à log9.txt
> ```

### 2. Globs ou expressions régulières ?

| Critère | Globs | Expressions régulières |
||||
| Simplicité | Très faciles à écrire | Plus complexes (syntaxe avancée) |
| Usage courant | Sélection de **fichiers** | **Analyse de texte**, validation |
| Constructions avancées | Non supportées | Lookahead, groupes nommés, etc. |

> Les mêmes symboles n'ont **pas le même sens** :
> | Symbole | Glob | Regex |
> ||||
> | `*` | n'importe quelle suite de caractères | répète **le caractère précédent** 0 fois ou plus |
> | `?` | exactement un caractère | rend le caractère précédent **optionnel** |
> | `.` | un point **littéral** | **n'importe quel** caractère |
>
> Équivalences : glob `*.txt` ≈ regex `^.*\.txt$`.
> Où on les rencontre :
> - **globs** : `ls`, `cp`, `rm`, `for f in *.log`, `case`, `[[ == ]]`, `find -name` ;
> - **regex** : `grep`, `sed`, `awk`, `[[ =~ ]]`.

### 3. Méthode d'apprentissage

Pour maîtriser les globs :

1. **Rassembler des exemples**
   Lister un large éventail de noms de fichiers ou de chaînes à faire correspondre.
2. **Identifier les points communs**
   Regrouper les éléments similaires pour repérer les préfixes, suffixes ou ensembles de caractères partagés.
3. **Choisir le bon glob**
   `*`, `?` ou une expression entre crochets `[ ]`.
4. **Tester avec des commandes shell**
   Vérifier avec `ls` ou `echo` que le glob sélectionne bien les fichiers voulus :

```bash
# Tous les fichiers .log commençant par "app"
ls app*.log
```

Si le résultat correspond à ce qui est attendu, le glob est correct.

> `echo` est idéal pour tester **sans risque** avant une commande destructrice :
> ```bash
> echo rm app*.log    # affiche la commande qui serait exécutée
> rm app*.log         # puis l'exécuter pour de vrai
> ```

> Comportements à connaître :
> - **C'est le shell** qui développe le glob **avant** d'appeler la commande : `ls` reçoit déjà la liste des fichiers.
> - `*` **n'inclut pas** les fichiers cachés (commençant par `.`) → `.*` ou `shopt -s dotglob`.
> - Si **aucun** fichier ne correspond, Bash laisse le motif **littéral** (`app*.log`) → `shopt -s nullglob` pour obtenir une liste vide.
> - Entre **guillemets**, un glob n'est **pas** développé : `ls "*.log"` cherche un fichier nommé `*.log`.

### À retenir

- **Glob** = motif simple pour sélectionner des fichiers ou comparer des chaînes : `*`, `?`, `[…]`.
- `*` = 0 ou plusieurs caractères ; `?` = exactement 1 ; `[abc]` = 1 parmi l'ensemble ; `[a-z]` plage ; `[!abc]` exclusion.
- Les motifs de `${var#…}`, `case` et `[[ == ]]` utilisent la **même syntaxe** que les globs de fichiers.
- Globs ≠ regex : `*`, `?` et `.` n'ont **pas le même sens**. Regex → `grep`, `sed`, `[[ =~ ]]`.
- Le shell développe le glob **avant** d'exécuter la commande.
- Pas de fichiers cachés avec `*` (sauf `dotglob`) ; motif laissé littéral si aucun résultat (sauf `nullglob`) ; pas d'expansion entre guillemets.
- Méthode : exemples → points communs → choix du glob → **test avec `ls`/`echo`** avant d'agir.

### Liens utiles

- [GNU Bash – Filename Expansion](https://www.gnu.org/software/bash/manual/html_node/Filename-Expansion.html)
- [GNU Bash – Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
- [man 7 glob](https://man7.org/linux/man-pages/man7/glob.7.html)
- [Expressions régulières (Wikipédia)](https://en.wikipedia.org/wiki/Regular_expression)
- [ShellCheck – analyse automatique de scripts](https://www.shellcheck.net/)
