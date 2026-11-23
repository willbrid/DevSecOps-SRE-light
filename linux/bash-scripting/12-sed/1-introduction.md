# Introduction

**sed** (*stream editor*) est l'éditeur de flux classique pour **analyser, transformer et modifier du texte** en ligne de commande. Compact et rapide, il est idéal pour les **substitutions** et les **modifications ligne par ligne** dans des pipelines ou des scripts.

Invocation :

```bash
$ sed
```

(Sans argument, sed affiche simplement son **mode d'emploi** : il attend au moins un script d'édition.)

### 1. sed, grep ou awk ?

| Outil | Rôle principal | Quand l'utiliser | Exemple |
|---|---|---|---|
| **grep** | Recherche de motifs | Trouver rapidement les lignes contenant un motif | `df -h \| grep "root"` |
| **awk** | Langage de traitement par champs/lignes | Extraire ou calculer des valeurs par colonnes et lignes | `df -h \| awk 'NR == 2 { print }'` |
| **sed** | Édition de flux (substitutions, éditions de lignes) | Remplacer du texte, éditer sur place, transformer un flux | `sed 's/sample/are/g' poem.txt` |

> Moyen mnémotechnique : **grep = trouver**, **awk = découper/calculer**, **sed = remplacer/modifier**.

### 2. grep : recherche rapide

grep est optimisé pour **localiser** des correspondances dans de gros volumes. Il ne fait **pas** de remplacement (on le combine alors avec sed).

Lister les systèmes de fichiers et filtrer la ligne de la racine :

```bash
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       7.7G  2.9G  4.9G  38% /
devtmpfs        486M     0  486M   0% /dev
tmpfs           490M     0  490M   0% /dev/shm
tmpfs            98M   828K   98M   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           490M     0  490M   0% /sys/fs/cgroup

$ df -h | grep "root"
/dev/root       7.7G  2.9G  4.9G  38% /
```

> `grep "root"` garde **toute ligne contenant** « root » (n'importe où). Pour être précis : `grep '^/dev/root'` (début de ligne).

### 3. awk : traitement par champs et enregistrements

awk est un petit **langage de programmation** orienté **colonnes** (champs) et **lignes** (enregistrements), idéal pour la logique conditionnelle, les calculs et le formatage.

Afficher la 2ᵉ ligne (la première après l'en-tête) de `df` :

```bash
$ df -h | awk 'NR == 2 { print }'
/dev/root       7.7G  2.9G  4.9G  38% /
```

### 4. sed : éditeur de flux

sed excelle pour **rechercher et transformer** du texte dans un flux. Pour une substitution rapide, c'est souvent l'outil le plus simple.

Remplacer toutes les occurrences de « sample » par « are ».

`poem.txt` :

```text
Roses sample red,
Violets sample blue,
Sugar sample sweet,
And so sample you.
```

Substitution :

```bash
$ sed 's/sample/are/g' poem.txt
Roses are red,
Violets are blue,
Sugar are sweet,
And so are you.
```

#### Décomposition de la commande `s`

| Élément | Rôle |
|---|---|
| `s` | Commande de **substitution** |
| `/sample/` | **Motif** recherché (expression régulière) |
| `/are/` | Texte de **remplacement** |
| `g` | **Global** : remplace **toutes** les occurrences de chaque ligne ; sans `g`, seule la **première** occurrence de chaque ligne est remplacée |

Donc `sed 's/sample/are/g' poem.txt` remplace **toutes** les occurrences de « sample » par « are », sur **chaque ligne** de `poem.txt`.

> Points essentiels :
> - Par défaut, sed **ne modifie pas le fichier** : il affiche le résultat sur **stdout**. `poem.txt` reste intact.
> - Toujours **quoter** le script sed avec des apostrophes (`'…'`).
> - Le délimiteur `/` peut être remplacé par un autre caractère, pratique pour les **chemins** :
>   ```bash
>   sed 's|/usr/local|/opt|g' config.txt    # au lieu de s/\/usr\/local/\/opt/g
>   ```
> - sed fonctionne aussi dans un pipeline : `df -h | sed 's/tmpfs/TMPFS/'`.


> Aperçu de quelques commandes courantes :
> ```bash
> sed -n '2p' fichier          # afficher seulement la ligne 2
> sed '1d' fichier             # supprimer la 1re ligne (ex. un en-tête)
> sed '/^#/d' fichier          # supprimer les lignes de commentaire
> sed -n '/ERROR/p' app.log    # afficher les lignes contenant ERROR (≈ grep)
> sed -i 's/old/new/g' f.txt   # modifier le fichier sur place (GNU)
> ```

### 6. GNU sed vs BSD sed

sed **diffère selon les plateformes** :
- **macOS** → version **BSD Unix** ;
- **Linux** → version **GNU Project**.

> Les contenus utiliseront **GNU sed**.
> L'édition sur place (`-i`) et certaines expressions étendues **diffèrent** entre GNU sed et BSD sed. Pour des scripts portables, tester sur toutes les plateformes cibles ou utiliser des constructions **POSIX**.

> Exemple concret de différence sur `-i` :
> ```bash
> sed -i 's/a/b/' f.txt         # GNU (Linux) : OK
> sed -i '' 's/a/b/' f.txt      # BSD (macOS) : suffixe de sauvegarde obligatoire (ici vide)
> sed -i.bak 's/a/b/' f.txt     # ✅ fonctionne sur les deux (crée f.txt.bak)
> ```
> Sous macOS, on peut installer GNU sed : `brew install gnu-sed` (commande `gsed`).

> Usage fréquent en contexte Kubernetes :
> ```bash
> sed -i 's|image: nginx:1.25|image: nginx:1.27|' deploy.yaml
> kubectl get deploy web -o yaml | sed 's/replicas: 1/replicas: 3/' | kubectl apply -f -
> ```

### À retenir

- **sed** = éditeur de **flux** : lit l'entrée ligne par ligne, applique des commandes, écrit sur **stdout**.
- `sed 's/motif/remplacement/'` remplace la **1re** occurrence par ligne ; avec **`g`**, **toutes**.
- Le fichier d'origine n'est **pas modifié** sans `-i`.
- Délimiteur libre : `s|a|b|`, `s#a#b#` → pratique pour les chemins.
- **grep** pour chercher, **awk** pour les colonnes et calculs, **sed** pour remplacer/modifier.
- **GNU** (Linux) ≠ **BSD** (macOS), surtout pour `-i` → `-i.bak` est portable.
- Toujours quoter le script sed (`'…'`).

### Liens utiles

- [GNU sed Manual](https://www.gnu.org/software/sed/manual/sed.html)
- [GNU sed – The `s` command](https://www.gnu.org/software/sed/manual/html_node/The-_0022s_0022-Command.html)
- [sed one-liners (Eric Pement)](https://sed.sourceforge.net/sed1line.txt)
- [Stack Overflow – `sed -i` portable (GNU vs BSD)](https://stackoverflow.com/questions/2011852/portable-way-to-sed-i-in-place-editing)
- [Expressions régulières POSIX (manuel GNU grep)](https://www.gnu.org/software/grep/manual/html_node/Regular-Expressions.html)
