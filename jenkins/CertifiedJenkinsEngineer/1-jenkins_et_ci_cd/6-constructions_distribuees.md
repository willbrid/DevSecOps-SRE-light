# Constructions distribuées

Les constructions (builds) distribués sont des tâches de construction dans lesquelles l'exécuteur de la construction est situé sur un nœud d'agent distinct du maître. Le maître agit en tant que contrôleur pour la construction, exécutant des constructions spécifiques sur les agents, permettant le parallélisme et une plus grande facilité dans les pipelines multiconfiguration.
<br><br>
**Exemple** : si nous aveons 3 versions du logiciel pour effectuer 5 tests unitaires, cela peut être fait en un seul passage parallèle, ce qui donne 5 tests sur chaque agent au lieu de 15 tests sur le maître.
<br><br>
Un nœud avec des configurations spécifiques peut être étiqueté afin que les étapes de pipeline spécifiques à cette configuration soient dirigées vers ce nœud.
<br><br>
Dans la plupart des cas les artefacts, les rapports d'avancement et les résultats de construction sont renvoyés au référentiel maître. Le stockage sur le maître doit être envisagé pour cette raison.
<br><br>
La communication maître/agent se fait via ssh (préféré) ou JNPL (TCP ou HTTP)
<br><br>
L'agent doit être remplaçable. Cela signifie que la configuration locale sur l'agent doit être réduite au minimum et que la configuration globale sur le maître doit être préférée.