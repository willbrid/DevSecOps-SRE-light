# Convention script shell

Les recommandations générales pour les scripts shell :

- Utiliser des minuscules et le snake_case pour les noms de variables. Exemple : `user_uid`.

- Préfixer les options booléennes avec **is_** ou **has_** . Exemple : `is_enabled`, `is_running`.

- Nommer les fonctions avec des verbes et le snake_case. Exemple: `backup_database`, `install_application`.

- Indenter avec deux espaces pour une meilleure lisibilité.

- Organiser les scripts dans les répertoires **bin/**, **lib/** et **conf/**.

Les interpréteurs de commandes appliquent certaines règles (comme l'absence d'espaces autour du caractère = dans les affectations). Il est recommandé de valider toujours nos scripts avec **ShellCheck** ([https://www.shellcheck.net/](https://www.shellcheck.net/)) avant le déploiement.

### Variables

- **Conventions de nommage**

Suivre ces instructions pour créer des noms de variables clairs et documentés :

--- Tous les noms de variables en minuscules : `user_group="admin"`

--- Utiliser des traits de soulignement pour les noms composés de plusieurs mots : `first_name_last_name="willbrid"`

--- Refléter l’objectif de la variable : `config_file="/etc/app.conf"`

--- lettre unique uniquement pour les compteurs simples ou les opérations arithmétiques : `x=10`

- **Définition des constantes**

Si nous avons des valeurs qui ne doivent jamais changer, définissons-les en majuscules **snake_case** et en ajoutant au début le mot clé **readonly**.

```
readonly FILE_NAME="file.txt"
readonly MAX_RETRIES=5
readonly PI=3.14159
```

L'utilisation du mot clé **readonly** a deux objectifs : <br>
--- **clarté**: signale aux lecteurs que ces valeurs sont fixes. <br>
--- **sécurité**: empêche toute réaffectation accidentelle ultérieure dans le script.

- **Exportation de variables**

Exporter des variables lorsque nous en avons besoin dans des **processus enfants**, des **sous-shells** ou des **scripts externes**.

```
source_file="/etc/config.yaml"
export source_file

export HOME_DIR="/home/user"
```

Les variables exportées font partie de l'environnement de toutes les commandes et processus ultérieurs démarrés à partir du shell actuel.

### Fonctions

- **Conventions de nommage**

Adopter une nomenclature cohérente pour que nos fonctions soient **auto-documentées**. Suivre ces règles :

--- Noms en minuscules : `calculate_area`

--- Refléter l’objectif de la fonction : `backup_database`

--- Utiliser des traits de soulignement pour les noms composés de plusieurs mots : `get_user_info`

--- Pas de lettre unique, ni de camelCase : `process_files`

- Définition des fonctions

Utiliser cette syntaxe standard pour déclarer des fonctions :

```
function_name() {
    # corps de fonction
}
```

--- Inclure des parenthèses **()** après le nom. <br>
--- Placer l'accolade ouvrante **{** sur la même ligne, précédée d'un espace. <br>
--- Aligner l'accolade fermante **}** avec la déclaration de la fonction (sans indentation supplémentaire). <br>

```
clone_repo() {
    local repo_url=$1
    git clone "$repo_url"
}
```

- Bonnes pratiques d'implémentation de fonctions

--- Définir des fonctions sans le mot-clé **function**. <br>
--- Utiliser des variables locales (avec le mot clé **local**) pour éviter la pollution de l'espace de noms global. <br>
--- Renvoyer des codes d'état et gérer les erreurs correctement <br>
--- Analyser les options de ligne de commande avec `getopts`.

### Expansion

Dans les scripts shell, l'**expansion de variable** utilise le signe dollar (**$**) pour indiquer au shell de remplacer le nom de la variable par sa valeur stockée.

Par défaut, les **expansions sans guillemets** sont séparées par des espaces définis par la variable d'environnement **IFS** (**espace**, **tabulation**, **saut de ligne**). Utiliser des guillemets pour conserver la valeur exacte.

```
# Sans guillemets
#!/bin/bash
string="One Two Three"

# Divise en mots à cause de ${string}
for element in ${string}; do
  echo "${element}"
done
```

```
# Avec guillemets
#!/bin/bash
string="One Two Three"

# Préserve la chaîne entière comme un seul élément à cause de "${string}"
for element in "${string}"; do
  echo "${element}"
done
```

Dans un script shell sous Linux, il ne faut jamais utiliser une variable non entourée de guillemets (non « quotée ») lorsqu’elle contient une entrée utilisateur ou un nom de fichier. <br>
Sans guillemets, le shell peut interpréter les espaces, les caractères spéciaux ou les métacaractères (*, ?, ;, etc.) d’une manière imprévisible ou dangereuse. Cela peut entraîner :
- des erreurs d’exécution (fichiers mal référencés, commandes tronquées),
- voire des failles de sécurité (injection de commandes).

|Cas d'utilisation|Entre quotes|Entre accolades|Exemple|
|-----------------|------------|---------------|-------|
expansion simple|Facultatif|Facultatif|`echo $var`
ajout de texte à une variable|Facultatif|Obligatoire|`echo "${var}suffix"`
chemins et noms de fichiers|Recommandé|Facultatif|`ls "${directory}/file.txt"`
url et chaînes complexes|Recommandé|Facultatif|`curl "${URL}?id=123&name=abc"`
itérer intentionnellement sur les mots|Facultatif|Facultatif|`for x in ${list}; do ...; done`
prévenir la division des mots|Obligatoire|Facultatif|`read -r line <<< "${input}"`