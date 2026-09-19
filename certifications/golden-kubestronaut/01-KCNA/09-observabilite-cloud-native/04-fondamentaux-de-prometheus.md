# Fondamentaux de Prometheus

**Prometheus** est une solution de monitoring **open-source** de premier plan, utilisée pour **collecter, visualiser et alerter** sur des données de métriques.

**Fonctionnement** :
- Il **scrape (collecte) les métriques** depuis des **cibles (targets)** via des **endpoints HTTP** ;
- Il stocke les données dans une **base de données time series** (séries temporelles) ;
- Il permet des requêtes complexes via son langage natif : **PromQL** ;
- Il intègre un mécanisme d'**alerting** permettant de définir des **règles** pour notifier les équipes lors du dépassement de seuils.

### Types de métriques monitorées

| Catégorie | Exemples |
|-----------|----------|
| **System Metrics** (système) | Utilisation **CPU**, usage **mémoire**, espace **disque**, **uptime** des services |
| **Application-Specific Metrics** (applicatives) | Nombre d'**exceptions**, mesures de **latence**, nombre de **requêtes en attente** (pending) |

### Intégration des données

Prometheus collecte de manière transparente les métriques depuis une **large gamme de sources** : non seulement applications et OS, mais aussi **équipements réseau, bases de données** et autres composants critiques de l'infrastructure IT. Ses **vastes capacités d'intégration** en font un favori des professionnels IT.

Prometheus est **hautement extensible**, permettant la collecte de **métriques personnalisées** selon les besoins.

### Axé sur les données numériques

Prometheus est spécialisé dans la capture de **données numériques de type time-series (séries temporelles)**. Il est conçu pour la **collecte et l'analyse de métriques**, ce qui signifie qu'il **N'EST PAS conçu** pour monitorer les **événements, les logs ou les traces**.

> **Rappel des 3 piliers de l'observabilité** : Prometheus couvre uniquement le pilier **Metrics**, pas le Logging ni le Tracing → il faut d'autres outils pour ces derniers.

### Contexte et développement

- Développé initialement avec le **sponsoring de SoundCloud** ;
- A rejoint la **CNCF (Cloud Native Computing Foundation) en 2016**, consolidant son rôle dans l'écosystème cloud-native ;
- Écrit principalement en **Go**, ce qui contribue à sa **performance et sa scalabilité**.

### À retenir

- **Prometheus** = outil de monitoring **open-source** qui **scrape** les métriques via **endpoints HTTP**, les stocke dans une **base time-series**, et permet requêtes (**PromQL**) et **alerting**.
- Monitore des métriques **système** (CPU, mémoire, disque, uptime) et **applicatives** (exceptions, latence, requêtes en attente).
- **Spécialisé dans les données numériques time-series** → **PAS** conçu pour les **événements, logs ou traces** (pilier **Metrics** uniquement).
- **Extensible** et intégrable à de multiples sources (apps, OS, réseau, bases de données).
- Historique : sponsorisé par **SoundCloud**, rejoint la **CNCF en 2016**, écrit en **Go**.

### Liens utiles

- Documentation officielle Prometheus : https://prometheus.io/docs
- Cloud Native Computing Foundation (CNCF) : https://www.cncf.io
- Prometheus sur GitHub : https://github.com/prometheus/prometheus
