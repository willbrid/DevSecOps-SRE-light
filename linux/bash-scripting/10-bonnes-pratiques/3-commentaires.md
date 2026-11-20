# Commentaires

Des commentaires **clairs et concis** rendent les scripts shell plus faciles à **maintenir**, **comprendre** et **faire évoluer**. Voici les bonnes pratiques pour des scripts bien documentés.

### 1. Structure de l'en-tête

Un en-tête standardisé contient généralement :

| Champ | Rôle |
|---|---|
| **Shebang** | Définit l'interpréteur (`#!/usr/bin/env bash`) |
| **Résumé** | Description en une ligne de ce que fait le script |
| **Usage** | Comment lancer le script, avec ses options |
| **Codes de sortie** | Liste des codes possibles et leur signification |
| **Auteur** | Nom et contact |

> Avec un gestionnaire de versions comme **Git**, inclure un **historique des modifications** dans les commentaires est généralement **inutile** : `git log` et `git blame` le font mieux.

### 2. Exemple d'en-tête

```bash
#!/usr/bin/env bash
#
# Script usage: Brief summary of the script's purpose and how to invoke it.
# Exit codes: 0 = Success, 1 = General error, 2 = Missing arguments
# Author: Your Name <your.email@example.com>
```

> Version plus complète, cohérente avec les leçons précédentes (`$0`, `terminate`, codes personnalisés) :
> ```bash
> #!/usr/bin/env bash
> #
> # backup.sh - Sauvegarde un répertoire dans une archive horodatée.
> #
> # Usage: backup.sh <source_dir> <dest_dir>
> #   -h, --help    Affiche l'aide
> #
> # Exit codes:
> #   0   Succès
> #   1   Erreur générale
> #   10  Argument manquant
> #   11  Répertoire source introuvable
> #
> # Author: Prénom Nom <prenom.nom@example.com>
>
> set -euo pipefail
>
> readonly E_MISSING_ARG=10
> readonly E_NO_SOURCE=11
> ```
> Les codes documentés dans l'en-tête doivent correspondre aux constantes `readonly` du script.

### 3. Conseils pour des commentaires efficaces

- Garder les lignes **sous 80 caractères** pour la lisibilité.
- Écrire des **phrases complètes** quand la clarté l'exige.
- **Mettre à jour** les commentaires à chaque modification du code concerné (un commentaire faux est pire que pas de commentaire).
- **Éviter de sur-commenter** le code trivial : expliquer l'**intention** (le *pourquoi*), pas l'**implémentation** (le *comment*).

> Exemples :
> ```bash
> # ❌ Inutile : répète le code
> # Incrémente i
> (( i++ ))
>
> # ✅ Utile : explique le pourquoi
> # On attend 5 s : l'API renvoie 429 si on dépasse 1 requête/seconde.
> sleep 5
> ```
>
> Commenter les **fonctions** (style Google Shell Style Guide) :
> ```bash
> #######################################
> # Supprime les sauvegardes plus anciennes que N jours.
> # Arguments:
> #   $1 - Répertoire des sauvegardes
> #   $2 - Nombre de jours à conserver
> # Outputs:
> #   Écrit les fichiers supprimés sur stdout
> # Returns:
> #   0 si succès, 1 si le répertoire n'existe pas
> #######################################
> cleanup_old_backups() {
>   …
> }
> ```
>
> Marqueurs utiles : `# TODO:`, `# FIXME:` (repérables avec `grep -rn TODO`).
>
> Commentaire **multiligne** (Bash n'en a pas de natif) : préfixer chaque ligne par `#`. L'astuce `: <<'COMMENT' … COMMENT` existe, mais elle reste du code exécuté (heredoc passé à `:`) → à réserver pour désactiver temporairement un bloc.

### À retenir

- Un en-tête standard : **shebang**, **résumé**, **usage**, **codes de sortie**, **auteur**.
- Pas d'historique des changements dans le script : **Git** s'en charge.
- Lignes **< 80 caractères**, phrases complètes si nécessaire.
- Commenter le **pourquoi** (intention), pas le **comment** (ce que le code dit déjà).
- Mettre à jour les commentaires **avec** le code ; un commentaire obsolète induit en erreur.
- Documenter les **fonctions** (arguments, sorties, codes de retour) et garder l'en-tête cohérent avec les constantes du script.
- `# TODO:` / `# FIXME:` pour marquer le travail restant.

### Liens utiles

- [Google Shell Style Guide – Comments](https://google.github.io/styleguide/shellguide.html#s4-comments)
- [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [Git – Documentation](https://git-scm.com/doc)
- [ShellCheck](https://www.shellcheck.net/)
