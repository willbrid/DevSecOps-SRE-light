# Mise en place des composants Thanos Sidecar

Le composant **Thanos sidecar** doit être déployé avec **Prometheus**. Le composant **Thanos sidecar** a plusieurs fonctionnalités :

- Il expose les métriques Prometheus en tant que **Thanos StoreAPI** commune. **StoreAPI** est une API gRPC générique permettant aux composants Thanos de récupérer des métriques à partir de divers systèmes et backends.
- Il est capable de surveiller la configuration et les règles Prometheus (alertes ou enregistrements) et de notifier Prometheus pour les rechargements dynamiques.

### Installation d'un composant Thanos sidecar sur chacun de nos serveurs prometheus

Sur le serveur **srv-clusterA**

```
podman run -d --net=host \
    -v $HOME/prometheus0_A.yml:/etc/prometheus/prometheus.yml:z \
    --name prometheus-0-sidecar-A \
    -u root \
    quay.io/thanos/thanos:v0.28.0 \
    sidecar \
    --http-address 0.0.0.0:19090 \
    --grpc-address 0.0.0.0:19190 \
    --reloader.config-file /etc/prometheus/prometheus.yml \
    --prometheus.url http://192.168.56.140:9090 && echo "Started sidecar for Prometheus 0 A"
```

Sur le serveur **srv-clusterB**

```
podman run -d --net=host \
    -v $HOME/prometheus0_B.yml:/etc/prometheus/prometheus.yml:z \
    --name prometheus-0-sidecar-B \
    -u root \
    quay.io/thanos/thanos:v0.28.0 \
    sidecar \
    --http-address 0.0.0.0:19091 \
    --grpc-address 0.0.0.0:19191 \
    --reloader.config-file /etc/prometheus/prometheus.yml \
    --prometheus.url http://192.168.56.141:9091 && echo "Started sidecar for Prometheus 0 B"
```

```
podman run -d --net=host \
    -v $HOME/prometheus1_B.yml:/etc/prometheus/prometheus.yml:z \
    --name prometheus-1-sidecar-B \
    -u root \
    quay.io/thanos/thanos:v0.28.0 \
    sidecar \
    --http-address 0.0.0.0:19092 \
    --grpc-address 0.0.0.0:19192 \
    --reloader.config-file /etc/prometheus/prometheus.yml \
    --prometheus.url http://192.168.56.141:9092 && echo "Started sidecar for Prometheus 1 B"
```

### Mettre à jour chaque configuration prometheus pour intégrer chaque composant thanos sidecar

Notons que ce n'est que grâce au composant **thanos sidecar** que toutes ces modifications seront immédiatement rechargées et mises à jour dans Prometheus !

Sur le serveur **srv-clusterA**

```
vi $HOME/prometheus0_A.yml
```

```
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: A
    replica: 0

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.56.140:9090']
  - job_name: 'thanos_sidecar'
    static_configs:
      - targets: ['192.168.56.140:19090']
```

Avec selinux en mode **enforcing**, nous serons obligés de redemarrer les deux conteneurs

```
podman restart prometheus-0-A
podman restart prometheus-0-sidecar-A
```

Sur le serveur **srv-clusterB**

```
vi $HOME/prometheus0_B.yml
```

```
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: B
    replica: 0

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.56.141:9091','192.168.56.141:9092']
  - job_name: 'thanos_sidecar'
    static_configs:
      - targets: ['192.168.56.141:19091','192.168.56.141:19092']
```

```
vi $HOME/prometheus1_B.yml
```

```
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: B
    replica: 1

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.56.141:9091','192.168.56.141:9092']
  - job_name: 'thanos_sidecar'
    static_configs:
      - targets: ['192.168.56.141:19091','192.168.56.141:19092']
```

Avec selinux en mode **enforcing**, nous serons obligés de redemarrer les 4 conteneurs

```
podman restart prometheus-0-B
podman restart prometheus-0-sidecar-B
podman restart prometheus-1-B
podman restart prometheus-1-sidecar-B
```

Nous devrions maintenant voir une nouvelle configuration mise à jour sur chaque Prometheus en consultant les liens

```
http://prometheusA.local:9090/config
http://prometheusB.local:9091/config
http://prometheusB.local:9092/config
```

Depuis que Prometheus a accès aux métriques **thanos sidecar**, nous pouvons interroger **thanos_sidecar_prometheus_up** pour vérifier si **thanos sidecar** a accès à Prometheus.