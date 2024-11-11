# Mise en place de la stack trace sur le serveur server-monitoring

- Préparation des repertoires de **tempo**, son fichier de configuration


```
mkdir -p $HOME/tempo/wal0 $HOME/tempo/wal1 $HOME/tempo/wal2
```

```
# $HOME/tempo/tempo.yaml
server:
  http_listen_port: 3200

distributor:
  receivers:
    otlp:
      protocols:
        http:
          endpoint: 0.0.0.0:5318
        grpc:
          endpoint: 0.0.0.0:5317

ingester:
  max_block_duration: 30m

memberlist:
  abort_if_cluster_join_fails: false
  bind_port: 7946
  join_members:
  - tempo-ingester-0:7946
  - tempo-ingester-1:7946
  - tempo-ingester-2:7946

compactor:
  compaction:
    block_retention: 128h

querier:
  frontend_worker:
    frontend_address: tempo-query-frontend:9095

query_frontend:
  max_retries: 3

storage:
  trace:
    backend: s3
    s3:
      bucket: bucket-traces
      endpoint: 192.168.56.20:9000
      access_key: 1MpVon6pfJgf9JiFQYfK
      secret_key: 4j3jdcAeCf4jqgPxBxJ6ZuPVzcRtgjaoefCQICES
      insecure: true
    wal:
      path: /var/tempo/wal
```

- Preparation du fichier **docker-compose** et installation des composants : **tempo distributor**, **tempo ingester**, **tempo compactor**, **tempo querier** et **tempo query-frontend**.

```
vi $HOME/tempo/docker-compose.yml
```

```
version: '3.8'

services:
  tempo-distributor:
    image: docker.io/grafana/tempo:r174-403fdcf
    command: "-target=distributor -config.file=/etc/tempo.yaml"
    ports:
      - "3200:3200"
      - "5318:5318"
      - "5317:5317"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/tempo/tempo.yaml:/etc/tempo.yaml:z'

  tempo-ingester-0:
    image: docker.io/grafana/tempo:r174-403fdcf
    command: "-target=ingester -config.file=/etc/tempo.yaml"
    user: root
    ports:
      - "3201:3200"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/tempo/tempo.yaml:/etc/tempo.yaml:z'
      - '$HOME/tempo/wal0:/var/tempo/wal:z'
  
  tempo-ingester-1:
    image: docker.io/grafana/tempo:r174-403fdcf
    command: "-target=ingester -config.file=/etc/tempo.yaml"
    user: root
    ports:
      - "3202:3200"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/tempo/tempo.yaml:/etc/tempo.yaml:z'
      - '$HOME/tempo/wal1:/var/tempo/wal:z'

  tempo-ingester-2:
    image: docker.io/grafana/tempo:r174-403fdcf
    command: "-target=ingester -config.file=/etc/tempo.yaml"
    user: root
    ports:
      - "3203:3200"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/tempo/tempo.yaml:/etc/tempo.yaml:z'
      - '$HOME/tempo/wal2:/var/tempo/wal:z'

  tempo-query-frontend:
    image: docker.io/grafana/tempo:r174-403fdcf
    command: "-target=query-frontend -config.file=/etc/tempo.yaml -log.level=debug"
    ports:
      - "3204:3200"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/tempo/tempo.yaml:/etc/tempo.yaml:z'

  tempo-querier:
    image: docker.io/grafana/tempo:r174-403fdcf
    command: "-target=querier -config.file=/etc/tempo.yaml -log.level=debug"
    ports:
      - "3205:3200"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/tempo/tempo.yaml:/etc/tempo.yaml:z'

  tempo-compactor:
    image: docker.io/grafana/tempo:r174-403fdcf
    command: "-target=compactor -config.file=/etc/tempo.yaml"
    ports:
      - "3206:3200"
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/tempo/tempo.yaml:/etc/tempo.yaml:z'

networks:
  networks-monitoring:
    name: server-monitoring
    external: true
```

```
podman-compose up -d
```

- Ajout de **tempo-query-frontend** comme source de données **tempo** sur Grafana

--- clic sur le bouton **Toggle menu** <br>
--- sélection du menu **Data sources** <br>
--- clic sur le bouton **add data source** <br>
--- sélection du type de source de données **tempo** <br>
--- renseignement des paramètres du composant **thanos query frontend** <br>
----- **Name** : **Tempo-Query-Frontend** <br>
----- **Tempo query frontend server URL** : **http://192.168.56.21:3204** <br>
--- clic sur le bouton **Save & test** : nous recevrons un message de succès.