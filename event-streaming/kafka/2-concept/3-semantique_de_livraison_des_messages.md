# Sémantique de livraison des messages

**Kafka** définit trois types de garanties possibles :

- **au plus une fois** : un message peut être perdu, mais jamais dupliqué.
- **au moins une fois** : aucun message n’est perdu, mais certains peuvent être traités plusieurs fois.
- **exactement une fois** : chaque message est livré et traité une seule fois.

### Côté producteur

- Un message est considéré comme validé (committed) uniquement lorsqu’il est écrit dans toutes les répliques synchronisées (**ISR : in-sync replicas**).

- En cas d’erreur réseau, le producteur ne sait pas si le message a été validé ou non <br>
--- avant Kafka 0.11, cela imposait de renvoyer le message, garantissant seulement une sémantique au moins une fois. <br>
--- Depuis Kafka 0.11.0.0 : <br>
  → **Idempotence** : chaque producteur a un identifiant et envoie un numéro de séquence par message : c'est le broker qui élimine les doublons. <br>
  → **Transactions** : permettent d’envoyer atomiquement des messages sur plusieurs partitions (tout est écrit ou rien).

- Le producteur peut aussi choisir le niveau de durabilité selon ses besoins : <br>
--- Attendre la validation complète (latence ~10 ms), <br>
--- Attendre seulement l’accusé du leader, <br>
--- Ou envoyer en mode asynchrone (plus rapide mais moins sûr).

### Côté consommateur

- Tous les brokers ont le même journal avec les mêmes offsets, et le consommateur contrôle sa position (offset).

- En cas de panne, un autre consommateur doit reprendre à partir de la dernière position connue. Deux stratégies existent :

--- Enregistrer la position avant traitement → risque de perte de messages non traités (sémantique **au plus une fois**). <br>
--- Enregistrer la position après traitement → risque de retraiter des messages déjà consommés (sémantique **au moins une fois**).

Dans beaucoup de cas, les messages ayant une clé primaire, les traitements sont idempotents, donc le retraitement ne pose pas problème.

### Qu'en est-il de la sémantique « exactement une fois » ?

Lors de la consommation depuis un sujet Kafka et de la production vers un autre sujet (comme dans une application **Kafka Streams**), nous pouvons exploiter les nouvelles fonctionnalités de production transactionnelle de la version 0.11.0.0. 

La position du consommateur est stockée sous forme de message dans un sujet interne, ce qui nous permet d'écrire l'offset dans Kafka dans la même transaction que les sujets de sortie recevant les données traitées. 

- Si la transaction est interrompue, la position stockée du consommateur revient à son ancienne valeur (bien que le consommateur doive récupérer l'offset validé, car il ne se rembobine pas automatiquement) et les données produites sur les sujets de sortie ne sont pas visibles par les autres consommateurs, selon leur niveau d'isolation. 

- Avec le niveau d'isolation par défaut « **read_uncommitted** », tous les messages sont visibles par les consommateurs, même s'ils faisaient partie d'une transaction interrompue. En revanche, avec le niveau d'isolation « **read_committed** », le consommateur ne renvoie que les messages des transactions validées (et ceux qui ne faisaient pas partie d'une transaction).

- Lors de l'écriture sur un système externe, la limitation réside dans la nécessité de coordonner la position du consommateur avec le contenu réellement stocké en sortie. La méthode classique consiste à introduire une validation en deux phases entre le stockage de la position du consommateur et celui de sa sortie. Cette solution est plus simple et plus générale : le consommateur peut stocker son offset au même endroit que sa sortie. Cette solution est préférable, car de nombreux systèmes de sortie sur lesquels un consommateur souhaite écrire ne prennent pas en charge une validation en deux phases. <br>
Eexemple d'un connecteur **Kafka Connect** qui alimente les données dans **HDFS**.