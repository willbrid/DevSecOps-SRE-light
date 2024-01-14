# Haute disponibilité
Les systèmes à haute disponibilité sont des systèmes résilients et durables. Ils sont capables de fonctionner pendant de longues périodes sans panne.
<br>
Rendre prometheus hautement disponible est en fait un processus assez simple. Nous pouvons exécuter plusieurs serveurs prometheus afin que si l'un échoue, d'autres fonctionnent toujours.
<br>
Nous pouvons simplement exécuter plusieurs serveurs prometheus avec la même configuration.
<br>
Chaque serveur récupère les métriques séparément de tous les exportateurs en fonction de la même configuration. Cette simplicité est l'un des avantages de la méthode de collecte de métriques basée sur l'extraction.