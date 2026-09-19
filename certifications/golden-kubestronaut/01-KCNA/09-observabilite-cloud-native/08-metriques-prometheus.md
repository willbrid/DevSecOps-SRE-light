# Métriques Prometheus

Une métrique Prometheus est composée de **trois parties fondamentales** :
1. Un **nom descriptif** (metric name) ;
2. Un ou plusieurs **labels** (paires clé-valeur) ajoutant du contexte ;
3. Une **valeur numérique** représentant la quantité mesurée à un instant donné.

### structure d'une métrique

Exemple généré par le node exporter :
```plaintext
node_cpu_seconds_total{cpu="0",mode="idle"} 258277.86
```

Décomposition :
- **Nom** : `node_cpu_seconds_total` = total des secondes CPU ;
- **Labels** : `cpu` et `mode` précisent quel CPU (CPU 0) et son état (idle) ;
- **Valeur** : `258277.86` = total de secondes où le CPU 0 a été inactif.

Sur les systèmes **multi-CPU**, on observe des métriques similaires avec des **valeurs de labels différentes** :
```plaintext
node_cpu_seconds_total{cpu="0",mode="idle"} 258277.86
node_cpu_seconds_total{cpu="1",mode="idle"} 427262.54
node_cpu_seconds_total{cpu="2",mode="idle"} 283288.12
```

→ Le **filtrage par labels** permet des analyses plus fines.

### Horodatage et collecte des métriques

À chaque **collecte**, Prometheus collecte non seulement la valeur mais aussi le **timestamp** — un **timestamp Unix** (nombre de secondes depuis le **1er janvier 1970 UTC**). Cela garantit un enregistrement précis dans le temps.

> Les timestamps Unix se convertissent en formats lisibles via des outils en ligne, mais la plupart des outils de dashboarding modernes le font **automatiquement** selon le fuseau horaire local.

### Séries temporelles (time Series)

Une **time series** est une **séquence de points de données horodatés** partageant le **même nom de métrique ET les mêmes labels**.

Exemple :
```plaintext
node_filesystem_files{device="sda2", instance="server1"}
node_filesystem_files{device="sda3", instance="server1"}
node_cpu_seconds_total{cpu="0", instance="server1"}
node_cpu_seconds_total{cpu="1", instance="server2"}
...
```

- **2 métriques distinctes** : `node_filesystem_files` et `node_cpu_seconds_total` ;
- Avec différentes **combinaisons de labels** (`device`, `cpu`, `instance`) → **8 time series uniques**.

**Point clé** : chaque **combinaison unique nom + labels** = une série temporelle distincte. Chaque collecte (typiquement toutes les 15 ou 30 s) ajoute une nouvelle entrée horodatée à la série temporelle concernée.

### Attributs de métrique

Chaque métrique a **deux attributs clés** :
- **HELP** : description en langage naturel de ce que mesure la métrique ;
- **TYPE** : spécifie le type (**counter**, **gauge**, **histogram**, **summary**).

```plaintext
# HELP node_disk_discard_time_seconds_total This is the total number of seconds spent by all discards.
# TYPE node_disk_discard_time_seconds_total counter
node_disk_discard_time_seconds_total{device="sda"} 0
```

#### Les 4 types de métriques

| Type | Description | Exemples |
|------|-------------|----------|
| **Counter** | Valeur qui **augmente uniquement** (ne décroît jamais) | Total de requêtes, nombre d'erreurs, exécutions de jobs |
| **Gauge** | Valeur qui peut **augmenter ou diminuer** | Utilisation CPU actuelle, usage mémoire |
| **Histogram** | Enregistre la **distribution** des valeurs dans des intervalles prédéfinis configurables appelés **buckets** | Temps de réponse, tailles de requêtes (buckets 0.2s, 0.5s, 1s) |
| **Summary** | Fournit des **quantiles** pour durées/tailles | Ex. 20% des requêtes < 0.3s, 50% < 0.8s, 80% < 1s |

> **Histogram vs Summary** : les deux décrivent des distributions, mais l'histogram utilise des **buckets** prédéfinis, tandis que le summary calcule directement des **quantiles**.

Un quantile est une valeur qui permet de découper un ensemble de données selon la proportion d'observations qui se trouvent en dessous.<br>
Dans Prometheus, c'est particulièrement utile pour analyser les temps de réponse.

**Exemple simple**

Imaginons 100 requêtes à une API, classées de la plus rapide à la plus lente.

```
p50 (50e quantile) : 50 % des requêtes sont plus rapides que cette valeur.

p90 : 90 % des requêtes sont plus rapides que cette valeur.

p95 : 95 % des requêtes sont plus rapides que cette valeur.

p99 : 99 % des requêtes sont plus rapides que cette valeur.
```

Si on obtient :

```
p95 = 800 ms
```

cela signifie que 95 % des requêtes ont un temps de réponse inférieur ou égal à environ 800 ms, et que les 5 % restantes sont plus lentes.

### Conventions de nommage des métriques

- Les noms doivent **clairement indiquer** la fonctionnalité mesurée ;
- Caractères valides : **lettres ASCII, chiffres, underscores, deux-points** ;
- **Éviter les deux-points (`:`)** dans les noms de métriques : ils sont **réservés aux recording rules** de Prometheus.

### Les labels en détail

Les **labels** ajoutent des **dimensions** aux métriques. Au lieu de créer des métriques séparées pour chaque variante, on utilise **une seule métrique** différenciée par labels.

**Exemple — requêtes API** :
- ❌ **Sans labels** (à éviter) :
  - `requests_auth_total` (endpoint auth) ;
  - `requests_user_total` (endpoint user) ;
  → complique l'agrégation du total.
- ✅ **Avec labels** (recommandé) :
  ```plaintext
  requests_total{path="/auth", method="get"}
  ```
  → une seule métrique `requests_total` avec un label `path` → simplifie les requêtes et permet l'**agrégation** (ex. `sum`). On peut ajouter d'autres dimensions (label `method` : GET, POST, PATCH, DELETE).

#### Labels réservés et automatiques

- Le **nom de la métrique** est traité en interne comme un label appelé **`__name__`** ;
- Les labels préfixés/suffixés de **doubles underscores** sont **réservés** à l'usage interne de Prometheus ;
- Chaque métrique inclut **automatiquement** deux labels :
  - **`instance`** : identifie la **target** (définie dans la config) ;
  - **`job`** : correspond au **nom du job** de la config.

```yaml
job_name: "node"
scheme: https
basic_auth:
  username: prometheus
  password: password
static_configs:
  - targets:
      - "192.168.1.168:9100"
```

→ Ces labels permettent de **tracer chaque métrique jusqu'à sa source**, facilitant monitoring et troubleshooting.

### À retenir

- Une métrique = **nom + labels + valeur numérique** (à un timestamp donné).
- Le **timestamp** est un **Unix timestamp** (secondes depuis le 1/1/1970 UTC).
- Une **time series** = combinaison **unique** de nom + labels ; chaque scrape ajoute un point horodaté.
- Attributs : **HELP** (description) et **TYPE** ; **4 types** : **Counter** (croît seulement), **Gauge** (monte/descend), **Histogram** (buckets), **Summary** (percentiles).
- **Nommage** : lettres/chiffres/underscores ; éviter les **`:`** (réservés aux recording rules).
- Les **labels** ajoutent des dimensions → préférer une métrique unique + labels plutôt que des métriques séparées (agrégation facilitée).
- Labels **automatiques** : **`instance`** (la target) et **`job`** (le nom du job) ; **`__name__`** = le nom de la métrique en interne.

### Liens utiles

- Page de téléchargement Prometheus : https://prometheus.io/download
- Documentation officielle Prometheus : https://prometheus.io/docs/
