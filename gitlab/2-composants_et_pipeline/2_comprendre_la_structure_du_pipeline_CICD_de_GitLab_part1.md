# Comprendre la structure du pipeline CI/CD de GitLab [Part1]

Nous présentons ici les termes pipeline et CI/CD.

### Comprendre ce qu'est un **pipeline GitLab CI/CD**

Un **pipeline GitLab CI/CD** est une **série d'étapes** effectuées sur **nos fichiers** chaque fois que nous validons des modifications dans la copie d'un référentiel hébergée par GitLab.

Qu’entend-on par « **une série d’étapes** » ? Nous pouvons considérer ces étapes comme des tâches effectuées sur nos fichiers. Par exemple, nous souhaiterons peut-être exécuter divers tests ou analyseurs sur nos fichiers pour nous assurer que notre code est bien écrit, qu'il est exempt de vulnérabilités de sécurité, qu'il utilise des dépendances sous licence appropriée et qu'il satisfait à toutes les exigences fonctionnelles ou de performances. Nous souhaiterons peut-être également regrouper notre code dans un format déployable, qu'il s'agisse d'un **Ruby Gem**, d'un **package Red Hat** installable, d'une **image Docker** ou de tout autre type de package. Bien entendu, nous aurons peut-être également besoin d’une étape permettant de déployer notre code dans un environnement approprié, qu’il s’agisse d’un environnement de **test**, d’un environnement de **pré-production** ou de l’environnement de **production réel** de notre projet.

Qu'entendons-nous par « **nos fichiers** » ? Techniquement, un pipeline GitLab CI/CD peut effectuer les étapes que nous venons de décrire sur tous les fichiers inclus dans le référentiel d'un projet GitLab : fichiers de code source, fichiers de configuration, fichiers README et fichiers de données de test. En bref, nous pouvons configurer un pipeline pour inspecter, tester, empaqueter, déployer ou manipuler de toute autre manière tous les fichiers de notre projet.

### Définir un pipeline par projet

Chaque projet définit un seul pipeline GitLab CI/CD. Mais que se passe-t-il exactement dans ce pipeline ? les tâches qu’il inclut peuvent dépendre de divers facteurs, ce qui amène une partie du pipeline à « **paraître différente** » des autres parties du pipeline du projet. Par exemple, le pipeline qui s'exécute sur le code source édité peut inclure de nombreux tests automatisés et regrouper le code dans une image Docker, tandis que le pipeline qui s'exécute sur la documentation éditée peut impliquer des vérifications orthographiques et un déploiement sur un serveur Web. Mais c’est toujours le même pipeline dans les deux cas.

### Comprendre les différentes utilisations du terme « pipeline »

Le terme « pipeline » est parfois utilisé de manière vague. La façon la plus précise d’y penser est de dire que le pipeline d’un projet n’est qu’un modèle pour la série d’étapes qui seront appliquées au dossier du projet. L'exécution de ces étapes n'est pas techniquement un pipeline et est plutôt appelée « **exécution de pipeline** » ou « **instance de pipeline** ». Un projet peut exécuter plusieurs instances de pipeline à la fois.

### Affichage d'une liste de pipelines

La liste des pipelines de GitLab nous indique non seulement l'état de **réussite/échec** de toutes nos exécutions de pipeline, mais nous permet également de savoir si des pipelines sont « bloqués » ou incapables de s'exécuter pour une raison quelconque. Il nous montre sur quelle version du code chaque pipeline s'exécute, le message de validation pour la validation ou le tag Git qui a déclenché le pipeline, qui a effectué la validation ou le tag, quand le pipeline a démarré et combien de temps il a fallu pour s'exécuter.

La liste des pipelines fournit également des contrôles GUI pour réexécuter n'importe quel pipeline. Nous souhaiterons peut-être procéder ainsi si un pipeline échoue en raison de ce que nous pensons être un problème de réseau intermittent par exemple.

### CI : savoir si notre code est bon

Le terme **CI** signifie intégration continue. Il s’agit la partie du pipeline qui garantit que toutes les modifications de fichiers sur lesquelles nous travaillons s'intégreront bien à la base de code stable de notre projet.

La partie **CI** d'un pipeline exécute des tests, des analyses et d'autres vérifications sur notre code chaque fois que nous le validons dans la copie du référentiel Git de notre projet hébergée par GitLab. C'est du moins le comportement par défaut des pipelines GitLab. Nous pouvons remplacer ce comportement afin que les pipelines ne s'exécutent pas à chaque validation.

Ci-dessous une liste partielle des étapes possibles du pipeline axées sur le **CI** : <br>

--- **tests fonctionnels** : notre logiciel fait-il ce qu'il est censé faire ? <br>
--- **analyses de sécurité** : notre code introduit-il des failles de sécurité ? <br>
--- **analyses de qualité du code** : notre code respecte-t-il les meilleures pratiques en matière de longueur de classe, d'utilisation des espaces blancs et d'autres considérations liées au style ? <br>
--- **tests de performances** : notre code répond-il aux attentes en matière de performances ? <br>
--- **analyse de licence** : toutes les dépendances de notre code utilisent-elles des licences logicielles compatibles avec la licence de notre projet principal ? <br>
--- **tests fuzz** : pouvons-nous déclencher des plantages ou des erreurs inattendues dans notre code en lui transmettant des chaînes inhabituellement longues, des nombres en dehors des plages attendues ou d'autres données étranges ou extrêmes en entrée ?

### CD – découvrir où doit aller notre code

Les logiciels développés avec GitLab utilisent également des environnements, et la partie CD d'un pipeline GitLab CI/CD est chargée de décider dans quel code d'environnement doit être déployé, puis de l'y placer. Selon la façon dont nous avons configuré le pipeline de notre projet, les tâches qui effectuent ce travail prennent en compte divers facteurs pour décider où placer notre code. Le facteur le plus couramment utilisé par les pipelines est de savoir s’ils s’exécutent sur une branche Git ou un tag Git, et dans le cas contraire, quel est le nom de la branche.

Ci-dessous un exemple typique de la façon dont la partie CD d'un pipeline GitLab peut décider où déployer le code d'un projet :

- si un pipeline s'exécute sur une branche portant un nom tel que **add-login-feature**, **fix-password-bug** ou **remediate-cross-site-scripting-vuln**, déployer le code dans un environnement de révision pour le tester.
- si un pipeline s'exécute sur la branche principale (**main**), déployer ce code dans l'environnement intermédiaire (parfois appelé **pré-production**).
- si un pipeline s'exécute sur un tag Git dans la branche de **production**, déployer le code dans l'environnement de **production**. Cela suppose que notre équipe ajoute un tag de version telle que **version 1.0.0** ou version **12.2.1** à chaque commit qu'elle a l'intention de déployer auprès des utilisateurs.

- **Comprendre les environnements de révision**

GitLab a un nom spécial pour tous les environnements de test : les **environnements de révision**. Chaque branche Git autre que celle par défaut dispose d'un **environnement de révision** dédié uniquement à cette branche. Dès que cette branche est fusionnée avec la branche par défaut qui contient la base de code stable, GitLab détruit l'**environnement de révision** qui n'est plus nécessaire. Les **environnements de révision** sont l'une des fonctionnalités les plus étonnantes de GitLab. Nous ne sommes pas obligés de configurer ces environnements nous-même. Chaque fois que nous créons une branche dans la copie du référentiel de notre projet hébergée par GitLab , un **environnement de révision** apparaît de manière automatique, prêt à être déployé pour notre pipeline CI/CD. Et lorsque nous avons terminé avec notre branche et que nous la supprimons ou la fusionnons dans notre base de code stable, l'**environnement de révision** disparaît de manière automatique.

- **Livraison continue**

Avec la notion de **livraison continue**, un pipeline GitLab CI/CD déploiera automatiquement notre code dans le bon environnement, en fonction des facteurs auxquels nous configurons le pipeline pour y prêter attention. Mais il existe une exception importante : avec la **livraison continue**, GitLab ne déploiera pas automatiquement notre code dans l'environnement de production. Au lieu de cela, il présente un contrôle GUI qui demande à un humain (généralement un ingénieur de publication) d'approuver manuellement et de déclencher le déploiement en production. Il s'agit d'une sécurité finale qui empêche notre équipe de déployer un code défectueux, ou la mauvaise version de notre code, auprès des utilisateurs finaux.

- **Déploiement continu**

L'autre chose que CD peut signifier est le **déploiement continu**. C'est la même chose que la **livraison continue**, à une exception près : elle supprime la sécurité intégrée finale et manuelle. Le **déploiement continu** envoie notre code à l'environnement de production de manière entièrement automatique, tout comme il déploie le code dans n'importe quel autre environnement. Se débarrasser de l'élément humain peut être considéré comme risqué par certaines organisations, mais si nous disposons d'une partie CI mature, éprouvée et fiable de notre pipeline, nous pouvons être sûr que tout code qui passe par le gant des tests, des analyses et autres vérifications sont suffisamment bons pour être déployés directement auprès des clients. Cela peut représenter un gain de temps appréciable pour les entreprises ayant un niveau élevé de confiance dans leur pipeline CI.

- **Empaqueter et déployer du code avec un CD**

Un pipeline CD, qu'il implémente une livraison continue ou un déploiement continu, doit parfois conditionner le code de notre projet sous une forme déployable avant de pouvoir être déployé. <br>
Bien entendu, il existe des cas où aucun emballage n’est requis. Certains projets dotés de stratégies de déploiement simples peuvent déployer un ensemble de fichiers libres et non empaquetés.

### GitLab Runners

Un pipeline CI/CD n'est qu'une série de commandes exécutées par un robot, où ces commandes effectuent des tâches liées à la création, à la vérification et au déploiement de logiciels. Les **GitLab Runners** sont les robots qui exécutent ces commandes. Techniquement parlant, un **GitLab Runner** est un petit programme auquel l'instance GitLab envoie des commandes à exécuter.