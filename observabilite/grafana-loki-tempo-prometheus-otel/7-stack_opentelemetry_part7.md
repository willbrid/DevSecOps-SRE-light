# Mise en place de la stack otelcollector

- Préparation du repertoire de **otelcollector** et son fichier de configuration

```
mkdir $HOME/otelcollector
```

```
# $HOME/otelcollector/config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
  memory_limiter:  
    limit_mib: 4000  
    spike_limit_mib: 512
    check_interval: 5s

extensions:
  health_check: {}

exporters:
  otlp:
    endpoint: "tempo-distributor:5317"
    tls:
      insecure: true

  otlphttp:
    endpoint: "http://loki-distributor:3100/otlp"
    tls:
      insecure: true

  prometheusremotewrite:
    endpoint: "http://prometheus:9090/api/v1/write"
    tls:
      insecure: true

service:
  extensions: [health_check]
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch,memory_limiter]
      exporters: [otlp]
    logs:
      receivers: [otlp]
      processors: [batch,memory_limiter]
      exporters: [otlphttp]
    metrics:
      receivers: [otlp]
      processors: [batch,memory_limiter]
      exporters: [prometheusremotewrite]
```

- Preparation du fichier **docker-compose** et installation du composant : **otelcollector**.

```
vi $HOME/otelcollector/docker-compose.yml
```

```
version: '3.8'

services:
  otel-collector:
    image: docker.io/otel/opentelemetry-collector-contrib:0.113.0
    ports:
      - 13133:13133
      - 4317:4317
      - 4318:4318
    networks:
      - networks-monitoring
    volumes:
      - '$HOME/otelcollector/config.yaml:/etc/otelcol-contrib/config.yaml:z'

networks:
  networks-monitoring:
    name: server-monitoring
    external: true
```

```
podman-compose up -d
```

- Autorisation des ports **4317** et **4318** sur le firewall


```
sudo firewall-cmd --permanent --add-port={4317/tcp,4318/tcp}

sudo firewall-cmd --reload
```