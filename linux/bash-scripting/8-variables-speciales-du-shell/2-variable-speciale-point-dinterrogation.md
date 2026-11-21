# Variable spéciale $?

> Fichiers d'exemple : [exemples/2-variable-speciale-point-dinterrogation/](exemples/2-variable-speciale-point-dinterrogation/) (lancer les commandes depuis ce répertoire).

En Bash et dans les shells POSIX, la variable spéciale **`$?`** contient le **code de sortie** de la **dernière** commande, du dernier script ou de la dernière fonction exécutée. La vérifier est essentiel pour une **gestion d'erreurs robuste**.

### Partie 1 : utiliser `$?`

#### 1. Qu'est-ce qu'un code de sortie ?

Chaque commande renvoie un **entier** :
- **0** = succès ;
- **non nul** = échec ou condition d'erreur particulière.

`$?` stocke ce code pour une commande, un script ou une fonction.

> Même si stdout et stderr sont redirigés (`> /dev/null 2>&1`) et que **rien ne s'affiche**, `$?` indique toujours le succès ou l'échec.

#### 2. `$?` en pratique

**1. Script avec une faute de frappe :**

```bash
#!/usr/bin/env bash
ehco "Hello!"
```

```bash
$ ./wrong_echo.sh > /dev/null 2>&1
$ echo $?
127
```

Code **127** = « command not found ». Le script renvoie le code de sa **dernière commande** exécutée.

**2. Commande réussie :**

```bash
$ ls
music videos photos documents
$ echo $?
0
```

**3. Fichier introuvable :**

```bash
$ ls some_file.txt
ls: cannot access 'some_file.txt': No such file or directory
$ echo $?
2
```

#### 3. Codes de sortie courants

| Code | Signification |
|---|---|
| **0** | Succès |
| **1** | Erreur générale |
| **2** | Mauvaise utilisation d'un built-in du shell |
| **126** | Commande trouvée mais **non exécutable** |
| **127** | Commande **introuvable** |
| **130** | Script interrompu par **Ctrl+C** |

On peut définir des codes personnalisés **à partir de 128**.

> Correction : les codes **128 + n** sont réservés aux processus **tués par le signal n** (130 = 128 + 2 = SIGINT/Ctrl+C, 137 = 128 + 9 = SIGKILL, 143 = 128 + 15 = SIGTERM). Pour des codes personnalisés **sans ambiguïté**, rester dans la plage **3 à 125**. (Les codes 150/160 utilisés plus bas fonctionnent, mais pourraient être confondus avec une mort par signal.)

#### 4. Commandes successives

`$?` reflète toujours la **dernière** commande :

```bash
$ ./script.sh
bash: ./script.sh: Permission denied
$ echo $?
126

$ ls script.sh
script.sh
$ echo $?
0
```

Le script existe mais n'a pas le droit d'exécution → **126** ; le `ls` suivant réussit et **écrase** `$?` avec **0**.

> Corriger : `chmod +x script.sh`.

#### 5. Masquer les erreurs

Un `exit 0` final peut **cacher** un échec précédent :

```bash
#!/usr/bin/env bash
ehco "Hello!"
exit 0
```

```bash
$ ./wrong_echo.sh
./wrong_echo.sh: line 2: ehco: command not found
$ echo $?
0
```

L'erreur s'affiche, mais le script **prétend avoir réussi** → un outil de CI, un cron ou un autre script croira que tout s'est bien passé.

### Partie 2 : écrire des scripts qui exploitent `$?`

Pour qu'un script **s'arrête** en cas d'erreur et **renvoie un statut exact**, trois techniques.

#### 6. Technique 1 : `if` après chaque commande

```bash
#!/usr/bin/env bash

ehco "Hello!"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to run command."
    exit 1
fi

echo "Command ran successfully!"
exit 0
```

```bash
$ ./wrong_echo-v2.sh
./wrong_echo-v2.sh: line 3: ehco: command not found
Error: Failed to run command.
$ echo $?
1
```

> Forme plus directe et recommandée (ShellCheck SC2181) : tester la commande elle-même.
> ```bash
> if ! echo "Hello!"; then
>     echo "Error: Failed to run command." >&2
>     exit 1
> fi
> ```

#### 7. Technique 2 : opérateur OU (`||`)

```bash
#!/usr/bin/env bash
ehco "Hello!" || { echo "Error: Failed to run command."; exit 1; }
exit 0
```

```bash
$ ./wrong_echo-v3.sh
./wrong_echo-v3.sh: line 2: ehco: command not found
Error: Failed to run command.
$ echo $?
1
```

Si la commande échoue, le bloc entre accolades s'exécute (message + `exit 1`).

> Accolades `{ …; }` et non parenthèses : avec `( … )`, le `exit` ne quitterait que le **sous-shell**.

#### 8. Technique 3 : `set -e`

```bash
#!/usr/bin/env bash
set -e
ehco "Hello!"
exit 0
```

```bash
$ ./wrong_echo-sete.sh
./wrong_echo-sete.sh: line 3: ehco: command not found
$ echo $?
127
```

Le script s'arrête **à la première erreur** et renvoie **le code de la commande en échec** (127) ; le `exit 0` n'est jamais atteint.

> `set -e` dans un **shell interactif** ferme la session à la première erreur :
> ```bash
> $ set -e
> $ ehco "Hello"
> -bash: ehco: command not found
> ```
> (le terminal se ferme)

> Limites de `set -e` à connaître : il **ne se déclenche pas** pour une commande testée dans un `if`/`while`, à gauche de `&&`/`||`, ni (sans `pipefail`) au milieu d'un pipeline. Combinaison robuste courante : `set -euo pipefail`.

#### 9. Codes personnalisés et fonction `terminate`

##### Script initial : `server_appender.sh`

```bash
#!/usr/bin/env bash

readonly CONF_FILE="./fqdn.properties"
readonly SERVER_NAMES="server1 server2 server3"
readonly DEFAULT_USER="mummshad"

fqdn=$(cat "${CONF_FILE}")

for server in ${SERVER_NAMES}; do
    echo "${DEFAULT_USER}@${server}.${fqdn}"
done

exit 0
```

Si `fqdn.properties` est **vide**, le script produit des adresses **malformées** (`mummshad@server1.`) tout en renvoyant **0**.

##### Ajout d'une vérification de fichier vide

```bash
#!/usr/bin/env bash

readonly CONF_FILE="./fqdn.properties"
readonly SERVER_NAMES="server1 server2 server3"
readonly DEFAULT_USER="mummshad"

if [[ ! -s "${CONF_FILE}" ]]; then
    echo "Error: ${CONF_FILE} is empty"
    exit 1
fi

fqdn=$(cat "${CONF_FILE}")

for server in ${SERVER_NAMES}; do
    echo "${DEFAULT_USER}@${server}.${fqdn}"
done

exit 0
```

```bash
$ ./server_appender.sh
Error: ./fqdn.properties is empty
$ echo $?
1
```

`-s` = le fichier existe **et** n'est pas vide → la guard clause arrête le script.

> `-s` est aussi faux si le fichier **n'existe pas** : le message « is empty » peut donc être trompeur. On peut distinguer les deux cas :
> ```bash
> [[ -f "${CONF_FILE}" ]] || terminate "${CONF_FILE} introuvable" 10
> [[ -s "${CONF_FILE}" ]] || terminate "${CONF_FILE} est vide" 11
> ```

##### Définir une fonction `terminate`

```bash
#!/usr/bin/env bash
set -e

readonly CONF_FILE="./fqdn.properties"
readonly SERVER_NAMES="server1 server2 server3"
readonly DEFAULT_USER="mummshad"
readonly ERROR_FILE=150

terminate() {
    local msg="$1"
    local code="${2:-160}"
    echo "Error: ${msg}" >&2
    exit "${code}"
}

if [[ ! -s "${CONF_FILE}" ]]; then
    terminate "FQDN file is empty" "${ERROR_FILE}"
fi

fqdn=$(cat "${CONF_FILE}")

for server in ${SERVER_NAMES}; do
    echo "${DEFAULT_USER}@${server}.${fqdn}"
done

exit 0
```

```bash
$ ./custom_exit_code_final.sh
Error: FQDN file is empty
$ echo $?
150
```

- `ERROR_FILE=150` : code **nommé** en constante (`readonly`) → l'appelant sait précisément quelle erreur s'est produite.
- `terminate` : message sur **stderr** + `exit` avec le code fourni (**160** par défaut via `${2:-160}`).
- `set -e` : arrêt automatique sur toute autre erreur imprévue.

> Améliorations possibles : `fqdn=$(< "${CONF_FILE}")` (sans lancer `cat`) ; un **tableau** pour la liste des serveurs (`servers=(server1 server2 server3)` puis `"${servers[@]}"`) ; codes dans la plage 3–125 (ex. `ERROR_FILE=10`).

Combiner **`set -e`**, des **codes personnalisés** et une **fonction `terminate`** réutilisable permet d'arrêter le script en cas d'échec et de renvoyer des statuts **significatifs**.

### À retenir

- `$?` = code de sortie de la **dernière** commande/script/fonction ; écrasé à chaque commande.
- Un script renvoie le code de sa **dernière commande** (ou celui de `exit N`).
- Codes clés : **0** succès, **1** générale, **2** mauvais usage, **126** non exécutable, **127** introuvable, **128+n** tué par signal (130 = Ctrl+C).
- Codes personnalisés : de préférence **3 à 125**, déclarés en constantes `readonly`.
- Un `exit 0` en fin de script peut **masquer** une erreur.
- 3 techniques : `if ! cmd; then …`, `cmd || { msg; exit N; }`, `set -e` (attention : jamais en interactif, et exceptions dans `if`/`&&`/`||`).
- Fonction `terminate` : message sur **stderr** (`>&2`) + `exit code`, avec valeur par défaut `${2:-…}`.
- `[[ -s fichier ]]` = existe et non vide ; distinguer « absent » (`-f`) et « vide » si besoin.
- Redirection vers `/dev/null` : la sortie disparaît, mais `$?` reste fiable.

### Liens utiles

- [GNU Bash – Exit Status](https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html)
- [GNU Bash – The Set Builtin (`set -e`)](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- [Advanced Bash-Scripting Guide – Exit Codes With Special Meanings](https://tldp.org/LDP/abs/html/exitcodes.html)
- [ShellCheck SC2181 – tester la commande plutôt que `$?`](https://www.shellcheck.net/wiki/SC2181)
- [BashFAQ 105 – Pourquoi `set -e` ne fait pas toujours ce qu'on attend](https://mywiki.wooledge.org/BashFAQ/105)
