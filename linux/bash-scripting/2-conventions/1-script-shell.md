# Convention script shell

Les recommandations générales pour les scripts shell :

- Utiliser des minuscules et le snake_case pour les noms de variables. Exemple : `user_uid`.

- Préfixer les options booléennes avec **is_** ou **has_** . Exemple : `is_enabled`, `is_running`.

- Nommer les fonctions avec des verbes et le snake_case. Exemple: `backup_database`, `install_application`.

- Indenter avec deux espaces pour une meilleure lisibilité.

- Organiser les scripts dans les répertoires **bin/**, **lib/** et **conf/**.

Les interpréteurs de commandes appliquent certaines règles (comme l'absence d'espaces autour du caractère = dans les affectations). Il est recommandé de valider toujours nos scripts avec **ShellCheck** ([https://www.shellcheck.net/](https://www.shellcheck.net/)) avant le déploiement.

### Variables

