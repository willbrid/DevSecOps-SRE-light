# Fragments

### Concepts

**OpenSearch** divise les index en fragments pour une distribution uniforme sur les nœuds d'un cluster. Chaque fragment stocke un sous-ensemble de tous les documents d'un index. Par exemple, un index de 400 Go peut être trop volumineux pour être géré par un seul nœud de notre cluster, mais divisé en dix fragments, chacune de 40 Go, **OpenSearch** peut répartir les partitions sur dix nœuds et travailler avec chaque partition individuellement.

Bien qu'il ne s'agisse que d'un élément d'un index **OpenSearch**, chaque fragment est en réalité un index Lucene complet. Chaque instance de Lucene est un processus en cours d'exécution qui consomme du processeur et de la mémoire. Une bonne règle empirique consiste à limiter la taille du fragment à **10-50 Go**.

### Fragments principaux et Fragments répliqués

Dans **OpenSearch**, un fragment peut être soit un **fragment principal (original)**, soit un **fragment répliqué (copie)**. Par défaut, **OpenSearch** crée un **fragment répliqué** pour chaque **fragment principal**. Si nous divisons notre index en dix **fragments principaux**, par exemple, **OpenSearch** crée également dix **fragments répliqués**. Ces **fragments répliqués** agissent comme des sauvegardes en cas de défaillance d'un nœud (**OpenSearch** distribue les **fragments répliqués** à des nœuds différents de leurs **fragments principaux** correspondants), mais ils améliorent également la vitesse et le taux à laquelle le cluster peut traiter les demandes de recherche. Nous pouvons spécifier plusieurs **fragments répliqués** par index pour une charge de travail intensive en recherche.