# Mise en place d'une authentification SASL/SCRAM-SHA-512 dans un cluster kafka

**SCRAM** (**Salted Challenge Response Authentication Mechanism**) est une famille de mécanismes **SASL** qui répond aux problèmes de sécurité des mécanismes traditionnels d'authentification par nom d'utilisateur et mot de passe, tels que **PLAIN** et **DIGEST-MD5**. Ce mécanisme est défini dans la **RFC 5802**. Kafka prend en charge `SCRAM-SHA-256` et `SCRAM-SHA-512`, utilisables avec TLS pour une authentification sécurisée. Par défaut, l'implémentation **SCRAM** de Kafka stocke les informations d'identification **SCRAM** dans le journal des métadonnées.

**SASL/SCRAM** utilise des mots de passe salés et des algorithmes de hachage cryptographiques pour protéger les identifiants des utilisateurs et ces identifiants ne sont ni stockés ni transmis en clair.

L'implémentation **SASL/SCRAM** dans Kafka utilise le journal de métadonnées comme système d'authentification. Ces authentifications peuvent être créées dans le journal de métadonnées à l'aide des scripts `kafka-storage.sh` ou `kafka-configs.sh`. Pour chaque mécanisme **SASL/SCRAM** activé, il est nécessaire de créer des authentifications en ajoutant une configuration avec le nom du mécanisme.

### Configuration initiale

- Nous allons commencer par arrêter les trois services Kafka conteneurisés actuellement en cours d’exécution.

```
systemctl --user stop kafka-1.service

systemctl --user stop kafka-2.service

systemctl --user stop kafka-3.service
```

- Nous supprimons les données persistées de notre ancienne installation

```
sudo rm -rf $HOME/kafka/data1/*

sudo rm -rf $HOME/kafka/data2/*

sudo rm -rf $HOME/kafka/data3/*
```

### Configuration des 3 services kafka

Les authentifications pour la communication entre les brokers doivent être créées avant le démarrage des brokers Kafka. Le script `kafka-storage.sh` permet de formater le stockage avec les authentifications initiales.

- Créons les authentifications **SASL/SCRAM 512** initiales pour l'utilisateur `admin` avec le mot de passe `admin-secret`

--- pour le noeud 1

```
podman run --rm --network kafkanet -h kafka-1 -e KAFKA_LOG_DIRS='/tmp/kraft-combined-logs' -v /home/vagrant/kafka/server1.properties:/opt/kafka/config/server.properties:Z -v /home/vagrant/kafka/data1:/tmp/kraft-combined-logs:Z docker.io/apache/kafka:4.1.0 /opt/kafka/bin/kafka-storage.sh format -t h6446m6i9UHem180lrU0Jg -c /opt/kafka/config/server.properties --add-scram 'SCRAM-SHA-512=[name="admin",password="admin-secret"]'
```

--- pour le noeud 2

```
podman run --rm --network kafkanet -h kafka-2 -e KAFKA_LOG_DIRS='/tmp/kraft-combined-logs' -v /home/vagrant/kafka/server2.properties:/opt/kafka/config/server.properties:Z -v /home/vagrant/kafka/data2:/tmp/kraft-combined-logs:Z docker.io/apache/kafka:4.1.0 /opt/kafka/bin/kafka-storage.sh format -t h6446m6i9UHem180lrU0Jg -c /opt/kafka/config/server.properties --add-scram 'SCRAM-SHA-512=[name="admin",password="admin-secret"]'
```

--- pour le noeud 3

```
podman run --rm --network kafkanet -h kafka-1 -e KAFKA_LOG_DIRS='/tmp/kraft-combined-logs' -v /home/vagrant/kafka/server1.properties:/opt/kafka/config/server.properties:Z -v /home/vagrant/kafka/data1:/tmp/kraft-combined-logs:Z docker.io/apache/kafka:4.1.0 /opt/kafka/bin/kafka-storage.sh format -t h6446m6i9UHem180lrU0Jg -c /opt/kafka/config/server.properties --add-scram 'SCRAM-SHA-512=[name="admin",password="admin-secret"]'
```

Les arguments de la commande **/opt/kafka/bin/kafka-storage.sh** : <br>
--- `format` : argument permettant de formatter l'emplacement des logs de métadonnées <br>
--- `-t` : permet d'indiquer l'identifiant du cluster <br>
--- `-c` : permet d'indiquer le fichier de configuration de kafka <br>
--- `--add-scram` : permet d'ajouter les identifiants SCRAM dans le sujet `__cluster_metadata` <br>
--- les fichiers `server1.properties`, `server2.properties`, `server3.properties` qui sont mappés à l'intérieur des conteneurs au fichier `/opt/kafka/config/server.properties` se trouvent via le lien [server properties files](./configurations/config-with-sasl-scram/).

- Nous créeons notre fichier **kafka_server_saslscram_jaas.conf** contenant la définition des crédentials de nos brokers

```
vi $HOME/kafka/kafka_server_saslscram_jaas.conf
```

```
internal.KafkaServer {
    org.apache.kafka.common.security.scram.ScramLoginModule required
    username="admin"
    password="admin-secret";
};
controller.KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="admin-secret"
    user_admin="admin-secret";
};
external.KafkaServer {
    org.apache.kafka.common.security.scram.ScramLoginModule required
    username="admin"
    password="admin-secret";
};
KafkaServer {
    org.apache.kafka.common.security.scram.ScramLoginModule required
    username="admin"
    password="admin-secret";
};
```

Les propriétés `username` et `password` de la section `KafkaServer` sont utilisées par le broker pour établir des connexions avec d'autres brokers.

- Nous éditons nos fichiers service

Nous allons définir les variables d'environnement 

--- KAFKA_SASL_MECHANISM=SCRAM-SHA-512 <br>
--- KAFKA_SASL_MECHANISM_CONTROLLER_PROTOCOL=PLAIN <br>
--- KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=SCRAM-SHA-512 <br>
--- KAFKA_SASL_ENABLED_MECHANISMS=SCRAM-SHA-512 <br>
--- KAFKA_SECURITY_PROTOCOL=SASL_PLAINTEXT <br>
--- KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:SASL_PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT <br>

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
Environment=KAFKA_SECURITY_PROTOCOL=SASL_PLAINTEXT
...
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:SASL_PLAINTEXT,CONTROLLER:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
...
Environment=KAFKA_SASL_MECHANISM=SCRAM-SHA-512
Environment=KAFKA_SASL_MECHANISM_CONTROLLER_PROTOCOL=PLAIN
Environment=KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=SCRAM-SHA-512
Environment=KAFKA_SASL_ENABLED_MECHANISMS='PLAIN,SCRAM-SHA-512'
Environment=KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf
Environment=KAFKA_LOG_DIRS='/tmp/kraft-combined-logs'
...
...
Volume=/home/vagrant/kafka/data1:/tmp/kraft-combined-logs:Z
Volume=/home/vagrant/kafka/kafka_server_saslscram_jaas.conf:/etc/kafka/kafka_server_jaas.conf:z

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
Environment=KAFKA_SECURITY_PROTOCOL=SASL_PLAINTEXT
...
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:SASL_PLAINTEXT,CONTROLLER:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
...
Environment=KAFKA_SASL_MECHANISM=SCRAM-SHA-512
Environment=KAFKA_SASL_MECHANISM_CONTROLLER_PROTOCOL=PLAIN
Environment=KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=SCRAM-SHA-512
Environment=KAFKA_SASL_ENABLED_MECHANISMS='PLAIN,SCRAM-SHA-512'
Environment=KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf
Environment=KAFKA_LOG_DIRS='/tmp/kraft-combined-logs'
...
...
Volume=/home/vagrant/kafka/data2:/tmp/kraft-combined-logs:Z
Volume=/home/vagrant/kafka/kafka_server_saslscram_jaas.conf:/etc/kafka/kafka_server_jaas.conf:z

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
Environment=KAFKA_SECURITY_PROTOCOL=SASL_PLAINTEXT
...
Environment=KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=INTERNAL:SASL_PLAINTEXT,CONTROLLER:SASL_PLAINTEXT,EXTERNAL:SASL_PLAINTEXT
...
Environment=KAFKA_SASL_MECHANISM=SCRAM-SHA-512
Environment=KAFKA_SASL_MECHANISM_CONTROLLER_PROTOCOL=PLAIN
Environment=KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=SCRAM-SHA-512
Environment=KAFKA_SASL_ENABLED_MECHANISMS='PLAIN,SCRAM-SHA-512'
Environment=KAFKA_OPTS=-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf
Environment=KAFKA_LOG_DIRS='/tmp/kraft-combined-logs'
...
...
Volume=/home/vagrant/kafka/data3:/tmp/kraft-combined-logs:Z
Volume=/home/vagrant/kafka/kafka_server_saslscram_jaas.conf:/etc/kafka/kafka_server_jaas.conf:z

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

- **Côté client**

Les identifiants client peuvent être créés et mis à jour dynamiquement; les identifiants mis à jour serviront à authentifier les nouvelles connexions. `kafka-configs.sh` permet de créer et de mettre à jour les identifiants après le démarrage des brokers Kafka.

Nous créons les identifiants SCRAM pour les utilisateurs `alice` et `bob` avec leur mot de passe `alice-secret` et `bob-secret`.

```
podman container exec --workdir /opt/kafka/bin/ -it kafka-1 /bin/bash
```

```
vi /opt/kafka/config/client.properties
```

```
security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="admin" \
    password="admin-secret";
```

```
./kafka-configs.sh --bootstrap-server localhost:9092 --alter --add-config 'SCRAM-SHA-512=[iterations=8192,password=alice-secret]' --entity-type users --entity-name alice --command-config /opt/kafka/config/client.properties

./bin/kafka-configs.sh --bootstrap-server localhost:9092 --alter --add-config 'SCRAM-SHA-512=[iterations=8192,password=bob-secret]' --entity-type users --entity-name bob --command-config /opt/kafka/config/client.properties
```

On peut vérifier la liste des utilisateurs avec la commande 

```
./kafka-configs.sh --bootstrap-server localhost:9092 --describe --entity-type users --command-config /opt/kafka/config/client.properties
```

On peut aussi supprimer un utilisateur

```
./kafka-configs.sh --bootstrap-server localhost:9092 --alter --delete-config 'SCRAM-SHA-512' --entity-type users --entity-name bob --command-config /opt/kafka/config/client.properties
```

### Tests de connexion depuis le serveur serverapp

- Tentative d'afficher des sujets et métadonnées du cluster sans utiliser de paramètres d'authentification avec l'outil **kafkaio**

[authentication_without_auth.png](./images/authentication_without_auth.png)

Nous allons constater que nous ne pouvons pas nous connecter.

- Tentative d'afficher des sujets et métadonnées du cluster en utilisant un paramètre d'authentification SCRAM avec l'outil **kafkaio**

[authentication_with_saslscram1.png](./images/authentication_with_saslscram1.png)

[authentication_with_saslscram2.png](./images/authentication_with_saslscram2.png)

Nous constatons que la connexion réussie.