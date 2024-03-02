# L'architecture d'exécuteur et les plates-formes prises en charge

L'**exécuteur GitLab** fait référence à l'application installée une fois sur un serveur. Une fois l'application **exécuteur GitLab** installée, elle ne communique pas encore avec GitLab ni n'exécute de tâches CI/CD. Afin de se connecter à GitLab et d'exécuter des tâches CI/CD, un administrateur devra exécuter une commande **exécuteur GitLab** qui enregistre les exécuteurs individuels auprès de GitLab et spécifie l'environnement d'exécution que ces exécuteurs utiliseront. Chaque exécuteur enregistré sera alors un processus dédié qui s'enregistre dans GitLab et exécute les tâches CI/CD.

Un administrateur peut installer l'application **exécuteur GitLab**, qu'il utilise ensuite pour enregistrer les éléments suivants :
- Un **processus exécuteur** qui exécute une tâche dans une session shell sur le système d'exploitation du serveur
- Un **deuxième processus exécuteur** qui exécute une tâche dans un conteneur Docker
- Un **processus tiers** qui transmet les commandes d'une tâche à un autre serveur via SSH

L'**exécuteur GitLab** peut être installé sur toutes les principales distributions et architectures Linux, ainsi que sur FreeBSD, Windows, macOS, Docker et Kubernetes.

Les propriétaires et responsables de projets peuvent choisir d'inscrire des exécuteurs uniquement pour leurs projets. Des exécuteurs spécifiques sont affectés à des projets spécifiques, récupèrent et exécutent uniquement les tâches des pipelines CI/CD exécutés dans le projet auquel ils sont affectés.
L’utilisation de exécuteurs spécifiques présente plusieurs avantages : 
- la première est que des exécuteurs spécifiques permettent aux propriétaires de projets et aux développeurs de configurer l'infrastructure d'exécution dont ils ont besoin sans rien changer en dehors du projet dans lequel ils travaillent.
- la deuxième est la possibilité d'un outillage dédié ou personnalisé pour des projets individuels. Des exécuteurs spécifiques permettent une comptabilité plus facile de l'utilisation des ressources au niveau du projet.

Certaines ressources de GitLab ne sont disponibles que dans les projets, certaines ressources ne sont disponibles que dans les groupes et d'autres peuvent être disponibles à la fois dans les projets et les groupes. Les exécuteurs sont un exemple de ce troisième type de ressource. L'enregistrement d'un exécuteur au niveau du groupe rend cet exécuteur disponible pour tous les pipelines de tous les projets de ce groupe et de ses sous-groupes.

Les administrateurs d'instance GitLab peuvent choisir d'enregistrer des exécuteurs capables de récupérer les tâches CI/CD de n'importe quel projet de n'importe quel groupe de l'instance GitLab. Cela permet aux propriétaires de plates-formes de soustraire la gestion des exécuteurs aux développeurs ou aux chefs de projet. Les administrateurs d'instance peuvent également configurer des quotas CI/CD au niveau global qui limitent le nombre de minutes de pipeline CI/CD que les projets individuels peuvent utiliser sur les exécuteurs partagés disponibles.

Chaque exécuteur possède un processus exécuteur défini. L'exécuteur fait référence à l'environnement qu'un processus exécuteur utilise pour exécuter une tâche CI/CD reçue. Le processus exécuteur d’un exécuteur est spécifié lors de sa première inscription sur GitLab.

Processus exécuteurs d'un exécuteur officiellement pris en charge
- docker
- shell
- virtualbox
- parallels
- kubernetes
- docker machine
- ssh
- Personnalisé

Les tags (labels) exécuteurs sont des étiquettes placées sur les exécuteurs GitLab qui les font correspondre aux définitions de tâches qui incluent également ce tag. Les tags peuvent représenter la plate-forme de l'exécuteur ou les outils disponibles. Les tags peuvent également représenter l'utilisation prévue par l'exécuteur à une certaine étape du processus CI/CD, telle que la **construction**, la **préparation** ou la **production**. Lorsque nous spécifions également une ou plusieurs tags dans une définition de tâche CI/CD, nous pouvons nous assurer que l'exécuteur dispose des outils et de l'environnement appropriés nécessaires pour exécuter cette tâche.