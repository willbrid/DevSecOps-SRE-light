# Composants de la plateforme gitlab

GitLab est une plateforme DevOps open source qui s’appuie sur le logiciel de gestion de versions Git. Elle permet de créer, tester et déployer des logiciels de manière collaborative. L’application tout-en-un propose d’accéder à l’ensemble des étapes du cycle de vie DevOps. Ainsi GitLab reconnaît 10 étapes dans le cycle de vie DevOps :

- **gérer** : créer des rapports d'audit et de conformité et restreindre l'accès aux ressources.
- **planifier** : diviser le travail en parties réalisables que nous pouvons hiérarchiser, pondérer et attribuer aux membres de l'équipe.
- **créer** : valider, réviser et approuver les modifications de fichiers, qu'elles contiennent du code, des informations de configuration ou d'autres ressources.
- **vérifier** : exécuter des tests automatisés pour nous assurer que notre logiciel fait ce qu'il est censé faire.
- **rassembler** : regrouper notre logiciel dans un format déployable.
- **sécuriser** : rechercher les failles de sécurité de notre logiciel ou de ses dépendances.
- **déployer** : déployer notre logiciel, éventuellement à l'aide de techniques sophistiquées telles que les indicateurs de fonctionnalités et les déploiements Canary.
- **configurer** : configurer les environnements dans lesquels notre code sera déployé.
- **surveiller** : fournir un rapport sur les mesures de performances, les incidents ou les erreurs.
- **protéger** : détecter les problèmes de sécurité potentiels dans les environnements de déploiement tels que les clusters Kubernetes.

### Organisation du travail

- **Projets**

Les **projets** sont les éléments fondamentaux de **GitLab**. Un **projet** **GitLab** représente un seul produit logiciel ou non logiciel sur lequel nous travaillons. Les **projets** sont l’endroit où nous stockons nos fichiers et constituent le point de départ pour naviguer dans les différentes fonctionnalités de **GitLab**. En bref, les **projets** sont l'endroit où nous passons la plupart de notre temps en tant qu'utilisateur de **GitLab**. <br> 

**Quelques exemples de projets typiques** :

- Une application pour téléphone mobile permettant de trouver un prestataire de services à proximité, utilisée par l'équipe de développement 
- Une version de bureau de la même application de prestation de services, utilisée par l'équipe de développement
- La documentation utilisée par l'équipe de rédaction technique
- Une conférence à venir, utilisée par l'équipe de planification de l'événement
- Tâches d'intégration pour les nouveaux employés, utilisées par l'ensemble de l'entreprise

Nous pouvons utiliser un **groupe GitLab** pour rassembler un ensemble de projets associés afin qu'ils existent tous au même endroit dans **GitLab**. Nous pouvons considérer les **groupes GitLab** comme étant similaires à des répertoires ou des dossiers contenant des **collections de projets**. <br>
À l'aide de groupes, nous pouvons effectuer les opérations suivantes :
- inviter d'autres utilisateurs de GitLab à devenir membres d'un groupe.
- attribuer à ces utilisateurs un rôle au sein de ce groupe.
- accorder à un utilisateur, un groupe ou un rôle l'autorisation d'afficher ou de modifier tous les projets de ce groupe.

Ainsi, les **groupes** constituent un moyen simple de réguler le contrôle d'accès de plusieurs utilisateurs à la fois. Un **groupe** regroupera également les composants de tous les projets de ce groupe. Par exemple, nous pouvons accéder à un seul écran pour voir tous les problèmes de tous les projets d'un **groupe**.

Par exemple supposons que nous souhaiterons mettre en place une plateforme permettant de trouver les prestataires de services à proximité intitulé : **Mymbolo**. Ainsi pour **Mymbolo**, nous pouvons organiser comme suit :
- créer un projet appelé **Documentation** au sein du groupe **Mymbolo**
- créer un projet appelé **Web** au sein du groupe **Mymbolo**
- créer un projet appelé **iOS** dans le sous-groupe **Mobile-Mymbolo**
- créer un projet appelé Android dans le sous-groupe **Mobile-Mymbolo**

### Suivi du travail avec des problèmes

Les **problèmes** résident dans les projets GitLab, chaque **problème** n'appartenant qu'à un seul projet (bien qu'ils puissent être déplacés entre les **projets**). Les **problèmes** GitLab se composent de plusieurs parties, dont les quatre sont les plus importantes :

- **titre**

- **description** : ce champ peut contenir autant de texte que nous le souhaitons. Il peut contenir des captures d’écran ou des liens et exploite pleinement les fonctionnalités de formatage de Markdown. Il peut également être modifié ultérieurement à mesure que de plus amples informations apparaissent ou que la direction exacte du problème change.

- **champs de métadonnées facultatifs** : les plus importants sont :

--- **destinataire** : ce champ identifie la ou les personnes à qui appartient le problème <br>
--- **date d'échéance** : il existe plusieurs façons d'utiliser les dates d'échéance dans GitLab, mais la plus simple consiste à attribuer une date d'échéance directement à un problème. <br>
--- **étiquettes** : elles servent, entre autres utilisations, à hiérarchiser, acheminer ou rendre compte de la progression d'un problème. Ce sont des balises colorées contenant un court morceau de texte. Nous pouvons appliquer des **étiquettes** aux problèmes ou à d'autres composants GitLab, tels que les demandes de fusion, et les supprimer lorsqu'ils ne sont plus utiles. <br>
Les **étiquettes** peuvent comporter des doubles deux-points à l’intérieur de leur texte descriptif. Les doubles deux-points ont une signification particulière : ils transforment ces étiquettes en étiquettes de portée, ce qui signifie qu'elles s'excluent mutuellement. Autrement dit, un problème peut avoir l’étiquette **Status::Healthy** ou l’étiquette **Status::At Risk** appliquée, mais pas les deux. Les étiquettes sans portée (les étiquettes qui ne contiennent pas de doubles deux-points) peuvent être appliquées dans n'importe quelle combinaison à n'importe quel problème. Par exemple, nous pouvons appliquer à la fois les étiquettes **Front-end** et **DB** à un problème qui nécessite le travail de notre **développeur front-end** et de notre **administrateur de base de données**. <br>
--- **poids** : ce champ décrit la quantité de travail que nous pensons que le problème nécessitera. <br>
--- un autre champ de métadonnées important sur le problème indiquant : s'il est **ouvert (open)** ou **fermé (closed)**. Chaque problème commence par un statut **ouvert (open)**. Lorsqu'une personne termine le travail requis par un problème, elle change normalement son statut en **fermé (closed)**.

- **fil de discussion**, où les membres de l'équipe peuvent commenter le problème.

Nous pouvons également consulter une liste de problèmes au niveau du **groupe** plutôt qu'au niveau du **projet**.

Les types de **tâches** que les problèmes peuvent représenter : **ajouter une fonctionnalité**, **correction d'un bug**, **rédiger des tests automatisés**
**mettre en place une base de données**, **configurer un outil que toute l'équipe pourra utiliser**, **rechercher des options techniques**, **réfléchir à des solutions à un problème**, **planifier un événement**, **sonder l'équipe sur ses préférences en matière de normes de codage**, **signaler et gérer un incident de sécurité**, **proposer une idée de nouveau produit ou de nouvelle fonctionnalité**, **poser une question sur laquelle n'importe qui peut donner son opinion**, **demander des modèles de T-shirts pour une prochaine sortie d'entreprise**.