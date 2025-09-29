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
`KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR`|Définit le facteur de réplication du topic des offsets
`KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR`|Définit le facteur de réplication du topic des transactions
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

Supposons que nous souhaitions créer un topic nommé **notifications**, destiné à stocker les événements du même nom. Pour cela, nous utiliserons le script **kafka-topics.sh**, disponible dans le conteneur Kafka.

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