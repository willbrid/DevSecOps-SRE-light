# Fondamentaux de l'observabilité

L'**observabilité (observability)** est la capacité à **comprendre et mesurer l'état d'un système** à partir des données qu'il génère. Elle apporte une **compréhension approfondie** sur le fonctionnement interne du système, ce qui permet de :
- accélérer le **troubleshooting** (dépannage) ;
- détecter les **problèmes difficiles à repérer** ;
- surveiller les **performances** ;
- améliorer la **collaboration inter-équipes**.

**Le concept de la « boîte noire »** : sans observabilité, une application se comporte comme une **boîte noire** — l'information entre et sort avec **peu de visibilité** sur les processus internes. L'observabilité **lève le voile**, montrant comment les composants interagissent → en cas de problème, elle aide à **localiser le composant défaillant** et sa **cause racine (root cause)**.

### Pourquoi l'observabilité est cruciale avec les microservices

À mesure que l'on adopte les **microservices**, l'infrastructure passe d'un système **monolithique unifié** à une **collection de services indépendants** qui interagissent. On ne surveille plus **une seule entité**, mais de **nombreux petits services** → cette complexité **complique le troubleshooting** (isoler le service défaillant demande une visibilité détaillée).

Le troubleshooting va au-delà du simple repérage des symptômes : il faut des **données complètes** pour comprendre **pourquoi** l'application a atteint un certain état, **quel composant** est responsable, et **comment prévenir** les récurrences. Exemples de questions : hausse des **taux d'erreur**, augmentation de la **latence**, **timeouts** fréquents.

### Les 3 piliers de l'observabilité

L'observabilité s'appuie sur **trois piliers critiques** : **Logging, Tracing, Metrics**.

#### 1. Logging (journalisation)

Les **logs** sont des **enregistrements d'événements** fournissant des informations détaillées sur les opérations du système. Chaque entrée comporte typiquement :
- un **timestamp** (horodatage) marquant quand l'événement s'est produit ;
- un **message descriptif**.

Les logs sont générés universellement par les **OS, applications et bases de données** → c'est le **premier point de données** d'une stratégie d'observabilité.

Exemple de logs :
```shell
Oct 26 19:35:00 ub1 kernel: [37510.942568] e1000: enp0s3 NIC Link is Down
Oct 26 19:35:00 ub1 kernel: [37510.942697] e1000 0000:00:03.0 enp0s3: Reset adapter
Oct 26 19:35:03 ub1 kernel: [37513.054072] e1000: enp0s3 NIC Link is Up 1000 Mbps Full Duplex
```

> **Limite** : Leur **forte verbosité** et l'**entrelacement des processus** entre plusieurs systèmes peuvent **compliquer** la localisation des problèmes lors d'une panne.

#### 2. Tracing (traçage)

Le **tracing** permet de **suivre les requêtes individuelles** à travers les différents systèmes et services. Fonctionnement :
- Chaque requête reçoit un **trace ID unique** → permet de visualiser son **parcours** dans toute l'application ;
- Au sein d'une trace, les événements individuels sont appelés **spans**, représentant les interactions à différentes interfaces/services ;
- Chaque **span** enregistre : **start time** (heure de début), **duration** (durée), et un **parent ID** qui le relie au composant d'origine.

**Exemple** : une requête peut générer :
- un span au niveau de la **gateway** ;
- un span dans la **couche applicative** ;
- des spans supplémentaires lors des interactions avec les **services utilisateurs** ou les **bases de données**.

Ces spans combinés forment une **trace complète** de la requête → vue **granulaire** des interactions.

#### 3. Metrics (métriques)

Les **metrics** offrent des **mesures quantifiables** reflétant l'état du système. Contrairement aux logs (données **textuelles**), les metrics délivrent des **données numériques** : charge CPU, nombre de fichiers ouverts, temps de réponse HTTP, nombre d'erreurs. Elles peuvent être **agrégées dans le temps** et **visualisées** → détection facilitée des **tendances** et **anomalies**.

Une entrée de metric contient typiquement :
- un **nom** décrivant la mesure ;
- une **valeur** (lecture actuelle ou récente) ;
- un **timestamp** ;
- des **dimensions** optionnelles pour le contexte.

Exemple :
```shell
node_filesystem_avail_bytes{fstype="vfat", mountpoint="/home"} 5000
4:30AM 12/1/22
```

### La force de l'observabilité : la corrélation

L'observabilité ne se limite pas à **capturer** les données : sa vraie puissance réside dans la **corrélation** des **logs, traces et metrics** pour obtenir une **vue complète** de la performance et de la santé du système.

### Observabilité avec Prometheus

Ce module se concentre sur **Prometheus**, une solution de monitoring de premier plan conçue pour **agréger les metrics**.

> **Point important** : Prometheus est **spécialisé pour les metrics uniquement** — il **ne capture PAS** les logs ni les traces. Pour une solution d'observabilité **complète**, il faut **intégrer d'autres outils** pour la gestion des logs et le tracing distribué.

### Tableau récapitulatif des 3 piliers

| Pilier | Type de données | Rôle | Élément clé |
|--------|-----------------|------|-------------|
| **Logging** | Textuel | Enregistre les **événements** | timestamp + message |
| **Tracing** | Parcours | Suit les **requêtes** à travers les services | trace ID + spans |
| **Metrics** | Numérique | Mesure quantifiée de l'**état** | nom + valeur + timestamp |

### À retenir

- L'**observabilité** = comprendre l'état d'un système via les données qu'il génère ; transforme la **boîte noire** en système transparent (localiser le composant défaillant + cause racine).
- Elle devient **cruciale avec les microservices** (nombreux services à surveiller vs un monolithe).
- **3 piliers** : **Logging** (événements textuels horodatés, verbeux), **Tracing** (suivi des requêtes via trace ID + spans), **Metrics** (données numériques agrégeables : CPU, latence, erreurs).
- La **vraie puissance** vient de la **corrélation** des trois piliers.
- **Prometheus** = spécialisé **metrics uniquement** → compléter avec d'autres outils pour logs et traces.

### Liens utiles

- Prometheus : https://prometheus.io
- Documentation Prometheus : https://prometheus.io/docs/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Docker Hub : https://hub.docker.com/
- Terraform Registry : https://registry.terraform.io/
