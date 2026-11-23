# sed find

sed permet de **rechercher**, **afficher** ou **supprimer** des lignes selon un **motif**, directement dans des fichiers. Proche de `grep`, mais sed combine **recherche** et **édition** en une seule étape.

Fichier d'exemple `employees.txt`, au format `ID|Prénom|Nom|Service|Poste|Email|Salaire`.

### 1. Syntaxe de base de la recherche

sed a besoin d'un **motif** (adresse) **et** d'une **action** (commande). Forme minimale :

```bash
sed '/pattern/' file
```

```bash
$ sed '/Manager/' employees.txt
# (Pas de commande : comportement selon la version de sed)
```

> Précision : avec GNU sed, c'est une **erreur** : `sed: -e expression #1, char 9: missing command`. Un motif seul n'est qu'une **adresse** ; il faut toujours une commande (`p`, `d`, `s`…).

Pour afficher **uniquement** les lignes correspondantes : **`-n`** + **`p`** :

```bash
sed -n '/Manager/p' employees.txt
```

| Élément | Rôle |
|---|---|
| `-n` | Désactive l'affichage automatique |
| `/Manager/` | Recherche « Manager » |
| `p` | Affiche les lignes trouvées |

```bash
$ sed -n '/Manager/p' employees.txt
5|Feng|Lin|Sales|Sales Manager|feng.lin@company.com|90000
6|Andy|Luscomb|IT|IT Manager|andy.luscomb@company.com|95000
7|Mark|Crocker|HR|HR Manager|mark.crocker@company.com|85000
8|Jing|Ma|Engineering|Engineering Manager|jing.ma@company.com|100000
```

> Équivalent : `grep 'Manager' employees.txt`.

La recherche est **sensible à la casse** : `manager` (minuscule) ne donne rien :

```bash
$ sed -n '/manager/p' employees.txt
# Aucun résultat
```

> Pour ignorer la casse, GNU sed propose le modificateur **`I`** :
> ```bash
> sed -n '/manager/Ip' employees.txt    # trouve "Manager"
> ```

### 2. Rechercher une sous-chaîne

Un **fragment** suffit :

```bash
$ sed -n '/Ma/p' employees.txt
4|Enrique|Rivera|Marketing|Marketing Specialist|enrique.rivera@company.com|65000
5|Feng|Lin|Sales|Sales Manager|feng.lin@company.com|90000
6|Andy|Luscomb|IT|IT Manager|andy.luscomb@company.com|95000
7|Mark|Crocker|HR|HR Manager|mark.crocker@company.com|85000
8|Jing|Ma|Engineering|Engineering Manager|jing.ma@company.com|100000
```

`Ma` correspond à « **Ma**rketing », « **Ma**nager », « **Ma**rk » et au nom « **Ma** ».

### 3. Mots entiers avec les limites de mot

`\<` (début de mot) et `\>` (fin de mot) pour ne trouver que le **mot entier** :

```bash
sed -n '/\<Ma\>/p' employees.txt
```

```bash
$ sed -n '/\<Ma\>/p' employees.txt
8|Jing|Ma|Engineering|Engineering Manager|jing.ma@company.com|100000
```

| Élément | Rôle |
|---|---|
| `sed` | Éditeur de flux |
| `-n` | Pas d'affichage automatique |
| `/\<Ma\>/` | Le mot exact « Ma » |
| `p` | Affiche la ligne |

> `\<`, `\>` (et `\b`) sont des **extensions GNU** ; elles n'existent pas en BSD sed (macOS). Équivalent avec grep : `grep -w 'Ma'`.
> Ici, `|` sert de séparateur : il compte comme une **limite de mot**, d'où la correspondance sur `|Ma|`.

### 4. Combiner plusieurs motifs

`-e` permet d'enchaîner **plusieurs scripts** :

```bash
sed -n \
    -e '/\<Manager\>/p' \
    -e '/\<IT\>/p' \
    employees.txt
```

Résultat indiqué par la leçon :

```bash
$ sed -n -e '/\<Manager\>/p' -e '/\<IT\>/p' employees.txt
3|Debbie|Miller|IT|Software Developer|debbie.miller@company.com|80000
5|Feng|Lin|Sales|Sales Manager|feng.lin@company.com|90000
6|Andy|Luscomb|IT|IT Manager|andy.luscomb@company.com|95000
7|Mark|Crocker|HR|HR Manager|mark.crocker@company.com|85000
8|Jing|Ma|Engineering|Engineering Manager|jing.ma@company.com|100000
```

> Correction : chaque script `-e` est appliqué **à chaque ligne**. La ligne 6 (Andy, service **IT** et poste **IT Manager**) correspond **aux deux** motifs → elle est affichée **deux fois** :
> ```text
> 3|Debbie|…|IT|…
> 5|Feng|…|Sales Manager|…
> 6|Andy|…|IT Manager|…
> 6|Andy|…|IT Manager|…     ← doublon
> 7|Mark|…
> 8|Jing|…
> ```
> Pour un « OU » sans doublon, **un seul motif** avec alternative :
> ```bash
> sed -n '/\<Manager\>\|\<IT\>/p' employees.txt       # GNU, syntaxe de base
> sed -En '/\<(Manager|IT)\>/p' employees.txt         # GNU, regex étendues (-E)
> ```
> (Équivalent grep : `grep -wE 'Manager|IT' employees.txt`.)

### 5. Supprimer les lignes trouvées

On remplace `p` par **`d`** :

Supprimer l'enregistrement d'Enrique :

```bash
sed -e '/\<Enrique\>/d' employees.txt
```

Supprimer toutes les lignes contenant le mot entier « Ma » :

```bash
$ sed -e '/\<Ma\>/d' employees.txt
1|Kriti|Shreshtha|Finance|Financial Analyst|kriti.shreshtha@company.com|60000
2|Rajasekar|Vasudevan|Finance|Senior Accountant|rajasekar.vasudevan@company.com|75000
3|Debbie|Miller|IT|Software Developer|debbie.miller@company.com|80000
4|Enrique|Rivera|Marketing|Marketing Specialist|enrique.rivera@company.com|65000
5|Feng|Lin|Sales|Sales Manager|feng.lin@company.com|90000
6|Andy|Luscomb|IT|IT Manager|andy.luscomb@company.com|95000
7|Mark|Crocker|HR|HR Manager|mark.crocker@company.com|85000
```

(Sans `-n` : toutes les autres lignes sont affichées normalement ; seule la ligne de Jing disparaît.)

> Avec `d`, plusieurs `-e` ne posent **pas** de problème de doublon : une ligne supprimée n'est plus traitée par les scripts suivants.
> Inverse (≈ `grep -v`) : `sed '/motif/!d'` garde uniquement les lignes qui correspondent.

### 6. Modifier le fichier sur place avec `-i`

Appliquer les suppressions **directement dans le fichier** :

```bash
$ sed -i \
    -e '/\<Manager\>/d' \
    -e '/\<IT\>/d' \
    employees.txt

$ cat employees.txt
1|Kriti|Shreshtha|Finance|Financial Analyst|kriti.shreshtha@company.com|60000
2|Rajasekar|Vasudevan|Finance|Senior Accountant|rajasekar.vasudevan@company.com|75000
4|Enrique|Rivera|Marketing|Marketing Specialist|enrique.rivera@company.com|65000
```

Les managers (5, 6, 7, 8) et le service IT (3, 6) ont été supprimés.

> `-i` **écrase** le fichier source. Toujours garder une sauvegarde ou utiliser un gestionnaire de versions. Version sûre et portable : `sed -i.bak …` ; et tester d'abord **sans** `-i`.

### 7. Référence rapide des options

| Option | Description | Exemple |
|---|---|---|
| `-n` | Désactive l'affichage automatique | `sed -n '/pattern/p' file` |
| `-i` | Édition sur place | `sed -i 's/foo/bar/' file` |
| `-e` | Ajoute un script (plusieurs possibles) | `sed -e '/A/p' -e '/B/p' file` |

> Complément :
> | Option / syntaxe | Description |
> |---|---|
> | `-E` | Regex **étendues** (`\|`, `( )`, `+`, `?` sans antislash) |
> | `/motif/I` | Recherche insensible à la casse (GNU) |
> | `/motif/!` | Négation (lignes qui **ne** correspondent **pas**) |
> | `-i.bak` | Édition sur place avec sauvegarde |

Points couverts : ✅ recherche avec `p` et `d` ✅ `-e` pour plusieurs scripts ✅ rappel de `-n` et `-i`.

### À retenir

- Un motif `/regex/` est une **adresse** : il faut toujours une **commande** (`p`, `d`, `s`…), sinon erreur.
- `sed -n '/motif/p'` ≈ `grep motif` ; `sed '/motif/d'` ≈ `grep -v motif`.
- Recherche **sensible à la casse** ; `I` pour l'ignorer (GNU).
- `/Ma/` = sous-chaîne ; `/\<Ma\>/` = mot entier (GNU) ≈ `grep -w`.
- Plusieurs `-e … p` → une ligne qui correspond à plusieurs motifs est affichée **plusieurs fois** ; utiliser un motif unique `\(A\|B\)` ou `-E '(A|B)'`.
- Avec `d`, plusieurs `-e` cumulent les suppressions sans doublon.
- `-i` modifie le fichier : tester sans, puis `-i.bak`.

### Liens utiles

- [GNU sed Manual](https://www.gnu.org/software/sed/manual/sed.html)
- [GNU sed – Regexp Addresses (`/regex/`, `I`)](https://www.gnu.org/software/sed/manual/html_node/Regexp-Addresses.html)
- [GNU sed – Regular Expressions (`\<`, `\>`, `\|`, `-E`)](https://www.gnu.org/software/sed/manual/html_node/sed-regular-expressions.html)
- [Regular-Expressions.info](https://www.regular-expressions.info/)
- [Baeldung – grep vs sed](https://www.baeldung.com/linux/grep-sed)
