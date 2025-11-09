# Aperçus

### La sécurité dans kafka

Les mesures de sécurité suivantes sont actuellement prises en charge :

- Authentification des connexions aux brokers depuis les clients (producteurs et consommateurs), les autres brokers et les outils, via SSL ou SASL. Kafka prend en charge les mécanismes SASL suivants :

--- **SASL/GSSAPI (Kerberos)** <br>
--- **SASL/PLAIN** <br>
--- **SASL/SCRAM-SHA-256** et **SASL/SCRAM-SHA-512** <br>
--- **SASL/OAUTHBEARER**

- Chiffrement des données transférées entre les brokers et les clients, entre les brokers, ou entre les brokers et les outils via SSL. L’activation du chiffrement SSL réduit les performances de Kafka, à un niveau variable selon la puissance du processeur et la JVM utilisée.

- Autorisation des opérations de **lecture/écriture** par les clients. L'autorisation est modulaire et l’intégration avec des services d’autorisation externes est prise en charge.

### Configuration des interfaces d’écoute du broker Kafka

La sécurisation d’un cluster Kafka passe par la protection des canaux de communication. Chaque serveur définit, via la propriété `listeners`, les interfaces d’écoute utilisés pour accepter les connexions des clients et des autres serveurs. Ces interfaces peuvent être configurées pour authentifier les connexions et chiffrer le trafic, garantissant ainsi des échanges sécurisés au sein du cluster.

```
{LISTENER_NAME}://{hostname}:{port}
```

La propriété `LISTENER_NAME` est généralement un nom descriptif qui définit le rôle de l'interface d'écoute.

```
listeners=CLIENT://localhost:9092
```

Le **protocole de sécurité de chaque interface d'écoute** est défini dans une configuration distincte : `listener.security.protocol.map`. La valeur est une liste, séparée par des virgules, de chaque interface d'écoute associé à son protocole de sécurité.

```
listener.security.protocol.map=CLIENT:SSL,BROKER:PLAINTEXT
```

Les valeurs possibles pour le protocole de sécurité sont :
- PLAINTEXT
- SSL
- SASL_PLAINTEXT
- SASL_SSL

Le protocole **PLAINTEXT** n'offre aucune sécurité et ne nécessite aucune configuration supplémentaire. Si chaque  interface d'écoute requis utilise un protocole de sécurité distinct, il est également possible d'utiliser le nom de ce protocole comme nom interface d'écoute. Toutefois, Il est recommandée de nommer explicitement les interfaces, car cela clarifie leur fonction.

```
listeners=SSL://localhost:9092,PLAINTEXT://localhost:9093
```

Kafka permet de définir une interface d'écoute dédiée aux communications **inter-brokers** via la propriété `inter.broker.listener.name`, (utilisé principalement pour la réplication des partitions). S'il n'est pas défini, l'interface d'écoute **inter-brokers** est déterminé par le protocole de sécurité défini par `security.inter.broker.protocol`, Dans un cluster KRaft, Les contrôleurs doivent utiliser une interface d'écoute distinct, défini par la configuration `controller.listener.names`. Même un serveur n’ayant pas le rôle de contrôleur doit configurer l’interface d'écoute d'un contrôleur.

```
process.roles=broker
listeners=BROKER://localhost:9092
inter.broker.listener.name=BROKER
controller.quorum.bootstrap.servers=localhost:9093
controller.listener.names=CONTROLLER
listener.security.protocol.map=BROKER:SASL_SSL,CONTROLLER:SASL_SSL
```

```
process.roles=broker,controller
listeners=BROKER://localhost:9092,CONTROLLER://localhost:9093
inter.broker.listener.name=BROKER
controller.quorum.bootstrap.servers=localhost:9093
controller.listener.names=CONTROLLER
listener.security.protocol.map=BROKER:SASL_SSL,CONTROLLER:SASL_SSL
```

Le port qui sera utilisé pour les contrôleurs, provient de la configuration `controller.quorum.voters`, qui définit la liste complète des contrôleurs.

Il est impératif que l'hôte et le port définis dans `controller.quorum.bootstrap.servers` soient acheminés vers les interfaces d'écoute de contrôleur exposés. Le contrôleur acceptera les requêtes sur tous les interfaces d'écoute définis par `controller.listener.names`. En général, il n'y a qu'une seule interface d'écoute de contrôleur, mais il est possible d'en avoir plusieurs.

Dans Kafka, il est d'usage d'utiliser une interface d'écoute distinct pour les clients. Cela permet d'isoler les interfaces d'écoute inter-clusters au niveau du réseau. Dans le cas de l'interface d'écoute du contrôleur dans KRaft, il est nécessaire de l'isoler puisque les clients n'interagissent pas avec lui.

### Autorisation et ACL

Kafka intègre un système d'autorisation modulaire, configurable via la propriété `authorizer.class.name` dans la configuration du serveur. Les implémentations configurées doivent étendre `org.apache.kafka.server.authorizer.Authorizer`. Kafka fournit une implémentation par défaut qui stocke les listes de contrôle d'accès (ACL) dans les métadonnées du cluster. <br>
Pour les clusters KRaft, il faut utiliser la configuration suivante sur tous les nœuds (brokers, contrôleurs ou nœuds combinant broker et contrôleur) :

```
authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer
```

Pour ajouter, supprimer ou lister les ACL, nous pouvons utiliser le script : **kafka-acls.sh** qui vient avec kafka.

Lorsqu’aucune liste de contrôle d’accès (ACL) n’est associée à une ressource, Kafka en bloque automatiquement l’accès. Dans ce cas, seuls les super-utilisateurs disposent des permissions nécessaires pour interagir avec cette ressource. <br>
Si nous préférons que les ressources sans ACL soient accessibles à tous les utilisateurs (et non seulement aux super-utilisateurs), nous pouvons modifier le comportement par défaut. Pour ce faire, l'on ajoute la ligne suivante à notre fichier **server.properties** :

```
allow.everyone.if.no.acl.found=true
```

Lorsque ce paramètre est activé, si aucune liste de contrôle d'accès (ACL) n'est définie pour une ressource, Kafka autorisera l'accès à tous. Si une ressource possède une ou plusieurs ACL définies, ces règles seront appliquées normalement, quel que soit le paramètre.

Dans les clusters KRaft, les requêtes d'administration telles que **CreateTopics** et **DeleteTopics** sont envoyées au broker par le client. Le broker transmet ensuite la requête au contrôleur actif via la première interface d'écoute configurée dans **controller.listener.names**. L'autorisation de ces requêtes est effectuée sur le nœud contrôleur. Ceci est réalisé au moyen d'une requête **Envelope** qui encapsule à la fois la requête sous-jacente du client et le principal client. Lorsque le contrôleur reçoit la requête **Envelope** transmise par le broker, il autorise d'abord la requête **Envelope** à l'aide du **principal authentifié du broker**. Ensuite, il autorise la requête sous-jacente à l'aide du **principal transmis**.