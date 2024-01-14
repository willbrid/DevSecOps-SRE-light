# API Rest

Nous interagissons avec les clusters OpenSearch à l'aide de l'API REST, qui offre une grande flexibilité. Nous pouvons utiliser des clients comme curl ou n'importe quel langage de programmation capable d'envoyer des requêtes HTTP. Pour ajouter un document JSON à un index OpenSearch (c'est-à-dire indexer un document), vous envoyez une requête HTTP :

```
PUT https://<host>:<port>/<index-name>/_doc/<document-id>
{
  "title": "The Wind Rises",
  "release_date": "2013-07-20"
}
```

Pour lancer une recherche du document :

```
GET https://<host>:<port>/<index-name>/_search?q=wind
```

Pour supprimer un document :

```
DELETE https://<host>:<port>/<index-name>/_doc/<document-id>
```

Nous pouvons modifier la plupart des paramètres OpenSearch à l'aide de l'API REST, modifier les index, vérifier la santé du cluster, obtenir des statistiques.