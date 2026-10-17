# Fonctions

Les fonctions permettent de **structurer, réutiliser et maintenir** ses scripts. Bash propose aussi les conditions, les boucles et le sourcing, mais les fonctions sont la clé d'un code **modulaire et lisible**.

### 1. Pourquoi définir des fonctions ?

Une fonction regroupe une suite de commandes en **une seule unité appelable**. Cela réduit la répétition, limite les erreurs et rend le script plus facile à modifier et à tester.

Analogie : un chef met au point une recette une fois, puis la réutilise chaque fois qu'il en a besoin.

#### Script de sauvegarde : avant / après

**Sans fonction :**

```bash
#!/bin/bash

mkdir backup
cd backup
cp -r "${1}" .
tar -czvf backup.tar.gz *
echo "Backup complete!"
```

**Avec une fonction :**

```bash
#!/bin/bash

perform_backup() {
    mkdir -p backup
    cd backup || exit 1
    cp -r "${1}" .
    tar -czvf backup.tar.gz *
    echo "Backup complete!"
}

perform_backup "${1}"
exit 0
```

> Utiliser `mkdir -p` pour éviter une erreur si le dossier existe déjà, et ajouter `|| exit 1` après `cd` pour arrêter le script si le changement de répertoire échoue.

> Remarque : `"${1}"` dans la fonction désigne le **1er argument passé à la fonction**, pas celui du script. C'est pour ça qu'on appelle `perform_backup "${1}"` en lui transmettant l'argument du script.



### 2. Refactoriser un exemple `git clone`

Regrouper les tâches liées dans des fonctions clarifie le flux principal du script.

**Version ad hoc :**

```bash
# Cloner et compter les fichiers
git clone "${1}"
find . -type f | wc -l
```

**Version refactorisée :**

```bash
git_url="${1}"

clone_git() {
  git clone "${1}"
}

count_files() {
  find . -type f | wc -l
}

clone_git "${git_url}"
count_files
```

Nommer `clone_git` et `count_files` isole la logique et facilite les tests.

### 3. Syntaxe de déclaration

Deux styles sont possibles ; le premier est recommandé pour une **compatibilité maximale** (POSIX).

**Style préféré (compatible POSIX) :**

```bash
my_function() {
  echo "Hello from my_function"
}
```

**Avec le mot-clé `function` (spécifique Bash) :**

```bash
function my_function {
  echo "Hello from my_function"
}
```

On peut aussi définir et appeler une fonction **directement dans le terminal** :

```bash
$ hello() { echo "Hi there"; }
$ hello
Hi there
```

> Attention à la syntaxe sur une ligne : un **espace après `{`** et un **`;` avant `}`** sont obligatoires.

### 4. Variables locales

Le mot-clé `local` limite la portée d'une variable à la fonction, pour éviter les effets de bord.

**La variable n'est pas visible hors de la fonction :**

```bash
#!/bin/bash

my_function() {
    local var1="Hello"
}

my_function
echo "${var1}"  # Aucune sortie
```

**Utilisation de la variable à l'intérieur de la fonction :**

```bash
#!/bin/bash

my_function() {
    local var1="Hello"
    echo "${var1}"
}

my_function  # Affiche : Hello
```

> `local` évite les collisions de noms de variables dans les gros scripts. Sans `local`, toute variable définie dans une fonction est **globale**.

### 5. Avantages des fonctions

- **Organisation** : découper un gros script en unités logiques.
- **Réutilisabilité** : appeler le même code plusieurs fois sans le dupliquer.
- **Lisibilité** : donner un nom explicite à une logique complexe.
- **Maintenabilité** : modifier une seule fonction plutôt que plusieurs blocs de code.
- **Code plus court** et plus **facile à gérer**.

### À retenir

- Une fonction se déclare avec `nom() { … }` (style POSIX recommandé) ou `function nom { … }`.
- **Déclarer une fonction ne l'exécute pas** : il faut l'appeler par son nom.
- Les arguments s'utilisent dans la fonction via `$1`, `$2`… (propres à la fonction, distincts de ceux du script).
- Les variables sont **globales par défaut** ; utiliser `local` pour les limiter à la fonction.
- Bonnes pratiques : `mkdir -p` et `cd dossier || exit 1` pour éviter les erreurs en cascade.
- Refactoriser en fonctions rend le **flux principal** du script lisible en quelques lignes.
- En une ligne : `f() { cmd; }` → espace après `{` et `;` avant `}`.

### Liens utiles

- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [LinuxCommand.org – Writing Shell Scripts](https://linuxcommand.org/lc3_writing_shell_scripts.php)
- [Stack Overflow – Définir des fonctions en Bash](https://stackoverflow.com/questions/9198033/defining-functions-in-bash)
