# Shebang

Ce contenu montre comment la directive **shebang** (`#!`) influence l'exécution et la **portabilité** d'un script.

### 1. Analogie et définition

Imagine un traducteur polyglotte face à un vieux manuscrit : chaque dialecte (shell) a ses subtilités. Le shebang est le **guide du traducteur** : il indique **quel interpréteur** doit lire le script. Sans lui, c'est le shell courant qui s'en charge, avec des risques de comportements inattendus et de problèmes de portabilité.

Shebang classique :

```bash
#!/bin/bash
```

Le mot **shebang** vient de *hash* (`#`, code hexadécimal **0x23**) + *bang* (`!`, **0x21**).

> Le shebang doit être **la toute première ligne** du fichier, à partir du **premier caractère** (pas d'espace, pas de ligne vide, pas de commentaire avant).

### 2. Que se passe-t-il sans shebang ?

Script `noshebang.sh` sans shebang (il utilise pourtant `[[ ]]`, spécifique à Bash) :

```bash
# noshebang.sh
WORDS="I don't have a shebang and I still run"
for word in ${WORDS}; do
  if [[ 2 < 3 ]]; then
    echo "${word}"
  fi
done
```

Exécution :

```bash
chmod +x noshebang.sh
./noshebang.sh
# Chaque mot s'affiche, car c'est Bash (ton shell) qui l'interprète
echo $SHELL
# /bin/bash
```

Ça marche **en local**, mais ce n'est **pas portable** : dans un autre environnement (cron, autre utilisateur, autre shell de connexion), le script peut être lu par `/bin/sh`, qui ne connaît pas les fonctionnalités propres à Bash comme `[[ ]]`.

### 3. Observer le noyau avec `strace`

Même script, **avec** shebang :

```bash
# shebang.sh
#!/bin/bash
WORDS="I don't have a shebang and I still run"
for word in ${WORDS}; do
  if [[ 2 < 3 ]]; then
    echo "${word}"
  fi
done
```

Tracer le shell courant (`$$`) en arrière-plan :

```bash
sudo strace -Tfp $$ 2>&1 | grep -E 'execve' &
```

Lancer les deux scripts :

```bash
./noshebang.sh
./shebang.sh
# [pid …] execve("./shebang.sh", ["./shebang.sh"], …) = 0
# Le script s'exécute sous /bin/bash
```

Quand le noyau détecte `#!` suivi d'un interpréteur valide, il **lance directement cet interpréteur** en lui passant le script.

> Ce qui se passe en coulisses :
> - **Avec shebang** : `execve` réussit (`= 0`) ; le noyau exécute en réalité `/bin/bash ./shebang.sh`.
> - **Sans shebang** : `execve` échoue avec **`ENOEXEC`** (format non reconnu). Bash rattrape l'erreur et **interprète lui-même** le script dans un sous-shell. C'est donc ton shell actuel qui décide, pas le script.

### 4. Avec un autre shell : exemple du C shell (`csh`)

La syntaxe du C shell est très différente de celle de Bash. Sans shebang, Bash essaie de l'interpréter et échoue :

```csh
# is_csh.sh
set x = 'a'
if ($x == 'a') then
    echo "running on a c shell csh"
endif
```

```bash
chmod +x is_csh.sh
./is_csh.sh
# -bash: ./is_csh.sh: ... syntax error: unexpected end of file
```

(Bash cherche un `fi` qui n'arrive jamais, puisque `csh` termine ses `if` par `endif`.)

Avec le bon shebang :

```csh
#!/bin/csh
set x = 'a'
if ($x == 'a') then
    echo "running on a c shell csh"
endif
```

```bash
./is_csh.sh
# running on a c shell csh
```

> Nécessite que `csh` soit installé (ex. `sudo apt install csh` ou `tcsh`).

### 5. Shebang moderne et portable

Écrire le chemin de l'interpréteur en dur peut casser d'un système à l'autre (Bash n'est pas toujours dans `/bin`). Alternative :

```bash
#!/usr/bin/env bash
```

`env` cherche `bash` dans le **`PATH`**, ce qui améliore la compatibilité entre systèmes. Il faut en revanche que `env` soit bien dans `/usr/bin` (c'est le cas quasiment partout).

| Shebang | Description | Avantages / inconvénients |
||||
| `#!/bin/bash` | Chemin direct vers Bash | Rapide et prévisible, mais échoue si Bash est installé ailleurs |
| `#!/usr/bin/env bash` | Cherche Bash dans le `PATH` via `env` | Portable, mais dépend d'un `PATH` correct |

> Autre limite : sous Linux, `#!/usr/bin/env bash -e` ne fonctionne pas comme prévu (tout ce qui suit l'interpréteur est passé comme **un seul argument**). On met plutôt `set -e` dans le script, ou `#!/usr/bin/env -S bash -e` avec un `env` récent.

#### Démo : fonctionnalités selon la version de Bash

`bash_versions.sh` :

```bash
#!/usr/bin/env bash
echo "Current Unix timestamp (integer): ${EPOCHSECONDS}"
echo "Current Unix timestamp (floating-point): ${EPOCHREALTIME}"
```

Avec le Bash par défaut de macOS (version 3.2) → variables vides :

```bash
bash --version
./bash_versions.sh
# Current Unix timestamp (integer):
# Current Unix timestamp (floating-point):
```

Après installation de Bash 5.2 (ex. via Homebrew) et mise à jour du `PATH` :

```bash
bash --version
./bash_versions.sh
# Current Unix timestamp (integer): 1679282700
# Current Unix timestamp (floating-point): 1679282700.176761
```

Avec `#!/usr/bin/env bash`, le script utilise automatiquement **le Bash trouvé en premier dans le `PATH`**, donc la version la plus récente installée.

> `EPOCHSECONDS` et `EPOCHREALTIME` existent depuis **Bash 5.0**. Avec `#!/bin/bash` sur macOS, on resterait bloqué sur la vieille version 3.2.

### 6. Précautions et recommandations

Les environnements minimalistes (BusyBox, images Docker Alpine…) n'ont pas forcément `bash`. Pour voir les shells disponibles :

```bash
cat /etc/shells
# /bin/sh
# /bin/bash
# /sbin/nologin
…
```

> Si `/usr/bin/env` ou le shell choisi n'existe pas, le script échoue (erreur du type *bad interpreter: No such file or directory*). Toujours vérifier les chemins des interpréteurs avant de déployer.

- Choisir un shebang adapté à l'environnement cible et aux shells installés.
- Il faudrait privilégier le shebang :

```bash
#!/usr/bin/env bash
```

### À retenir

- Le shebang `#!` (0x23 0x21) indique au **noyau** quel interpréteur utiliser ; il doit être sur la **1re ligne, 1er caractère**.
- Sans shebang, `execve` échoue (`ENOEXEC`) et c'est **le shell courant** qui interprète le script → non portable.
- Un script Bash sans shebang peut casser s'il est lancé par `/bin/sh` (pas de `[[ ]]`, tableaux, etc.).
- Un script pour un autre shell (`csh`, `zsh`, `python`…) **doit** avoir le shebang correspondant.
- `#!/bin/bash` = chemin fixe ; `#!/usr/bin/env bash` = cherche dans le `PATH` → plus portable, utilise la version la plus récente disponible.
- `env` ne transmet qu'**un seul argument** sous Linux : préférer `set -e` dans le script.
- `cat /etc/shells` liste les shells disponibles ; attention aux environnements minimalistes (Alpine/BusyBox → souvent seulement `sh`).
- Lancer explicitement `bash script.sh` **ignore** le shebang (c'est l'interpréteur appelé qui gagne).

### Liens utiles

- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Shebang (Wikipédia)](https://en.wikipedia.org/wiki/Shebang_(Unix))
- [man env](https://man7.org/linux/man-pages/man1/env.1.html)
- [strace – site officiel](https://strace.io/)
