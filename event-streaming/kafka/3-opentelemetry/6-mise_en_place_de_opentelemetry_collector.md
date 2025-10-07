# Mise en place de Otelcollector

Les configurations de ces différentes sections se feront dans notre serveur **monitoring**.

Dans cette section, nous allons déployer **Opentelemetry collector** (**Otelcollector**) en un seul conteneur.

### Configuration des préréquis

- Création du repertoire de **Otelcollector**

```
mkdir -p $HOME/otelcollector
```

- Définition du fichier de configuration

```
vi $HOME/otelcollector/config.yaml
```

```
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
    endpoint: "tempo:4317"
    tls:
      insecure: true

  otlphttp:
    endpoint: "http://loki-gateway:3100/loki/api/v1/push"
    encoding: json
    tls:
      insecure: true
    headers:
      "X-Scope-OrgID": "tenant"

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

### Configuration du service otelcollector

```
vi $HOME/.config/containers/systemd/otelcollector.container
```

```
[Unit]
Description=otelcollector
After=local-fs.target
After=prometheus.container
Requires=prometheus.container
After=tempo.container
Requires=tempo.container
After=loki-gateway.container
Requires=loki-gateway.container

[Container]
ContainerName=otelcollector
Image=docker.io/otel/opentelemetry-collector-contrib:0.137.0
Network=monitoring.network
PublishPort=4317:4317
PublishPort=4318:4318
Timezone=Europe/Paris
Volume=/home/vagrant/otelcollector/config.yaml:/etc/otelcol-contrib/config.yaml:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start otelcollector
```

Verification du statut du service otelcollector

```
systemctl --user status otelcollector
```

- Autorisation les ports 4317 et 4318

```
sudo firewall-cmd --permanent --add-port=4317/tcp --add-port=4318/tcp

sudo firewall-cmd --reload
```