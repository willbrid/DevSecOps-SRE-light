# Exit code

Sous Unix, chaque application ou commande renvoie un **code de sortie** (*exit status*) : un nombre qui indique le **succès** ou l'**échec**. Par convention :
- **0** = succès ;
- **tout code non nul** = erreur.

Les comprendre est indispensable pour écrire des scripts robustes et une automatisation prévisible.

### 1. Analogie : le livreur de repas

Un livreur vérifie l'adresse avant de partir. Si elle est correcte, il livre ; sinon, il revient avec un **rapport d'erreur**. Les scripts et commandes font pareil :
- ✅ ils **vérifient** les conditions (l'adresse) ;
- ✅ ils **exécutent** la tâche ;
- ✅ ils **rendent compte** de leur statut (tâche accomplie ou non).

### 2. Fonctionnement des codes de sortie sous Unix

Toute commande Unix se termine avec un code :
- **0** : succès
- **≠ 0** : une erreur s'est produite

> Le code de la dernière commande est disponible dans **`$?`** :
> ```bash
> $ ls /tmp > /dev/null
> $ echo $?
> 0
> $ ls /dossier_inexistant
> ls: cannot access '/dossier_inexistant': No such file or directory
> $ echo $?
> 2
> ```
> `$?` est écrasé par **chaque** commande : le lire (ou le sauvegarder dans une variable) **immédiatement**.

#### Tableau des codes courants

| Code | Signification |
|||
| **0** | Succès |
| **1** | Erreur générale |
| **2** | Mauvaise utilisation d'un built-in du shell (mauvais arguments) |
| **126** | Commande trouvée mais **non exécutable** (ex. permissions) |
| **127** | Commande **introuvable** |
| **128+** | Erreur fatale |

Les codes sont limités à la plage **0–255**. Au-delà, la valeur est prise **modulo 256**.

> Précisions :
> - **128 + n** = processus tué par le **signal n** : `130` = Ctrl+C (SIGINT, 2), `137` = `kill -9` (SIGKILL, 9), `143` = SIGTERM (15). Très utile pour comprendre un conteneur Kubernetes en `exit code 137` (souvent un **OOMKilled**).
> - Exemple de dépassement : `exit 256` → code **0** ; `exit 300` → code **44**.
> - Code négatif : `exit -1` → **255**.

Certains codes sont **réservés** par le shell ou l'OS. Définir ses **propres codes** (au-dessus de 2) permet à l'appelant de distinguer les différents types d'échec.

### 3. Codes de sortie personnalisés dans un script

Modèle qui vérifie la présence d'un fichier de configuration et se termine avec un code explicite :

```bash
#!/usr/bin/env bash

export CONF_FILE="/var/tmp/file.conf"

terminate() {
    local message="$1"
    local code="${2:-1}"
    echo "${message}" >&2
    exit "${code}"
}

echo "Starting script execution"
echo "Sourcing configuration file"
if [[ ! -f "${CONF_FILE}" ]]; then
    terminate "Configuration file not found: ${CONF_FILE}" 2
fi

exit 0
```

Fonctionnement :
- `terminate` reçoit un **message** (`$1`) et un **code** (`$2`).
- `${2:-1}` : si aucun code n'est fourni, valeur par défaut **1**.
- Le message est envoyé sur **stderr** (`>&2`).
- `exit "${code}"` termine **tout le script** (même appelé depuis une fonction).
- Si le fichier de config est absent → sortie avec le code **2** ; sinon → `exit 0`.

Exécution sans le fichier :

```bash
$ ./script.sh
Starting script execution
Sourcing configuration file
Configuration file not found: /var/tmp/file.conf
$ echo $?
2
```

> Utiliser des codes **clairs et documentés** pour que les utilisateurs et les autres scripts puissent gérer les erreurs automatiquement.

> Remarques :
> - Le script utilise le code **2**, alors que la leçon recommande des codes **au-dessus de 2** (2 = mauvais usage d'un built-in). Un code dédié (ex. `10` pour « config manquante ») serait plus cohérent.
> - Bonne pratique : déclarer les codes en constantes en haut du script :
>   ```bash
>   readonly E_NO_CONFIG=10
>   readonly E_BAD_ARGS=11
>   terminate "Configuration file not found" "${E_NO_CONFIG}"
>   ```
> - Dans une **fonction**, `return N` renvoie un code **sans quitter** le script, contrairement à `exit N`.
> - `exit` sans argument renvoie le code de la **dernière commande** exécutée.

### À retenir

- **0 = succès**, **≠ 0 = erreur** ; le code de la dernière commande est dans **`$?`** (à lire immédiatement).
- Codes réservés : **1** générale, **2** mauvais usage, **126** non exécutable, **127** introuvable, **128+n** tué par le signal n (130 = Ctrl+C, 137 = SIGKILL/OOM, 143 = SIGTERM).
- Plage **0–255** ; au-delà, modulo 256 (`exit 256` → 0).
- Définir ses **propres codes** (au-dessus de 2, sous 126) et les **documenter** (constantes `readonly`).
- Fonction `terminate` : message sur **stderr** + `exit code` ; `${2:-1}` = valeur par défaut.
- `exit` quitte le script, `return` quitte seulement la fonction.
- Les codes de sortie sont la base de `&&`, `||`, `if`, `set -e` et `pipefail`.

### Liens utiles

- [GNU Bash – Exit Status](https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html)
- [Advanced Bash-Scripting Guide – Exit Codes With Special Meanings](https://tldp.org/LDP/abs/html/exitcodes.html)
