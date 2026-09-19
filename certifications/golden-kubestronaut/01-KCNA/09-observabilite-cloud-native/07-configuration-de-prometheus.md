# Configuration de Prometheus

Ce contenu explique comment configurer un serveur Prometheus pour **scraper les métriques** d'un ou plusieurs nœuds. Après avoir installé Prometheus et configuré les nœuds avec des **Node Exporters**, il faut **explicitement configurer** Prometheus pour **découvrir et scraper** ces targets (modèle **pull-based**).

**Point essentiel** : la configuration est maintenue dans le fichier **`prometheus.yaml`** (ou `.yml`), typiquement dans le répertoire **`/etc/prometheus`**.

Configuration de base :
```yaml
# my global config
global:
  scrape_configs:
    - job_name: "prometheus"
      static_configs:
        - targets: ["localhost:9090"]
```

- La section **`global`** définit les paramètres par défaut (héritables ou surchargeables) ;
- La section **`scrape_configs`** spécifie les endpoints cibles à scraper.

### Configuration détaillée du scraping

Le bloc **`scrape_configs`** identifie les targets. On peut affiner le comportement avec `scrape_interval`, `scrape_timeout`, `sample_limit` :
```yaml
global:
  scrape_interval: 1m
  scrape_timeout: 10s

scrape_configs:
  - job_name: 'node'
    scrape_interval: 15s
    scrape_timeout: 5s
    sample_limit: 1000
    static_configs:
      - targets: ['172.16.12.1:9090']

alerting:      # Config liée à l'Alertmanager
rule_files:    # Où lire les règles
remote_read:   # Lecture distante
remote_write:  # Écriture distante
storage:       # Config du stockage
```

Points clés :
- Les **defaults globaux** : intervalle de scrape de 1 min, timeout de 10 s ;
- Le job **`node`** **surcharge** ces defaults (intervalle 15 s, timeout 5 s) ;
- Le bloc **`static_configs`** indique l'**IP et le port** des targets ;
- Blocs additionnels : **alerting, rule_files, remote_read/write, storage**

### Personnaliser les jobs

Pour un nouveau job sous `scrape_configs`, on précise : nom, intervalle, timeout, **scheme (HTTP/HTTPS)** et **chemin des métriques**. Par défaut, Prometheus scrape sur **`/metrics`**, mais c'est personnalisable.

Exemple : scraper deux targets en **HTTPS** avec un chemin personnalisé :
```yaml
scrape_configs:
  - job_name: 'nodes'
    scrape_interval: 30s
    scrape_timeout: 3s
    scheme: https
    metrics_path: /stats/metrics
    static_configs:
      - targets: ['10.231.1.2:9090', '192.168.43.9:9090']
```

Ce qui est montré : intervalle de 30 s, timeout de 3 s, **HTTPS**, chemin changé de `/metrics` vers `/stats/metrics`, et deux targets.

**Options ajustables courantes de `scrape_configs`** :
```yaml
scrape_configs:
  [ scrape_interval: <duration> | default = <global.scrape_interval> ]  # fréquence
  [ scrape_timeout: <duration> | default = <global.scrape_timeout> ]    # timeout
  [ metrics_path: <path> | default = /metrics ]                         # chemin des métriques
  [ scheme: <scheme> | default = http ]                                 # protocole
  basic_auth:                                                           # authentification
    [ username: <string> ]
    [ password: <secret> ]
    [ password_file: <string> ]   # 'password' et 'password_file' mutuellement exclusifs
```

### Mettre à jour la configuration

**Prometheus NE recharge PAS automatiquement** les changements du fichier → il faut **redémarrer le processus** :
- En manuel (`./prometheus`) : **Ctrl+C** puis relancer ;
- Via **signal HUP** : `kill -HUP <pid>` ;
- Via **systemd** : `sudo systemctl restart prometheus`.

```bash
$ ctrl+c  -> ./prometheus
$ kill -HUP <pid>
sudo systemctl restart prometheus
```

Exemple de config mise à jour ajoutant un job pour un Node Exporter :
```yaml
global:
  scrape_interval: 15s      # Scrape toutes les 15 s (défaut : 1 min)
  evaluation_interval: 15s  # Évalue les règles toutes les 15 s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

rule_files:
  # - "first_rules.yml"

scrape_configs:
  - job_name: "prometheus"   # Prometheus se scrape lui-même
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node"         # Nouveau job : Node Exporter
    static_configs:
      - targets: ["192.168.1.168:9100"]
```

- Le job **`prometheus`** continue de scraper Prometheus lui-même ;
- Le nouveau job **`node`** scrape une machine Linux (Node Exporter sur `192.168.1.168:9100`).

Appliquer les changements :
```bash
sudo vi /etc/prometheus/prometheus.yml
sudo systemctl restart prometheus
```

### Vérifier la configuration

Après redémarrage, ouvrir la **web UI** de Prometheus → **Status → Targets**. On y inspecte tous les targets configurés et leur statut de scrape. Les targets **prometheus** et **node** doivent afficher le statut **"UP"**.

Vérification via requêtes **PromQL** :
```promql
up{instance="192.168.1.100",job="node"}
up{instance="localhost:9090",job="prometheus"}
```

Une valeur retournée de **1** confirme que les instances sont **actives et fonctionnelles**.

### À retenir

- La config vit dans **`prometheus.yaml`** (dans `/etc/prometheus`), avec les sections **`global`** (defaults) et **`scrape_configs`** (targets).
- Un **job** définit : `job_name`, `static_configs.targets` (IP:port), et peut surcharger `scrape_interval`, `scrape_timeout`, `scheme`, `metrics_path`, `basic_auth`.
- Endpoint par défaut : **`/metrics`** ; scheme par défaut : **`http`** (personnalisables).
- Tout changement exige un **redémarrage** de Prometheus (`Ctrl+C`, `kill -HUP <pid>`, ou `systemctl restart prometheus`).
- Vérification : page **Status → Targets** (statut **UP**) ou requête PromQL **`up{...}`** (valeur **1** = actif).

### Liens utiles

- Page de téléchargement Prometheus : https://prometheus.io/download
- Documentation officielle Prometheus : https://prometheus.io/docs/
