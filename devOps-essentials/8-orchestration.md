# Orchestration

## Qu'est-ce que l'orchestration ?

- Orchestration : automatisation qui prend en charge les processus et les flux de travail, tels que le provisionnement des ressources

- Avec l'orchestration, gérer une infrastructure complexe revient moins à être un constructeur qu'à diriger un orchestre

- Au lieu de sortir et de créer une infrastructure, le chef d'orchestre signale simplement ce qui doit être fait et l'orchestre l'exécute : <br>
--- Le conducteur n'a pas besoin de contrôler chaque détail <br>
--- Les musiciens (automatisation) sont capables d'interpréter leur morceau avec seulement un peu de conseils.

## À quoi ressemble l'orchestration ?

- Voici un exemple :

--- Un client demande plus de ressources pour un service Web dont l'utilisation est sur le point de connaître une forte augmentation en raison d'un effort marketing planifié. <br>

--- Au lieu de créer manuellement de nouveaux nœuds, les ingénieurs d'exploitation utilisent un outil d'orchestration pour demander cinq nœuds supplémentaires pour prendre en charge le service. <br>

---  Quelques minutes plus tard, l'outil dispose de cinq nouveaux nœuds opérationnels <br>

- Un exemple beaucoup plus cool :

--- Un outil de surveillance détecte une charge accrue sur le service <br>
--- Un outil d'orchestration répond à cela en faisant tourner des ressources supplémentaires pour gérer la charge <br>

--- Lorsque la charge diminue à nouveau, l'outil fait tourner les ressources supplémentaires vers le bas, les libérant pour être utilisées par autre chose <br>

--- Tout cela se passe pendant que l'ingénieur prend du café