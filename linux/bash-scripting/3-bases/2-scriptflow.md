# Scriptflow

## A- Introduction

### 1. Cycle de vie d'un script shell

Tout script passe par quatre phases prévisibles :

| Phase | Description |
|---|---|
| **Invocation** | L'interpréteur est lancé via le shebang `#!` (ex. `#!/bin/bash`) |
| **Analyse (parsing)** | Le shell lit le script, le découpe en tokens et vérifie la syntaxe |
| **Exécution** | Les commandes s'exécutent dans l'ordre ou via des appels de fonctions |
| **Terminaison** | Le script se termine avec un code de sortie (`0` = succès, autre = erreur) |

### 2. Exécution impérative, de haut en bas

Par défaut, Bash exécute les commandes **dans l'ordre, du haut vers le bas**. Ce style est simple, mais devient difficile à gérer quand le script grossit.

```bash
#!/bin/bash

echo "Hello World"
echo "Hello World one more time"
echo "Hello World one last time"
```

Les commandes interactives fonctionnent de la même manière :

```bash
$ ls
documents  download  music  pict
```

Un script combine des binaires externes, des commandes intégrées (built-ins), de la logique conditionnelle et une syntaxe spécifique pour automatiser des tâches répétitives.

### 3. Organiser le code avec des fonctions

Une fonction regroupe de la logique dans un bloc réutilisable. **La déclarer ne l'exécute pas** : il faut l'appeler explicitement.

```bash
#!/bin/bash

echo_function() {
    echo "This function runs only when called, even if declared above."
}

echo "This is the first line of the script."

# Appel de la fonction deux fois
echo_function
echo_function
```

Résultat : la ligne « first line » s'affiche en premier, puis le message de la fonction deux fois.

Avantages : meilleure **lisibilité**, **maintenabilité** et **testabilité**.

### 4. Gestion des erreurs et codes de sortie

Un script fiable doit signaler le succès ou l'échec de chaque étape. Par exemple si la création d'un répertoire échoue, le script doit s'arrêter immédiatement plutôt que provoquer des erreurs en cascade.

Deux techniques courantes :

- **`set -e`** en haut du script : arrêt dès qu'une commande échoue.
- **Vérifier explicitement le code de retour** des commandes critiques via `$?` :

```bash
mkdir /important/dir
if [[ $? -ne 0 ]]; then
    echo "Failed to create /important/dir" >&2
    exit 1
fi
```

> Toujours valider le résultat des opérations sur le système de fichiers et des commandes externes : une erreur non gérée peut se transformer en incident plus grave.

## B- Exécution

Maîtriser le chemin d'exécution d'un script est essentiel pour écrire des scripts Bash fiables. Par défaut, un script s'exécute **séquentiellement**, mais on peut modifier cet ordre grâce à des instructions de contrôle : **conditions, boucles, sourcing de fichiers et fonctions**. Elles permettent de :

- exécuter des commandes **uniquement si** certaines conditions sont remplies ;
- **répéter** des commandes plusieurs fois avec des entrées différentes.

### 1. Analogie : acheter un billet de cinéma

Au guichet d'un cinéma, si vous présentez un billet valide, vous entrez ; sinon, on vous refuse l'accès. Ce mécanisme de décision correspond exactement à une instruction `if` en Bash, qui évalue une condition puis choisit une branche.

### 2. Analogie : l'usine (workflows complexes)

Dans une usine, les pièces avancent sur un tapis roulant. À un poste d'inspection, les pièces défectueuses sont retirées et les bonnes passent à l'étape suivante. Ce poste joue le rôle d'une instruction de contrôle : il décide si les données continuent leur chemin ou sont traitées autrement.

### 3. Les instructions qui modifient le flux

| instruction | Rôle | Exemple de syntaxe |
|---|---|---|
| Condition (`if`, `case`) | Brancher selon une condition | `if [[ $x -gt 5 ]]; then … fi` |
| Boucle (`for`, `while`, `until`) | Répéter un bloc tant qu'une condition n'a pas changé | `for i in {1..3}; do … done` |
| Sourcing de fichier externe | Inclure et exécuter un autre script à l'exécution | `source config.sh` |
| Fonction | Encapsuler et réutiliser du code | `my_func() { echo "Hi"; }` |


### 4. Les conditions

#### `if`

La commande de test `[[ … ]]` offre des vérifications plus riches que `[ … ]`.

```bash
#!/usr/bin/env bash
# Ce bloc ne s'exécute jamais car 3 n'est pas supérieur à 4
if [[ 3 -gt 4 ]]; then
    echo "This will never be printed"
fi
```

> Préférer `[[ … ]]` à `[ … ]` : il gère le **pattern matching** et les **opérateurs logiques** (`&&`, `||`).

#### `case`

Idéal pour comparer une variable à **plusieurs motifs** de façon lisible.

```bash
#!/usr/bin/env bash
action="$1"

case "$action" in
  start)
    echo "Starting service";;
  stop)
    echo "Stopping service";;
  restart)
    echo "Restarting service";;
  *)
    echo "Usage: $0 {start|stop|restart}";;
esac
```

- `;;` termine chaque branche.
- `*)` est le cas par défaut (aucun motif ne correspond).

### 5. Les boucles

Les boucles servent à exécuter des commandes plusieurs fois : un nombre fixe de fois, ou jusqu'à ce qu'une condition change. Cinq modèles courants :

**1. `while` avec compteur**
```bash
#!/usr/bin/env bash
i=1
while [[ $i -le 3 ]]; do
    echo "Iteration $i"
    i=$(( i + 1 ))
done
```

**2. `for` avec expansion d'accolades**
```bash
#!/usr/bin/env bash
for i in {1..3}; do
    echo "Iteration $i"
done
```

**3. `until` en décompte**
```bash
#!/usr/bin/env bash
i=3
until [[ $i -eq 0 ]]; do
    echo "Iteration $i"
    i=$(( i - 1 ))
done
```

**4. `seq` redirigé (pipe) vers `while`**
```bash
#!/usr/bin/env bash
seq 1 3 | while read -r i; do
    echo "Iteration $i"
done
```

**5. Lecture d'un fichier ligne par ligne**
```bash
#!/usr/bin/env bash
while read -r line; do
    echo "Line: $line"
done < fds.txt
```

> for` : quand le **nombre d'itérations est connu** à l'avance.
> `while` / `until` : quand on attend une **condition dynamique** ou un **événement externe**.

### 6. Sourcing de fichiers externes

On peut importer un autre script ou un fichier de configuration **en cours d'exécution** avec `source` ou son raccourci `.`. Son contenu est fusionné dans l'**environnement du shell courant** (les variables définies deviennent disponibles).

#### Exemple v1 : sourcing simple

```bash
# Le fichier .conf contient par ex. : name="Bob Doe"
#!/usr/bin/env bash
source .conf
echo "${name}"
```

```bash
$ ./conf_read-v1.sh
Bob Doe
```

#### Exemple v2 : sourcing sécurisé avec valeur par défaut

```bash
#!/usr/bin/env bash
readonly CONF_FILE=".conf"

if [[ -f "${CONF_FILE}" ]]; then
    source "${CONF_FILE}"
else
    name="Bob"
fi

echo "${name}"
exit 0
```

Sans fichier `.conf` → valeur par défaut :

```bash
$ ./conf_read-v2.sh
Bob
```

Avec un fichier `.conf` présent :

```bash
$ echo 'name="Juan Carlos"' > .conf
$ ./conf_read-v2.sh
Juan Carlos
```

> Toujours vérifier ou assainir les fichiers sourcés : `source` **exécute** leur contenu, un fichier non fiable peut lancer du code malveillant.

### À retenir

- Le **shebang** (`#!/bin/bash`) détermine l'interpréteur utilisé.
- Un script suit 4 phases : **invocation → parsing → exécution → terminaison**.
- Bash exécute les commandes **de haut en bas** par défaut.
- Une **fonction déclarée n'est exécutée que lorsqu'elle est appelée**.
- Code de sortie **`0` = succès**, toute autre valeur = erreur.
- `set -e` arrête le script à la première erreur ; `$?` permet de tester le code de retour de la dernière commande.
- Les messages d'erreur s'envoient sur **stderr** avec `>&2`, suivis d'un `exit 1`.

- Un script s'exécute **séquentiellement** par défaut ; 4 instructions modifient ce flux : **conditions, boucles, sourcing, fonctions**.
- `[[ … ]]` est préférable à `[ … ]` (motifs, opérateurs logiques).
- `case` remplace avantageusement une suite de `if/elif` pour tester une même variable ; `*)` = cas par défaut, `;;` = fin de branche.
- `for` → nombre d'itérations connu ; `while`/`until` → condition dynamique.
- `while` continue **tant que** la condition est vraie ; `until` continue **jusqu'à ce qu'elle** devienne vraie.
- `while read -r line; do …; done < fichier` est le modèle standard pour lire un fichier ligne par ligne.
- `source fichier` (ou `. fichier`) charge le contenu dans le shell courant ; vérifier l'existence avec `[[ -f … ]]` et prévoir une valeur par défaut.
- `readonly` empêche la modification d'une variable (utile pour les constantes comme un chemin de config).

### Liens utiles

- [Bash Reference Manual (GNU)](https://www.gnu.org/software/bash/manual/)
- [Bash Reference Manual (GNU)](https://www.gnu.org/software/bash/manual/bash.html)
- [Advanced Bash-Scripting Guide (TLDP)](https://tldp.org/LDP/abs/html/)
- [ShellCheck – linter pour Bash](https://www.shellcheck.net/)