# Monitorer un cluster kubernetes avec Prometheus

Ce contenu explique comment utiliser Prometheus pour monitorer à la fois les **applications** et le **cluster Kubernetes** lui-même. En déployant Prometheus **directement sur le cluster**, on observe efficacement les applications tout en exploitant les fonctionnalités intégrées de Kubernetes.

**Deux avantages** de déployer Prometheus sur Kubernetes :
- Il **colocalise** l'outil de monitoring **près des applications** ;
- Il **exploite l'infrastructure Kubernetes existante**, évitant des serveurs/VM séparés.

### Les cibles de monitoring dans Kubernetes

Il y a **deux cibles principales** :

**1. Les applications sur le cluster** : applications web, serveurs, ou tout service tournant sur Kubernetes.

**2. Les composants au niveau du cluster** :
- les éléments du **control plane** (API server, kube-scheduler, CoreDNS) ;
- le **kubelet** (qui fournit des métriques au niveau conteneur, similaires à cAdvisor) ;
- les métriques exposées par le conteneur **kube-state-metrics**.

De plus, chaque **nœud** (essentiellement un serveur Linux) devrait exécuter un **node exporter** pour exposer les statistiques CPU, mémoire et réseau.

> **Point crucial** : Kubernetes **n'expose PAS nativement** les métriques au niveau cluster (pods, deployments, services). Pour y accéder, il faut **déployer le conteneur kube-state-metrics**.

### Utiliser les DaemonSets pour les Node Exporters

Chaque hôte du cluster doit exécuter un **node exporter** pour exposer les statistiques système (CPU, mémoire, réseau). L'approche recommandée est de déployer le node exporter comme un **DaemonSet** Kubernetes. Cela garantit que :
- Chaque nœud exécute **un pod node exporter** ;
- Le système planifie **automatiquement** le node exporter sur **tout nouveau nœud** ajouté.

> **Rappel** : un DaemonSet garantit qu'un pod tourne sur **chaque nœud** — d'où sa pertinence pour le node exporter.

### La Service Discovery de Kubernetes

La **service discovery** de Kubernetes simplifie le processus en accédant à l'**API Kubernetes**. Elle **identifie automatiquement** tous les targets que Prometheus doit scraper : composants Kubernetes, node exporters et endpoints kube-state-metrics.

### Déployer Prometheus avec Helm

Bien que Prometheus puisse être installé **manuellement** (en créant deployments, services, config maps, secrets), cette méthode est **complexe**. Une approche plus efficace utilise les **Helm charts**, notamment le **Prometheus operator chart**, qui **automatise** la configuration de tous les composants nécessaires.

**Helm** (le package manager de Kubernetes) simplifie le déploiement en regroupant tous les fichiers de config dans un **package unique** (le **Helm chart**) :
```bash
helm install
```

Les **Helm charts** sont des collections de **templates et fichiers YAML**, regroupés dans un dépôt pour un partage facile (comme partager du code sur GitHub/GitLab). Ici, on utilise le **Kube Prometheus Stack** du dépôt de la communauté Prometheus, qui inclut : **Alertmanager, Pushgateway et le Prometheus operator**.

### Le Prometheus Operator

Le **Prometheus operator** est une **extension de Kubernetes** qui simplifie la gestion du **cycle de vie** de Prometheus. En **étendant l'API Kubernetes**, il rationalise l'initialisation, la configuration et les **redémarrages automatiques** lorsque la config change.

**L'avantage clé** : au lieu de créer manuellement des objets Kubernetes standards (Deployments, StatefulSets), on définit des **abstractions de plus haut niveau**, comme la ressource **Prometheus** :
```yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  labels:
    app: kube-prometheus-stack-prometheus
    name: prometheus-kube-prometheus-prometheus
spec:
  alerting:
    alertmanagers:
      - apiVersion: v2
        name: prometheus-kube-prometheus-alertmanager
        namespace: default
        pathPrefix: /
        port: http-web
```

Cette abstraction permet de personnaliser le déploiement via une **API simplifiée**. Des abstractions similaires existent pour :
- **Alertmanager** ;
- les **Prometheus rules** et configurations d'alerting ;
- les ressources **ServiceMonitor** et **PodMonitor**, qui définissent **quels endpoints** Prometheus doit scraper.

> Ces abstractions de haut niveau simplifient la gestion des instances Prometheus et facilitent les modifications/maintenance du monitoring dans Kubernetes.

### Metrics-server vs Prometheus

#### 1. Le metrics-server s'appuie-t-il sur kubelet ? — Oui

**Oui, absolument.** Le **metrics-server** récupère les métriques CPU et mémoire en interrogeant le **kubelet** de chaque nœud.

**La chaîne complète** :
```
cAdvisor (intégré au kubelet)
   │  collecte les métriques CPU/mémoire des conteneurs
   ▼
kubelet  ──── expose ces métriques via son endpoint /metrics/resource
   │
   ▼
metrics-server  ──── scrape le kubelet de chaque nœud, agrège en mémoire
   │
   ▼
Metrics API (metrics.k8s.io)
   │
   ▼
kubectl top / HPA / VPA
```

**Points clés** :
- Le **kubelet** embarque **cAdvisor**, qui collecte les métriques des conteneurs sur le nœud ;
- Le **metrics-server** interroge le kubelet (endpoint **`/metrics/resource`**) et **agrège** les données **en mémoire** (il ne les stocke pas durablement) ;
- Il expose ensuite ces données via la **Metrics API** (`metrics.k8s.io`) ;
- C'est cette API qu'utilisent **`kubectl top pods/nodes`**, le **HPA** et le **VPA**.

> **Important** : le metrics-server ne conserve que des métriques **récentes et légères** (CPU/mémoire uniquement, pas d'historique). Il est conçu **spécifiquement** pour alimenter l'autoscaling et `kubectl top`, **pas** pour le monitoring général.

#### 2. Comment Prometheus récupère les métriques CPU/mémoire des pods ?

Prometheus procède **différemment** du metrics-server, mais s'appuie **aussi sur le kubelet/cAdvisor** — via son **modèle pull (scraping)**.

**Le fonctionnement** :
1. Le **kubelet** expose les métriques des conteneurs via **cAdvisor**, sur l'endpoint **`/metrics/cadvisor`** ;
2. Prometheus, grâce à son **service discovery Kubernetes**, découvre automatiquement les **nœuds/kubelets** comme **targets** ;
3. Prometheus **scrape** cet endpoint à intervalles réguliers (ex. toutes les 15 s) ;
4. Il **stocke** les métriques dans sa **base time-series** (avec historique) ;
5. On les interroge ensuite en **PromQL**.

**Exemples de métriques cAdvisor scrapées par Prometheus** :
```promql
container_cpu_usage_seconds_total{pod="myapp-xxx", namespace="default"}
container_memory_usage_bytes{pod="myapp-xxx", namespace="default"}
```

Et pour les **métriques d'objets** (nombre de pods, état des deployments…), Prometheus scrape en plus **kube-state-metrics**.

#### Distinction clé entre metrics-server vs prometheus

Les deux s'appuient sur le **kubelet/cAdvisor** comme source, mais leurs objectifs diffèrent radicalement :

| Aspect | **metrics-server** | **Prometheus** |
|--------|--------------------|----------------|
| Source des métriques | kubelet (`/metrics/resource`) | kubelet/cAdvisor (`/metrics/cadvisor`) + kube-state-metrics |
| Stockage | **En mémoire**, éphémère (pas d'historique) | **Base time-series** (historique durable) |
| Métriques | CPU + mémoire uniquement | CPU, mémoire, réseau, disque, applicatives, custom… |
| But principal | Alimenter **`kubectl top`**, **HPA**, **VPA** | **Monitoring complet**, alerting, dashboards (Grafana) |
| Requêtes | Metrics API (`metrics.k8s.io`) | **PromQL** |
| Léger ? | Oui, très léger | Plus lourd (stockage, rétention) |

#### Le point commun essentiel

Les deux systèmes remontent à la **même source de base** : **cAdvisor, intégré dans le kubelet**. C'est ce qui explique la phrase du cours (« le kubelet fournit des métriques au niveau conteneur, similaires à cAdvisor ») — en réalité, ces métriques **proviennent** de cAdvisor qui est **embarqué dans le kubelet**.

La différence est ce qu'ils **en font** :
- **metrics-server** : agrège en temps réel, léger, pour le **scaling** ;
- **Prometheus** : scrape et **stocke** avec historique, pour le **monitoring et l'observabilité**.

### À retenir

- Déployer Prometheus **sur le cluster** = colocalisation avec les apps + réutilisation de l'infra existante.
- **2 cibles** : les **applications** et les **composants cluster** (control plane, kubelet, kube-state-metrics).
- Kubernetes n'expose pas nativement les métriques cluster → déployer **kube-state-metrics**.
- Déployer le **node exporter** comme **DaemonSet** (un par nœud, auto sur les nouveaux nœuds).
- La **service discovery** identifie automatiquement les targets à scraper via l'API Kubernetes.
- Installation simplifiée via **Helm** + le **Kube Prometheus Stack** (Alertmanager, Pushgateway, Prometheus operator).
- Le **Prometheus operator** étend l'API Kubernetes avec des abstractions de haut niveau : ressource **Prometheus**, **Alertmanager**, **ServiceMonitor**, **PodMonitor** (définissent quoi scraper).

### Liens utiles

- Documentation kube-prometheus-stack : https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
