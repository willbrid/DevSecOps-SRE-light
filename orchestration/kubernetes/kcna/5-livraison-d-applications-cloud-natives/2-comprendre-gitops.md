# Comprendre GitOps

#### Qu'est-ce que GitOps ?

GitOps est un moyen de mettre en œuvre le déploiement continu pour les applications cloud natives. Il se concentre sur une expérience centrée sur le développeur lors de l'exploitation de l'infrastructure, en utilisant des outils que les développeurs connaissent déjà, notamment les outils Git et de déploiement continu.
<br>
L'idée centrale de GitOps est d'avoir un référentiel Git qui contient toujours des descriptions déclaratives de l'infrastructure actuellement souhaitée dans l'environnement de production et un processus automatisé pour faire correspondre l'environnement de production à l'état décrit dans le référentiel. Si vous souhaitez déployer une nouvelle application ou mettre à jour une application existante, il vous suffit de mettre à jour le référentiel - le processus automatisé gère tout le reste. C'est comme avoir un régulateur de vitesse pour gérer vos applications en production.

GitOps traite un référentiel Git comme une source de vérité et utilise les données stockées dans Git pour mettre en œuvre des modifications de l'infrastructure, comme un cluster Kubernetes.

#### Comment fonctionne GitOps ?

- Configurations d'environnement en tant que référentiel Git

GitOps organise le processus de déploiement autour des référentiels de code comme élément central. Il existe au moins deux référentiels : le référentiel d'applications et le référentiel de configuration de l'environnement. Le référentiel d'application contient le code source de l'application et les manifestes de déploiement pour déployer l'application. Le référentiel de configuration d'environnement contient tous les manifestes de déploiement de l'infrastructure actuellement souhaitée d'un environnement de déploiement. Il décrit quelles applications et services d'infrastructure (messages du broker, maillage de services, outil de surveillance, …) doivent s'exécuter avec quelle configuration et quelle version dans l'environnement de déploiement.

- Déploiements basés sur le push ou basés sur le pull

Il existe deux manières de mettre en œuvre la stratégie de déploiement pour GitOps : les déploiements basés sur Push et les déploiements basés sur Pull. La différence entre les deux types de déploiement réside dans la manière dont il est garanti que l'environnement de déploiement ressemble réellement à l'infrastructure souhaitée. Lorsque cela est possible, l'approche basée sur Pull doit être préférée car elle est considérée comme la plus sûre et donc la meilleure pratique pour mettre en œuvre GitOps. 
<br>
---- Déploiements basés sur le push <br>

La stratégie de déploiement basée sur Push est mise en œuvre par des outils CI/CD populaires tels que Jenkins, CircleCI ou Travis CI. Le code source de l'application réside dans le référentiel de l'application avec les fichiers YAML Kubernetes nécessaires au déploiement de l'application. Chaque fois que le code de l'application est mis à jour, le pipeline de génération est déclenché, ce qui génère les images de conteneur et enfin le référentiel de configuration de l'environnement est mis à jour avec de nouveaux descripteurs de déploiement.
<br>
Une autre chose importante à garder à l'esprit lors de l'utilisation de cette approche est que le pipeline de déploiement n'est déclenché que lorsque le référentiel d'environnement change. Il ne peut pas remarquer automatiquement les écarts de l'environnement et de son état souhaité. Cela signifie qu'il faut un moyen de surveillance en place, afin que l'on puisse intervenir si l'environnement ne correspond pas à ce qui est décrit dans le référentiel d'environnement. <br>

--- Déploiements basés sur le pull <br>

La stratégie de déploiement basée sur pull utilise les mêmes concepts que la variante basée sur push, mais diffère dans le fonctionnement du pipeline de déploiement. Les pipelines CI/CD traditionnels sont déclenchés par un événement externe, par exemple lorsqu'un nouveau code est poussé vers un référentiel d'application. Avec l'approche de déploiement basée sur pull, l'opérateur est introduit. Il prend le relais du pipeline en comparant en permanence l'état souhaité dans le référentiel d'environnement avec l'état réel de l'infrastructure déployée. Chaque fois que des différences sont constatées, l'opérateur met à jour l'infrastructure pour correspondre au référentiel d'environnement. De plus, le registre d'images peut être surveillé pour trouver de nouvelles versions d'images à déployer.
<br>
Tout comme le déploiement push, cette variante met à jour l'environnement chaque fois que le référentiel d'environnement change. Cependant, avec l'opérateur, des changements peuvent également être remarqués dans l'autre sens. Chaque fois que l'infrastructure déployée change d'une manière non décrite dans le référentiel d'environnement, ces modifications sont annulées. Cela garantit que toutes les modifications sont rendues traçables dans le journal Git, en rendant impossible toute modification directe du cluster.


#### Pourquoi devrons-nous utiliser GitOps ?

- Déployer plus rapidement et plus souvent

Plusieurs technologies de déploiement continu promettent probablement d'accélérer le déploiement et nous permettent de déployer plus souvent. Ce qui est unique avec GitOps, c'est que nous n'avons pas besoin de changer d'outil pour déployer notre application. Tout se passe de toute façon dans le système de contrôle de version que nous utilisons pour développer l'application.

- Récupération d'erreur facile et rapide

Oh non! Notre environnement de production est en panne ! Avec GitOps, nous disposons d'un historique complet de l'évolution de notre environnement au fil du temps. Cela rend la récupération d'erreur aussi simple que d'émettre un git revert et de regarder notre environnement en cours de restauration.

- Gestion simplifiée des identifiants

GitOps nous permet de gérer complètement les déploiements depuis notre environnement. Pour cela, notre environnement n'a besoin que d'un accès à notre référentiel et à notre registre d'images. Nous ne sont pas obligés de donner à nos développeurs un accès direct à l'environnement.

- Déploiements auto-documentés

Avec GitOps, chaque modification apportée à n'importe quel environnement doit passer par le référentiel. Nous pouvons toujours consulter la branche principale et obtenir une description complète de ce qui est déployé et où, ainsi que l'historique complet de chaque modification apportée au système. Et nous obtenons gratuitement une piste d'audit de toutes les modifications apportées à notre système !

- Partage des connaissances dans les équipes

L'utilisation de Git pour stocker des descriptions complètes de notre infrastructure déployée permet à tous les membres de notre équipe de vérifier son évolution au fil du temps. Avec de bons messages d'engagement, tout le monde peut reproduire le processus de réflexion de l'évolution de l'infrastructure et également trouver facilement des exemples de mise en place de nouveaux systèmes.

#### Quelques outils GitOps

Les outils GitOps tels que **Flux** et **Argo CD** surveillent un référentiel Git et appliquent des modifications au cluster en fonction du contenu de ce référentiel. <br>
**Flux** et **Argo CD** sont tous deux écrits en Go.

- Flux est un ensemble de solutions de livraison continue et progressive pour Kubernetes qui sont ouvertes et extensibles. Flux est construit sur la bibliothèque standard GitOps Toolkit.
- Argo CD est un outil de livraison continue GitOps déclaratif pour Kubernetes.


[https://www.gitops.tech/](https://www.gitops.tech/)

[https://fluxcd.io/](https://fluxcd.io/)

[https://argoproj.github.io/cd/](https://argoproj.github.io/cd/)