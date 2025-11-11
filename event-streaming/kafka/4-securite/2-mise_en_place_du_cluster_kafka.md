# Mise en place du cluster Kafka

À partir de notre serveur **broker** de notre environnement sandbox, nous allons déployer un cluster **Kafka KRaft** composé de trois nœuds conteneurisés, chacun jouant à la fois le rôle de **broker** et de **contrôleur**.

### Configuration des préréquis

Avant de commencer, il est nécessaire de supprimer tous les conteneurs existants sur le serveur broker afin de repartir sur une base propre.

- Création du répertoire de données des 3 noeuds kafka

```
mkdir -p $HOME/kafka/data1 $HOME/kafka/data2 $HOME/kafka/data3
```

```
chmod -R 0777 $HOME/kafka/data1 $HOME/kafka/data2 $HOME/kafka/data3
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

### Configuration des 3 services kafka

```
vi $HOME/.config/containers/systemd/kafka-1.container
```

```
[Unit]
Description=kafka
After=local-fs.target

[Container]
ContainerName=kafka-1
Image=docker.io/apache/kafka:4.1.0
Network=kafkanet.network
PublishPort=29092:9092
HostName=kafka-1
Environment=KAFKA_NODE_ID=1
Environment=KAFKA_PROCESS_ROLES='broker,controller'
Environment=KAFKA_LISTENERS=INTERNAL://:19092,CONTROLLER://kafka-1:29093,EXTERNAL://:9092
Environment=KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL
Environment=KAFKA_SECURITY_PROTOCOL=PLAINTEXT
Environment=KAFKA_ADVERTISED_LISTENERS=INTERNAL://kafka-1:19092,EXTERNAL://192.168.56.209:29092
Environment=KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER 
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT
Environment=KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafka-1:29093,2@kafka-2:29093,3@kafka-3:29093
Environment=KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
Environment=KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
Environment=KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
Environment=KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0
Environment=KAFKA_NUM_PARTITIONS=3
Environment=KAFKA_LOG_DIRS='/tmp/kraft-combined-logs'
Environment=CLUSTER_ID='h6446m6i9UHem180lrU0Jg'
Timezone=Europe/Paris
Volume=/home/vagrant/kafka/data1:/tmp:Z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
vi $HOME/.config/containers/systemd/kafka-2.container
```

```
[Unit]
Description=kafka
After=local-fs.target

[Container]
ContainerName=kafka-2
Image=docker.io/apache/kafka:4.1.0
Network=kafkanet.network
PublishPort=39092:9092
HostName=kafka-2
Environment=KAFKA_NODE_ID=2
Environment=KAFKA_PROCESS_ROLES='broker,controller'
Environment=KAFKA_LISTENERS=INTERNAL://:19092,CONTROLLER://kafka-2:29093,EXTERNAL://:9092
Environment=KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL
Environment=KAFKA_SECURITY_PROTOCOL=PLAINTEXT
Environment=KAFKA_ADVERTISED_LISTENERS=INTERNAL://kafka-2:19092,EXTERNAL://192.168.56.209:39092
Environment=KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER 
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT
Environment=KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafka-1:29093,2@kafka-2:29093,3@kafka-3:29093
Environment=KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
Environment=KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
Environment=KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
Environment=KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0
Environment=KAFKA_NUM_PARTITIONS=3
Environment=KAFKA_LOG_DIRS='/tmp/kraft-combined-logs'
Environment=CLUSTER_ID='h6446m6i9UHem180lrU0Jg'
Timezone=Europe/Paris
Volume=/home/vagrant/kafka/data2:/tmp:Z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

```
vi $HOME/.config/containers/systemd/kafka-3.container
```

```
[Unit]
Description=kafka
After=local-fs.target

[Container]
ContainerName=kafka-3
Image=docker.io/apache/kafka:4.1.0
Network=kafkanet.network
PublishPort=49092:9092
HostName=kafka-3
Environment=KAFKA_NODE_ID=3
Environment=KAFKA_PROCESS_ROLES='broker,controller'
Environment=KAFKA_LISTENERS=INTERNAL://:19092,CONTROLLER://kafka-3:29093,EXTERNAL://:9092
Environment=KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL
Environment=KAFKA_SECURITY_PROTOCOL=PLAINTEXT
Environment=KAFKA_ADVERTISED_LISTENERS=INTERNAL://kafka-3:19092,EXTERNAL://192.168.56.209:49092
Environment=KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER 
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT
Environment=KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafka-1:29093,2@kafka-2:29093,3@kafka-3:29093
Environment=KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
Environment=KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
Environment=KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1
Environment=KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0
Environment=KAFKA_NUM_PARTITIONS=3
Environment=KAFKA_LOG_DIRS='/tmp/kraft-combined-logs'
Environment=CLUSTER_ID='h6446m6i9UHem180lrU0Jg'
Timezone=Europe/Paris
Volume=/home/vagrant/kafka/data3:/tmp:Z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

La valeur de la variable d'environnement **CLUSTER_ID** peut-être généré avec la commande `openssl rand -base64 16` avec le caractère `=` omis.

```
systemctl --user daemon-reload
```

```
systemctl --user start kafka-1.service

systemctl --user start kafka-2.service

systemctl --user start kafka-3.service
```

Vérification du statut du service kafka

```
systemctl --user status kafka-1.service

systemctl --user status kafka-2.service

systemctl --user status kafka-3.service
```

```
podman container ls
```

- Autorisation des ports **29092**, **39092**, **49092**

```
sudo firewall-cmd --permanent --add-port=29092/tcp --add-port=39092/tcp --add-port=49092/tcp

sudo firewall-cmd --reload
```
