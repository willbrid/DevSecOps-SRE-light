# Notions de base sur les requêtes

## sélecteurs
Le composant le plus basique de la requête promQL est un **sélecteur** de séries temporelles. Un **sélecteur** de séries chronologiques est un simple nom de métrique, éventuellement associé à des étiquettes. <br> 
Les deux éléments suivants sont des sélecteurs de séries chronologiques valides : <br>
- node_cpu_seconds_total
- node_cpu_seconds_total{cpu="0"}

Lorsque plusieurs valeurs existent pour l'étiquette dans les données prometheus et que nous ne spécifions pas l'étiquette dans votre requête, prometheus renverra simplement des données pour toutes les valeurs de l'étiquette.

## Etiquettes correspondant
Nous pouvons utiliser une variété d'opérateurs pour effectuer des correspondances avancées basées sur des valeurs d'étiquette. <br>
- = : égal
- != : n'est pas égal
- =~ : correspondance d'expression régulière
- !~ : ne correspond pas à la regex

Exemple :
```
node_cpu_seconds_total{cpu="0"}
node_cpu_seconds_total{cpu!="0"}
node_cpu_seconds_total{cpu=~"1*"}
node_cpu_seconds_total{cpu!~"1*"}
node_cpu_seconds_total{mode=~"s.*"}
node_cpu_seconds_total{mode=~"user|system"}
node_cpu_seconds_total{mode!~"user|system"}
```

## Sélecteurs de vecteur de plage
Étant donné que les données prometheus sont fondamentalement des données de séries chronologiques, nous pouvons sélectionner des points de données sur une plage de temps particulière.<br>
Comme exemple cette requête ci-dessous sélectionne toutes les valeurs pour le nom et l'étiquette de la métrique enregistrées au cours des deux dernières minutes :
```
node_cpu_seconds_total{cpu="0"}[2m]
```

## Modificateur de décalage
Nous pouvons utiliser un modificateur de décalage pour fournir un décalage temporel à sélectionner dans le passé, avec ou sans sélecteur de plage. <br>
Par exemple sélectionnons l'utilisation du processeur il y a une heure :
```
node_cpu_seconds_total offset 1h
```

Sélectionnons les valeurs d'utilisation du processeur sur une période de cinq minutes il y a une heure :
```
node_cpu_seconds_total[5m] offset 1h
```