# Groupes de partage

Depuis **apache kafka 4.1**, les **groupes de partage** constituent un nouveau type de groupe, existant aux côtés des groupes de consommateurs traditionnels. Ils permettent aux consommateurs Kafka de consommer et de traiter de manière coopérative les enregistrements des sujets. Ils offrent une alternative aux groupes de consommateurs traditionnels, notamment lorsque les applications nécessitent un partage plus fin des partitions et des enregistrements.

Les différences fondamentales entre un **groupe de partage** et un **groupe de consommateurs** sont les suivantes :

- Les consommateurs d'un **groupe de partage** consomment des enregistrements de manière coopérative, et les partitions peuvent être attribuées à plusieurs consommateurs. C'est à dire un même sujet peut être utilisé par plusieurs groupes de partage, mais chaque groupe le traite indépendamment.

- Le nombre de consommateurs d'un **groupe de partage** peut dépasser le nombre de partitions d'un sujet. Chaque consommateur peut définir dynamiquement les sujets auxquelles il s’abonne, mais en pratique, les membres d’un même groupe s’abonnent souvent aux mêmes sujets.

- Les enregistrements sont acquittés individuellement, bien que le système soit optimisé pour le traitement par lots afin d'améliorer l'efficacité.

- Les tentatives de livraison aux consommateurs d'un **groupe de partage** sont comptabilisées, ce qui permet une gestion automatisée des enregistrements non traitables.


Lorsqu’un consommateur récupère des enregistrements :

- il acquiert ces enregistrements avec un verrou temporaire (par défaut 30 s, configurable avec share.record.lock.duration.ms), empêchant les autres consommateurs d’y accéder.
- Le consommateur peut ensuite : <br>
--- accuser réception si le traitement réussit ; <br>
--- libérer l’enregistrement pour une nouvelle tentative de livraison ; <br>
--- rejeter l’enregistrement (il ne sera plus retenté) ; <br>
--- ne rien faire, et dans ce cas le verrou expirera automatiquement.

Le cluster limite également le nombre d’enregistrements acquis simultanément par partition dans un groupe (**group.share.partition.max.record.locks**). Si cette limite est atteinte, les nouvelles récupérations sont suspendues jusqu’à libération ou expiration des verrous. <br>
En limitant la durée du verrou d'acquisition et en le levant automatiquement, le broker garantit la progression de la livraison, même en cas de défaillance du consommateur.