# Globs combinés

Ce contenu combine `?`, `*` et l'**échappement** pour faire correspondre des noms de fichiers complexes, **sans recourir aux expressions régulières**.

Rappel des opérateurs :

| Joker | Description | Exemple |
||||
| `*` | Zéro ou plusieurs caractères | `*.txt` |
| `?` | Exactement un caractère | `file.?` |
| `\` | Rend le caractère suivant littéral | `file\*.*` |

### 1. Méthode pour construire un glob complexe

1. **Sélection d'exemples**
   Lister des noms de fichiers et marquer ceux qui doivent correspondre (✅) ou non (❌). Repérer :
   - les segments **bleus** = texte **littéral** ;
   - les segments **jaunes** = parties **variables** (jokers).
2. **Ordre des catégories**
   Noter l'enchaînement des segments bleus et jaunes dans les noms ciblés.
3. **Construire le glob**
   Concaténer littéraux et jokers dans cet ordre.

### 2. Exemple 1 : « file. » + au moins un caractère

```text
file.        ❌
file.c       ✅
file.conf    ✅
file.txt     ✅
data.sh      ❌
```

1. Bleu : `file.`
2. Jaune : `?` (un caractère obligatoire) puis `*` (le reste)
3. Glob : **`file.?*`**

```bash
$ ls file.?*
file.c  file.conf  file.txt
```

> Astuce clé : **`?*` = « au moins un caractère »** (`*` seul accepterait `file.` sans extension). De même `??*` = au moins deux, etc.

### 3. Exemple 2 : préfixe « file_ » + extension de 3 caractères

```text
file_1.txt    ✅
file_2.doc    ✅
file_1_a.sh   ❌
file_2_b.doc  ✅
```

1. Bleu : `file_`
2. Jaune : `*` (n'importe quoi avant le point)
3. Bleu : `.`
4. Jaune : `???` (exactement trois caractères)
5. Glob : `file_*.___` *(selon la leçon)*

```bash
$ ls file_*.___
file_1.txt  file_2.doc  file_2_b.doc
```

> Correction : `_` n'est **pas** un joker, c'est un caractère littéral. `file_*.___` chercherait une extension composée de trois underscores et ne trouverait rien. Le glob correct, cohérent avec l'étape 4, est :
> ```bash
> $ ls file_*.???
> file_1.txt  file_2.doc  file_2_b.doc
> ```
> `file_1_a.sh` est exclu car son extension (`sh`) n'a que 2 caractères.

### 4. Exemple 3 : n'importe quel nom + extension de 4 caractères

```text
document1.txt  ❌
image1.py      ❌
report2.pdf    ❌
memo1.docx     ✅
invoice3.xlsx  ✅
```

1. Jaune : `*` (n'importe quel préfixe)
2. Bleu : `.`
3. Jaune : `????` (exactement quatre)
4. Glob : **`*.????`**

```bash
$ ls *.????
memo1.docx  invoice3.xlsx
```

> Attention : `*.????` correspond aussi à `archive.tar.gzip` ou `notes.2026` (seule la partie après le **dernier** point compte… ou n'importe quel point suivi de 4 caractères en fin de nom).

### 5. Exemple 4 : « 1 » + un caractère + une extension

```text
file1.sh           ❌
document1M.docx    ✅
file3.txt          ❌
image1T.png        ✅
```

1. Jaune : `*` (préfixe quelconque)
2. Bleu : `1`
3. Jaune : `?` (un caractère)
4. Bleu : `.`
5. Jaune : `*` (extension quelconque)
6. Glob : **`*1?.*`**

```bash
$ ls *1?.*
document1M.docx  image1T.png
```

- `file1.sh` est exclu : après `1`, le `?` prendrait le `.`, et il faudrait ensuite **un autre** point.
- `file3.txt` est exclu : pas de `1`.

### 6. Exemple 5 : échapper un `*` littéral dans les noms

```text
R*al.py        ✅
f*a*il.txt     ✅
hail.doc       ❌
S*ail.txt      ✅
m*a?i*l.sh     ✅
4ai*l.txt      ❌
```

1. Jaune : `?` (un caractère quelconque)
2. Bleu : `\*` (étoile **littérale**)
3. Bleu : `a`
4. Jaune : `*`
5. Bleu : `.`
6. Jaune : `*`
7. Glob : **`?\*a*.*`**

La leçon indique de quoter le motif :

```bash
$ ls '?\*a*.*'
R*al.py  f*a*il.txt  S*ail.txt  m*a?i*l.sh
```

> Correction : avec des **guillemets simples**, le shell ne fait **aucune** expansion : `ls` reçoit la chaîne littérale `?\*a*.*` et cherche un fichier portant exactement ce nom → erreur *No such file or directory*. Le glob doit rester **non quoté**, seul le `*` littéral est échappé :
> ```bash
> $ ls ?\*a*.*
> R*al.py  S*ail.txt  f*a*il.txt  m*a?i*l.sh
> ```
> - `4ai*l.txt` exclu : le 2ᵉ caractère est `a`, pas `*`.
> - `hail.doc` exclu : pas de `*`.

### 7. Exemple 6 : échapper un antislash et un point d'interrogation

Cible : les noms contenant la séquence littérale `\?`.

```text
file5\?xt             ✅
file_1234567\?890?xt  ✅
docA\?.docx           ✅
docZ.docx             ❌
rep1.txt              ❌
```

1. Jaune : `*` (préfixe)
2. Bleu : `\?` littéral
3. Jaune : `*` (reste)
4. Glob : `*\\?*` *(selon la leçon)*

```bash
$ ls '*\\?*'
file5\?xt  file_1234567\?890?xt  docA\?.docx
```

> Correction (deux problèmes) :
> 1. Comme dans l'exemple 5, les **guillemets simples** empêchent toute expansion → `ls` cherche un fichier nommé littéralement `*\\?*`.
> 2. Dans `*\\?*`, `\\` donne un antislash littéral, mais le `?` **n'est pas échappé** : il reste un joker (« antislash + n'importe quel caractère »). Ça marche ici par hasard, mais `docB\x.txt` correspondrait aussi.
>
> Glob correct pour la séquence littérale `\?` :
> ```bash
> $ ls *\\\?*
> docA\?.docx  file5\?xt  file_1234567\?890?xt
> ```
> (`\\` = antislash littéral, `\?` = point d'interrogation littéral.)
> Variante plus lisible : quoter **uniquement** la partie littérale, laisser les jokers dehors :
> ```bash
> $ ls *'\?'*
> ```

### 8. Conclusion

En découpant les noms en segments **littéraux** (bleus) et **variables** (jaunes), on peut construire des globs précis, même pour les noms les plus compliqués.

> Règle d'or pour mélanger littéraux et jokers : **échapper ou quoter seulement les caractères littéraux**, jamais tout le motif. Tester d'abord avec `echo` :
> ```bash
> echo ?\*a*.*
> ```

### À retenir

- Méthode : exemples ✅/❌ → segments **littéraux** vs **jokers** → assemblage dans l'ordre.
- `?*` = **au moins un** caractère ; `???` = **exactement trois**.
- `_`, `.`, `-` sont des caractères **littéraux**, pas des jokers.
- `*.????` = extension de 4 caractères ; `file_*.???` = préfixe `file_` + extension de 3 caractères.
- `\*`, `\?`, `\\` → `*`, `?`, `\` littéraux ; le reste du motif garde ses jokers.
- **Quoter tout le motif** (`'?\*a*.*'`) **désactive tous les jokers** → aucun fichier trouvé. Quoter seulement le littéral : `*'\?'*`.
- Toujours vérifier avec `echo motif` avant une commande destructrice.

### Liens utiles

- [GNU Bash – Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
- [GNU Bash – Quoting](https://www.gnu.org/software/bash/manual/html_node/Quoting.html)
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)
