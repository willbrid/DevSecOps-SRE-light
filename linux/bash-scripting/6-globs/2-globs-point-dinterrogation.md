# Globs : point d'interrogration

Dans les globs, le joker **`?` correspond à exactement un caractère**. Les noms de fichiers doivent donc avoir **la même longueur** que le motif. En combinant du texte fixe et des `?`, on obtient une sélection de fichiers très **précise**.

### 1. Les bases du joker `?`

- `?` remplace **exactement un** caractère.
- Il ne correspond **jamais à zéro** caractère.
- Le point (`.`) est traité comme un **caractère normal**…

> Précision : … **sauf en début de nom**. Un `?` (ou `*`) ne correspond pas au **point initial** d'un fichier caché (`.bashrc`), sauf si l'option `dotglob` est activée. Ailleurs dans le nom, `?` peut parfaitement correspondre à un `.`.

> Différence avec `*` (zéro ou plusieurs caractères) : utiliser `?` quand on veut une **longueur exacte**.

### 2. Exemple 1 : un caractère + « ail »

Contenu du répertoire : `rail`, `Document.doc`, `fail`, `hail`, `bar`, `sail`, `foo`, `mail`, `4ail`, `foobar`.

Motif `?ail` : n'importe quel caractère **unique** suivi de `ail` :

```bash
$ ls
rail  Document.doc  fail  hail  bar  sail  foo  mail  4ail  foobar

$ ls ?ail
rail  fail  hail  sail  mail  4ail
```

- `?` correspond à un caractère (`r`, `f`, `h`, `s`, `m`, `4`) : lettres **et chiffres**.
- `ail` fixe la fin du nom.
- `bar`, `foo`, `foobar`, `Document.doc` ne correspondent pas.

### 3. Exemple 2 : « tes » + deux caractères + « .txt »

Contenu : `test.sh`, `file.txt`, `tes1t.txt`, `test2.txt`, `file1.txt`.

```bash
$ ls
test.sh  file.txt  tes1t.txt  test2.txt  file1.txt

$ ls tes??.txt
tes1t.txt  test2.txt
```

- `tes` fixe les trois premières lettres.
- `??` correspond à **exactement deux** caractères.
- `.txt` fixe l'extension.

> Correction : la leçon indique que `??` correspond à `1t` et `2.`. En réalité :
> - `tes1t.txt` → `tes` + **`1t`** + `.txt` ✅
> - `test2.txt` → `tes` + **`t2`** + `.txt` ✅
>
> `test.sh` est exclu (mauvaise extension) ; `file*.txt` sont exclus (ne commencent pas par `tes`).

### 4. Exemple 3 : « test » + un caractère + « .txt »

Contenu : `test1-2.txt`, `tes1t.txt`, `test2.txt`, `test3.sh`, `test1.txt`, `file1.txt`.

```bash
$ ls
test1-2.txt  tes1t.txt  test2.txt  test3.sh  test1.txt  file1.txt

$ ls test?.txt
test1.txt  test2.txt
```

- `test` fixe le préfixe.
- `?` correspond à un seul caractère (`1`, `2`).
- `.txt` impose l'extension.

Exclus :
- `test1-2.txt` → 3 caractères (`1-2`) entre `test` et `.txt` ;
- `tes1t.txt` → ne commence pas par `test` ;
- `test3.sh` → mauvaise extension ;
- `file1.txt` → mauvais préfixe.

### 5. Exemple 4 : un caractère + « est. » + trois caractères

Motif `?est.???` : un caractère, puis `est.`, puis une extension d'**exactement trois** caractères :

```bash
$ ls
test.txt  vest.txt  test.jpg  file.sh  rest.txt  west.doc

$ ls ?est.???
test.txt  vest.txt  test.jpg  rest.txt  west.doc
```

- `?est` accepte n'importe quel premier caractère (`t`, `v`, `r`, `w`).
- Le `.` après `est` est un point **littéral**.
- `???` exige une extension de **3 caractères** (`txt`, `jpg`, `doc`).
- `file.sh` est exclu.

> Variante : `?est.*` accepterait aussi des extensions de longueur quelconque (`.sh`, `.yaml`…).

### 6. Exemple 5 : noms d'exactement quatre caractères

Contenu : `1234`, `abcd`, `kei5`, `some_file.txt`, `x0f4p`, `90c1`, `dir`, `keio5`, `touch`, `x0fp`.

```bash
$ ls
1234  abcd  kei5  some_file.txt  x0f4p  90c1  dir  keio5  touch  x0fp

$ ls ????
1234  abcd  kei5  90c1  x0fp
```

- Chacun des quatre `?` correspond à un caractère.
- Exclus : `dir` (3), `x0f4p`, `keio5`, `touch` (5), `some_file.txt` (13).

> Si un **répertoire** de 4 caractères correspond, `ls` affiche son **contenu** au lieu de son nom. Utiliser `ls -d ????` pour lister les noms seulement, ou `echo ????`.

### 7. Conclusion

Le joker `?` permet de filtrer précisément les fichiers selon leur **longueur** et leur **contenu**. On combine du texte fixe et des `?` pour obtenir exactement la correspondance voulue.

Pour inclure les **fichiers cachés** dans les correspondances :

```bash
shopt -s dotglob
```

> Autres usages du `?` (non présents dans la leçon) :
> ```bash
> # Dans une comparaison de chaîne
> code="A7"
> [[ $code == ?? ]] && echo "code de 2 caractères"
>
> # Dans un case
> case "$1" in
>   ?)  echo "un seul caractère" ;;
>   ??) echo "deux caractères" ;;
>   *)  echo "autre" ;;
> esac
>
> # Avec find (mettre le motif entre guillemets pour que find l'interprète, pas le shell)
> find . -name "test?.txt"
> ```

### À retenir

- `?` = **exactement un** caractère (jamais zéro) ; `*` = zéro ou plus.
- Le nombre de `?` impose la **longueur** : `????` = noms de 4 caractères exactement.
- Combiner texte fixe + `?` : `?ail`, `test?.txt`, `tes??.txt`, `?est.???`.
- `?` correspond à **n'importe quel** caractère : lettre, chiffre, `-`, `.`…
- Sauf le **point initial** des fichiers cachés → `shopt -s dotglob` pour les inclure.
- `ls -d` (ou `echo`) pour éviter que `ls` affiche le contenu d'un répertoire qui correspond.
- Avec `find -name`, mettre le motif **entre guillemets**.

### Liens utiles

- [GNU Bash – Pattern Matching](https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
- [GNU Bash – The Shopt Builtin (dotglob, nullglob…)](https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
- [Glob (Wikipédia)](https://en.wikipedia.org/wiki/Glob_(programming))
