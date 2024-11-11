# Mise en place de la stack metric sur le serveur server-monitoring

- Préparation des répertoires de prometheus, son fichier de configuration et un fichier d'une règle d'alerte

```
mkdir -p $HOME/prometheus/data && mkdir $HOME/prometheus/rules
```

```
# $HOME/prometheus/prometheus.yml
global:
  scrape_interval: 5s
  external_labels:
    cluster: cluster1
    replica: 0

rule_files:
- "/etc/prometheus/rules/*"    

alerting:
 alertmanagers:
 - static_configs:
   - targets: ['192.168.56.21:9093']

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.56.21:9090']

  - job_name: 'thanos-sidecar'
    static_configs:
      - targets: ['192.168.56.21:19090']

  - job_name: 'thanos-store-gateway'
    static_configs:
      - targets: ['192.168.56.21:19091']

  - job_name: 'thanos-compactor'
    static_configs:
      - targets: ['192.168.56.21:19095']

  - job_name: 'thanos-querier'
    static_configs:
      - targets: ['192.168.56.21:9091']   

  - job_name: 'thanos-query-frontend'
    static_configs:
      - targets: ['192.168.56.21:9092']     
```

```
# $HOME/prometheus/rules/linux_server_rules.yml
groups:
- name: NODE_CLUSTER_A
  rules:
  - alert: NodeDown
    expr: up{job="node-exporter"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Node is down"
      description: "The node has been down for the last 1 minute."
```

- Préparation du fichier de configuration du bucket **bucket-metrics**

```
# $HOME/prometheus/bucket_storage.yaml
type: S3
config:
  bucket: "bucket-metrics"
  endpoint: "192.168.56.20:9000"
  insecure: true
  signature_version2: true
  access_key: "1MpVon6pfJgf9JiFQYfK"
  secret_key: "4j3jdcAeCf4jqgPxBxJ6ZuPVzcRtgjaoefCQICES"
```

- Préparation du fichier d'accès à **Redis** par le composant **thanos query-frontend**

```
# $HOME/prometheus/frontend.yml
type: REDIS
config:
  addr: "192.168.56.20:6379"
  username: ""
  password: ""
  db: 0
  dial_timeout: 5s
  read_timeout: 3s
  write_timeout: 3s
  max_get_multi_concurrency: 100
  get_multi_batch_size: 100
  max_set_multi_concurrency: 100
  set_multi_batch_size: 100
  expiration: 24h0m0s
```

- Preparation du fichier **docker-compose** et installation des composants : **prometheus**, **thanos sidecar**, **thanos store gateway**, **thanos compactor**, **thanos querier** et **thanos query-frontend**.

```
vi $HOME/prometheus/docker-compose.yml
```

```
version: '3.8'

services:
  prometheus:
    image: quay.io/prometheus/prometheus:v2.53.2
    user: root
    command: 
    - --config.file=/etc/prometheus/prometheus.yml
    - --storage.tsdb.retention.time=6h
    - --storage.tsdb.wal-compression
    - --storage.tsdb.path=/prometheus
    - --storage.tsdb.max-block-duration=2h
    - --storage.tsdb.min-block-duration=2h
    - --web.listen-address=:9090
    - --web.external-url=http://192.168.56.21:9090
    - --web.enable-lifecycle
    - --web.enable-admin-api
    - --web.enable-remote-write-receiver
    ports:
      - "9090:9090"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:z'
      - '$HOME/prometheus/data:/prometheus:z'
      - '$HOME/prometheus/rules:/etc/prometheus/rules:z'

  thanos-sidecar:
    image: quay.io/thanos/thanos:v0.36.0
    user: root
    command:
    - sidecar
    - --tsdb.path=/prometheus
    - --objstore.config-file=/etc/thanos/minio-bucket.yaml
    - --shipper.upload-compacted
    - --http-address=0.0.0.0:19090
    - --grpc-address=0.0.0.0:19190
    - --prometheus.url=http://192.168.56.21:9090
    ports:
      - "19090:19090"
      - "19190:19190"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/prometheus/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z'
      - '$HOME/prometheus/data:/prometheus:z'

  thanos-store-gateway:
    image: quay.io/thanos/thanos:v0.36.0
    user: root
    command:
    - store
    - --objstore.config-file=/etc/thanos/minio-bucket.yaml
    - --http-address=0.0.0.0:19091
    - --grpc-address=0.0.0.0:19191
    ports:
      - "19091:19091"
      - "19191:19191"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/prometheus/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z'

  thanos-compactor:
    image: quay.io/thanos/thanos:v0.36.0
    user: root
    command:
    - compact
    - --wait
    - --wait-interval=30s
    - --consistency-delay=0s
    - --objstore.config-file=/etc/thanos/minio-bucket.yaml
    - --http-address=0.0.0.0:19095
    ports:
      - "19095:19095"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/prometheus/bucket_storage.yaml:/etc/thanos/minio-bucket.yaml:z'

  thanos-querier:
    image: quay.io/thanos/thanos:v0.36.0
    user: root
    command:
    - query
    - --http-address=0.0.0.0:9091
    - --query.replica-label=replica
    - --store=192.168.56.21:19190
    - --store=192.168.56.21:19191
    ports:
      - "9091:9091"
    networks:
      - networks-monitoring

  thanos-query-frontend:
    image: quay.io/thanos/thanos:v0.36.0
    user: root
    command:
    - query-frontend
    - --http-address=0.0.0.0:9092
    - --query-frontend.compress-responses
    - --query-frontend.downstream-url=http://192.168.56.21:9091
    - --query-frontend.log-queries-longer-than=5s
    - --query-range.split-interval=1m
    - --query-range.response-cache-max-freshness=1m
    - --query-range.max-retries-per-request=5
    - --query-range.response-cache-config-file=/etc/thanos/frontend.yml
    - --cache-compression-type=snappy
    ports:
      - "9092:9092"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/prometheus/frontend.yml:/etc/thanos/frontend.yml:z'

networks:
  networks-monitoring:
    name: server-monitoring
    external: true
```

```
podman-compose up -d
```

- Ajout de **thanos-query-frontend** comme source de données **prometheus** sur Grafana

--- clic sur le bouton **Toggle menu** <br>
--- sélection du menu **Data sources** <br>
--- clic sur le bouton **add data source** <br>
--- sélection du type de source de données **prometheus** <br>
--- renseignement des paramètres du composant **thanos query frontend** <br>
----- **Name** : **Thanos-Query-Frontend** <br>
----- **Thanos query frontend server URL** : **http://192.168.56.21:9092** <br>
--- clic sur le bouton **Save & test** : nous recevrons un message de succès.