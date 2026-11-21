# Introduction

**Awk** est un **langage spécialisé** (*domain-specific language*) pour le **traitement de texte**. Qu'il s'agisse de trouver une place libre dans une salle de cinéma ou d'analyser des statistiques système, sa syntaxe orientée **champs** et ses **variables intégrées** facilitent le **filtrage**, la **transformation** et la **mise en forme** de texte structuré.

### 1. Pourquoi utiliser awk ?

- Traite des données structurées par **lignes** (*records*) et **colonnes** (*fields*) ;
- Gère **automatiquement** les espacements irréguliers ;
- S'intègre naturellement dans les **pipelines** Unix ;
- Permet des **one-liners** concis comme des **scripts** complets.

### 2. Champs et enregistrements

Exemple : un plan de salle stocké dans `minimovies.txt`, où **`Y`** = place **occupée** et **`N`** = place **libre**. Awk considère :
- chaque **ligne** comme un **enregistrement** (*record*) ;
- chaque élément séparé par des espaces comme un **champ** (*field*).

| Notion | Awk |
|---|---|
| Colonnes → champs | `$1`, `$2`, `$3`… |
| Lignes → enregistrements | `NR` = compteur de lignes intégré |

### Extraire une place précise

1. Sélectionner la **3ᵉ colonne** (`$3`) de chaque ligne ;
2. Filtrer sur la **ligne n° 2** avec `NR`.

```bash
# Vérifier l'installation d'awk
$ awk --version
# Étape 1 : afficher le 3e champ de chaque ligne
$ awk '{ print $3 }' minimovies.txt
c
n
n
n
y

# Étape 2 : seulement la ligne 2
$ awk 'NR == 2 { print $3 }' minimovies.txt
n
```

(La 1ʳᵉ ligne du fichier est l'en-tête des colonnes, d'où `c`.)

> `NR` = numéro de l'enregistrement (ligne) courant ; les champs se notent `$1`, `$2`, etc.

> Autres variables essentielles :
> | Variable | Signification |
> |---|---|
> | `$0` | La **ligne entière** |
> | `NF` | **Nombre de champs** de la ligne |
> | `$NF` | **Dernier** champ |
> | `FS` / `-F` | Séparateur de champs en **entrée** |
> | `OFS` | Séparateur de champs en **sortie** |
> ```bash
> awk 'NR > 1 { print $1, $NF }' minimovies.txt       # 1er et dernier champ, sans l'en-tête
> awk -F: '{ print $1, $7 }' /etc/passwd              # séparateur ":" → utilisateur et shell
> ```

## 3. Awk, un langage spécialisé

Awk est plus qu'un simple filtre : c'est un **petit langage de programmation** dédié au texte, avec :
- des instructions **motif → action** (*pattern-action*) : `condition { action }` ;
- des **variables intégrées** (`NR`, `NF`, `FS`, `OFS`) ;
- des **structures de contrôle** (`if`, `while`, `for`).

Un **DSL** (*Domain-Specific Language*) est un langage conçu pour un **domaine précis**.

> Par défaut, awk utilise toute suite d'**espaces et de tabulations** comme séparateur de champs.

> Structure générale d'un programme awk :
> ```awk
> BEGIN   { … }   # exécuté UNE fois, avant de lire l'entrée
> motif   { … }   # exécuté pour chaque ligne qui correspond au motif
> END     { … }   # exécuté UNE fois, à la fin
> ```
> Sans motif → action sur **toutes** les lignes ; sans action → `print $0` (affiche la ligne).
> ```bash
> awk 'END { print NR }' fichier                    # nombre de lignes (≈ wc -l)
> awk '/ERROR/' app.log                             # lignes contenant ERROR (≈ grep)
> awk '{ s += $2 } END { print s }' data.txt        # somme de la 2e colonne
> ```

### 4. Espacements irréguliers

Même avec des espacements **incohérents** (plusieurs espaces, tabulations), awk découpe correctement les champs :

```bash
$ awk 'NR == 2 { print $3 }' minimovies.txt
n
```

awk produit avec très peu de code des programmes ou one-liners puissants pour analyser des **données textuelles volumineuses et complexes**.

> C'est un gros avantage sur `cut -d' '`, qui considère **chaque** espace comme séparateur (deux espaces = un champ vide). Avec le séparateur par défaut, awk ignore aussi les espaces **en début et fin** de ligne.

### 5. Awk dans les pipelines Unix

On combine awk avec d'autres commandes pour filtrer et formater à la volée :

```bash
$ cat minimovies.txt | awk '$1 == "2" { print $4 }'
n
```

(Ligne dont le 1er champ vaut `2` → afficher le 4ᵉ champ.)

> Plus direct sans `cat` : `awk '$1 == "2" { print $4 }' minimovies.txt`.

#### Cas d'usage courants

| Commande | Rôle | Exemple |
|---|---|---|
| `top` | Statistiques système | `top \| awk '{ print $2 }' \| head -5` |
| `ps` | Liste des processus | `ps aux \| awk '$3 > 50 {print $1, $3}'` |
| `df -h` | Occupation disque | `df -h \| awk '$5 > "80%"'` |

```bash
$ top | awk '{ print $2 }' | head -n 5
702
Avg:
996838
353T
41224173/79G
```

```bash
$ df -h
Filesystem            Size  Used Avail Use% Mounted on
C:/Program Files/Git   459G  182G  277G  40% /
G:                     15G     0   15G   0% /g
```

> Corrections sur ces exemples :
> - **`top`** est interactif : dans un pipeline, utiliser le **mode batch** : `top -b -n 1 | awk 'NR > 7 { print $1, $9 }'` (PID et %CPU sous Linux). La sortie montrée ci-dessus vient de macOS et n'est pas exploitable.
> - **`df -h | awk '$5 > "80%"'`** compare des **chaînes** : `"9%" > "80%"` est **vrai** et `"100%" > "80%"` est **faux**. Version correcte (conversion numérique, en-tête ignoré) :
>   ```bash
>   df -h | awk 'NR > 1 && $5+0 > 80 { print $6, $5 }'
>   ```
>   (`$5+0` transforme `"85%"` en `85`.)
> - **`ps aux | awk '$3 > 50'`** fonctionne (colonne `%CPU`), on peut ajouter `NR > 1` pour exclure l'en-tête.

> Exemples utiles en contexte Kubernetes :
> ```bash
> kubectl get pods -A | awk 'NR > 1 && $4 != "Running" { print $1, $2, $4 }'   # pods non Running
> kubectl get nodes --no-headers | awk '{ print $1 }'                            # noms des nœuds
> kubectl top pods --no-headers | sort -k2 -rn | awk 'NR <= 5'                   # top 5 CPU
> ```

### 6. Écrire des scripts awk complets

Au lieu de one-liners, on peut écrire de vrais **programmes awk** :

```awk
#!/usr/bin/awk -f
BEGIN {
    print "Hello, World!"
}
```

Rendre exécutable et lancer :

```bash
$ chmod +x hello.awk
$ ./hello.awk
Hello, World!
```

> Le chemin du shebang (`/usr/bin/awk`) doit correspondre à l'installation (`command -v awk`). L'option **`-f`** indique à awk de lire le programme depuis le fichier.

> Alternative sans shebang : `awk -f hello.awk fichier.txt`.
> Différentes implémentations existent : **gawk** (GNU, la plus complète), **mawk** (rapide, par défaut sur Debian/Ubuntu), **awk BSD** (macOS). Les fonctionnalités de base sont identiques.

### 7. Conclusion

Awk rend le traitement de texte intuitif en combinant **correspondance de motifs**, **manipulation de champs** et un **mini-langage de script**, en one-liner comme en script complet.

### À retenir

- awk lit l'entrée **ligne par ligne** (enregistrements) et découpe chaque ligne en **champs** (`$1`, `$2`…, `$0` = ligne entière, `$NF` = dernier).
- Variables clés : `NR` (n° de ligne), `NF` (nb de champs), `FS`/`-F` (séparateur d'entrée), `OFS` (sortie).
- Syntaxe : `motif { action }` ; `BEGIN { }` avant, `END { }` après.
- Séparateur par défaut = suites d'espaces/tabulations → gère les espacements irréguliers (contrairement à `cut`).
- `NR > 1` pour ignorer une ligne d'en-tête.
- Attention aux comparaisons de **chaînes** (`"80%"`) : convertir en nombre avec `$5+0`.
- `top` dans un pipeline → `top -b -n 1`.
- Scripts : shebang `#!/usr/bin/awk -f` ou `awk -f script.awk`.

### Liens utiles

- [GNU Awk User's Guide](https://www.gnu.org/software/gawk/manual/gawk.html)
- [GNU Awk – Built-in Variables (`NR`, `NF`, `FS`, `OFS`)](https://www.gnu.org/software/gawk/manual/html_node/Built_002din-Variables.html)
- [man awk (POSIX)](https://man7.org/linux/man-pages/man1/awk.1p.html)
- [Kubernetes – What is Kubernetes?](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)
- [Docker Hub](https://hub.docker.com/)
- [Terraform Registry](https://registry.terraform.io/)
