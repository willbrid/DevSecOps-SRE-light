# Replication

Kafka réplique le journal des partitions de chaque sujet sur un nombre configurable de serveurs (ce facteur de réplication peut être défini sujet par sujet). Cela permet un basculement automatique vers ces réplicas en cas de défaillance d'un serveur du cluster, afin que les messages restent disponibles en cas de panne.

L'unité de réplication est la partition du sujet. En l'absence de défaillance, chaque partition dans Kafka possède un leader et zéro, ou plusieurs suiveurs. Le nombre total de réplicas, leader compris, constitue le facteur de réplication. Toutes les écritures sont dirigées vers le leader de la partition, et les lectures peuvent être dirigées vers lui ou ses suiveurs. Généralement, il y a beaucoup plus de partitions que de brokers, et les leaders sont répartis équitablement entre eux. Les journaux des suiveurs sont identiques à celui du leader : ils présentent tous les mêmes décalages et messages dans le même ordre (bien que, bien sûr, le leader puisse à tout moment contenir quelques messages non répliqués à la fin de son journal).

Les suiveurs consomment les messages du leader comme le ferait un consommateur Kafka normal et les appliquent à leur propre journal. Le fait que les suiveurs extraient les messages du leader présente l'avantage de permettre aux suiveurs de regrouper naturellement les entrées de journal qu'ils appliquent à leur journal.

Dans Kafka, un nœud spécifique, appelé « contrôleur », est chargé de gérer l'enregistrement des brokers dans le cluster. La viabilité d'un broker repose sur deux conditions :

- Les brokers doivent maintenir une session active avec le contrôleur afin de recevoir des mises à jour régulières des métadonnées.
- Les brokers agissant en tant que suiveurs doivent répliquer les écritures du leader et ne pas être trop en retard.

La définition d'une « session active » dépend de la configuration du cluster. Pour les clusters KRaft, une session active est maintenue par l'envoi de pulsations périodiques au contrôleur. Si le contrôleur ne reçoit pas de pulsation avant l'expiration du délai configuré par **broker.session.timeout.ms**, le nœud est considéré comme hors ligne.

Nous qualifions de « synchronisés » les nœuds satisfaisant ces deux conditions afin d'éviter toute ambiguïté entre « **actifs** » et « **défaillants** ». Le leader assure le suivi de l'ensemble des réplicas « synchronisés », appelés **ISR**. Si l'une de ces conditions n'est pas remplie, le broker est retiré de l'**ISR**. Par exemple, si un suiveur tombe en panne, le contrôleur constate la défaillance par la perte de sa session et retire le broker de l'**ISR**. En revanche, si le suiveur est trop en retard sur le leader mais conserve une session active, le leader peut également le retirer de l'**ISR**. La détermination des réplicas en retard est contrôlée par la configuration **replica.lag.time.max.ms**. Les réplicas qui ne parviennent pas à rattraper la fin du journal sur le leader dans le délai maximal défini par cette configuration sont retirés de l'**ISR**.

Seuls les messages validés sont transmis au consommateur. Ainsi, le consommateur n'a pas à craindre de voir un message potentiellement perdu en cas de défaillance du leader. Les producteurs, quant à eux, ont le choix d'attendre ou non la validation du message, selon leur préférence pour un compromis entre latence et durabilité. Cette préférence est contrôlée par le paramètre **acks** utilisé par le producteur. Notez que les sujets disposent d'un paramètre définissant le nombre minimum de réplicas synchronisés (**min.insync.replicas**). Ce paramètre est vérifié lorsque le producteur demande un accusé de réception pour l'écriture d'un message sur l'ensemble des réplicas synchronisés. Si un accusé de réception moins strict est demandé par le producteur, le message est validé de manière asynchrone sur l'ensemble des réplicas synchronisés si **acks=0**, ou de manière synchrone uniquement sur le leader si **acks=1**. Quel que soit le paramètre **acks**, les messages ne seront visibles par les consommateurs que lorsque toutes les conditions suivantes seront remplies :

- Les messages sont répliqués sur tous les réplicas synchronisés.
- Le nombre de réplicas synchronisés est supérieur ou égal au paramètre **min.insync.replicas**.

Kafka garantit qu'un message validé ne sera pas perdu, tant qu'au moins un réplica synchronisé est actif à tout moment.

Kafka reste disponible en cas de panne de nœud après une courte période de basculement, mais peut ne pas l'être en présence de partitions réseau.

### Journaux répliqués : quorums, ISR et machines à états

Au cœur d’une partition Kafka se trouve un journal répliqué, une primitive essentielle des systèmes distribués qui permet de garantir un consensus sur l’ordre des événements.

- Le leader fixe l’ordre des valeurs, et les suiveurs se contentent de les recopier.
- Si le leader tombe en panne, un nouveau leader doit être élu parmi les suiveurs, idéalement celui dont le journal est le plus à jour.

La garantie clé est la suivante : lorsqu’un message est déclaré validé, il doit obligatoirement être présent chez le nouveau leader après une panne. Cela crée un compromis :

- Plus le leader attend d’accusés de réception avant de considérer un message comme validé,
- plus il y aura de suiveurs éligibles pour devenir leader en cas de défaillance.

Si l'on choisit le **nombre d'accusés de réception requis** et le **nombre de journaux à comparer** pour élire un leader de manière à garantir un chevauchement, on parle alors de **quorum**.

Un modèle classique (bien que différent de celui de Kafka) consiste à avoir **2f+1 réplicas** et à exiger **f+1 accusés** de réception pour valider un message. Ainsi, avec jusqu’à **f pannes**, on garantit qu’au moins un réplica ayant tous les messages validés sera présent, et donc choisi comme nouveau leader. Une approche courante pour ce compromis consiste à utiliser un **vote majoritaire** pour la décision de **validation et l'élection du leader**. **Ce n'est pas ce que fait Kafka**.

Kafka adopte une approche légèrement différente pour choisir son ensemble de **quorum**. Au lieu d'un vote majoritaire, Kafka gère dynamiquement un ensemble de réplicas synchronisés (**ISR**) rattrapés par le leader. Seuls les membres de cet ensemble sont éligibles à l'élection comme leader. Une écriture sur une partition Kafka n'est considérée comme validée que lorsque tous les réplicas synchronisés l'ont reçue. Cet ensemble d'**ISR** est conservé dans les métadonnées du cluster à chaque modification. De ce fait, tout réplica de l'**ISR** est éligible à l'élection comme leader. Il s'agit d'un facteur important pour le modèle d'utilisation de Kafka, où les partitions sont nombreuses et où l'équilibre du leadership est primordial. Avec ce modèle d'**ISR** et des réplicas **f+1**, un sujet Kafka peut tolérer **f échecs** sans perdre de messages validés.

Une autre distinction de conception importante réside dans le fait que Kafka n'exige pas que les nœuds en panne se rétablissent avec toutes leurs données intactes. En effet le protocole permettant à un réplica de rejoindre l'**ISR** garantit qu'avant de rejoindre, il doit se resynchroniser complètement, même si il a perdu des données non vidées lors de son crash.

### Et si tous les leaders crashaient tous ?

La garantie de Kafka concernant la perte de données repose sur la synchronisation d'au moins une réplique. Si tous les nœuds répliquant une partition disparaissent, cette garantie n'est plus valable.
Cependant, un système fonctionnel doit réagir de manière raisonnable lorsque toutes les répliques disparaissent. Si par malchance, cela se produit, il est important d'anticiper les conséquences. Deux comportements peuvent être mis en œuvre :

- Attendre qu'une réplique de l'ISR se réactive et la choisir comme leader (en espérant qu'elle conserve toutes ses données).
- Choisir la première réplique (pas nécessairement de l'ISR) à se réactiver comme leader.

Il s'agit d'un simple compromis entre disponibilité et cohérence. Si nous attendons des répliques dans l'ISR, nous resterons indisponibles tant que ces répliques seront hors service. Si ces répliques sont détruites ou que leurs données sont perdues, nous sommes définitivement hors service. En revanche, si une réplique non synchronisée est réactivée et que nous l'autorisons à devenir leader, son journal devient la source de référence, même s'il n'est pas garanti qu'elle contienne tous les messages validés. Par défaut, depuis la version 0.11.0.0, Kafka choisit la première stratégie et privilégie l'attente d'une réplique cohérente. Ce comportement peut être modifié via la propriété de configuration **unclean.leader.election.enable**, afin de prendre en charge les cas d'utilisation où la disponibilité est préférable à la cohérence.

### Garanties de disponibilité et de durabilité

Lors de l'écriture dans Kafka, les producteurs peuvent choisir d'attendre que le message soit acquitté par 0, 1 ou tous les réplicas (-1). L'« **accusé de réception par tous les réplicas** » ne garantit pas que l'ensemble des réplicas assignés ait reçu le message. Par défaut, lorsque **acks=all**, l'accusé de réception intervient dès que tous les réplicas synchronisés actuels ont reçu le message. Par exemple, si un sujet est configuré avec seulement deux réplicas et que l'un d'eux échoue (c'est-à-dire qu'il ne reste qu'un seul réplica synchronisé), les écritures spécifiant **acks=all** réussiront. Cependant, ces écritures pourraient être perdues si le réplica restant échoue également.

Par conséquent, il existe deux configurations de sujet permettant de privilégier la durabilité des messages à la disponibilité :

- **désactiver l'élection d'un leader non propre** : si tous les réplicas deviennent indisponibles, la partition restera indisponible jusqu'à ce que le leader le plus récent soit à nouveau disponible. Cela privilégie l'indisponibilité au risque de perte de messages.

- **spécifier une taille ISR minimale** : la partition n'acceptera les écritures que si la taille de l'**ISR** est supérieure à un certain minimum, afin d'éviter la perte de messages écrits sur une seule réplique, qui deviendrait alors indisponible. Ce paramètre n'est effectif que si le producteur utilise **acks=all** et garantit que le message sera acquitté par au moins autant de répliques synchronisées. Ce paramètre offre un compromis entre cohérence et disponibilité. Une taille **ISR** minimale élevée garantit une meilleure cohérence, car le message est assuré d'être écrit sur davantage de répliques, ce qui réduit le risque de perte. Cependant, cela réduit la disponibilité, car la partition sera indisponible pour les écritures si le nombre de répliques synchronisées descend en dessous du seuil minimum.

### Gestion des réplicas

Un cluster Kafka ne gère pas un seul journal (partition), mais des centaines ou milliers de partitions. Pour éviter la surcharge, Kafka :

- équilibre la répartition des partitions entre les nœuds (éviter de concentrer les partitions à fort volume sur quelques brokers) ;

- équilibre aussi les rôles de leaders afin que chaque nœud soit leader pour une proportion équitable de ses partitions.

Il est également important d'optimiser le processus d'élection du leader, car il s'agit de la fenêtre critique d'indisponibilité. <br>
Kafka optimise cela grâce au **rôle du contrôleur** :

- Le contrôleur gère l’enregistrement des brokers.
- En cas de panne d’un broker, il élit rapidement de nouveaux leaders parmi les réplicas synchronisés (ISR).
- Il regroupe les notifications de changement de leader, rendant le processus plus rapide et économique, même avec un grand nombre de partitions.
- Si le contrôleur lui-même échoue, un autre contrôleur est automatiquement élu.