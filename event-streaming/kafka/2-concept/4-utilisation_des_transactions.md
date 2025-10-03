# Utilisation des transactions

Le moyen le plus simple d’obtenir une sémantique « **exactement une fois** » est d’utiliser **Kafka Streams**, mais on peut aussi l’obtenir directement avec un producteur et un consommateur Kafka.

Dans Kafka, seul le producteur est **transactionnel**. Toutefois, il peut inclure dans ses transactions la mise à jour de la position du consommateur (offset validé). C’est cette capacité qui permet d’assurer la garantie globale « **exactement une fois** », même si producteur et consommateur restent des entités séparées.

Le traitement « exactement une fois » utilisant le producteur et le consommateur comporte trois aspects clés, qui correspondent au fonctionnement de Kafka Streams.

1. Le consommateur utilise l'affectation de partition pour s'assurer qu'il est le seul consommateur du groupe de consommateurs à traiter chaque partition.

2. Le producteur utilise des transactions afin que tous les enregistrements qu'il produit, ainsi que les décalages qu'il met à jour pour le compte du consommateur, soient exécutés de manière atomique.

3. Afin de gérer correctement les transactions en combinaison avec le rééquilibrage, il est conseillé d'utiliser une instance de producteur pour chaque instance de consommateur. Des schémas plus complexes et efficaces sont possibles, mais au prix d'une plus grande complexité.

Pour garantir un traitement **exactement une fois**, il est généralement recommandé d’utiliser le niveau d’isolation « **read_committed** ».
Sans ce paramètre, le consommateur peut voir les enregistrements issus de transactions interrompues ou de transactions encore ouvertes, ce qui compromet la sémantique.

La configuration du consommateur doit inclure **isolation.level=read_committed** et **enable.auto.commit=false**. La configuration du producteur doit définir **transactional.id** sur le nom de l'ID transactionnel à utiliser, ce qui configure le producteur pour la livraison transactionnelle et garantit également qu'un redémarrage de l'application entraîne l'abandon de toute transaction en cours de l'instance précédente. Seul le producteur dispose de la configuration **transactional.id**.