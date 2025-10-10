# Tests et monitoring

Dans cette section, nous allons vérifier la bonne exposition et la remontée des données de télémétrie du **broker Kafka** instrumenté avec OpenTelemetry, puis faire du monitoring du noeud (conteneur) kafka. 

L’objectif est de : 

- s’assurer que les **métriques**, les **traces** et les **logs** générés par le conteneur Kafka sont correctement collectés, exportés et visibles depuis Grafana avec les sources de données provenant de **thanos** (**métriques**), **tempo** (**traces**), **loki** (**logs**).

- faire la Surveillance du conteneur Kafka (**état**, **consommation CPU/mémoire**,...) et alerter lorsque celui-ci tombe en panne

### Tests

- Depuis notre serveur **serverapp**, nous allons installer l'utilitaire client **kcat** permettant d'interagir avec notre noeud kafka.

```
sudo dnf install epel-release
```

```
sudo dnf install kcat
```

- Depuis notre serveur **broker**, nous allons créer un sujet **notifications**

```
podman container exec --workdir /opt/kafka/bin/ -it kafka /bin/bash
```

```
./kafka-topics.sh --create --topic notifications --bootstrap-server localhost:9092

exit
```

- Depuis notre serveur **serverapp**, nous allons interroger notre noeud kafka pour se rassurer de la présence de notre sujet créé

```
kcat -b 192.168.56.209:9092 -L
```

A la sortie de cette commande, nous verrons :

```
Metadata for all topics (from broker 1: 192.168.56.209:9092/1):
 1 brokers:
  broker 1 at 192.168.56.209:9092 (controller)
 1 topics:
  topic "notifications" with 3 partitions:
    partition 0, leader 1, replicas: 1, isrs: 1
    partition 1, leader 1, replicas: 1, isrs: 1
    partition 2, leader 1, replicas: 1, isrs: 1
```

- Depuis notre serveur **serverapp**, avec l'utilitaire kcat, nous allons exécuter un consommateur de notre sujet

```
kcat -C -b 192.168.56.209:9092 -t notifications -o begin
```

- Depuis notre serveur **serverapp**, nous allons créer notre script bash permettant d'envoyer les messages dans notre sujet

```
vi $HOME/producer.sh
```

```
#!/bin/bash

BROKER="192.168.56.209:9092"
TOPIC="notifications"

if [ -z "$1" ]; then
  echo "Usage: $0 <nombre_de_requetes>"
  exit 1
fi

REQUEST_TOTAL=$1

if ! kcat -L -b "$BROKER" >/dev/null 2>&1; then
  echo "Erreur : impossible de joindre le broker Kafka ($BROKER)"
  exit 2
fi
echo "Broker Kafka accessible."

for ((i=1; i<=$REQUEST_TOTAL; i++)); do
  MESSAGE="devsecops dojo message#$i"
  echo "$MESSAGE" | kcat -b "$BROKER" -t "$TOPIC" -P

  if [ $? -ne 0 ]; then
    echo "Erreur lors de l'envoi du message #$i"
    exit 3
  fi

  echo "Message #$i envoyé"
  sleep 2
done

exit 0
```

```
chmod +x $HOME/producer.sh
```

```
./$HOME/producer.sh 50
```

Par exemple nous exécutons le script pour 50 messages, en se connectant sur l'**explorateur de grafana**, nous pourrons déjà voir certaines métriques : 

- **kafka_message_count_total** : nombre total de messages envoyés
- **kafka_request_count_total** : nombre total de requêtes envoyées pour le producteur (étiquette : **type=produce**) ou pour le consommateur (étiquette : **type=fetch**)