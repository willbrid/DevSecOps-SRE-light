# Opérateurs de requête

Les opérateurs nous permettent d'effectuer des calculs basés sur nos données métriques. Il existe plusieurs types d'opérateurs.

## opérateurs binaires arithmétiques.
Les opérateurs suivants effectuent des opérations arithmétiques de base sur des valeurs numériques.
```
+ : addition
- : soustraction
* : multiplication
/ : division
% : modulo
^ : exponentiation
```

Exemple
```
node_cpu_seconds_total * 2
```

- Règles de correspondance

Lors de l'utilisation d'opérateurs, prometheus utilise des règles de correspondance pour déterminer comment combiner ou comparer les enregistrements de deux ensembles de données. Par défaut, les enregistrements ne correspondent que si tous leurs étiquettes correspondent.<br>
Utilisons les mots clés suivants pour contrôler le comportement de correspondance : <br>
--- Ignorer les étiquettes spécifiées lors de la correspondance
```
ignoring(label list)
```

--- utiliser uniquement les étiquettes spécifiées lors de la correspondance
```
on(liste d'étiquettes)
```

exemple :
```
node_cpu_seconds_total{mode="system"} + ignoring(mode) node_cpu_seconds_total{mode="user"}
node_cpu_seconds_total{mode="system"} + on(cpu) node_cpu_seconds_total{mode="user"}
```

## Opérateurs binaires de comparaison
Par défaut, les opérateurs binaires de comparaison filtrent les résultats uniquement pour ceux pour lesquels la comparaison est évaluée comme vraie.
```
== : égal à
!= : inégal
> : supérieur
< : inférieur
>= : supérieur ou égal
<= : inférieur ou égal
```

Exemple :
```
node_cpu_seconds_total == 0
```

Utilisons le modificateur **bool** pour renvoyer à la place le résultat booléen de la comparaison :
```
node_cpu_seconds_total == bool 0
```

## Opérateurs binaires logiques/set
ces opérateurs combinent des ensembles de résultats de différentes manières.
```
and : intersection
or : union
unless : complément
```

Ces opérateurs utilisent des étiquettes pour comparer les enregistrements. Par exemple, **and** ne renvoie que les enregistrements dans lesquels l'ensemble d'étiquettes d'un ensemble de résultats correspond aux étiquettes de l'autre ensemble.
```
node_cpu_seconds_total and node_cpu_guest_seconds_total
```

## Opérateurs d'agrégation
Les opérateurs d'agrégation combinent plusieurs valeurs en une seule valeur.
```
sum : additionner toutes les valeurs
min : sélectionner la plus petite valeur
max : sélectionner la grande petite valeur
avg : calculer la moyenne de toutes les valeurs
stddev : calculer l'écart-type de la population sur toutes les valeurs
stdvar : calculer la variance standard de la population sur toutes les valeurs
count : compter le nombre de valeurs
count_values : compter le nombre de valeurs avec la même valeur
bottomk : plus petit nombre k d'éléments
topk : plus grand nombre k d'éléments
quantile : calculer le quantile pour une dimension particulière
```

Cette requête utilise **avg** pour obtenir le temps d'inactivité moyen entre tous les processeurs.
```
avg(node_cpu_seconds_total{mode="idle"}) 
```