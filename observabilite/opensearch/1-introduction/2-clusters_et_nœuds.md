# Clusters et nœuds

Sa conception distribuée signifie que nous interagissons avec les clusters OpenSearch. Chaque cluster est un ensemble d'un ou plusieurs nœuds, des serveurs qui stockent nos données et traitent les requêtes de recherche.
<br><br>
Nous pouvons exécuter OpenSearch localement sur un ordinateur portable (sa configuration système est minimale), mais nous pouvons également faire évoluer un seul cluster vers des centaines de machines puissantes dans un centre de données.
<br><br>
Dans un cluster à nœud unique, tel qu'un ordinateur portable, une machine doit tout faire : gérer l'état du cluster, indexer et rechercher des données, et effectuer tout prétraitement des données avant de les indexer. Cependant, au fur et à mesure qu'un cluster grandit, nous pouvons subdiviser les responsabilités. Les nœuds avec des disques rapides et beaucoup de RAM peuvent être excellents pour l'indexation et la recherche de données, alors qu'un nœud avec beaucoup de puissance CPU et un petit disque peut gérer l'état du cluster.