# Persistence et Efficacite

### Persistence (système de fichiers)

**Kafka** s’appuie sur le système de fichiers car les disques offrent un excellent débit en accès séquentiel, optimisé par les systèmes d’exploitation via la lecture anticipée et l’écriture différée. Pour compenser la lenteur des recherches sur disque, les OS modernes exploitent la mémoire principale comme cache disque unifié, où toutes les lectures et écritures transitent. Ainsi, même si un processus conserve un cache des données en cours de traitement, celles-ci seront probablement dupliquées dans le cache de pages du système d'exploitation, stockant ainsi tout en double.

Les systèmes de messagerie traditionnels utilisent souvent des structures complexes comme les arbres B pour gérer les métadonnées, mais ces opérations (**O(log N)**) deviennent très coûteuses sur disque en raison de la lenteur des recherches et du faible parallélisme. À l’inverse, une file d’attente persistante basée sur des ajouts et lectures séquentiels de fichiers, comme dans **Kafka**, permet des opérations en **O(1)**, sans blocage entre lectures et écritures, et exploite efficacement des disques peu coûteux mais de grande capacité. Cette approche offre de meilleures performances indépendamment de la taille des données et permet de conserver les messages plus longtemps (par exemple une semaine), offrant ainsi une flexibilité accrue par rapport aux systèmes de messagerie classiques.

**Reférence** : [https://docs.confluent.io/kafka/design/file-system-constant-time.html](https://docs.confluent.io/kafka/design/file-system-constant-time.html)

### Efficacité

**Kafka** a été conçu pour maximiser l’efficacité, notamment pour gérer de gros volumes de données d’activité web dans un environnement multi-locataires. Deux sources majeures d’inefficacité ont été traitées : les **petites opérations d’E/S** et la **copie excessive d’octets**.

- Pour **limiter les E/S**, Kafka regroupe les messages en « **ensembles de messages** », permettant un traitement par lots plus efficace côté réseau, disque et mémoire. 
- Pour **éviter les copies inutiles**, un format binaire commun est utilisé entre producteurs, brokers et consommateurs, ce qui permet d’exploiter l’appel système **sendfile** et de transférer directement les données du cache de pages vers le réseau, réduisant les copies et les appels système. Ainsi, les données peuvent être consommées à la vitesse maximale du réseau, avec peu ou pas de lecture disque lorsque le cache est utilisé. En revanche, cette optimisation n’est pas disponible avec TLS/SSL, car ces bibliothèques fonctionnent uniquement en espace utilisateur.

**Kafka** optimise l’utilisation de la bande passante réseau en prenant en charge la **compression par lots de message** grâce à un format de traitement par **lots efficace**. Un lot de messages peut être regroupé, compressé et envoyé au serveur sous cette forme. Le broker décompresse le lot afin de le valider. Par exemple, il vérifie que le nombre d'enregistrements du lot correspond à l'état de l'en-tête du lot. Ce lot de messages est ensuite écrit sur le disque sous forme compressée. Le lot restera compressé dans le journal et sera également transmis au consommateur sous forme compressée. Le consommateur décompresse les données compressées qu'il reçoit. <br>
**Kafka** prend en charge les protocoles de compression **GZIP**, **Snappy**, **LZ4** et **ZStandard**.