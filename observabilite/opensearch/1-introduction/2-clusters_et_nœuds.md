# Clusters et nœuds

**OpenSearch** est conçu pour être un moteur de recherche distribué, ce qui signifie qu'il peut s'exécuter sur un ou plusieurs nœuds (serveurs qui stockent nos données et traitent les requêtes de recherche). Un cluster **OpenSearch** est un ensemble de nœuds.

Nous pouvons exécuter **OpenSearch** localement sur un ordinateur portable (ses exigences système sont minimales), mais nous pouvons également faire évoluer un seul cluster vers des centaines de machines puissantes dans un centre de données.

Dans un cluster à nœud unique, tel qu'un cluster déployé sur un ordinateur portable, une machine doit effectuer toutes les tâches : gérer l'état du cluster, indexer et rechercher des données, et effectuer tout prétraitement des données avant leur indexation. Cependant, à mesure que le cluster se développe, nous pouvons subdiviser les responsabilités. Les nœuds dotés de disques rapides et de beaucoup de RAM peuvent bien fonctionner lors de l'indexation et de la recherche de données, tandis qu'un nœud doté d'une grande puissance de processeur et d'un petit disque peut gérer l'état du cluster.

Dans chaque cluster, il existe un nœud de gestionnaire de cluster élu, qui orchestre les opérations au niveau du cluster, telles que la création d'un index. Les nœuds communiquent entre eux. Ainsi, si notre requête est acheminée vers un nœud, ce nœud envoie des requêtes à d’autres nœuds, collecte les réponses des nœuds et renvoie la réponse finale.