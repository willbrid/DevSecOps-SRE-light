# Fonctions de requête
Les fonctions fournissent un large éventail de fonctionnalités intégrées pour faciliter le processus d'écriture des requêtes.<br>
Consultons la documentation prometheus pour une liste complète des fonctions disponibles. <br>

Quelques fonctions :
```
abs() : calcule la valeur absolue
clamp_max() : renvoie la valeur mais les remplace par une valeur maximale si elles dépassent cette valeur
clamp_min() : renvoie la valeur mais les remplace par une valeur minimale si elles sont inférieures à cette valeur
```

Exemple :
```
clamp_max(node_cpu_seconds_total{cpu="0"}, 1000)
```

Fonction de taux (rate()): il s'agit d'une fonction particulièrement utile pour suivre le taux d'augmentation moyen par seconde d'une valeur de série chronologique. <br>
Par exemple, cette fonction est utile pour alerter lorsqu'une métrique particulière "monte" ou augmente anormalement rapidement. <br>
Exemple :
```
rate(node_cpu_seconds_total[1h])
```