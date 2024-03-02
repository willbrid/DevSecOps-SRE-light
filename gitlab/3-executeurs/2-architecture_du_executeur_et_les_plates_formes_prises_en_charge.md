# L'architecture d'un agent exécuteur et les plates-formes prises en charge

L'**agent exécuteur GitLab** fait référence à l'application installée une fois sur un serveur. Une fois l'application **agent exécuteur GitLab** installée, elle ne communique pas encore avec GitLab ni n'exécute de tâches CI/CD. Afin de se connecter à GitLab et d'exécuter des tâches CI/CD, un administrateur devra exécuter une commande d'**agent exécuteur GitLab** qui enregistre les **agents exécuteurs** individuels auprès de GitLab et spécifie l'environnement d'exécution que ces **agents exécuteurs** utiliseront. Chaque agent exécuteur enregistré sera alors un processus dédié qui s'enregistre dans GitLab et exécute les tâches CI/CD.

Un administrateur peut installer l'application **agent exécuteur GitLab**, qu'il utilise ensuite pour enregistrer les éléments suivants :
- Un **processus exécuteur** qui exécute une tâche dans une session shell sur le système d'exploitation du serveur
- Un **deuxième processus exécuteur** qui exécute une tâche dans un conteneur Docker
- Un **processus tiers** qui transmet les commandes d'une tâche à un autre serveur via SSH

L'**agent exécuteur GitLab** peut être installé sur toutes les principales distributions et architectures Linux, ainsi que sur FreeBSD, Windows, macOS, Docker et Kubernetes.

Les propriétaires et responsables de projets peuvent choisir d'inscrire des agents exécuteurs uniquement pour leurs projets. Des agents exécuteurs spécifiques sont affectés à des projets spécifiques, récupèrent et exécutent uniquement les tâches des pipelines CI/CD exécutés dans le projet auquel ils sont affectés. L’utilisation d'agents exécuteurs spécifiques présente plusieurs avantages : 
- la première est que des agents exécuteurs spécifiques permettent aux propriétaires de projets et aux développeurs de configurer l'infrastructure d'exécution dont ils ont besoin sans rien changer en dehors du projet dans lequel ils travaillent.
- la deuxième est la possibilité d'un outillage dédié ou personnalisé pour des projets individuels. Des agents exécuteurs spécifiques permettent une comptabilité plus facile de l'utilisation des ressources au niveau du projet.

Certaines ressources de GitLab ne sont disponibles que dans les projets, certaines ressources ne sont disponibles que dans les groupes et d'autres peuvent être disponibles à la fois dans les projets et les groupes. Les agents exécuteurs sont un exemple de ce troisième type de ressource. L'enregistrement d'un **agent exécuteur** au niveau du groupe rend cet **agent exécuteur** disponible pour tous les pipelines de tous les projets de ce groupe et de ses sous-groupes.

Les administrateurs d'instance GitLab peuvent choisir d'enregistrer des agents exécuteurs capables de récupérer les tâches CI/CD de n'importe quel projet de n'importe quel groupe de l'instance GitLab. Cela permet aux propriétaires de plates-formes de soustraire la gestion des agents exécuteurs aux développeurs ou aux chefs de projet. Les administrateurs d'instance peuvent également configurer des quotas CI/CD au niveau global qui limitent le nombre de minutes de pipeline CI/CD que les projets individuels peuvent utiliser sur les agents exécuteurs partagés disponibles.

Chaque agent exécuteur possède un exécuteur défini. L'agent exécuteur fait référence à l'environnement qu'un exécuteur utilise pour exécuter une tâche CI/CD reçue. L'exécuteur d’un agent exécuteur est spécifié lors de sa première inscription sur GitLab.

Ci-dessous les exécuteurs d'agent exécuteur officiellement pris en charge
- docker
- shell
- virtualbox
- parallels
- kubernetes
- docker machine
- ssh
- Personnalisé

Les tags d'agent exécuteur sont des étiquettes placées sur les agents exécuteurs GitLab qui les font correspondre aux définitions de tâches qui incluent également ce tag. Les tags peuvent représenter la plate-forme de l'agent exécuteur ou les outils disponibles. Les tags peuvent également représenter l'utilisation prévue par l'agent exécuteur à une certaine étape du processus CI/CD, telle que la **construction**, la **préparation** ou la **production**. Lorsque nous spécifions également une ou plusieurs tags dans une définition de tâche CI/CD, nous pouvons nous assurer que l'agent exécuteur dispose des outils et de l'environnement appropriés nécessaires pour exécuter cette tâche.