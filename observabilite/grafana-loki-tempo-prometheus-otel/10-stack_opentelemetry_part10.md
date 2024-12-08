# Mise en place du monitoring système et des logs système avec fluent-bit

Ici nous allons monitorer avec **fluent-bit** notre serveur **server-app** afin qu'il puisse téléverser les **données de métriques** vers notre **collecteur opentelemetry**.

- Installation de **fluent-bit 3.2.1** sur le serveur **server-app**

```
sudo vi /etc/yum.repos.d/fluent-bit.repo
```

```
[fluent-bit]
name = Fluent Bit
baseurl = https://packages.fluentbit.io/centos/8/x86_64/
gpgcheck=1
gpgkey=https://packages.fluentbit.io/fluentbit.key
repo_gpgcheck=1
enabled=1
```

```
sudo yum install fluent-bit-3.2.1
```

- Verification du statut de **fluent-bit**

```
systemctl status fluent-bit
```

Ici nous constatons que le service **fluent-bit** n'est pas encore démarré.

- Configuration de **fluent-bit**

```
sudo mv /etc/fluent-bit/fluent-bit.conf /etc/fluent-bit/fluent-bit.conf.backup
```

```
sudo vi /etc/fluent-bit/fluent-bit.yaml
```

```
service:
  flush: 1
  log_level: info

pipeline:
  inputs:
  - name: node_exporter_metrics
    tag: system
    scrape_interval: 2
    processors:
      logs:
      - name: opentelemetry_envelope
      - name: content_modifier
        context: otel_resource_attributes
        action: upsert
        key: 'service.name'
        value: 'server-app'

  - name: tail
    tag: system
    path: '/var/log/*log'
    db: '/var/log/fluent-bit/tail.db'
    processors:
      logs:
      - name: opentelemetry_envelope
      - name: content_modifier
        context: otel_resource_attributes
        action: upsert
        key: 'service.name'
        value: server-app

  - name: event_type
    tag: system
    type: traces
    processors:
      logs:
      - name: opentelemetry_envelope
      - name: content_modifier
        context: otel_resource_attributes
        action: upsert
        key: 'service.name'
        value: 'server-app'

  outputs:
  - name: opentelemetry
    match: '*'
    host: 192.168.56.21 
    port: 4318
    metrics_uri: '/v1/metrics'
    logs_uri: '/v1/logs'
    traces_uri: '/v1/traces'
    log_response_payload: True
    tls: Off
    tls.verify: Off
    logs_body_key: $message
    logs_span_id_message_key: span_id
    logs_trace_id_message_key: trace_id
    logs_severity_text_message_key: loglevel
    logs_severity_number_message_key: lognum
```

Modifier le fichier de configuration dans le fichier service **/usr/lib/systemd/system/fluent-bit.service**

```
sudo vi /usr/lib/systemd/system/fluent-bit.service
```

```
[Unit]
Description=Fluent Bit
Documentation=https://docs.fluentbit.io/manual/
Requires=network.target
After=network.target

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/fluent-bit
EnvironmentFile=-/etc/default/fluent-bit
ExecStart=/opt/fluent-bit/bin/fluent-bit -c //etc/fluent-bit/fluent-bit.yaml
Restart=always

[Install]
WantedBy=multi-user.target
```

- Démarrage et activation du service **fluent-bit**

```
sudo systemctl enable --now fluent-bit
```

- Verification du statut de **fluent-bit**

```
systemctl status fluent-bit
```

Ici nous constatons que le service **fluent-bit** est bien démarré.

- Visualisation des métriques sur grafana

Nous accédons à grafana via l'url **http://192.168.56.21:3000/** puis nous suivons les étapes :

--- clic sur le bouton **Toggle menu** <br>
--- sélection du menu **Explore** <br>
--- choix de la datasource **Thanos-Query-Frontend** <br>
--- au niveau de **Metric** on sélectionne par exemple **node_memory_MemAvailable_bytes**, puis au niveau de **Label filters** on sélectionne le label **host** et sa valeur **server-app**.

L'on pourra ainsi visualiser la quantité de **memoire** disponible sur une période précise.