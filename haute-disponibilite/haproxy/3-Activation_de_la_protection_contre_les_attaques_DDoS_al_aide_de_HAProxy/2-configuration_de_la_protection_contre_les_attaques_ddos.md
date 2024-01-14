# Configuration de la protection contre les attaques DDoS

## Faire face aux attaques

Les types communs d'attaques :

- **HTTP Flood** : submerger le site avec le volume de requête http
- **slowloris** : requêtes lentes - lier les connexions
- **caractéristiques statiques** : ACLs - blocage par adresse IP

## Qu'est ce qu'un reverse-proxy ?

Un reverse-proxy, habituellement placé en amont des serveurs internes, permet aux utilisateurs d'Internet d'accéder à ces serveurs internes.

- Quelques avantages : <br>
--- intercepter les requêtes <br>
--- agir sur les requêtes <br>
--- augmenter la sécurité du site : <br>
----- rejeter les requêtes malveillantes <br>
----- empêcher la communication directe avec les serveurs internes

## Comment est faite la protection contre les attaques DDoS sur Haproxy ?

Quelle est la différence entre le HTTP et le TCP load balancing ?

- Le HTTP load balancing repose sur la couche 7 du modèle OSI. Il agit sur les données trouvées dans la couche d'application HTTP. 
- Le TCP load balancing repose sur la couche 4 du modèle OSI. Il agit sur les données trouvées dans les couches réseau et transport.

Les fonctionnalités haproxy utilisées pour implémenter ces protections :

- **ACLs** : il exécute une ou plusieurs actions en fonction d'une condition
- **Maps** : il recherche la table qui stocke les paires clé-valeur. Il peut être édité directement, via **api** ou en utilisant **http-request set-map**
- **Stick Tables** : magasin **clé-valeur** pour le suivi du nombre de certains éléments. La **clé** est ce que nous monitorons (client Adresse IP) et la **valeur** compte ce que nous monitorons (le nombre de requêtes IP des clients au cours des 10 dernières secondes). Il s'appuie fortement sur les ACLs. L'on doit avoir seulement 1 **Stick table** par **frontend** ou **backend**.