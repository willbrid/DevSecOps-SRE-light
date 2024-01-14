# Service Meshes [PART1]

#### Qu'est-ce qu'un maillage de services ?

Un maillage de services est une couche de plate-forme placée sur la couche d'infrastructure qui permet une communication gérée, observable et sécurisée entre les différents services. Cette couche de plate-forme permet aux entreprises ou aux particuliers de créer des applications d'entreprise robustes constituées de nombreux microservices sur une infrastructure choisie. Les maillages de services utilisent des outils cohérents pour prendre en compte toutes les préoccupations courantes concernant l'exécution d'un service, telles que la surveillance, la mise en réseau et la sécurité. Ainsi, les développeurs et les opérateurs de services peuvent se concentrer sur la création et la gestion d'applications pour leurs utilisateurs, sans avoir à se soucier de mettre en œuvre des mesures pour résoudre les problèmes de chaque service.
<br><br>
Les maillages de services sont transparents pour l'application. Le maillage de services surveille tout le trafic via un proxy. Le proxy est déployé par un modèle side-car sur les microservices. Ce modèle dissocie l'application ou la logique métier des fonctions réseau et permet aux développeurs de se concentrer sur les fonctionnalités dont l'entreprise a besoin. Les maillages de services permettent également aux équipes chargées des opérations et du développement de dissocier leur travail les unes des autres.

#### Caractéristiques et fonctionnalités

Les maillages de services fournissent des fonctionnalités spécifiques pour gérer et contrôler les relations de communication entre services.

- **Architecture mutualisée**

Ce modèle de déploiement à architecture mutualisée isole les groupes de microservices les uns des autres lorsqu'un locataire utilise exclusivement ces groupes. Un cas d'utilisation typique de l'architecture mutualisée consiste à isoler les services entre deux services différents d'une organisation ou à isoler des organisations entières. L'objectif est que chaque locataire dispose de ses propres services dédiés. Ces services ne peuvent pas du tout accéder aux services d'autres locataires, ou ne peuvent accéder aux services d'autres locataires que lorsqu'ils y sont autorisés.
<br><br>
La forme la plus simple d'architecture mutualisée consiste à disposer d'une infrastructure dédiée à un seul locataire. Chaque locataire dispose de ses propres composants réseaux, calcul, stockage et autres tels que Kubernetes et des microservices, sans partager l'infrastructure. Bien que cette forme d'architecture mutualisée soit possible, son utilisation de l'infrastructure est inefficace dans de nombreuses situations. Il est plus efficace de partager l'infrastructure entre locataires et de recourir à la configuration et aux règles des maillages de services pour les séparer.
<br><br>
L'architecture mutualisée de maillages de services est basée sur l'une des deux formes de location : la location d'espaces de noms et la location de clusters. <br>

--- **Location d'espaces de noms** <br>

La forme de location d'espaces de noms fournit à chaque locataire un espace de noms dédié dans un cluster. Étant donné que chaque cluster peut admettre plusieurs locataires, la location d'espaces de noms optimise le partage d'infrastructure.
<br>
Pour limiter la communication entre les services de différents locataires, n'exposons qu'un sous-ensemble des services en dehors de l'espace de noms (à l'aide d'une configuration side-car) et utilisons des règles d'autorisation de maillages de services pour contrôler les services exposés. Configurons chaque espace de noms individuellement pour l'ensemble des services disponibles. Étant donné que l'accès à chaque service est autorisé, seuls les locataires autorisés peuvent accéder aux services les uns des autres. Bien que la fédération multimaillage fonctionne avec ce cas d'utilisation, il n'est pas nécessaire de créer une fédération multimaillage.
<br>
Un espace de noms peut s'étendre sur un ou plusieurs clusters. La location n'est définie que par l'espace de noms et est indépendante des clusters qui prennent en charge l'espace de noms. En fait, deux maillages de service différents peuvent avoir le même espace de noms. Un exemple de ce concept est le suivant : un maillage de services représente un locataire de préproduction et un maillage de services représente un locataire de production. Ces deux maillages peuvent avoir un espace de noms customer par exemple.

--- **Location de clusters** <br>

La forme de location de clusters consacre exclusivement l'ensemble du cluster, y compris tous les espaces de noms, à un locataire. Un locataire peut également comporter plusieurs clusters. Chaque cluster possède son propre maillage.
<br>
La location de cluster implique la séparation au niveau du cluster. Elle n'est pas véritablement mutualisée en termes de partage de ressources entre locataires.

- **Sécurité**

La sécurité est importante quel que soit le type d'architecture. Les microservices présentent des besoins de sécurité supplémentaires par rapport aux autres architectures. Par exemple, l'authentification, l'autorisation et le contrôle de flux de trafic entre microservices. Les fonctionnalités de sécurité des maillages de services répondent à ces besoins.
<br><br>
Avant l'intégration du maillage de services, il n'était pas facile d'atteindre le seuil de zéro confiance. La confiance nécessitait des outils pour gérer les certificats pour les services et les charges de travail, ainsi que pour l'authentification et l'autorisation des services. Après la mise en œuvre d'un maillage de services, il est moins complexe d'atteindre le seuil de zéro confiance. Les maillages de services fournissent ces identités d'authentification et d'autorisation via une autorité de certification centrale qui fournit des certificats pour chaque service.
<br>
Les maillages de services utilisent ces identités pour authentifier et autoriser les services à l'intérieur et à l'extérieur du maillage. Les autorités de certification et la disponibilité des certificats permettent aux développeurs de mettre en œuvre des règles d'autorisation qui leur permettent de contrôler avec précision les services qui peuvent communiquer entre eux. Il est également possible de spécifier avec précision les chemins et les verbes HTTP autorisés pour certains services.
<br>
Les maillages de services permettent aux développeurs de plates-formes d'appliquer des règles, telles que le protocole TLS mutuel, afin de garantir le chiffrage du trafic entre les services et d'empêcher les attaques MITM (Man-in-the-middle). Une fois le maillage de services déployé, il est responsable du chiffrement et du déchiffrement de toutes les requêtes et réponses.

- **Observabilité et analyse**

L'observabilité est un ensemble d'activités qui incluent la mesure, la collecte et l'analyse de plusieurs signaux d'un système. L'observation des systèmes était moins complexes avant les architectures de microservices. Les requêtes étaient envoyées à un seul service qui collectait les données.
<br>
Dans une architecture de microservices distribués, les données de réponse doivent être collectées à partir de plusieurs services pour obtenir la réponse complète. Comme indiqué précédemment, tout le trafic en provenance et à destination d'un service du maillage passe par un proxy. Ce proxy permet aux opérateurs d'obtenir une meilleure visibilité sur les interactions des services. Chaque proxy génère des rapports sur sa partie de la requête afin de produire la même vue complète qui existe dans les applications monolithiques. Un maillage génère généralement les types de télémétrie suivants pour fournir l'observabilité : des métriques, des traces distribuées et des journaux d'accès.
<br>

--- **Métriques** <br>

Un maillage génère des métriques pour tout le trafic entrant dans le maillage, parcourant le maillage ou sortant du maillage. Parmi ces métriques, on peut citer les taux d'erreur, le nombre de requêtes par seconde et les temps de réponse des requêtes. Ces métriques aident les développeurs à comprendre le comportement des services de manière globale.
<br>
Le maillage peut produire les métriques suivantes, comme décrit dans la documentation d'Istio : <br>

----- **Métriques au niveau du proxy** : les proxys side-car génèrent un ensemble volumineux de métriques sur l'ensemble du trafic proxy entrant et sortant. Elles incluent des statistiques détaillées sur les fonctions d'administration du proxy, telles que des informations de configuration et des informations d'état. <br>
----- **Métriques au niveau du service** : les métriques au niveau du service couvrent les quatre signaux de surveillance clés : la latence, le trafic, les erreurs et la saturation. <br>
----- **Métriques du plan de contrôle** : les métriques du plan de contrôle surveillent le plan de contrôle du maillage de services plutôt que les services au sein du maillage. <br>

--- **Traces distribuées** <br>

Un maillage de services peut générer des délais de traces distribuées pour chaque service qu'il contient. Utilisez ces traces pour suivre une seule requête via le maillage sur plusieurs services et proxys.

--- **Journaux d'accès** <br>

Un maillage de services peut générer un journal d'accès complet qui inclut tous les appels de service, y compris la source de l'appel et sa destination, permettant des audits au niveau du service.

- **Conformité**

La conformité consiste à appliquer les stratégies et les règles servant à gérer un système. Ces stratégies et ces règles sont auto-appliquées ou imposées par les réglementations du secteur ou du gouvernement.
<br>
Une forme d'application consiste à surveiller et auditer les charges de travail afin de déterminer si des violations des stratégies ou des règles empêchent la conformité. Une autre forme d'application consiste à utiliser des mises en œuvre formelles de stratégies et de règles qui permettent de s'assurer qu'elles sont actives. En pratique, les deux systèmes sont mis en place : des mises en œuvre formelles pour les stratégies et les règles, en plus de la surveillance et de l'audit en temps réel.
<br>
Certaines stratégies et règles ne peuvent pas être appliquées à un maillage de services. Par exemple, les exigences en matière de résidence des données n'entrent pas dans le champ d'application d'un maillage de services. Si les données utilisateur doivent résider dans le même pays que celui de l'emplacement d'accueil spécifié par un utilisateur, un maillage de services est insuffisant pour configurer ou appliquer cette exigence. Un autre exemple consiste à stocker toutes les données et leur historique pendant un certain nombre d'années. Un maillage de services ne peut pas mettre en œuvre ni superviser cette stratégie.

- **Contrôle du trafic**

Un maillage de services permet de contrôler le flux de trafic entre les services, dans le maillage et vers les services externes. Les ressources personnalisées permettent aux utilisateurs de gérer ce trafic. Ces ressources varient en fonction du maillage de services choisi. Elles permettent aux utilisateurs de créer des déploiements Canary, de créer des déploiements bleu-vert et de créer un contrôle ultraprécis sur des routes spécifiques pour des services.
<br>
Le maillage de services gère un registre de tous les services du maillage par nom et par leurs points de terminaison respectifs. Il gère le registre pour gérer le flux de trafic (par exemple, les adresses IP des pods Kubernetes). En utilisant ce registre de services et en exécutant les proxys et les services côte à côte, le maillage peut diriger le trafic vers le point de terminaison approprié.

- **Résilience**

Un maillage de services peut augmenter la résilience d'appel des microservices déployés sur Kubernetes. Il existe deux classes de mesures de résilience : <br>

--- Augmenter la fiabilité des appels de microservices <br>

La fiabilité d'un appel de microservice augmente si les échecs sont omis de l'appelant. En cas d'échec, le maillage de services peut utiliser les stratégies suivantes pour tenter de le résoudre de manière transparente sans renvoyer l'échec à l'appelant : **Délai avant expiration**, **Réessayer**, **Ruptures de circuit**.
<br>
--- Créer des échecs d'appel intentionnellement <br>

Un maillage de services assure la résilience en spécifiant les délais d'expiration ou les nouvelles tentatives. Les applications peuvent également mettre en œuvre la résilience. Par exemple, il est possible qu'une application doive appeler trois microservices de manière séquentielle pour traiter les entrées et obtenir un résultat. Si l'un de ces appels échoue, l'application peut réessayer la séquence pour vérifier si les appels fonctionnent lors de la deuxième tentative.
<br>
Pour vérifier qu'une application fonctionne correctement, il est possible d'injecter des erreurs d'appel intentionnelles via un maillage de services au moment de l'exécution. L'un des types d'erreurs est le retard. L'appel est intentionnellement retardé et ce retard teste la capacité de l'application de gérer une variation des latences. Un autre type d'erreur est l'annulation. L'annulation interrompt l'appel. L'application observe un échec d'appel, puis décide de la manière de le traiter.


[https://cloud.google.com/architecture/service-meshes-in-microservices-architecture?hl=fr](https://cloud.google.com/architecture/service-meshes-in-microservices-architecture?hl=fr)