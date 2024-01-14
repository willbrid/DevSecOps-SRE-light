# Données de séries chronologiques dans prometheus

Toutes les données Prometheus sont fondamentalement stockées sous la forme d'une série chronologique. Cela signifie qu'il suit non seulement la valeur actuelle de chaque métrique, mais également l'évolution de chaque métrique au fil du temps. Il est donc construit autour du stockage de données de séries chronologiques.<br>
Les données chronologiques consistent en une série de valeurs associées à différents points.

- Point de données unique vs série chronologique

Nous pouvons suivre un seul point de données, comme la température extérieure actuelle.<br>
Exemple : température extérieure : 0C/31F <br>
Cependant, si nous notons la température une fois par heure, il s'agit d'une série chronologique : <br>
```
08h00 - -6C/21F
09h00 - -3C/26F
10h00 - -2C/28F
11h00 - -0C/31F
```

- Exemple de série chronologique

Chaque métrique dans prometheus suit une valeur particulière au fil du temps. Par exemple, prometheus peut suivre la mémoire disponible pour un serveur, avec une entrée dans la série chronologique pour chaque minute.
```
21/02/2020 09h55 - node_memory_memavailable_bytes=3734269952
21/02/2020 09h56 - node_memory_memavailable_bytes=3734276545
```
