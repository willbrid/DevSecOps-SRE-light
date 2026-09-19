# Architecture de Prometheus

**Prometheus** est construit autour de **trois composants principaux** : le **data retrieval worker**, la **time series database** et le **HTTP server**.

### Les composants principaux du serveur Prometheus

#### Agent chargé de la récupération de données (Data Retrieval Worker)

Responsable de la **collecte des métriques** depuis les targets. Il envoie des **requêtes HTTP** — typiquement vers l'endpoint **`/metrics`** — des applications/systèmes. Les métriques collectées sont ensuite **stockées** dans la base de données de séries temporelles (time series database).

#### Base de données de séries temporelles (Time Series Database)

**Dépôt dédié** aux métriques collectées. Optimisée spécifiquement pour les **données time-series**, elle permet un **enregistrement efficace** et une **récupération rapide**.

#### Serveur HTTP

Fournit une **interface de requête** permettant d'accéder, visualiser et analyser les métriques stockées. Via **PromQL**, les utilisateurs interagissent avec les données depuis la **web UI de Prometheus** ou des outils tiers comme **Grafana**.

> Des composants additionnels — **exporters, service discovery, Alertmanager** — étendent les fonctionnalités de Prometheus dans les environnements dynamiques.

### Collecteurs de données

Pour scraper efficacement, Prometheus utilise des **collecteurs (exporters)** : des **processus légers** tournant sur les targets, qui **exposent les métriques dans un format compatible** Prometheus. Comme de nombreux systèmes ne présentent **pas** nativement leurs métriques au format attendu, les collecteurs sont **essentiels** pour **convertir** les données internes en format standardisé (exposé sur `/metrics`).

**Modèle pull + Pushgateway** :
- Prometheus utilise un **modèle pull-based** : il **interroge activement** les targets ;
- Mais pour les **jobs éphémères (short-lived)** qui pourraient ne pas exister assez longtemps pour être scrapés, on utilise la **Pushgateway** : elle **stocke temporairement** les métriques poussées par ces jobs jusqu'à ce que Prometheus les scrape.

**Découverte des targets** :
- Les targets à scraper sont généralement définies dans un **fichier de configuration statique** ;
- Dans les environnements **dynamiques** (Kubernetes, cloud), les mécanismes de **service discovery** mettent à jour **automatiquement** la liste des targets.

### Alerting

Prometheus supporte l'alerting en **évaluant les métriques** collectées par rapport à des **seuils définis**. **Important** : il **n'envoie PAS** les notifications directement → il **transmet les alertes à Alertmanager**. L'**Alertmanager** gère ensuite et **dispatche les notifications** via divers canaux : **email, SMS, Slack**.

### Interroger des métriques avec PromQL

Prometheus permet de requêter et visualiser les métriques via **PromQL** (langage de requête puissant), depuis la **web UI** ou des outils comme **Grafana**. Par défaut, Prometheus scrape depuis l'endpoint **`/metrics`** de chaque target (personnalisable dans la config).

Rappel : les **collecteurs** comblent le fossé en collectant les métriques des applications, les convertissant au bon format et les exposant sur `/metrics`.

**Collecteurs natifs** : Prometheus offre de nombreux collecteurs, dont le **Node Exporter** (systèmes Linux), ainsi que pour **Windows, MySQL, Apache, HAProxy**, etc.

### Collecte de métriques personnalisées

Pour monitorer des **métriques personnalisées** (erreurs, latence, temps d'exécution), Prometheus fournit des **client libraries** dans plusieurs langages : **Go, Java, Python, Ruby, Rust**. Ces bibliothèques permettent d'exposer des métriques **spécifiques à l'application**.

### Modèle Pull-Based vs Push-Based

Prometheus repose principalement sur un **modèle pull-based** : il **scrape** les métriques depuis des targets **connues**.

**Avantages du modèle pull** :
- **Détection facilitée** des targets **down** (indisponibles) ;
- **Contrôle de la charge** du serveur (métriques collectées à intervalles planifiés) ;
- Maintien d'une **liste à jour des targets** → source de vérité fiable (registre centralisé).

**Modèle push-based** (à l'inverse) : les targets **envoient directement** leurs métriques au serveur, sans enregistrement préalable. Exemples : **Logstash, Graphite, OpenTSDB**.

| Aspect | **Pull-based** (Prometheus) | **Push-based** (Logstash, Graphite, OpenTSDB) |
|--------|------------------------------|-----------------------------------------------|
| Initiative | Le serveur **interroge** les targets | Les targets **envoient** au serveur |
| Liste de targets | Requise (registre centralisé) | Pas d'enregistrement préalable |
| Détection des pannes | Facile | Plus difficile |

> **Limite du pull** : efficace pour les métriques numériques, mais **pas idéal** pour les données **basées sur les événements** ou les **jobs éphémères** → dans ces cas, la **Pushgateway** permet à ces jobs de pousser leurs métriques.


Prometheus est conçu pour la collecte, le stockage et le requêtage efficaces de métriques time-series. Son **architecture modulaire** (exporters, service discovery, Alertmanager) répond aux besoins d'environnements **statiques et dynamiques**. Le **modèle pull** + les alternatives **push via Pushgateway** en font une solution complète.

### À retenir

- **3 composants cœur** : **Data Retrieval Worker** (scrape via HTTP `/metrics`), **Time Series Database** (stockage optimisé), **HTTP Server** (requêtes PromQL / UI / Grafana).
- **Exporters** = processus légers convertissant les métriques au format Prometheus (ex. **Node Exporter** pour Linux, MySQL, Apache…).
- **Modèle pull** : Prometheus interroge les targets (avantages : détection des pannes, contrôle de charge, registre à jour) ; **Pushgateway** pour les **jobs éphémères**.
- **Service discovery** met à jour la liste des targets dans les environnements dynamiques (Kubernetes, cloud).
- **Alerting** : Prometheus évalue les seuils mais **délègue les notifications à l'Alertmanager** (email, SMS, Slack).
- **Client libraries** (Go, Java, Python, Ruby, Rust) pour les **métriques personnalisées**.

### Liens utiles

- Documentation officielle Prometheus (overview) : https://prometheus.io/docs/introduction/overview/
