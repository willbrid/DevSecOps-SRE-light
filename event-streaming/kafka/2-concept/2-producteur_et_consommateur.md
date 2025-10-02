# Producteur et consommateur

### Producteur

- **Équilibrage de charge**

Le **producteur Kafka** envoie directement les messages au broker leader d’une partition sans aucune couche de routage intermédiaire. Tous les nœuds Kafka peuvent répondre à une requête de métadonnées concernant les nœuds actifs et la localisation des leaders des partitions d'un sujet à tout moment, afin de permettre au producteur d'orienter ses requêtes de manière appropriée. La répartition peut être : 

--- **aléatoire** <br>
--- **déterminée** par une clé de partition (ex. identifiant utilisateur).

- **Envoi asynchrone** 

Le **producteur Kafka** regroupent en mémoire plusieurs messages en lots et envoie ces lots plus volumineux en une seule requête. Le traitement par lots peut être configuré pour ne pas accumuler plus d'un nombre fixe de messages et ne pas dépasser une latence fixe (par exemple 64 Ko ou 10 ms). Cela permet d'accumuler davantage d'octets à envoyer et de limiter les opérations d'E/S importantes sur les serveurs.

### Consommateur

Le **consommateur Kafka** lit les messages en envoyant des requêtes fetch aux brokers, en indiquant l’offset à partir duquel il veut lire. Kafka adopte un modèle pull (et non push) :

- le consommateur contrôle son rythme, peut rejouer des données, et évite d’être saturé par un flux imposé.
- ce modèle favorise le traitement par lots efficace et réduit le gaspillage de ressources.
- pour éviter les interrogations vides, Kafka utilise des requêtes longues qui attendent l’arrivée des données avant de répondre.

**Position du consommateur**

Dans les systèmes de messagerie classiques, le broker suit l’état des messages consommés via des accusés de réception, ce qui entraîne des problèmes de performance (états multiples par message) et de fiabilité (perte ou double consommation possible).

Kafka adopte une approche plus simple :

- chaque partition est consommée par un seul consommateur à la fois au sein de chaque groupe de consommateurs abonnés à un instant donné.
- la position d'un consommateur dans chaque partition correspond à un seul entier indiquant l'offset du prochain message à lire. Cela réduit considérablement l'état des données consommées (peut être vérifié périodiquement), un seul nombre par partition.
- en cas de bug ou d'incident, les consommateurs peuvent revenir en arrière à un offset précédent pour relire des messages (ex. après correction d’un bug).

**Chargement de données hors ligne**

La persistance évolutive permet la prise en charge de consommateurs ponctuels, tels que les chargements de données par lots, qui chargent périodiquement des données en masse dans un système hors ligne : Hadoop ou base de données,...