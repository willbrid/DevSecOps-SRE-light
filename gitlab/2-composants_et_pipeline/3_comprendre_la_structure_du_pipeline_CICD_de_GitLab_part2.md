# Comprendre la structure du pipeline CI/CD de GitLab [Part2]

Nous présentons ici les parties d'un pipeline : **étapes (stages)**, **tâches (jobs)** et **commandes**.

### Étapes (stages)

Chaque pipeline se compose d'une ou plusieurs **étapes**. Une **étape** est un ensemble de tâches de pipeline thématiquement liées. Par exemple, ci-dessous les trois **étapes** les plus couramment utilisées :

- **Build** : cette étape contient des tâches qui compilent et/ou conditionnent notre code source dans un format déployable.
- **Test** : cette étape contient des tâches qui exécutent des tests automatisés, des analyses de qualité de code et des linters, et éventuellement des analyses de sécurité.
- **Déployer** : cette étape envoie notre code à l'environnement approprié, en fonction de la branche Git ou de la balise Git sur laquelle le pipeline s'exécute (entre autres facteurs possibles).

Ces trois **étapes** sont si couramment utilisées que GitLab les ajoute par défaut à notre pipeline. Nous pouvons bien entendu remplacer ce paramètre par défaut en ajoutant, supprimant ou remplaçant des **étapes**. Quelles que soient les **étapes** auxquelles nous nous retrouvons, il est recommandé de toujours définir explicitement nos **étapes**, même si nous utilisons les trois **étapes** par défaut. Cela facilite la lisibilité, facilite le dépannage et évite toute confusion ultérieure.

### Tâches (jobs)

Nous pouvons considérer les **tâches** comme le niveau immédiatement inférieur (en dessous des **étapes**) en ce qui concerne les éléments de base qui composent un pipeline CI/CD GitLab. Chaque **étape** contient une ou plusieurs **tâches**, et chaque **tâche** est contenue dans une **étape**.

Par exemple, une **tâche** peut compiler tout notre code source Java en classes. Une autre **tâche** peut réinitialiser les données dans une base de données de test. Une autre **tâche** peut transférer une image Docker vers un registre.

### Commandes

Chaque **tâche** contient une ou plusieurs **commandes** qui permettent à la **tâche** d'effectuer quelque chose.
Une **commande** contenue dans une **tâche** est la même chose qu'une **commande** qu'un humain peut saisir dans un terminal. Imaginer un **tâche** comme celui d'un robot qui tape une **commande** dans un shell bash Linux, un shell macOS Zsh ou Windows PowerShell, tout comme le ferait une vraie personne.

En définitive,
- chaque pipeline GitLab CI/CD comprend au moins une **étape**. Une **étape** représente une catégorie de **tâches** que le pipeline doit effectuer.
- chaque **étape** comprend au moins une **tâche**. Une **tâche** représente un processus unique que le pipeline doit effectuer.
- chaque **tâche** consiste en au moins une **commande**, où une **commande** correspond exactement à ce qu'un humain saisirait dans un shell pour effectuer une **tâche** de pipeline.