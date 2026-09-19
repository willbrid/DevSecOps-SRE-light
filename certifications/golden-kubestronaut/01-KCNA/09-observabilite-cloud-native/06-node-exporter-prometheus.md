# Node Exporter de Prometheus

Ce contenu explique comment installer le **Prometheus Node Exporter** sur un hôte Linux. Le Node Exporter **collecte les métriques au niveau système** et les expose dans un format que Prometheus peut **scraper** pour le monitoring.

### Étape 1 : Télécharger le Node Exporter

Se rendre sur la **page de téléchargement officielle** de Prometheus et sélectionner le Node Exporter. Choisir la version, puis télécharger le binaire ou copier l'URL pour `wget` :

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.12.1/node_exporter-1.12.1.linux-amd64.tar.gz
```

**Vérifier l'intégrité** du fichier en comparant son **checksum SHA256** avec celui fourni sur la page de téléchargement.

### Étape 2 : Extraire l'archive

```bash
tar -xvf node_exporter-1.12.1.linux-amd64.tar.gz
```

Cela crée un répertoire `node_exporter-1.12.1.linux-amd64` contenant l'**exécutable** et des fichiers additionnels (**LICENSE**, **NOTICE**). Se déplacer dans le répertoire :

```bash
cd node_exporter-1.12.1.linux-amd64
```

### Étape 3 : Lancer le Node Exporter

Depuis le répertoire, exécuter le binaire :
```bash
./node_exporter
```
La sortie indique que l'exporter écoute sur le **port 9100** (port par défaut) :
```
level=info msg="listening on" address=:9100
level=info msg="TLS is disabled."
```

> **Point important** : s'assurer que le **port 9100** est **ouvert** dans le firewall pour permettre à Prometheus de scraper les métriques.

### Étape 4 : Vérifier l'installation

Confirmer que le Node Exporter fonctionne via `curl` sur l'endpoint des métriques :
```bash
curl localhost:9100/metrics
```

La réponse contient des métriques au **format Prometheus**, par exemple :
```
# TYPE promhttp_metric_handler_requests_in_flight gauge
promhttp_metric_handler_requests_in_flight 1
# TYPE promhttp_metric_handler_requests_total counter
promhttp_metric_handler_requests_total{code="200"} 0
```

Alternative : ouvrir dans un navigateur → **http://localhost:9100/metrics**

### Exemple avec une version différente

Le processus reste **identique** avec une autre version (ex. `node_exporter-1.12.0.linux-amd64`) :
```bash
cd node_exporter-1.12.0.linux-amd64
ls -la          # vérifier le contenu (LICENSE, node_exporter, NOTICE)
./node_exporter # lancer
curl localhost:9100/metrics  # vérifier
```

La sortie fournit diverses métriques système : **CPU, mémoire, réseau**, etc. Exemples de métriques :

```
# TYPE node_timex_tick_seconds gauge
node_timex_tick_seconds 0.01
# TYPE node_udp_queues gauge
node_udp_queues{ip="v4",queue="rx"} 0
node_uname_info{machine="x86_64",nodename="user2",release="5.15.0-52-generic",sysname="Linux"} 1
```

Le **Node Exporter** est désormais configuré pour **collecter les métriques de l'hôte**, permettant à Prometheus de les scraper depuis l'endpoint `/metrics`. C'est un composant clé pour monitorer la **performance et la fiabilité** du système.

### À retenir

- Le **Node Exporter** collecte les **métriques système** (CPU, mémoire, réseau, disque…) d'un hôte Linux et les expose au format Prometheus.
- **Workflow d'installation** : télécharger (`wget`) → extraire (`tar -xvf`) → se déplacer (`cd`) → lancer (`./node_exporter`) → vérifier (`curl localhost:9100/metrics`).
- Il écoute par défaut sur le **port 9100** → veiller à l'**ouvrir dans le firewall**.
- Vérifier l'**intégrité** du téléchargement via le **SHA256**.
- Les métriques sont exposées sur l'endpoint **`/metrics`**, prêtes à être scrapées par Prometheus.

### Liens utiles

- Page de téléchargement Prometheus : https://prometheus.io/download
- Documentation officielle Prometheus : https://prometheus.io/docs/
- Node Exporter sur GitHub : https://github.com/prometheus/node_exporter
