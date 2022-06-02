# Gestion de la configuration

## Qu'est-ce que la gestion des configurations ?

- Gestion de la configuration : maintenir et modifier l'état des éléments d'infrastructure de manière cohérente, maintenable et stable.

- Les changements doivent toujours se produire - la gestion de la configuration consiste à les faire de manière maintenable

- La gestion de la configuration vous permet de minimiser la dérive de la configuration : les petits changements qui s'accumulent au fil du temps et rendent les systèmes différents les uns des autres et plus difficiles à gérer

- L'infrastructure en tant que code est très bénéfique pour la gestion de la configuration.

## À quoi ressemble la gestion de la configuration ?

Voici un exemple : 

- Vous devez mettre à niveau un package logiciel sur plusieurs serveurs : <br>

--- Sans une bonne gestion de la configuration, vous vous connectez à chaque serveur et effectuez la mise à niveau. Cependant, cela peut entraîner de nombreux problèmes. Peut-être qu'un serveur a été manqué en raison d'une documentation médiocre, ou peut-être que quelque chose ne fonctionne pas alors que les versions sont temporairement incompatibles entre les serveurs, ce qui entraîne de nombreux temps d'arrêt pendant la mise à niveau. <br>

--- Avec une bonne gestion de la configuration, vous définissez la nouvelle version du progiciel dans un fichier ou un outil de configuration et déployez automatiquement la modification sur tous les serveurs.

- La gestion de la configuration consiste à gérer votre configuration quelque part en dehors des serveurs eux-mêmes.

## Pourquoi faire de la gestion de configuration ?

- Gain de temps – Il faut moins de temps pour modifier la configuration.

- Insight - Avec une bonne gestion de la configuration, nous pouvons connaître l'état de tous les éléments d'une infrastructure vaste et complexe.

- Maintenabilité - Une infrastructure plus maintenable est plus facile à modifier de manière stable.

- Moins de dérive de configuration - Il est plus facile de conserver une configuration standard sur une multitude d'hôtes.