# Installation et instrumentation de KAFKA

Les configurations de ces différentes sections se feront dans notre serveur **broker**.

Dans cette section, nous allons déployer un nœud unique **Kafka** en mode **KRaft** (**Kafka Raft**) et l’instrumenter afin d’exposer ses données de télémétrie. L’objectif est d’exposer les métriques, les traces et les logs du broker Kafka à l’aide de l’agent OpenTelemetry Java, en s’appuyant sur le module **JMX Metric Insight** pour la collecte des métriques.

### Configuration des préréquis

- Création du répertoire **$HOME/.config/containers/systemd**

```
mkdir -p $HOME/.config/containers/systemd
```

- Autorisation de l'utilisateur vagrant à exécuter en continu des services

```
sudo loginctl enable-linger vagrant
```

- Création du fichier service réseau **kafkanet**

```
vi $HOME/.config/containers/systemd/kafkanet.network
```

```
[Unit]
Description=Kafkanet network
After=network-online.target

[Network]
NetworkName=kafkanet

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
sudo reboot
```

- Création du repertoire de **kafka**

```
mkdir -p $HOME/kafka/logs
```

- Téléchargement de l'agent opentelemetry (version **2.20.1**)

```
curl -L https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.20.1/opentelemetry-javaagent.jar -o $HOME/kafka/opentelemetry-javaagent.jar
```

### Configuration du service kafka

```
vi $HOME/.config/containers/systemd/kafka.container
```

```
[Unit]
Description=kafka
After=local-fs.target

[Container]
ContainerName=kafka
Image=docker.io/apache/kafka:4.1.0
Network=kafkanet.network
PublishPort=9092:9092
Environment=KAFKA_NODE_ID=1
Environment=KAFKA_PROCESS_ROLES=broker,controller
Environment=KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093
Environment=KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.56.209:9092
Environment=KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER 
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
Environment=KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093
Environment=KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
Environment=KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
Environment=KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
Environment=KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0
Environment=KAFKA_NUM_PARTITIONS=3
Environment=KAFKA_OPTS=-javaagent:/tmp/opentelemetry-javaagent.jar
Environment=OTEL_SERVICE_NAME=kafka-broker
Environment=OTEL_JMX_TARGET_SYSTEM=kafka-broker
Environment=OTEL_EXPORTER_OTLP_ENDPOINT=http://192.168.56.211:4318
Environment=OTEL_METRICS_EXPORTER=otlp
Environment=OTEL_LOGS_EXPORTER=otlp
Environment=OTEL_TRACES_EXPORTER=otlp
Volume=/home/vagrant/kafka/opentelemetry-javaagent.jar:/tmp/opentelemetry-javaagent.jar:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
systemctl --user daemon-reload
```

```
systemctl --user start kafka
```

Verification du statut du service kafka

```
systemctl --user status kafka
```

- Activation du parefeu firewalld et autorisation du port 9092

```
sudo systemctl enable firewalld --now

sudo systemctl status firewalld
```

```
sudo firewall-cmd --permanent --add-port=9092/tcp

sudo firewall-cmd --reload
```