# Fédération

La fédération est le processus par lequel un serveur prometheus récupère certaines ou toutes les données de séries chronologiques d'un autre serveur prometheus.

Il existe plusieurs types de fédération :

- **fédération hiérarchique** : avec la fédération hiérarchique, les serveurs prometheus de niveau supérieur collectent des données de séries chronologiques à partir de plusieurs serveurs de niveau inférieur.

Cas d'utilisation : plusieurs centres de données, chacun avec ses propres serveurs prometheus internes surveillant les éléments du centre de données. Un serveur prometheus de niveau supérieur récupère et agrège les données de tous les centres de données.

- **fédération interservices** : avec la fédération interservices, un serveur prometheus surveillant un service ou un ensemble de services récupère les données sélectionnées d'un autre serveur surveillant un ensemble différent de services afin que les requêtes et les alertes puissent être exécutées sur l'ensemble de données combiné.

Cas d'utilisation : un serveur prometheus surveille les métriques du serveur et un autre serveur prometheus surveille les métriques de l'application. Le serveur prometheus de surveillance des applications extrait les données d'utilisation du processeur du serveur prometheus de surveillance du serveur, ce qui permet d'exécuter des requêtes qui prennent en compte à la fois l'utilisation du processeur et les mesures basées sur les applications.

La fédération peut être configurée en configurant un serveur prometheus pour extraire du endpoint **/federate** sur un autre serveur prometheus.

- Le endpoint **/federate** nous permet de récupérer la valeur actuelle pour les séries chronologiques sélectionnées.
- Affiner les données de séries chronologiques que nous récupérons avec le paramètre **match[]**
- Faire correspondre les noms et/ou les étiquettes des métriques pour récupérer un sous-ensemble des données.

### Configuration d'un service prometheus sur le serveur federating de la sandbox

Nous pouvons utiliser le lien [installation prometheus](../1-installation-et-configuration/1-installation-de-prometheus.md) pour configurer prometheus sur le serveur **federating** .

- Modifions la configuration prometheus sur notre serveur **federating** pour collecter les métriques sur le serveur prometheus **monitoring**

```
sudo vi /etc/prometheus/prometheus.yml
```

```
scrape_configs:
...
  - job_name: 'federate'
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
          - '{job="prometheus"}'
          - '{__name__=~"job:.*"}'
    static_configs:
      - targets:
        - '192.168.56.230:9090'
```

```
sudo systemctl restart prometheus
```

- Accédons à notre serveur Prometheus fédérateur dans un navigateur à l'adresse : **http://192.168.56.233:9090** .

Exécutons ces requêtes pour extraire des données sur nos jobs

```
up

prometheus_http_requests_total
```

Nous devrions voir les données sur les jobs exécutés par notre premier serveur Prometheus.