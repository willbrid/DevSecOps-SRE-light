# Monitorer les Conteneurs avec Prometheus

Ce contenu montre comment **étendre le monitoring Prometheus** des hôtes Linux vers les **environnements conteneurisés**. En collectant des métriques à la fois depuis le **Docker engine** et depuis les **conteneurs individuels** (via **cAdvisor**), on obtient une vue complète des performances.

### Activer les métriques du Docker Engine

Sur l'hôte Docker :

**1.** Créer/éditer le fichier **`/etc/docker/daemon.json`** pour exposer l'endpoint de métriques :
```json
{
  "metrics-addr": "127.0.0.1:9323",
}
```

**2.** Redémarrer Docker :
```bash
sudo systemctl restart docker
```

**3.** Vérifier que l'endpoint est accessible :
```bash
curl localhost:9323/metrics
```

**4.** Mettre à jour la config Prometheus pour scraper ces métriques :
```yaml
scrape_configs:
  - job_name: "docker"
    static_configs:
      - targets: ["12.1.13.4:9323"]
```

(Remplacer `12.1.13.4` par l'IP réelle de l'hôte Docker.)

### Monitorer les conteneurs avec cAdvisor

**cAdvisor** est un outil puissant pour collecter des métriques **spécifiques aux conteneurs** : usage CPU, consommation mémoire, nombre de processus, uptime.

**1.** Créer un fichier **`docker-compose.yml`** (basé sur la doc officielle cAdvisor) :
```yaml
version: '3.4'
services:
  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    container_name: cadvisor
    privileged: true
    devices:
      - "/dev/kmsg:/dev/kmsg"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker:/var/lib/docker:ro
      - /dev/disk:/dev/disk:ro
    ports:
      - 8080:8080
```

**2.** Démarrer cAdvisor :
```bash
docker-compose up -d
```

**3.** Vérifier la collecte des métriques (endpoint sur le **port 8080**) :
```bash
curl localhost:8080/metrics
```

**4.** Ajouter un job à la config Prometheus :
```yaml
scrape_configs:
  - job_name: "cAdvisor"
    static_configs:
      - targets: ["12.1.13.4:8080"]
```

(Remplacer `12.1.13.4` par l'IP où tourne cAdvisor.)

### Docker Engine vs cAdvisor (distinction clé)

| Aspect | **Docker Engine Metrics** | **cAdvisor Metrics** |
|--------|---------------------------|----------------------|
| Portée | Performance **globale** du Docker engine | Métriques **granulaires par conteneur** |
| Port | **9323** | **8080** |
| Exemples | CPU global du moteur, builds d'images échoués, temps de traitement des actions | CPU/mémoire par conteneur, nombre de processus, uptime du conteneur |
| Usage idéal | Vue **holistique** de la santé du moteur Docker | Analyse **détaillée** de chaque conteneur |

> **Recommandation** : utiliser les **Docker engine metrics** pour une vue globale de l'hôte, et **cAdvisor** pour l'analyse approfondie de chaque conteneur. Ajuster la config Prometheus en conséquence.

### À retenir

- Pour monitorer les conteneurs, on étend Prometheus avec **deux sources** : le **Docker engine** (port **9323**) et **cAdvisor** (port **8080**).
- **Docker engine metrics** : activées via `/etc/docker/daemon.json` (`metrics-addr`) → vue **globale** du moteur.
- **cAdvisor** : déployé via Docker Compose (image `gcr.io/cadvisor/cadvisor`) → métriques **par conteneur** (CPU, mémoire, processus, uptime).
- Dans les deux cas : vérifier l'endpoint `/metrics` avec `curl`, puis ajouter un **job** dans `scrape_configs` de Prometheus.
- **Docker engine = vue d'ensemble** ; **cAdvisor = détail par conteneur**.

#### Liens utiles

- Documentation officielle Prometheus : https://prometheus.io/docs/
- Documentation officielle Cadvisor : https://github.com/google/cadvisor/blob/master/docs/web.md
- Documentation docker engine metrics prometheus : https://docs.docker.com/engine/daemon/prometheus/
