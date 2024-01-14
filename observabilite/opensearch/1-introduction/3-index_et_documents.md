# Index et documents

OpenSearch organise les données en index. Chaque index est une collection de documents JSON. Si nous avons un ensemble d'articles d'encyclopédie bruts ou de lignes de journal que nous souhaitons ajouter à OpenSearch, nous devons d'abord les convertir en JSON. Un simple document JSON pour un film pourrait ressembler à ceci :

```
{
  "title": "The Wind Rises",
  "release_date": "2013-07-20"
}
```

Lorsque nous ajoutons le document à un index, OpenSearch ajoute certaines métadonnées, telles que l'ID unique du document :

```
{
  "_index": "<index-name>",
  "_type": "_doc",
  "_id": "<document-id>",
  "_version": 1,
  "_source": {
    "title": "The Wind Rises",
    "release_date": "2013-07-20"
  }
}
```

Les index contiennent également des mappages et des paramètres :
- Un mappage est la collection de champs que possèdent les documents de l'index. Dans ce cas, ces champs sont **title** et **release_date**.
- Les paramètres incluent des données telles que le nom de l'**index**, la **date de création** et le **nombre de fragments**.