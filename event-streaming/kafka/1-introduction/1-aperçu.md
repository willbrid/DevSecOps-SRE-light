# Aperçu

### Qu'est-ce que le streaming d'événements ?

Le **streaming d'événements** consiste à capturer des données en temps réel à partir de sources (bases de données, capteurs, appareils mobiles, services cloud et applications logicielles...), sous forme de flux d'événements ; à stocker durablement ces flux d'événements pour une récupération ultérieure ; à les manipuler, les traiter et y réagir en temps réel et rétrospectivement ; et à les acheminer vers différentes technologies de destination selon les besoins. Le streaming d'événements garantit ainsi un flux et une interprétation continus des données, afin que la bonne information soit au bon endroit, au bon moment.

### À quoi peut me servir le streaming d’événements ?

Le streaming d’événements trouve des applications dans de nombreux secteurs et organisations dont parmi on peut citer :

- traiter les paiements et les transactions financières en temps réel (en bourse, les banques et les assurances);
- suivre et surveiller les voitures, les camions, les flottes et les expéditions en temps réel (dans la logistique et l'industrie automobile);
- capturer et analyser en continu les données des capteurs provenant d'objets connectés ou d'autres équipements (dans les usines et les parcs éoliens);
- collecter et réagir immédiatement aux interactions et aux commandes des clients (dans le commerce de détail, l'hôtellerie et le tourisme, et les applications mobiles);
- suivre les patients hospitalisés et anticiper leur évolution afin d'assurer une prise en charge rapide en cas d'urgence;
- connecter, stocker et mettre à disposition les données produites par les différentes divisions d'une entreprise;
- servir de base aux plateformes de données, aux architectures pilotées par événements et aux microservices.

### Qu'est-ce que Apache Kafka ?

**Kafka** est une plateforme de streaming d’événements qui combine trois fonctionnalités clés :

- publier (écriture) et s'abonner (lecture) à des flux d'événements, y compris l'importation/exportation continue de vos données depuis d'autres systèmes;

- stocker les flux d'événements de manière durable et fiable selon la rétention définie;

- traiter les flux d'événements au fur et à mesure ou rétrospectivement.

**Kafka** offre des fonctionnalités **distribuées**, **évolutives**, **tolérantes aux pannes** et **sécurisées**, déployables sur tout type d’infrastructure (bare metal, VM, conteneurs, cloud ou on-premise), avec le choix entre une **gestion autonome** ou un **service managé**.

### Comment fonctionne Kafka en quelques mots ?

**Kafka** est un système distribué basé sur TCP, pouvant être déployé sur serveurs physiques, VM ou conteneurs, aussi bien sur site que dans le cloud.

- **Serveurs**

Un cluster Kafka est composé de serveurs jouant différents rôles :

--- les **brokers** assurent le stockage et la diffusion des événements, <br>
--- **Kafka Connect** pour intégrer Kafka avec des systèmes externes (bases de données, autres serveurs kafka).

Le cluster **Kafka** est conçu pour être hautement évolutif et tolérant aux pannes, garantissant la continuité du service même en cas de défaillance de serveurs.

- **Clients**

Les **clients** permettent de créer des applications distribuées (ou microservices) et tolérantes aux pannes qui produisent, consomment et traitent des flux d’événements à grande échelle. **Kafka** est fourni avec certains de ces clients, complétés par des clients fournis par la communauté Kafka : client pour java et scala, client pour Go, client pour python...

### Principaux concepts et terminologie

Un **événement** enregistre le fait que quelque chose s'est produit. On l'appelle aussi **enregistrement** ou **message**. Lorsque nous lisons ou écrivons des données dans **Kafka**, cela se fait sous forme d'**événements**. Conceptuellement, un **événement** possède une **clé**, une **valeur**, un **horodatage** et des **en-têtes de métadonnées facultatifs**.

Les **producteurs** sont les applications clientes qui publient (écrivent) des événements dans Kafka, et les **consommateurs** sont ceux qui s'abonnent (lisent et traitent) ces événements. Dans Kafka, **producteurs** et **consommateurs** sont totalement découplés et indépendants les uns des autres, ce qui constitue un élément de conception essentiel pour atteindre la grande évolutivité qui caractérise **Kafka**.

Dans **Kafka**, les **événements** sont stockés dans des sujets (**topics**), comparables à des dossiers (**topics**) contenant des fichiers (**events**). Un **sujet** accepte zéro, un ou plusieurs producteurs et consommateurs. Les **événements** ne sont pas supprimés après lecture mais selon une durée de rétention configurable par **sujet** (**topic**).

Les **sujets** (**topics**) sont partitionnés, ce qui signifie qu'un sujet est réparti sur plusieurs **partitions** situés sur différents **brokers** Kafka. Ce placement distribué des données est essentiel à l'évolutivité, car il permet aux applications clientes de lire et d'écrire des données depuis/vers plusieurs brokers simultanément. Lorsqu'un nouvel événement est publié sur un sujet, il est ajouté à l'une des **partitions** de ce sujet. Tout consommateur d'une **partition** de sujet donnée lira toujours les événements de cette **partition** dans le même ordre d'écriture.

Pour garantir la tolérance aux pannes et la haute disponibilité de nos données, chaque sujet peut être répliqué, même entre différentes **régions géographiques** ou **centres de données**. Ainsi, plusieurs brokers disposent toujours d'une copie des données en cas de problème, de maintenance. Un paramètre de production courant est un facteur de réplication de 3, ce qui signifie qu'il y aura toujours trois copies de nos données. Cette réplication s'effectue au niveau des partitions de sujets.

### Les différents cas d'utilisation

- **Messagerie**

Kafka peut remplacer un courtier de messages traditionnel, en offrant un débit plus élevé, le partitionnement, la réplication et une meilleure tolérance aux pannes, ce qui le rend idéal pour la **messagerie** à grande échelle.

- **Suivi de l'activité du site web**

À l’origine, **Kafka** a été conçu pour suivre l’activité des utilisateurs d'un site (pages vues, recherches ou autres actions des utilisateurs) en temps réel via des flux de publication-abonnement, permettant aussi bien le traitement et la surveillance immédiats que le chargement vers des systèmes de stockage ou d’analyse hors ligne (**hadoop** ou **offline data warehousing**).

- **Métriques**

**Kafka** est souvent utilisé pour la surveillance opérationnelle des données. Il s'agit d'agréger les statistiques des applications distribuées afin de générer des flux centralisés de données opérationnelles.

- **Agrégation de logs**

Kafka peut remplacer une solution d’**agrégation de logs**, en transformant les logs en flux d’événements pour un traitement distribué et à faible latence. Par rapport à des systèmes comme Scribe ou Flume, il offre des performances équivalentes mais avec une meilleure durabilité et une latence plus faible.

- **Traitement des flux**

De nombreux utilisateurs de Kafka traitent les données dans des pipelines de traitement composés de plusieurs étapes. Les données d'entrée brutes sont consommées à partir des **sujets** Kafka, puis agrégées, enrichies ou transformées en nouveaux **sujets** pour une consommation ultérieure ou un traitement complémentaire. Cela permet de créer des graphes de flux en temps réel sur les sujets individuels. Depuis la version **0.10.0.0**, Kafka propose la bibliothèque **Kafka Streams** pour ce traitement.

- **Event sourcing**

L’event sourcing est une méthode de conception d'applications où chaque changement d’état est enregistré sous forme d’événements chronologiques. Grâce à sa capacité à gérer de grands volumes de journaux, Kafka est bien adapté comme backend pour ces types d’applications.

- **Log de validation**

Kafka peut servir de **log de validation externe** pour un système distribué. Ce log permet de répliquer les données entre les nœuds et sert de mécanisme de resynchronisation pour les nœuds défaillants afin de restaurer leurs données. La fonctionnalité de compactage des logs de Kafka permet cette utilisation.