# Vérifier l'achèvement des tâches planifiées

Un serveur Linux comporte plusieurs tâches cron planifiées pour diverses tâches. Comment pouvez-vous confirmer que les tâches s'exécutent comme prévu ?

Les informations peuvent être écrites à plusieurs endroits qui peuvent varier selon les distributions linux. Les tâches peuvent écrire dans des journaux personnalisés ou dans les journaux système.

C'est une bonne pratique de faire à ce que chaque tâche puisse écrire dans son propre fichier journal unique dans un répertoire spécifique. Avec cette méthode, nous pouvons contrôler l'emplacement de chaque journal et disposerons d'un fichier ciblé à examiner.