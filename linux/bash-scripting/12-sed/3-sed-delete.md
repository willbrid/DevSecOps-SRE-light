# sed delete

sed (*Stream Editor*) transforme du texte dans un pipeline. Ce guide montre comment **supprimer des lignes** avec la commande **`d`** (*delete*) : sans toucher au fichier, une ligne précise, une plage de lignes, puis directement **dans le fichier** (`-i`).

### 1. La commande `d`

La forme la plus simple :

```bash
sed 'd' employees.txt
```

sed lit chaque ligne et la **supprime** → **aucune sortie**.

Syntaxe générale :

```text
sed [OPTIONS] SCRIPT [INPUT-FILE...]
```

- **SCRIPT** : commandes d'édition, entre apostrophes (ici `'d'`) ;
- **INPUT-FILE** : un ou plusieurs fichiers (par défaut : stdin).

> Mettre le script entre **apostrophes** (`'d'`) pour que le shell le transmette littéralement.

> Fonctionnement : `d` **vide le pattern space** et passe directement à la ligne suivante, **sans** l'affichage automatique de fin de cycle. Les commandes placées après `d` ne sont donc pas exécutées pour cette ligne.

### 2. Suppression non destructive

Par défaut, sed écrit le résultat sur **stdout** et **ne modifie pas** le fichier d'origine. Supprimer la **ligne 2** :

```bash
sed '2d' employees.txt
```

```text
1|Kriti|Shreshtha|Finance|Financial Analyst|kriti.shreshtha@company.com|60000
3|Debbie|Miller|IT|Software Developer|debbie.miller@company.com|80000
4|Enrique|Rivera|Marketing|Marketing Specialist|enrique.rivera@company.com|65000
5|Feng|Lin|Sales|Sales Manager|feng.lin@company.com|90000
6|Andy|Luscomb|IT|IT Manager|andy.luscomb@company.com|95000
7|Mark|Crocker|HR|HR Manager|mark.crocker@company.com|85000
8|Jing|Ma|Engineering|Engineering Manager|jing.ma@company.com|100000
```

Le fichier source reste **intact** :

```bash
cat employees.txt
```

> Pour conserver le résultat **sans** toucher à l'original : `sed '2d' employees.txt > employees_new.txt`.
> Jamais `sed '2d' f.txt > f.txt` : le shell **vide** `f.txt` avant que sed ne le lise.

### 3. Supprimer une ligne précise

Supprimer uniquement la **6ᵉ ligne** :

```bash
sed '6d' employees.txt
```

Toutes les lignes s'affichent sauf la 6ᵉ (Andy).

> Cas pratiques :
> ```bash
> sed '1d' data.csv          # supprimer l'en-tête
> sed '$d' fichier           # supprimer la dernière ligne
> df -h | sed '1d'           # sortie de df sans en-tête
> ```

### 4. Supprimer une plage de lignes

Une **paire d'adresses** séparées par une virgule supprime un **bloc** :

```bash
sed '3,5d' employees.txt
```

Supprime les lignes **3 à 5** (Debbie, Enrique, Feng).

> Précision : avec GNU sed, `5,3d` n'est pas sans effet. Si la 2ᵉ adresse est **inférieure** à la 1ʳᵉ, seule la **ligne 5** est concernée → `5,3d` supprime **uniquement la ligne 5**. Le résultat n'est donc pas une erreur, mais probablement pas ce qu'on voulait.

> Autres formes d'adresses avec `d` :
> ```bash
> sed '3,$d' fichier             # de la ligne 3 jusqu'à la fin
> sed '/^#/d' config.conf        # lignes de commentaire
> sed '/^$/d' fichier            # lignes vides
> sed '/^\s*$/d' fichier         # lignes vides ou ne contenant que des espaces (GNU)
> sed '/|IT|/d' employees.txt    # employés du service IT
> sed '2,7!d' employees.txt      # garder UNIQUEMENT les lignes 2 à 7 (! = négation)
> ```
> Nettoyer un fichier de config (commentaires + lignes vides) :
> ```bash
> sed -e '/^#/d' -e '/^$/d' /etc/ssh/sshd_config
> ```

### 5. Suppression sur place avec `-i`

Pour **modifier directement le fichier**, option **`-i`** (*in-place*) :

```bash
# Contenu original
cat employees.txt

# Supprimer les lignes 2 à 7 et enregistrer
sed -i '2,7d' employees.txt

# Vérifier
cat employees.txt
```

Résultat :

```text
1|Kriti|Shreshtha|Finance|Financial Analyst|kriti.shreshtha@company.com|60000
8|Jing|Ma|Engineering|Engineering Manager|jing.ma@company.com|100000
```

> Sous **macOS** (BSD sed), `-i` exige un suffixe, éventuellement vide : `sed -i '' '2,7d' file.txt`. **Toujours sauvegarder** les données importantes avant une édition sur place.

> Bonnes pratiques :
> ```bash
> sed '2,7d' employees.txt        # 1. tester SANS -i et vérifier le résultat
> sed -i.bak '2,7d' employees.txt # 2. appliquer avec sauvegarde (crée employees.txt.bak), portable GNU/BSD
> diff employees.txt.bak employees.txt
> ```
> `-i` n'est **pas réversible** : sans `.bak`, les lignes supprimées sont perdues.

### 6. Référence rapide

| Syntaxe | Effet | Exemple |
|---|---|---|
| `sed 'd'` | Supprime toutes les lignes | `sed 'd' employees.txt` |
| `sed 'Nd'` | Supprime la ligne N | `sed '6d' employees.txt` |
| `sed 'M,Nd'` | Supprime les lignes M à N | `sed '3,5d' employees.txt` |
| `sed -i 'M,Nd'` | Suppression dans le fichier | `sed -i '2,7d' employees.txt` |

> Complément :
> | Syntaxe | Effet |
> |---|---|
> | `sed '$d'` | Supprime la dernière ligne |
> | `sed '/regex/d'` | Supprime les lignes qui correspondent |
> | `sed '/regex/!d'` | Garde **seulement** les lignes qui correspondent (≈ `grep`) |
> | `sed -i.bak '…'` | Édition sur place avec sauvegarde |

### À retenir

- `d` supprime la ligne du flux (pas d'affichage automatique pour elle).
- Sans `-i`, le fichier d'origine **n'est pas modifié** ; rediriger vers un **autre** fichier pour garder le résultat.
- Adresses : `N`, `M,N`, `N,$`, `$`, `/regex/`, et `!` pour inverser.
- `5,3d` (plage « à l'envers ») ne supprime que la ligne 5 en GNU sed.
- Classiques : `1d` (en-tête), `/^#/d` (commentaires), `/^$/d` (lignes vides).
- `-i` modifie le fichier : **tester d'abord sans `-i`**, puis `-i.bak` (portable et réversible).
- macOS : `sed -i '' …` ou `-i.bak`.

### Liens utiles

- [GNU sed Manual](https://www.gnu.org/software/sed/manual/sed.html)
- [GNU sed – Selecting lines (adresses, plages, `!`)](https://www.gnu.org/software/sed/manual/html_node/Addresses-overview.html)
- [GNU sed – Command-Line Options (`-i`)](https://www.gnu.org/software/sed/manual/html_node/Command_002dLine-Options.html)
- [Sed One-Liners Explained (Eric Pement)](https://www.pement.org/sed/)
- [GNU Bash – Quoting](https://www.gnu.org/software/bash/manual/html_node/Quoting.html)
