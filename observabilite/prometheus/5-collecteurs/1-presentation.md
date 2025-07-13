# Introduction aux collecteurs (exporter), jobs et instances

Les **collecteurs de données** nous permettent de collecter des métriques à partir d'une grande variété de systèmes et d'applications afin qu'elles puissent être extraites par un serveur Prometheus.

Les collecteurs fournissent les données métriques collectées par le serveur prometheus. Un collecteur est une application qui expose des données dans un format que prometheus peut lire. Le **scrape_config** dans le fichier **prometheus.yml** configure le serveur prometheus pour qu'il se connecte régulièrement à chaque collecteur et collecte des données métriques.

Il existe plusieurs manières de surveiller les applications :

- utiliser un collecteur existant
- utiliser Prometheus **pushgateway** pour le traitement par lots et les travaux de courte durée
- utiliser des bibliothèques clientes pour créer un collecteur dans vos applications personnalisées
- coder vos propres bibliothèques clientes ou collecteurs

**Instances** : prometheus ajoute automatiquement une étiquette d'instance aux métriques. Les instances sont des endpoints individuels que prometheus sniffe. Généralement, une instance est une application ou un processus unique surveillé.

**Job** : prometheus ajoute également automatiquement des étiquettes pour les jobs. Un job est une collection d'instances, partageant toutes le même objectif. Par exemple, un job peut faire référence à une collection de plusieurs réplicas pour une seule application.

**Exemple :**

- Interroger les données d'un job spécifique

```
up{job="Linux Server"}
```

- Interroger les données d'une instance spécifique

```
up{instance="localhost:9090"}
```

Prometheus crée automatiquement des données métriques sur les données sniffées pour chaque instance.