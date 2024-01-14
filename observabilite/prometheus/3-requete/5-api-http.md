# Prometheus : api http

Prometheus http api : prometheus fournit une API http que nous pouvons utiliser pour exécuter des requêtes et obtenir des résultats à l'aide de requêtes http.<br>
Cette API est un moyen utile d'interagir avec prometheus, en particulier si nous créeons nos propres outils personnalisés nécessitant un accès aux données de prometheus. <br><br>

Requête via l'api http : nous pouvons exécuter des requêtes via l'api à **/api/v1/query** sur le serveur prometheus. <br>
Utilisons le paramètre de requête pour spécifier notre requête :
```
/api/v1/query?query=node_cpu_seconds_total{cpu="0"}
```

Pour les requêtes contenant certains caractères, nous devons peut-être coder la requête en URL :
```
/api/v1/query --data-urlencode "query=node_cpu_seconds_total{cpu=\"0\"}"
```

Utilisons le endpoint **/api/v1/query_range** pour interroger un vecteur de plage. Indiquons les paramètres de début et de fin pour spécifier le début et la fin de la plage de temps. <br>
Le paramètre **step** détermine le niveau de détail des résultats. Une durée de pas de 1m renverra des valeurs pour chaque minute pendant la plage de temps spécifiée :
```
start=$(date --date '-5 min' +'%Y-%m-%dT%H:%M:%SZ')
end=$(date +'%Y-%m-%dT%H:%M:%SZ')
```

```
/api/v1/query_range?query=node_cpu_seconds_total&start=$start&end=$end&step=1m
```