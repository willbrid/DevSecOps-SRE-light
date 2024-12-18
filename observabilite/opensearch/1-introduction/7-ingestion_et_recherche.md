# Ingestion et recherche des données

### Ingestion des données

Il existe plusieurs façons d'ingérer des données dans **OpenSearch** :

- Ingérer des documents individuels
- Indexer plusieurs documents en masse via l'api **Bulk**
- Utiliser **Data Prepper**, un collecteur de données côté serveur **OpenSearch** qui peut enrichir les données pour l'analyse et la visualisation en aval
- Utiliser d'autres outils d'ingestion

### Recherche des données

Dans **OpenSearch**, il existe plusieurs façons de rechercher des données :

- **Query domain-specific language (DSL)** : langage de requête principal d'**OpenSearch**, que nous pouvons utiliser pour créer des requêtes complexes et entièrement personnalisables.
- **Query string query language** : un langage de requête réduit que nous pouvons utiliser dans un paramètre de requête d'une demande de recherche ou dans les tableaux de bord OpenSearch.
- **SQL** : un langage de requête traditionnel qui comble le fossé entre les concepts de base de données relationnelle traditionnels et la flexibilité du stockage de données orienté document d'**OpenSearch**.
- **PPL (Piped Processing Language)** : langage principal utilisé pour l'observabilité dans **OpenSearch**. **PPL** utilise une syntaxe de pipe qui enchaîne les commandes dans une requête.
- **Dashboards Query Language (DQL)** : un langage de requête textuel simple pour filtrer les données dans les tableaux de bord **OpenSearch**.