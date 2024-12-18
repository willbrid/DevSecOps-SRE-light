# Index et Document

### Document

Un **document** est une unité qui stocke des informations (texte ou données structurées). Dans **OpenSearch**, les documents sont stockés au format **JSON**.

Nous pouvons considérer un document de plusieurs manières :

- dans une base de données d'étudiants, un document peut représenter un étudiant.
- lorsque nous recherchons des informations, **OpenSearch** renvoie les documents liés à notre recherche.
- un document représente une ligne dans une base de données traditionnelle.

Un simple document JSON pour un film pourrait ressembler à ceci :

```
{
  "title": "The Wind Rises",
  "release_date": "2013-07-20"
}
```

### Index

Un **index** est une collection de **documents**.

Nous pouvons considérer un index de plusieurs manières :

- dans une base de données d'étudiants, un index représente tous les étudiants de la base de données.
- lorsque nous recherchons des informations, nous interrogeons les données contenues dans un index.
- un index représente une table de base de données dans une base de données traditionnelle.

Lorsque nous ajoutons le document à un index, **OpenSearch** ajoute certaines métadonnées, telles que l'ID unique du document :

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