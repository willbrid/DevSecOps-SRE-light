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