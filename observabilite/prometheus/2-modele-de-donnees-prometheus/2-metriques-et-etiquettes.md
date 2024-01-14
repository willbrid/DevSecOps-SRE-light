# Métriques et étiquettes

Prometheus utilise une combinaison de métriques et d'étiquettes pour identifier de manière unique chaque ensemble de données de séries chronologiques.
<br>
Accédons au navigateur d'expressions Prometheus pour notre serveur Prometheus dans un navigateur Web. Assurons-nous d'utiliser l'adresse IP publique de votre serveur Prometheus :
```
http://<PROMETHEUS_SERVER_PUBLIC_IP>:9090
```

Exécutons une requête simple à l'aide d'un nom de métrique :
```
node_cpu_seconds_total
```

Ajoutez une étiquette à la requête pour récupérer les données d'utilisation uniquement pour un processeur spécifique :
```
node_cpu_seconds_total{cpu="0"}
```

Ajoutez des étiquettes supplémentaires à la requête pour récupérer un ensemble de données encore plus restreint :
```
node_cpu_seconds_total{cpu="0",mode="idle"}
```