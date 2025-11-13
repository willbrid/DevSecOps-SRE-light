# Mise en place d'une authentification SASL/PLAIN dans un cluster kafka

**SASL/PLAIN** est un mécanisme d'authentification simple par nom d'utilisateur et mot de passe, généralement utilisé avec TLS pour le chiffrement afin de garantir une authentification sécurisée. Kafka prend en charge une implémentation par défaut de **SASL/PLAIN**.

**SASL/PLAIN** repose sur un échange direct de **login** et **mot de passe** entre le **client** et le **serveur Kafka**.

### Configuration des 3 services kafka

- Nous allons commencer par arrêter les trois services Kafka conteneurisés actuellement en cours d’exécution.

```
systemctl --user stop kafka-1.service

systemctl --user stop kafka-2.service

systemctl --user stop kafka-3.service
```

- Nous créeons notre fichier **kafka_server_saslplain_jaas.conf** contenant la définition des crédentials de nos utilisateurs

```
vi $HOME/kafka/kafka_server_saslplain_jaas.conf
```

```
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="admin-secret"
    user_admin="admin-secret"
    user_alice="alice-secret"
    user_bob="bob-secret";
};
```

Cette configuration définit trois utilisateurs (**admin**, **alice** et **bob**). Les propriétés `username` et `password` de la section `KafkaServer` sont utilisées par le broker pour établir des connexions avec d'autres brokers. Dans cet exemple, **admin** est l'utilisateur utilisé pour la communication inter-brokers. L'ensemble de propriétés `user_userName` définit les mots de passe de tous les utilisateurs se connectant au broker. Ce dernier valide toutes les connexions client, y compris celles provenant d'autres brokers, à l'aide de ces propriétés.

- Nous éditons nos fichiers service

Nous allons définir les variables d'environnement 

--- KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN <br>
--- KAFKA_SASL_ENABLED_MECHANISMS=PLAIN <br>
--- KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf <br>
--- KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:SASL_PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT (cette ligne est une mise à jour)

```
vi $HOME/.config/containers/systemd/kafka-1.container
```

```
[Unit]
Description=kafka
After=local-fs.target

[Container]
ContainerName=kafka-1
...
...
Environment=KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN
Environment=KAFKA_SASL_ENABLED_MECHANISMS=PLAIN
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:SASL_PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
Environment=KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf
Environment=KAFKA_LOG_DIRS='/tmp/kraft-combined-logs'
...
...
Volume=/home/vagrant/kafka/data1:/tmp:Z
Volume=/home/vagrant/kafka/kafka_server_saslplain_jaas.conf:/etc/kafka/kafka_server_jaas.conf:z

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
...
...
Environment=KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN
Environment=KAFKA_SASL_ENABLED_MECHANISMS=PLAIN
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:SASL_PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
Environment=KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf
Environment=KAFKA_LOG_DIRS='/tmp/kraft-combined-logs'
...
...
Volume=/home/vagrant/kafka/data1:/tmp:Z
Volume=/home/vagrant/kafka/kafka_server_saslplain_jaas.conf:/etc/kafka/kafka_server_jaas.conf:z

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
...
...
Environment=KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=PLAIN
Environment=KAFKA_SASL_ENABLED_MECHANISMS=PLAIN
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:SASL_PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
Environment=KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf
Environment=KAFKA_LOG_DIRS='/tmp/kraft-combined-logs'
...
...
Volume=/home/vagrant/kafka/data1:/tmp:Z
Volume=/home/vagrant/kafka/kafka_server_saslplain_jaas.conf:/etc/kafka/kafka_server_jaas.conf:z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

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

### Création manuelle de sujet avec l'authentification SASL/PLAIN

Pour créer un sujet directement à partir d’un conteneur broker Kafka, il convient de suivre les étapes ci-dessous.

En guise d'exemple nous créons un sujet **userstatus**.

```
podman container exec --workdir /opt/kafka/bin/ -it kafka-1 /bin/bash
```

```
echo 'security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="admin" password="admin-secret";' > /tmp/kafka-client.conf
```

```
./kafka-topics.sh --create --topic userstatus --command-config /tmp/kafka-client.conf --bootstrap-server localhost:9092
```

De même pour envoyer des messages dans le sujet **userstatus** à partir de notre conteneur broker kafka, on exécute :

```
./kafka-console-producer.sh --topic userstatus --producer.config /tmp/kafka-client.conf --bootstrap-server localhost:9092
```

### Tests de connexion depuis le serveur serverapp

- Tentative d'afficher des sujets et métadonnées du cluster sans utiliser de paramètres d'authentification

```
kcat -b 192.168.56.209:29092 -L
```

```
# Résultat

%4|1762875492.602|FAIL|rdkafka#producer-1| [thrd:192.168.56.209:29092/bootstrap]: 192.168.56.209:29092/bootstrap: Disconnected: verify that security.protocol is correctly configured, broker might require SASL authentication (after 36ms in state UP)
%4|1762875492.713|FAIL|rdkafka#producer-1| [thrd:192.168.56.209:29092/bootstrap]: 192.168.56.209:29092/bootstrap: Disconnected: verify that security.protocol is correctly configured, broker might require SASL authentication (after 94ms in state UP, 1 identical error(s) suppressed)
% ERROR: Failed to acquire metadata: Local: Timed out
```

- Tentative d'afficher des sujets et métadonnées du cluster en utilisant un paramètre d'authentification

```
kcat -b 192.168.56.209:29092 -L \
  -X security.protocol=SASL_PLAINTEXT \
  -X sasl.mechanisms=PLAIN \
  -X sasl.username=alice \
  -X sasl.password=alice-secret
```

```
# Résultat

Metadata for all topics (from broker 1: sasl_plaintext://192.168.56.209:29092/1):
 3 brokers:
  broker 1 at 192.168.56.209:29092
  broker 2 at 192.168.56.209:39092 (controller)
  broker 3 at 192.168.56.209:49092
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

### Inconvénients d'un cluster kafka sécurisé avec une authentification SASL/PLAIN

- Le mot de passe circule en clair si **SSL** n’est pas activé.
- Les identifiants sont souvent stockés dans les fichiers de configuration du broker, donc peu sécurisés.
- Les messages peuvent toujours être interceptés.
- Ce mécanisme est simple mais non recommandé en production sans chiffrement TLS.

En guise d'exemple, on peut utiliser la commande `tcpdump` pour capturer tous les communications tcp d'un client sur l'interface eth1 de notre serveur **broker**.

```
sudo tcpdump -i eth1 -nn -s 0 -A -X port 29092 -w kafka.pcap
```

Le package `tcpdump` est installé sur le serveru **broker**. <br>
Le fichier généré **kafka.pcap** peut être chargé dans l'outil **wireshark** afin de voir en clair les crédentials et les messages.
