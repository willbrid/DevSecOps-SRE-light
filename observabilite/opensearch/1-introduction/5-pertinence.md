# Pertinence

Lorsque nous recherchons un document, **OpenSearch** fait correspondre les mots de la requête aux mots des documents. Avec l'exemple d'un index ci-dessous contenant 2 documents, si nous recherchons le mot **La**, **OpenSearch** renvoie les documents 1 et 2. À chaque document est attribué un score de pertinence qui nous indique dans quelle mesure le document correspond à la requête.

```
Document 1 : « La beauté est dans l'œil de celui qui regarde »
Document 2 : « La belle et la bête »
```

Les mots individuels d'une requête de recherche sont appelés **termes de recherche**. Chaque **terme de recherche** est noté selon les règles suivantes :

- un **terme de recherche** qui apparaît plus fréquemment dans un document aura tendance à obtenir un score plus élevé. Il s'agit de la **composante fréquence du terme du score**.

- un **terme de recherche** qui apparaît dans plus de documents aura tendance à obtenir un score plus bas. Il s'agit de la **composante fréquence du document inverse du score**.

- une correspondance sur un document plus long devrait avoir tendance à obtenir un score plus bas qu'une correspondance sur un document plus court. Un document contenant un dictionnaire complet correspondrait à n'importe quel mot mais ne serait pas très pertinent pour un mot particulier. Cela correspond au **composant de normalisation de la longueur du score**.