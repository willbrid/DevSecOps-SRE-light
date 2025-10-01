# Cas pratiques de base

Nous allons à installer **Apache Kafka 4.1.0** à l’aide de Podman, en utilisant l’image officielle **apache/kafka:4.1.0**. L’objectif est de déployer Kafka dans un seul conteneur jouant à la fois le rôle de controller et de broker, ce qui constitue une configuration simple et pratique pour les tests, l’apprentissage ou le prototypage rapide. Cette installation servira également pour explorer plusieurs cas pratiques de base d’utilisation de Kafka.

Lien : [Guide d'utilisation des images Docker Kafka](https://github.com/apache/kafka/blob/trunk/docker/examples/README.md)

### Préréquis

Comme préréquis il faudrait au préalable **podman** sur tous les serveurs de notre sandbox via **ansible** depuis notre machine hôte.

```
vi $HOME/homelab-kafka/hosts.ini
```

```
[servers]
192.168.56.209
192.168.56.210
192.168.56.211
192.168.56.212
```

```
vi $HOME/homelab-kafka/ansible.cfg
```

```
[defaults]
inventory = hosts.ini
remote_user = vagrant
host_key_checking = false
ansible_python_interpreter = /usr/bin/python3
private_key_file = $HOME/.vagrant.d/insecure_private_key
```

Ce chemin **$HOME/.vagrant.d/insecure_private_key** peut être différent sur votre machine hôte.

```
ansible servers -m dnf -a "name=podman state=present" --become
```

### Installation de kafka

Depuis notre serveur **broker**, nous exécutons la commande :

```
podman container run -d \
    --name broker \
    --net=host \
    -e KAFKA_NODE_ID=1 \
    -e KAFKA_PROCESS_ROLES=broker,controller \
    -e KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
    -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
    -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT \
    -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
    -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
    -e KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
    -e KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1 \
    -e KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0 \
    -e KAFKA_NUM_PARTITIONS=3 \
    docker.io/apache/kafka:4.1.0
```

|Variable|Description|
|--------|-----------|
`KAFKA_NODE_ID`|Définit un identifiant unique pour ce nœud Kafka
`KAFKA_PROCESS_ROLES`|Définit les rôles que ce nœud Kafka joue : `broker` et `controller`
`KAFKA_LISTENERS`|Définit les ports d’écoute réseau. `PLAINTEXT://:9092` : broker Kafka écoute sur le port 9092 `CONTROLLER://:9093` : controlleur écoute sur le port 9093
`KAFKA_ADVERTISED_LISTENERS`|Adresse broker que Kafka publie pour permettre aux clients de s’y connecter
`KAFKA_CONTROLLER_LISTENER_NAMES`|Définit une liste séparée par des virgules des noms d'écoute utilisés par les contrôleurs
`KAFKA_LISTENER_SECURITY_PROTOCOL_MAP`|Associe chaque listener à un protocole de sécurité
`KAFKA_CONTROLLER_QUORUM_VOTERS`|Définit les membres votants du quorum de contrôle : `nodeId@host:port`
`KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR`|Définit le facteur de réplication du sujet des offsets
`KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR`|Définit le facteur de réplication du sujet des transactions
`KAFKA_TRANSACTION_STATE_LOG_MIN_ISR`|Définit le nombre minimum d'instances qui doivent accuser réception d'une écriture dans un sujet de transaction pour être considérée comme réussie
`KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS`|Définit la durée pendant laquelle le coordinateur du groupe attendra que davantage de consommateurs rejoignent un nouveau groupe avant d'effectuer le premier rééquilibrage.
`KAFKA_NUM_PARTITIONS`|Définit le nombre par défaut de partitions de logs par sujet

Nous pouvons vérifier notre installation avec les ports en écoute (**9092** et **9093**) :

```
podman container ls
```

```
ss -tupln | grep 909
```

### Création d'un nouveau sujet

- Créer un sujet

Supposons que nous souhaitions créer un sujet nommé **notifications**, destiné à stocker les événements du même nom. Pour cela, nous utiliserons le script **kafka-topics.sh**, disponible dans le conteneur Kafka.

Dans une session vagrant de terminal, accédons à notre conteneur **broker** et créeons notre sujet.

```
podman container exec --workdir /opt/kafka/bin/ -it broker /bin/bash
```

L'option **--workdir** permet de se placer immédiatement dans le repertoire des scripts (**/opt/kafka/bin/**) de kafka à l'intérieur du conteneur.

```
./kafka-topics.sh --create --topic notifications --bootstrap-server localhost:9092
```

- Afficher les détails de notre sujet **notifications**

```
./kafka-topics.sh --describe --topic notifications --bootstrap-server localhost:9092
```

### Ecriture de quelques événements dans le sujet

Dans la même session de terminal, à l'intérieur du conteneur ouvert, utilisons le script **kafka-console-producer.sh** pour produire des événements. Une fois la saisie terminée, il suffit d'appuyer sur Ctrl+C pour quitter l'invite de commande du producteur.

```
./kafka-console-producer.sh --topic notifications --bootstrap-server localhost:9092
```

```
> notification for event 1
> notification for event 2
> notification for event 3
```

### Lecture de quelques événements dans le sujet

Dans une autre session vagrant de terminal, accédons à notre conteneur **broker** et démarrons notre consommateur sur notre sujet.

```
podman container exec --workdir /opt/kafka/bin/ -it broker /bin/bash
```

```
./kafka-console-consumer.sh --topic notifications --from-beginning --bootstrap-server localhost:9092
```

### Kafka Connect : synchronisation avec des fichiers

**Kafka Connect** nous permet d'ingérer en continu des données provenant de **systèmes externes** vers **Kafka**, et inversement. Cet outil extensible exécute des **connecteurs** implémentant la logique personnalisée d'interaction avec un système externe.

Pour ce cas pratique, nous verrons comment exécuter **Kafka Connect** avec des **connecteurs simples** qui importent des données d'un **fichier** vers un **sujet Kafka** et exportent des données d'un **sujet Kafka** vers un **fichier**.

- Configuration du plugin **connect-file-4.1.0.jar**

Depuis notre serveur broker, connectons-nous au conteneur broker

```
podman container exec --workdir /opt/kafka/bin/ -it broker /bin/bash
```

Verification de la présence du plugin **connect-file-4.1.0.jar** dans le repertoire de plugins **/opt/kafka/libs/**

```
ls -l /opt/kafka/libs/ | grep connect-file-4.1.0.jar
```

Configuration du path du plugin **connect-file-4.1.0.jar** dans le fichier **/opt/kafka/config/connect-standalone.properties**

```
echo "plugin.path=/opt/kafka/libs/connect-file-4.1.0.jar" >> /opt/kafka/config/connect-standalone.properties
```

- Création du fichier source de synchronisation **/home/appuser/test.txt** avec un contenu

```
echo -e "foo\nbar" > /home/appuser/test.txt
```

- Configuration du fichier **/opt/kafka/config/connect-file-source.properties** du connecteur source

```
vi /opt/kafka/config/connect-file-source.properties
```

```
...
name=local-file-source
connector.class=FileStreamSource
tasks.max=1
file=/home/appuser/test.txt
topic=connect-test
...
```

|Variable|Description|
|--------|-----------|
`name`|Définit le nom du connecteur
`connector.class`|Définit la classe de connecteur à instancier
`tasks.max`|Définit le nombre maximum de tâches que le connecteur peut exécuter en parallèle
`file`|Définit le fichier source de synchronisation
`topic`|Définit le sujet de sychronisation

- Configuration du fichier **/opt/kafka/config/connect-file-sink.properties** du connecteur récepteur

```
vi /opt/kafka/config/connect-file-sink.properties
```

```
...
name=local-file-sink
connector.class=FileStreamSink
tasks.max=1
file=/home/appuser/test.sink.txt
topics=connect-test
...
```

- Démarrage du processus de synchronisation

```
./connect-standalone.sh /opt/kafka/config/connect-standalone.properties /opt/kafka/config/connect-file-source.properties /opt/kafka/config/connect-file-sink.properties
```

Nous fournissons trois fichiers de configuration en tant que paramètres. Le premier correspond toujours à la configuration du processus **Kafka Connect**, contenant les paramètres communs tels que les brokers Kafka auxquels se connecter et le format de sérialisation des données. Les fichiers de configuration restants spécifient chacun un connecteur à créer. Ces fichiers incluent un nom de connecteur unique, la classe de connecteur à instancier, un fichier et le sujet de synchronisation.

Le premier est un **connecteur source** qui lit les lignes du fichier d'entrée **/home/appuser/test.txt** et les envoie chacune vers un sujet Kafka (**connect-test**) ; le second est un **connecteur récepteur** qui lit les messages d'un sujet Kafka (**connect-test**) et les envoie chacun sous forme de ligne dans le fichier de sortie **/home/appuser/test.sink.txt** .

- Vérification du fichier de sortie **/home/appuser/test.sink.txt**

Nous pouvons vérifier que les données ont été transmises tout au long du pipeline en examinant le contenu du fichier de sortie. <br>
Pour cela dans une autre session vagrant de terminal, accédons à notre conteneur **broker** et vérifions la présence du fichier **/home/appuser/test.sink.txt** et son contenu.

```
podman container exec --workdir /opt/kafka/bin/ -it broker /bin/bash
```

```
ls -l /home/appuser/test.sink.txt

more /home/appuser/test.sink.txt
```

- Connexion au sujet **connect-test** avec un consommateur

Dans une autre session vagrant de terminal, accédons à notre conteneur **broker** et démarrons notre consommateur sur le sujet **connect-test**.

```
podman container exec --workdir /opt/kafka/bin/ -it broker /bin/bash
```

```
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic connect-test --from-beginning
```

Nous aurons comme sortie

```
{"schema":{"type":"string","optional":false},"payload":"foo"}
{"schema":{"type":"string","optional":false},"payload":"bar"}
```

Dans une autre session vagrant de terminal, accédons à notre conteneur **broker** et ajoutons une nouvelle ligne dans le fichier source **/home/appuser/test.txt**.

```
podman container exec --workdir /opt/kafka/bin/ -it broker /bin/bash
```

```
echo "new line" >> /home/appuser/test.txt
```

Nous constaterons que la ligne apparaît dans la sortie console du consommateur et dans le fichier récepteur **/home/appuser/test.sink.txt**.