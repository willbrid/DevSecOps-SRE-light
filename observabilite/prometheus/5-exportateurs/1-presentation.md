# Introduction aux exportateurs, jobs et instances

Les exportateurs Prometheus nous permettent de collecter des métriques à partir d'une grande variété de systèmes et d'applications afin qu'elles puissent être extraites par un serveur Prometheus.
<br>
Les exportateurs fournissent les données métriques collectées par le serveur prometheus. Un exportateur est une application qui expose des données dans un format que prometheus peut lire. Le **scrape_config** dans le fichier **prometheus.yml** configure le serveur prometheus pour qu'il se connecte régulièrement à chaque exportateur et collecte des données métriques.
<br>
Il existe plusieurs manières de surveiller les applications :
- utiliser un exportateur existant
- utiliser Prometheus **pushgateway** pour le traitement par lots et les travaux de courte durée
- utilisez des bibliothèques clientes pour créer un exportateur dans vos applications personnalisées
- coder vos propres bibliothèques clientes ou exportateurs
<br>
<br>
Instances : prometheus ajoute automatiquement une étiquette d'instance aux métriques. Les instances sont des endpoints individuels que prometheus sniffe. Généralement, une instance est une application ou un processus unique surveillé.
<br>
Job : prometheus ajoute également automatiquement des étiquettes pour les jobs. Un job est une collection d'instances, partageant toutes le même objectif. Par exemple, un job peut faire référence à une collection de plusieurs réplicas pour une seule application.
<br>
Exemple : 
<br>
- Interroger les données d'un job spécifique :
```
up{job="Linux Server"}
```

- Interroger les données d'une instance spécifique :
```
up{instance="localhost:9090"}
```

prometheus crée automatiquement des données métriques sur les données sniffées pour chaque instance.