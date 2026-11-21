# awk option files

Beaucoup de programmes awk sont tapés directement en ligne de commande pour des tâches rapides. Pour des scripts **plus longs** ou **réutilisables**, il vaut mieux les stocker dans des **fichiers** : plus faciles à **lire**, **tester**, **versionner** et **maintenir**.

### 1. Deux façons de lancer « Hello, World! »

**En ligne de commande** (programme entre apostrophes) :

```bash
$ awk 'BEGIN { print "Hello, World!" }'
Hello, World!
```

**Depuis un fichier** `hello.awk`, avec `-f` :

```awk
BEGIN {
    print "Hello, World!"
}
```

```bash
$ awk -f hello.awk
Hello, World!
```

### 2. Points clés pour les programmes en fichier

- **Ne pas** entourer le contenu du fichier d'**apostrophes** : elles ne servent qu'à passer le programme comme **un seul argument** en ligne de commande.
- On peut rendre le fichier **exécutable** avec un **shebang** contenant **`-f`**, pour qu'awk lise le programme depuis ce fichier :

```bash
#!/usr/bin/env awk -f

BEGIN {
    print "Hello, World!"
}
```

> `#!/usr/bin/env awk -f` peut **ne pas fonctionner** : sous Linux, tout ce qui suit l'interpréteur dans le shebang est transmis comme **un seul argument**, et `env` cherche alors un programme nommé littéralement `awk -f` (`env: 'awk -f': No such file or directory`). Alternatives plus sûres :
> - chemin **explicite** : `#!/usr/bin/awk -f` (vérifier avec `command -v awk`) ;
> - si `env` supporte **`-S`** (GNU coreutils 8.30+) : `#!/usr/bin/env -S awk -f`.
>
> Pour une portabilité maximale : chemin explicite, ou appel `awk -f script` depuis un script shell.

L'option **`-f`** indique à awk de lire le **programme** depuis un fichier ; dans un shebang awk, elle est indispensable.

## 3. Deux styles de scripts awk en fichier

| Style | Shebang / appel | Avantages | Inconvénients | Idéal pour |
|---|---|---|---|---|
| **awk pur** | `#!/usr/bin/awk -f` ou `awk -f script.awk` | Fichier 100 % awk ; idiomatique pour les gros programmes awk | Pas d'accès direct aux fonctionnalités du shell (globbing, expansions, pipelines) sauf via `system()` / `getline` | Utilitaires et filtres de texte autonomes |
| **Hybride Bash + awk** | `#!/usr/bin/env bash` puis `awk '…'` | Accès complet au shell (pipes, variables d'environnement, substitution de commande) ; intégration facile | Code awk **entre guillemets** dans le shell ; mélange de langages → quoting délicat | Scripts shell qui utilisent awk pour une étape de traitement |

#### 3.1 Script awk pur (exécutable)

Fichier contenant **uniquement** de la syntaxe awk, avec un shebang :

```awk
#!/usr/bin/env awk -f

BEGIN {
    print "Hello, World!"
}
```

Deux façons de l'exécuter :

```bash
$ awk -f hello.awk
Hello, World!

# ou en le rendant exécutable
$ chmod +x hello.awk
$ ./hello.awk
Hello, World!
```

(Avec `awk -f`, le shebang est simplement ignoré, c'est un commentaire pour awk.)

#### 3.2 Hybride Bash + awk

Shebang **Bash**, et programme awk passé comme chaîne (généralement entre apostrophes) :

```bash
#!/usr/bin/env bash

awk 'BEGIN {
    print "Hello, World!"
}'
```

```bash
$ chmod +x hello.sh
$ ./hello.sh
Hello, World!
```

#### Pourquoi le quoting est important

En style hybride, le programme awk est un **argument** passé par le shell : il faut le **quoter** (apostrophes en général) pour que le shell n'interprète pas la syntaxe awk (`$1`, accolades, etc.).

> Piège : une **apostrophe** dans le programme awk (ex. `print "Don't"`) ferme la chaîne shell. Solutions : séquence octale `\047` (`print "Don\047t"`), ou programme dans un fichier séparé.

### 4. Passer et déclarer des variables

- Depuis le **shell** (ligne de commande ou script Bash) : **`-v`**.
- Dans un **script awk pur** : affectation **dans le script** (souvent dans `BEGIN`).

**awk pur** (`hello-v1.awk`) :

```awk
#!/usr/bin/env awk -f

BEGIN {
    hello = "Hello, World"
    print hello
}
```

```bash
$ awk -f hello-v1.awk
Hello, World
```

**Hybride** (`hello-v2.sh`) :

```bash
#!/usr/bin/env bash

awk -v hello="Hello, World!" 'BEGIN {
    print hello
}'
```

```bash
$ chmod +x hello-v2.sh
$ ./hello-v2.sh
Hello, World!
```

Raison pratique : `-v` permet au shell de fournir des valeurs à awk de façon **sûre et prévisible**, sans problème de quoting ni d'expansion.

La syntaxe awk dans un script Bash est **identique** à celle tapée dans le terminal ; seule la façon de **déclarer les variables** diffère dans un programme awk pur.

> Un script awk pur peut **aussi** recevoir des valeurs de l'extérieur :
> ```bash
> awk -v hello="Bonjour" -f hello-v1.awk       # -v fonctionne avec -f
> HELLO="Salut" awk 'BEGIN { print ENVIRON["HELLO"] }'   # variable d'environnement
> ```
> (Attention : dans `hello-v1.awk`, l'affectation dans `BEGIN` **écraserait** la valeur passée par `-v`.)

### 5. Séparateur de champs : les deux styles

**awk pur** (`separator.awk`) : `FS` dans `BEGIN` :

```awk
#!/usr/bin/env awk -f

BEGIN {
    FS = "|"
}

{
    print $2, $3
}
```

**Hybride** (`separator.sh`) : option `-F` :

```bash
#!/usr/bin/env bash

awk -F "|" '{
    print $2, $3
}'
```

Les deux affichent les champs 2 et 3 (prénom et nom) pour un fichier délimité par `|` :

```bash
$ ./separator.sh < employees.txt
Kriti Shrestha
Rajasekar Vasudevan
Debbie Miller
Enrique Rivera
Feng Lin
Andy Luscomb
Mark Crocker
Jing Ma

$ awk -f separator.awk < employees.txt
Kriti Shrestha
Rajasekar Vasudevan
...
```

> `FS` doit être défini dans **`BEGIN`** : s'il est modifié dans un bloc normal, la **première ligne** est déjà découpée avec l'ancien séparateur.

> `separator.sh` ne lit que **stdin** (awk hérite du stdin du script). Pour accepter aussi des fichiers en argument : transmettre `"$@"` :
> ```bash
> #!/usr/bin/env bash
> awk -F'|' '{ print $2, $3 }' "$@"
> # ./separator.sh employees.txt   ou   ./separator.sh < employees.txt
> ```

### 6. Quel style choisir ?

- Pour ce cours et la plupart des workflows **orientés shell** : le style **hybride Bash + awk**, car il montre l'intégration d'awk avec les pipes, variables d'environnement, substitution de commande, `set`…
- Pour un **utilitaire de traitement de texte autonome** ou un outil distribué sous forme de fichier awk : le **script awk pur**, plus propre et idiomatique.

> Troisième option, souvent la meilleure pour les gros programmes : **script Bash + fichier `.awk` séparé**. On garde les fonctionnalités du shell, sans aucun problème de quoting :
> ```bash
> #!/usr/bin/env bash
> set -euo pipefail
> readonly WORK_DIR=$(dirname "$(readlink -f "$0")")
>
> awk -F'|' -v high_salary="${1:-90000}" -f "${WORK_DIR}/report.awk" employees.txt
> ```

### 7. Synthèse

- Exécuter un programme awk depuis un fichier : `awk -f script` ou fichier exécutable avec shebang (`#!/usr/bin/awk -f`).
- Deux styles : **awk pur** vs **Bash qui appelle awk**.
- Différences : quoting, variables (`-v` vs affectation dans `BEGIN`), séparateur (`-F` vs `FS`).
- Style hybride privilégié dans un contexte shell ; awk pur pour un utilitaire autonome.

### À retenir

- `awk -f fichier.awk` lit le programme depuis un fichier ; **pas d'apostrophes** dans le fichier.
- Shebang awk : `#!/usr/bin/awk -f` (fiable) ou `#!/usr/bin/env -S awk -f` ; `#!/usr/bin/env awk -f` échoue souvent sous Linux.
- **awk pur** : variables et `FS` définis dans `BEGIN` ; **hybride** : `-v` et `-F` depuis le shell.
- En hybride, programme awk entre **apostrophes** ; apostrophe interne → `\047` ou fichier séparé.
- `-v` fonctionne aussi avec `-f` ; `ENVIRON["VAR"]` lit l'environnement.
- Script Bash qui encapsule awk : transmettre `"$@"` pour accepter des fichiers en argument.
- Bon compromis pour les gros programmes : **Bash + `awk -f script.awk`**.

### Liens utiles

- [GNU Awk – Running long programs (`-f`)](https://www.gnu.org/software/gawk/manual/html_node/Long.html)
- [GNU Awk – Executable awk programs (shebang)](https://www.gnu.org/software/gawk/manual/html_node/Executable-Scripts.html)
- [GNU Awk – Shell quoting issues](https://www.gnu.org/software/gawk/manual/html_node/Quoting.html)
- [GNU coreutils – env invocation (`-S`)](https://www.gnu.org/software/coreutils/manual/html_node/env-invocation.html)
- [GNU Awk Manual](https://www.gnu.org/software/gawk/manual/)
- [awk (Wikipédia)](https://en.wikipedia.org/wiki/Awk)
