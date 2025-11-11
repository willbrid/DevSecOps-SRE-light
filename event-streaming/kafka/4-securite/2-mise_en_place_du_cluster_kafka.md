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

- Exemple avec la création de 2 sujets **usertokens** et **transactions**

```
podman container exec --workdir /opt/kafka/bin/ -it kafka-1 /bin/bash
```

```
./kafka-topics.sh --create --topic usertokens --bootstrap-server localhost:9092

./kafka-topics.sh --create --topic transactions --bootstrap-server localhost:9092
```

Ecriture de quelques messages sensibles :

```
./kafka-console-producer.sh --topic usertokens --bootstrap-server localhost:9092
```

```
> user1 token1 
> user2 token2
> user3 token3
```


```
./kafka-console-producer.sh --topic transactions --bootstrap-server localhost:9092
```

```
> trid1 value1
> trid2 value2
> trid3 value3
```

```
exit
```

### Inconvénients d'un cluster kafka non sécurisé

Un cluster Kafka non sécurisé expose de nombreuses informations sensibles et ouvre la porte à des actions malveillantes. Sans **contrôles d’accès**, **chiffrement** et **authentification**, un attaquant (ou même un employé non autorisé) peut obtenir ou manipuler des informations critiques du système.

Nous allons simuler des actions non autorisées depuis notre serveur **serverapp** :

- Afficher les sujets et métadonnées du cluster

```
kcat -b 192.168.56.209:29092 -L
```

```
# Résultats

Metadata for all topics (from broker 1: 192.168.56.209:29092/1):
 3 brokers:
  broker 1 at 192.168.56.209:29092
  broker 2 at 192.168.56.209:39092
  broker 3 at 192.168.56.209:49092 (controller)
 2 topics:
  topic "usertokens" with 3 partitions:
    partition 0, leader 1, replicas: 1, isrs: 1
    partition 1, leader 2, replicas: 2, isrs: 2
    partition 2, leader 3, replicas: 3, isrs: 3
  topic "transactions" with 3 partitions:
    partition 0, leader 2, replicas: 2, isrs: 2
    partition 1, leader 3, replicas: 3, isrs: 3
    partition 2, leader 1, replicas: 1, isrs: 1
```

- Afficher les messages contenus dans les sujets

```
kcat -C -b 192.168.56.209:39092 -t usertokens -o begin

kcat -C -b 192.168.56.209:49092 -t transactions -o begin
```

- Envoyer les messages dans n'importe quel sujet

```
echo "trid3 fakevalue4" | kcat -b 192.168.56.209:29092 -t transactions -P
```
