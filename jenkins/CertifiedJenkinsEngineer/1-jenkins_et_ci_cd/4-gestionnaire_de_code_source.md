# Gestionnaire de code source

- Gestionnaire de code source

Un gestionnaire de code source est un logiciel utilisé pour suivre les modifications du code. <br>
Les changements de code, les révisions, sont horodatés et incluent l'identité de la personne qui a effectué le changement. <br>
Les modifications peuvent être suivies ou annulées si nécessaire. Les versions du code peuvent être comparées, stockées et fusionnées avec d'autres versions. <br>
Quelques exemples sont git, subversion, mercurial et perforce. <br>
Les scm basés sur le cloud tels que Git-hub ou Gitlab peuvent être exploités en tant que référentiels hors site pour le code. <br>
Les changelogs jenkins sont utilisés pour suivre les changements dans les builds.

- Archiver le code dans le contrôle de code source

L'archivage du code est le processus de transmission des modifications à un référentiel. L'archivage du code est identique à un commit de code.<br>
Dans le cadre de la méthodologie CI, le code doit être archivé souvent.
Tous les commits de code doivent avoir un message descriptif indiquant les modifications incluses dans le commit.

- Infrastructure en tant que code

Il s'agit du processus de gestion et de provisionnement des ressources via des fichiers de configuration. <br>
Il permet de maintenir les configurations de la machine dans le contrôle de source. Ces configurations peuvent ensuite être annulées ou versionnées.

- Stratégies de branchement et de fusion

ce sont les méthodes d'extraction et d'archivage du code dans le contrôle de code source de telle manière qu'une source de vérité est déterminée.
<br>
Un référentiel est déterminé comme étant la source de vérité. Les modifications conflictuelles sont résolues en faveur de cette source.