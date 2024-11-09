# Mise en place de la stack Loki, Tempo, Prometheus, Otelcollector, Grafana

Dans le contexte actuel de la supervision des infrastructures, la complexité croissante des environnements distribués et des applications 
en microservices impose des outils de monitoring performants et adaptatifs. La mise en œuvre d’une solution de monitoring capable de 
centraliser les métriques, traces et logs de manière efficace est devenue essentielle pour garantir la fiabilité et la disponibilité 
des systèmes.

Cet article présentera pas à pas la configuration d’un système de monitoring basé sur une stack complète et open-source. Combinant 
**OpenTelemetry Collector** pour la collecte des données, Prometheus pour la gestion des métriques, **Tempo** pour le traçage distribué, 
**Loki** pour la gestion des logs, et **Grafana** pour la visualisation, nous utiliserons également **MinIO S3** comme stockage d’objets 
pour centraliser les données de manière durable.

Pour renforcer cette solution, nous intégrons également **Alertmanager** pour la gestion des alertes, ce qui permet de détecter rapidement 
les anomalies et d’avertir l’équipe technique dès qu’un incident survient. L’ajout d’**Alertmanager** assure une réactivité accrue dans 
la résolution des incidents et améliore ainsi la fiabilité du système.

L’objectif de cette configuration est de mettre en place une solution robuste et scalable qui permet non seulement de surveiller les 
performances des applications, mais aussi d’identifier et d’alerter sur les éventuels points de défaillance.

### Architecture

![prom_otel_tempo_loki_grafana.drawio.png](./images/prom_otel_tempo_loki_grafana.drawio.png)

- **Stack Otelcollector**

**Collecteur OpenTelemetry** propose une implémentation indépendante du fournisseur pour la réception, le traitement et l'exportation des données de télémétrie. Il élimine la nécessité d'exécuter, d'exploiter et de maintenir plusieurs agents/collecteurs. Cela fonctionne avec une évolutivité améliorée et prend en charge les formats de données d'observabilité open source (par exemple **Jaeger**, **Prometheus**, **Fluent Bit**, etc.) envoyés à un ou plusieurs backends open source ou commerciaux. L'**agent Collector local** est l'emplacement par défaut vers lequel les bibliothèques d'instrumentation exportent leurs données de télémétrie.

La réception, le traitement et l'exportation des données s'effectuent à l'aide de pipelines. Nous pouvons configurer le collecteur pour qu'il dispose d'un ou de plusieurs pipelines.

Chaque pipeline comprend les éléments suivants :

--- **Receiver** : il est responsable de la réception et de la répartition des données de télémétrie entrantes, provenant des sources d’instrumentation (applications, services, etc.), vers le composant **Processor**.

--- **Processor** : il intervient dans la transformation, l’agrégation ou l’enrichissement des données de télémétrie avant qu’elles ne soient exportées par le composant **Exporter**. Il apporte des modifications ou des ajustements nécessaires pour que les données répondent aux exigences de traitement et de stockage en aval.

--- **Exporter** : il est chargé de transmettre les données transformées aux backends de stockage ou d’analyse, tels que **Prometheus**, **Tempo**, **Loki**, ou d’autres **solutions d’observabilité**...

Le même composant **Receiver** peut être inclus dans plusieurs pipelines et plusieurs pipelines peuvent inclure le même composant **Exporter**.

- **Stack metrique**

La **stack de monitoring** utilise **Prometheus** pour la collecte de métriques et plusieurs composants Thanos pour assurer une haute disponibilité, l'agrégation des métriques et la rétention à long terme.

--- **Prometheus** : il est responsable de la collecte des métriques depuis les sources de données configurées (services, applications, infrastructures)

--- **Thanos Sidecar** : il agit comme une extension de Prometheus. Il se déploie à côté de chaque instance Prometheus pour transférer les métriques vers un stockage objet (par exemple, Amazon S3, GCS) tout en assurant la rétention à long terme.

--- **Thanos Store Gateway** : il permet de lire les métriques stockées dans le stockage objet. Il récupère et expose les données historiques au près par exemple du composant **Thanos Querier**.

--- **Thanos Compactor** : il regroupe et compresse les blocs de données stockés afin d'optimiser l'espace et de réduire les coûts de stockage. Il réalise également le downsampling (réduction de la granularité des données anciennes) pour améliorer les performances de requêtes sur le long terme, rendant les requêtes historiques plus efficaces.

--- **Thanos Querier** : il interroge de manière unifiée plusieurs sources de données : pour les données récentes il requête vers **Thanos Sidecar** et pour les données historiques il requête vers **Thanos Store Gateway**.

--- **Thanos Query Frontend** : il se place en amont du composant **Thanos Querier** pour gérer les requêtes des utilisateurs. Il introduit des mécanismes de mise en cache et de répartition des requêtes. Il améliore les performances des requêtes complexes, réduit la charge sur du composant **Thanos Querier** et offre des temps de réponse plus rapides, ce qui est particulièrement utile pour les requêtes historisées ou sur des périodes étendues.

- **Stack Trace**

La **stack trace** avec **Grafana Tempo** offre une solution scalable et efficace pour la collecte, le stockage et l’interrogation de traces de performances d’applications distribuées. Elle permet d’analyser le cheminement des requêtes à travers divers services et de diagnostiquer les problèmes de performance ou de latence dans les systèmes complexes.

--- **Tempo Distributor** : il reçoit les traces (de différents formats comme **Jaeger**, **OpenTelemetry**, **Zipkin**), les hache et les distribue au composant **Tempo Ingester** pour traitement.

--- **Tempo Ingester** : il organise les traces en blocs, crée des filtres Bloom et des index, puis les envoie vers le stockage objet (par exemple, Amazon S3, GCS) ou localement.

--- **Tempo Compactor** : il réduit le nombre de blocs stockés en regroupant les blocs de traces dans le stockage objet.

--- **Tempo Querier** : il recherche les traces demandées en interrogeant le composant **Tempo Ingester** et le stockage objet pour extraire les blocs de données.

--- **Tempo Query Frontend** : il se place en amont du composant **Tempo Querier**. Il divise les requêtes de recherche en fragments pour améliorer les performances et met les requêtes en file d'attente, gérant la répartition de la recherche sur plusieurs fragments. Cette file d'attente est consultée par le composant **Tempo Querier** afin d'effectuer la recherche et fournit le résultat au composant **Tempo Query Frontend**.

- **Stack Log**

La **stack Loki** avec **Grafana Loki** offre une solution de gestion et d'analyse des logs, optimisée pour une recherche rapide et scalable sans les coûts d’indexation élevés des solutions de logs classiques.

--- **Loki Distributor** : il reçoit les logs et les valide avant de les répartir au composant **Loki Ingester** en parallèle.

--- **Loki Ingester** : il stocke temporairement les logs et les envoie ensuite vers un stockage objet.

--- **Loki Compactor** : il regroupe et compacte les index de logs dans le stockage objet pour réduire le nombre de fichiers et améliorer la recherche.

--- **Loki Querier** : exécute les requêtes de logs, récupérant les données du composant **Loki Ingester** et du stockage objet. Donc il interroge le composant **Loki Ingester** pour les données en mémoire avant de revenir à l'exécution de la même requête sur le stockage objet.

--- **Loki Scheduler** : il récupère des requêtes fractionnées envoyées par le composant **Loki Query Frontend**, les met dans une file d'attente interne en mémoire. Le composant **Loki Querier** qui se connecte au composant **Loki Scheduler** agit comme un **worker** qui extrait leurs tâches de la file d'attente, l'exécute et les renvoit au composant **Loki Query Frontend** pour agrégation.

--- **Loki Query Frontend** il optimise et envoie les requêtes au composant **Loki Scheduler** pour traitement.

--- **Index Gateway** : il est responsable de la gestion et du traitement des requêtes de métadonnées. Les requêtes de métadonnées sont des requêtes qui recherchent des données à partir de l'index. Le composant **Loki Query Frontend** interroge le composant **Index Gateway** pour connaître le volume de logs des requêtes afin de pouvoir prendre une décision sur la manière de fragmenter les requêtes. Le composant **Loki Querier** interroge le composant **Index Gateway** pour connaître les références de blocs pour une requête donnée afin de savoir quels blocs récupérer et interroger.

--- **Loki Ruler** : il gère et évalue les expressions de règle et/ou d'alerte fournies dans une configuration de règle. La configuration de règle est stockée dans le stockage d'objets (ou alternativement sur le système de fichiers local) et peut être gérée via l'API de règle ou directement en téléchargeant les fichiers dans le stockage d'objets.

- **MinIO s3**

**MinIO** est une solution open-source de stockage d'objets compatible avec l’API S3 d’AWS. Il est optimisé pour les performances de stockage et de récupération des données, offrant une gestion des objets rapide même avec des données volumineuses. Il peut être configuré pour fournir une haute disponibilité en répliquant les données entre plusieurs nœuds et centres de données.

- **Redis**

**Redis (Remote Dictionary Server)** est un système de gestion de base de données clé-valeur extensible et NoSQL en mémoire, extrêmement rapide et open-source, souvent utilisée comme cache, file d'attente ou encore pour le stockage de sessions. **Redis** est populaire pour sa capacité à fournir des performances élevées et une faible latence grâce à son stockage des données en mémoire, ce qui le rend idéal pour les applications nécessitant un accès rapide aux données.

- **AlertManager**

**AlertManager** est un composant chargé de gérer les alertes déclenchées par Prometheus ou d’autres sources. Sa mission principale est de gérer l’envoi, le regroupement, et la suppression des alertes pour assurer une notification cohérente et fiable.

- **Grafana**

**Grafana** est un outil open-source de visualisation de données et d'analyse utilisé pour surveiller des métriques en temps réel, générer des tableaux de bord interactifs et explorer des données provenant de diverses sources. Il est compatible avec une large gamme de sources de données, telles que **Prometheus**, **Tempo**, **Loki**, **InfluxDB**, de nombreuses **bases de données SQL/NoSQL**...