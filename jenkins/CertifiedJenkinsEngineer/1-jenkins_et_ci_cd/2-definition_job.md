# Qu'est ce qu'un job sur jenkins ?

- Job

Un job dans Jenkins est une tâche exécutable contrôlée par Jenkins. Un job est une description des actions que nous voulons que Jenkins fasse. Dans la documentation actuelle de Jenkins, le terme **job** a été remplacé par le terme **projet**. Un projet est une tâche exécutable contrôlée par Jenkins, un travail est une tâche exécutable contrôlée par Jenkins, les termes sont interchangeables.
<br>
Lorsque nous devons pouvoir exécuter quelques actions sur le lot, quelques actions sur la ligne de commande Windows, et que nous devons pouvoir le faire de manière automatisée, nous devons utiliser un projet **freestyle** sur jenkins.
<br>

- Pipeline

Les pipelines sont le concept le plus important dans Jenkins. Les projets sont normalement écrits en Jenkins Domain Specific Language : le DSL. Ce DSL est placé dans un fichier Jenkins qui indique à Jenkins quoi faire. Ce fichier Jenkins peut être inséré dans le contrôle de source afin que la configuration puisse être itérée avec le code source pour que le flux de travail du pipeline puisse réellement changer selon les besoins. Ces types de projets sont des projets qui ne rentrent pas dans un projet **freestyle**.
<br>

- Projet multi-configuration

Il s'agit d'un projet qui sera testé sur plusieurs environnements et qui nécessitera différentes configurations, en fonction de ces environnements.
<br>

- Plateforme github

Ce type de projet peut utiliser une plateforme de contrôle de source et permettre à jenkins d'agir sur les fichiers jenkins stockés dans les référentiels de cette plateforme.
<br>

- Dossier

Cela fournit une méthode pour regrouper des projets ensemble. Ce n'est pas un projet technique. Il agit comme un type de structure de répertoires pour les projets et le nom du dossier devient une partie du chemin des projets.
<br>

- Pipeline multi-branches

Dans ce type de projet, jenkins utilise un fichier jenkins pour marquer les référentiels. Si une branche est créée dans ce référentiel, jenkins créera un nouveau projet dans jenkins pour cette branche.
<br>

- Portée d'un projet/job

Cela inclut tous les éléments qui font partie de ce projet particulier. Dans certains cas, il existe des bibliothèques globales qui sont intégrées à la portée d'un projet simplement en y étant incluses. Les autres éléments déclarés dans un projet n'existent que dans la portée de ce projet et ne sont pas disponibles en tant que ressource partagée.