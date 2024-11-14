# Mise en place de la stack logs sur le serveur server-monitoring

- Préparation des repertoires de **loki**, **consul** et leur fichier de configuration

```
mkdir -p $HOME/loki/etcd $HOME/loki/compactor $HOME/loki/ingester $HOME/loki/ruler
```

```
# $HOME/loki/config.yaml
auth_enabled: false

server:
  http_listen_address: 0.0.0.0
  grpc_listen_address: 0.0.0.0
  http_listen_port: 3100
  grpc_listen_port: 9096
  log_level: info

common:
  path_prefix: /loki
  replication_factor: 1
  storage:
    s3:
      s3forcepathstyle: true
      bucketnames: "bucket-logs"
      endpoint: 192.168.56.20:9000
      access_key_id: 1MpVon6pfJgf9JiFQYfK
      secret_access_key: 4j3jdcAeCf4jqgPxBxJ6ZuPVzcRtgjaoefCQICES
      insecure: true
  ring:
    kvstore:
      store: "etcd"
      prefix: "loki/"
      etcd:
        endpoints: ["http://loki-etcd:2379"]
        username: loki
        password: loki2024
        tls_enabled: false
  compactor_grpc_address: "loki-compactor:9096"

schema_config:
  configs:
    - from: 2024-01-01
      store: tsdb
      object_store: s3
      schema: v13
      index:
        prefix: index_
        period: 24h

table_manager:
  retention_deletes_enabled: true
  retention_period: 336h

query_range:
  align_queries_with_step: true
  max_retries: 5
  cache_results: true
  results_cache:
    cache:
      default_validity: 1h
      redis:
        endpoint: "192.168.56.20:6379"
        username: ""
        password: ""
        tls_enabled: false
        
limits_config:
  max_global_streams_per_user: 5000
  max_cache_freshness_per_query: '10m'
  reject_old_samples: true
  reject_old_samples_max_age: 30m
  ingestion_rate_mb: 10
  ingestion_burst_size_mb: 20
  split_queries_by_interval: 15m
  volume_enabled: true
  allow_structured_metadata: true

distributor:
  write_failures_logging:
    rate: 1KB

ingester:
  lifecycler:
    join_after: 30s
    observe_period: 5s
    final_sleep: 0s
  chunk_idle_period: 1m
  wal:
    enabled: true
    dir: /loki/wal
    flush_on_shutdown: true
  max_chunk_age: 1m
  chunk_retain_period: 30s
  chunk_encoding: snappy
  chunk_target_size: 1.572864e+06
  chunk_block_size: 262144
  flush_op_timeout: 10s

ruler:
  rule_path: /loki/rules
  alertmanager_url: "http://alertmanager:9093"

querier:
  max_concurrent: 4
  query_ingesters_within: 1h

query_scheduler:
  max_outstanding_requests_per_tenant: 32000
  use_scheduler_ring: true

compactor:
  working_directory: /tmp/compactor
  compaction_interval: 10m
  retention_enabled: true
  retention_delete_delay: 2h
  retention_delete_worker_count: 150
  delete_request_store: filesystem

index_gateway:
  mode: "ring"

frontend_worker:
  scheduler_address: loki-query-scheduler:9096
  query_scheduler_grpc_client:
    max_send_msg_size: 1.048576e+08

frontend:
  log_queries_longer_than: 5s
  scheduler_address: loki-query-scheduler:9096
  compress_responses: true
  max_outstanding_per_tenant: 2048
  tail_proxy_url: http://loki-querier:3100
```

- Preparation du fichier **docker-compose** et installation des composants : **loki distributor**, **loki ingester**, **loki compactor**, **loki querier**, **loki query-frontend**, **loki query-scheduler**, **loki ruler**, **etcd**.

```
vi $HOME/loki/docker-compose.yml
```

```
version: '3.8'

services:
  loki-distributor:
    image: docker.io/grafana/loki:k228-f2da621
    command: "-target=distributor -config.file=/etc/loki/loki.yaml -config.expand-env=true"
    ports:
      - "3100:3100"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/loki/config.yaml:/etc/loki/loki.yaml:z'

  loki-ingester:
    image: docker.io/grafana/loki:k228-f2da621
    command: "-target=ingester -config.file=/etc/loki/loki.yaml -config.expand-env=true"
    user: root
    ports:
      - "3101:3100"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/loki/config.yaml:/etc/loki/loki.yaml:z'
      - '$HOME/loki/ingester:/loki/wal:z'

  loki-query-frontend:
    image: docker.io/grafana/loki:k228-f2da621
    command: "-target=query-frontend -config.file=/etc/loki/loki.yaml -config.expand-env=true"
    ports:
      - "3102:3100"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/loki/config.yaml:/etc/loki/loki.yaml:z'

  loki-querier:
    image: docker.io/grafana/loki:k228-f2da621
    command: "-target=querier -config.file=/etc/loki/loki.yaml -config.expand-env=true"
    ports:
      - "3103:3100"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/loki/config.yaml:/etc/loki/loki.yaml:z'

  loki-compactor:
    image: docker.io/grafana/loki:k228-f2da621
    command: "-target=compactor -config.file=/etc/loki/loki.yaml -config.expand-env=true"
    ports:
      - "3104:3100"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/loki/config.yaml:/etc/loki/loki.yaml:z'

  loki-index-gateway:
    image: docker.io/grafana/loki:k228-f2da621
    command: "-target=index-gateway -config.file=/etc/loki/loki.yaml -config.expand-env=true"
    ports:
      - "3105:3100"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/loki/config.yaml:/etc/loki/loki.yaml:z'

  loki-ruler:
    image: docker.io/grafana/loki:k228-f2da621
    command: "-target=ruler -config.file=/etc/loki/loki.yaml -config.expand-env=true"
    ports:
      - "3106:3100"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/loki/config.yaml:/etc/loki/loki.yaml:z'
      - '$HOME/loki/ruler:/loki/rules:z'

  loki-query-scheduler:
    image: docker.io/grafana/loki:k228-f2da621
    command: "-target=query-scheduler -config.file=/etc/loki/loki.yaml -config.expand-env=true"
    ports:
      - "3107:3100"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/loki/config.yaml:/etc/loki/loki.yaml:z'

  loki-etcd:
    image: quay.io/coreos/etcd:v3.4.34
    command:
    - /usr/local/bin/etcd
    - --data-dir=/etcd-data
    - --name=node1
    - --initial-advertise-peer-urls=http://192.168.56.21:2380
    - --listen-peer-urls=http://0.0.0.0:2380
    - --advertise-client-urls=http://192.168.56.21:2379
    - --listen-client-urls=http://0.0.0.0:2379
    - --initial-cluster
    - node1=http://192.168.56.21:2380
    ports:
      - "2379:2379"
      - "2380:2380"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/loki/etcd:/etcd-data:z'

networks:
  networks-monitoring:
    name: server-monitoring
    external: true
```

- Démarrage de **loki-etcd**, Activation de l'authentification et création d'un utilisateur **loki** et son mot de passe **loki2024**

```
podman-compose up loki-etcd -d
```

On ajoute un utilisateur **root** avec pour mot de passe **root2024**

```
podman container exec -it loki_loki-etcd_1 /usr/local/bin/etcdctl user add root --new-user-password root2024
```

On lui ajoute le rôle **root**

```
podman container exec -it loki_loki-etcd_1 /usr/local/bin/etcdctl user grant-role root root
```

On active l'authentification sur l'etcd

```
podman container exec -it loki_loki-etcd_1 /usr/local/bin/etcdctl auth enable
```

On crée un utilisateur **loki** avec pour mot de passe **loki2024**

```
podman container exec -it loki_loki-etcd_1 /usr/local/bin/etcdctl user add loki --new-user-password loki2024 --user="root:root2024"
```

On ajoute un rôle **loki_rw** pour le préfixe **loki/**

```
podman container exec -it loki_loki-etcd_1 /usr/local/bin/etcdctl role add loki_rw --user="root:root2024"
```

On ajoute les permissions **readwrite** au rôle **loki_rw** pour le préfixe **loki/**

```
podman container exec -it loki_loki-etcd_1 /usr/local/bin/etcdctl role grant-permission loki_rw readwrite --prefix loki/ --user="root:root2024"
```

On ajoute le rôle **loki_rw** à l'utilisateur **loki**

```
podman container exec -it loki_loki-etcd_1 /usr/local/bin/etcdctl user grant-role loki loki_rw --user="root:root2024"
```

- Lancement de tous les autres composants

```
podman-compose up -d
```

- Ajout de **loki-query-frontend** comme source de données **loki** sur Grafana

--- clic sur le bouton **Toggle menu** <br>
--- sélection du menu **Data sources** <br>
--- clic sur le bouton **add data source** <br>
--- sélection du type de source de données **loki** <br>
--- renseignement des paramètres du composant **loki query frontend** <br>
----- **Name** : **Loki-Query-Frontend** <br>
----- **Tempo query frontend server URL** : **http://192.168.56.21:3102** <br>
--- clic sur le bouton **Save & test** : nous recevrons un message de succès.

**Référence de configuration :** 
- [https://grafana.com/docs/loki/latest/configure/](https://grafana.com/docs/loki/latest/configure/)
- [https://etcd.io/docs/v3.4/op-guide/authentication/](https://etcd.io/docs/v3.4/op-guide/authentication/)
- [https://etcd.io/docs/v3.4/op-guide/container/](https://etcd.io/docs/v3.4/op-guide/container/)