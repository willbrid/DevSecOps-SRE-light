# sed substitute

La commande **`s`** (*substitute*) de sed est l'outil de **recherche-remplacement** par excellence sur des flux de texte : mise à jour de fichiers de configuration, refactorisation automatisée, nettoyage de logs…

Par défaut, sed lit **stdin** ou un fichier et écrit sur **stdout**. Option **`-i`** pour modifier le fichier sur place.

### 1. Syntaxe de base

```bash
sed 's/old_string/new_string/' input-file
```

| Élément | Rôle |
|---|---|
| `s` | Commande de substitution |
| `old_string` | Motif recherché (**expression régulière** acceptée) |
| `new_string` | Texte de remplacement |
| `/` | Délimiteurs (peuvent être **n'importe quel caractère**) |

Par défaut, seule la **première** occurrence de **chaque ligne** est remplacée.

> Délimiteur alternatif, pratique pour les chemins :
> ```bash
> sed 's|/var/log|/data/logs|' config.conf     # au lieu de s/\/var\/log/\/data\/logs/
> ```

### 2. Référence rapide

| Commande | Description | Exemple |
|---|---|---|
| `s/original/replacement/` | Remplace la 1ʳᵉ occurrence de chaque ligne | `sed 's/foo/bar/' file.txt` |
| `-n '/pattern/p'` | Affiche uniquement les lignes correspondantes | `sed -n '/Error/p' /var/log/syslog` |
| `/pattern/d` | Supprime les lignes correspondantes | `sed '/^#/d' config.conf` |

### 3. Exemple pratique : modifier un salaire

Avec `employees.txt`, passer le salaire d'**Enrique Rivera** de `65000` à `85000` :

```bash
sed 's/65000/85000/' employees.txt
```

Remplace la 1ʳᵉ occurrence de `65000` sur **chaque ligne** et affiche le résultat sur stdout (le fichier n'est pas modifié).

> Cette commande s'applique à **toutes** les lignes : si un autre employé gagnait 65000 (ou si `65000` apparaissait dans un autre champ), il serait aussi modifié. Version ciblée :
> ```bash
> sed '/\<Enrique\>/ s/|65000$/|85000/' employees.txt
> ```
> - `/\<Enrique\>/` : uniquement la ligne d'Enrique ;
> - `|65000$` : `65000` en **dernier champ** (`$` = fin de ligne).

### 4. Portée de la substitution

#### Remplacement global (`g`)

Le drapeau **`g`** remplace **toutes** les occurrences de chaque ligne :

```bash
sed 's/\bIT\b/Information Technology/g' employees.txt
```

#### Première occurrence uniquement

Sans `g`, seule la **première** occurrence est remplacée :

```bash
sed 's/\bIT\b/Information Technology/' employees.txt
```

> `\b` = **limite de mot** (GNU) : `IT` seul, mais pas le « it » de « Sm**it**h ».
> Exemple sur la ligne d'Andy (`6|Andy|Luscomb|IT|IT Manager|…`) :
> - sans `g` → `…|Information Technology|IT Manager|…`
> - avec `g` → `…|Information Technology|Information Technology Manager|…`

### 5. Cibler la n-ième occurrence

Un **nombre** comme drapeau remplace uniquement la **n-ième** occurrence de chaque ligne :

```bash
sed 's/\bIT\b/Information Technology/2' employees.txt
```

Remplace seulement le **2ᵉ** `IT` de chaque ligne (ligne d'Andy : `…|IT|Information Technology Manager|…`).

> Combinable avec `g` (GNU) : `s/x/y/2g` remplace à partir de la **2ᵉ** occurrence jusqu'à la fin de la ligne.

### 6. Adressage de lignes

Limiter la substitution à certaines lignes ou plages.

**Une ligne** (ligne 7) :

```bash
sed '7 s/\bHR\b/Human Resources/' employees.txt
```

**Une plage** (lignes 1 à 3) :

```bash
sed '1,3 s/Finance/Taxes/' employees.txt
```

**Une autre ligne** (ligne 5) :

```bash
sed '5 s/\bSales\b/Transactions/' employees.txt
```

> L'espace entre l'adresse et `s` est facultatif (`7s/…/` fonctionne aussi).
> Adresse par **motif** (souvent plus robuste qu'un numéro de ligne) :
> ```bash
> sed '/\<Feng\>/ s/Sales/Transactions/g' employees.txt
> ```
> Remarque : sur la ligne 5, `\bSales\b` sans `g` ne change que le **service** (`Sales`), pas le poste (`Sales Manager`).

### 7. Édition sur place (`-i`)

Modifier **directement** le fichier :

```bash
sed -i 's/\bcompany\b/KodeKloud/g' employees.txt
```

Remplace toutes les occurrences de `company` dans `employees.txt` (ici, le domaine des e-mails : `@company.com` → `@willbrid.com`, car `@` et `.` sont des limites de mot).

> Avec `-i`, les modifications sont **irréversibles**, sauf avec une sauvegarde :
> ```bash
> sed -i.bak 's/old/new/g' file.txt
> ```
> Crée `file.txt.bak` avant l'édition (forme portable GNU/BSD).

### 8. Insérer du texte avec `i`

La commande **`i`** insère une ligne **avant** la ligne courante, ou avant la ligne indiquée :

```bash
sed '1iID|Name|FirstName|LastName|Job|Department|Email|Salary' employees.txt
```

Sortie :

```text
ID|Name|FirstName|LastName|Job|Department|Email|Salary
1|Kriti|Shreshtha|Finance|Financial Analyst|kriti.shreshtha@KodeKloud.com|60000
2|Rajasekar|Vasudevan|Finance|Senior Accountant|rajasekar.vasudevan@KodeKloud.com|75000
...
```

> L'en-tête de l'exemple ne correspond pas aux données (8 colonnes pour 7 champs, ordre différent). En-tête cohérent :
> ```bash
> sed '1i ID|FirstName|LastName|Department|Job|Email|Salary' employees.txt
> ```

Sans texte après `i`, sed renvoie une erreur :

```bash
$ sed 'i' employees.txt
sed: -e expression #1, char 1: expected \ after 'a', 'c' or 'i'
```

> Commandes voisines :
> | Commande | Effet | Exemple |
> |---|---|---|
> | `i` | Insère **avant** la ligne | `sed '1i Titre' f` |
> | `a` | Ajoute **après** la ligne | `sed '$a # fin du fichier' f` |
> | `c` | **Remplace** toute la ligne | `sed '/^PORT=/c PORT=8080' app.conf` |
>
> `sed '1i texte'` (sur une ligne) est une syntaxe **GNU** ; la forme POSIX/BSD est `1i\` suivi d'un retour à la ligne puis du texte.

### 9. Aller plus loin avec `s`

> Fonctionnalités très utiles :
> ```bash
> # & = le texte trouvé
> sed 's/[0-9]\{5,\}$/€&/' employees.txt          # 60000 → €60000
>
> # Groupes et références arrière (-E = regex étendues)
> sed -E 's/^([0-9]+)\|([^|]+)\|([^|]+)/\1|\3 \2/' employees.txt   # échange prénom et nom
>
> # Insensible à la casse (GNU)
> sed 's/manager/Lead/gI' employees.txt
>
> # N'afficher que les lignes modifiées
> sed -n 's/Finance/Taxes/p' employees.txt
>
> # Plusieurs substitutions
> sed -e 's/HR/Human Resources/' -e 's/IT/Tech/' employees.txt
> ```
> Exemple CKA : changer une image dans un manifeste :
> ```bash
> sed -i 's|image: nginx:.*|image: nginx:1.27|' deploy.yaml
> ```

### 10. Conclusion

- `s/old/new/` pour une substitution simple ;
- drapeaux **`g`** (toutes) et **numérique** (n-ième occurrence) ;
- **adressage** de lignes et de plages pour des modifications ciblées ;
- **`-i`** (avec sauvegarde `.bak`) pour l'édition sur place ;
- **`i`** pour insérer de nouvelles lignes.

### À retenir

- `s/motif/remplacement/` : 1ʳᵉ occurrence par ligne ; `g` = toutes ; `2` = la 2ᵉ ; `2g` = à partir de la 2ᵉ (GNU).
- Délimiteur libre (`s|a|b|`) pour éviter d'échapper les `/`.
- Sans adresse, la substitution s'applique à **toutes les lignes** → cibler avec `N`, `M,N` ou `/motif/`.
- `\b` / `\<…\>` = limites de mot (GNU) ; `$` = fin de ligne pour viser le dernier champ.
- `&` = texte trouvé ; `\1`, `\2` = groupes (avec `-E` : `( )` sans antislash) ; `I` = insensible à la casse.
- `-n 's/…/…/p'` affiche seulement les lignes modifiées.
- `-i.bak` = édition sur place avec sauvegarde ; tester d'abord sans `-i`.
- `i` insère avant, `a` ajoute après, `c` remplace la ligne.

### Liens utiles

- [GNU sed Manual](https://www.gnu.org/software/sed/manual/sed.html)
- [GNU sed – The `s` Command (drapeaux g, N, p, I, &, \1)](https://www.gnu.org/software/sed/manual/html_node/The-_0022s_0022-Command.html)
- [GNU sed – Other Commands (`i`, `a`, `c`)](https://www.gnu.org/software/sed/manual/html_node/Other-Commands.html)
- [GNU sed – Regular Expressions](https://www.gnu.org/software/sed/manual/html_node/Regular-Expressions.html)
- [Devhints – sed cheat sheet](https://devhints.io/sed)
