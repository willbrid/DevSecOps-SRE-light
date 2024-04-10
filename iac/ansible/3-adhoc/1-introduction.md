# Introduction aux commandes adhoc

Le nombre de serveurs gérés par un administrateur individuel a considérablement augmenté au cours de la dernière décennie, d'autant plus que la virtualisation et l'utilisation croissante des applications cloud sont devenues monnaie courante. En conséquence, les administrateurs ont dû trouver de nouvelles façons de gérer les serveurs de manière rationalisée. Chaque jour, un administrateur système a de nombreuses tâches :

Le nombre de serveurs gérés par un administrateur individuel a considérablement augmenté au cours de la dernière décennie, d'autant plus que la virtualisation et l'utilisation croissante des applications cloud sont devenues monnaie courante. En conséquence, les administrateurs ont dû trouver de nouvelles façons de gérer les serveurs de manière rationalisée. Chaque jour, un administrateur système a de nombreuses tâches :

- appliquer des correctifs et des mises à jour via **dnf** , **apt** et d'autres **gestionnaires de packages**.
- vérifier l'utilisation des ressources (espace disque, mémoire, CPU, espace d'échange, réseau).
- vérifier les fichiers journaux.
- gérer les utilisateurs et les groupes du système.
- gérer les paramètres DNS, les fichiers hôtes, etc.
- copiez des fichiers vers et depuis des serveurs.
- déployez des applications ou exécutez la maintenance des applications.
- redémarrez les serveurs.
- gérer les tâches cron.

Presque toutes ces tâches peuvent être (et sont généralement) au moins partiellement automatisées, mais certaines nécessitent souvent une intervention humaine, en particulier lorsqu'il s'agit de diagnostiquer des problèmes en temps réel. Et dans les environnements multi-serveurs complexes d'aujourd'hui, se connecter individuellement aux serveurs n'est pas une solution viable. **Ansible** permet aux administrateurs d'exécuter des commandes **ad hoc** sur une ou des centaines de machines en même temps, à l'aide de la commande **ansible**.