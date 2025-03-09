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

Nous pouvons considérer un **index** de plusieurs manières :

- dans une base de données d'étudiants, un **index** représente tous les étudiants de la base de données.
- lorsque nous recherchons des informations, nous interrogeons les données contenues dans un **index**.
- un **index** représente une table de base de données dans une base de données traditionnelle.

### Index inversé

Un **index OpenSearch** utilise une structure de données appelée **index inversé**. Un **index inversé** associe les mots aux documents dans lesquels ils apparaissent. Par exemple, considérons un index contenant les deux documents suivants :

```
Document 1 : « La beauté est dans l'œil de celui qui regarde »
Document 2 : « La belle et la bête »
```

Un **index inversé** pour un tel index associe les mots aux documents dans lesquels ils apparaissent

```
La     ->   documents : 1,2
est    ->   documents : 1
dans   ->   documents : 1
et     ->   documents : 2
```

En plus de l'ID du document, **OpenSearch** stocke la position du mot dans le document pour exécuter des requêtes de phrase, où les mots doivent apparaître les uns à côté des autres.