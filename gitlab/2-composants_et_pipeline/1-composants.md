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

- **titre** : intitulé du problème

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

### Activation des pratiques DevOps avec le workflow GitLab

Tout en travaillant sur l'application **Mymbolo**, nous décidons d'ajouter une fonctionnalité qui permet d'authentifier les utilisateurs prestataire. Voici toutes les étapes prescrites par le flux GitLab pour faire exister cette fonctionnalité :

1- Dans le projet mobile du groupe **Mymbolo**, nous créons un problème intitulé **authentifier les utilisateurs prestataire**, en laissant tous les champs de métadonnées vides.

2- Dans la section de discussion du problème, nous mentionnons deux personnes qui, selon nous, pourraient avoir des opinions sur la question de savoir si cette fonctionnalité est une bonne idée.

3- Ces deux personnes ajoutent des réponses à la section de discussion. On laisse juste un emoji du pouce levé. L’autre exprime son soutien à l’idée mais demande si l’application doit également **authentifier les utilisateurs clients**.

4- Nous décidons que **authentifier les utilisateurs clients** est une bonne idée, mais nous ne sommes pas sûr. Nous faisons un autre problème intitulé **Question : devons-nous authentifier les utilisateurs clients ?** Nous mettons ce problème de côté pour le traiter plus tard et nous concentrons à nouveau sur le problème **authentifier les utilisateurs prestataire**, car nous sommes convaincu que les prestataires doivent avoir un compte.

5- Lors d'une réunion de planification à l'échelle de l'équipe, le groupe décide d'attribuer au problème une pondération de **8**, ce qui signifie que pour notre équipe, cela devrait représenter une tâche d'une semaine. Nous attribuons le problème à un développeur back-end nommé **willbrid** et nous définissons son champ de date d'échéance sur 2 semaines à compter d'aujourd'hui.

6- **willbrid** applique une étiquette **Status::In Progress** avec une portée et une étiquette Back-end sans portée au problème. Cela aidera l’équipe à savoir si le problème est sur la bonne voie et à comprendre qui en est responsable.

7- **willbrid** crée une branche temporaire appelée **authentifier-utilisateurs-prestataire** pour conserver ses commits.

8- **willbrid** crée une demande de fusion intitulée **Brouillon : authentifier les utilisateurs prestataire**. Il charge ses coéquipiers **Alice** et **Bob** d'examiner la demande de fusion. Ils n’ont encore rien à faire puisque **willbrid** n’a ajouté aucun code à la branche du MR.

9- Maintenant que **willbrid** a configuré les éléments : le problème, la branche et la demande de fusion, il commence à coder.

10- Après avoir terminé un petit morceau de code testable, il le valide dans sa branche.

11- **willbrid** consulte le MR pour voir les résultats des tests automatisés, des analyses de qualité du code, des analyses de licence et des analyses de sécurité exécutées sur son premier commit. Ils ne signalent aucun problème, alors il célèbre la fête.

12- **Alice** et **Bob** reçoivent des notifications par e-mail indiquant que **willbrid** a transmis du code au MR. Ils examinent le MR et examinent ses modifications. Tous deux ajoutent quelques commentaires sur les parties de son code qu'ils aiment et sur les parties qui peuvent être améliorées.

13- Certaines des suggestions semblent erronées à **willbrid**, c'est pourquoi il ajoute des commentaires dans la section de discussion du MR expliquant son point de vue. Il continue d'en parler jusqu'à ce qu'ils parviennent tous à un accord sur la façon dont il doit procéder. **willbrid** ajoute un nouveau commit avec les correctifs convenus.

14- Une fois de plus, **willbrid** regarde dans le MR pour voir les résultats des tests et analyses automatisés par rapport à son dernier commit. L'une des analyses de sécurité souligne une vulnérabilité qu'il a involontairement introduite. Il ajoute rapidement un nouveau commit qui corrige la vulnérabilité. Les analyses s'exécutent à nouveau sur ce code fixe, et cette fois tout se passe bien.

15- **willbrid** reçoit l'avis favorable d'**Alice** et de **Bob** sur tout le code qu'il a engagé jusqu'à présent, son travail est donc terminé. Il supprime l'étiquette Back-end, ajoute une étiquette Front-end et réattribue le problème à un ingénieur front-end nommé **George**.

16- **George** écrit du code frontend et ajoute quelques commits à la même branche de la fonctionnalité que **willbrid** utilisait. Chaque commit déclenche une nouvelle série de tests et d'analyses automatisés, et chacun est examiné par Alice et Bob.

17- **George** se rend compte que le travail prend du retard, il ajoute donc une étiquette **à risque** au problème original. Le responsable du développement répond à cela en affectant un autre développeur frontend nommé **Helen** pour aider **George**.

18- Le cycle de validation, puis de révision, puis d'inspection, de test et d'analyse automatisés se poursuit pendant quelques tours supplémentaires jusqu'à ce que **George** et **Helen** terminent la fonctionnalité. Ils suppriment l’étiquette **à risque**. **Alice** et **Bob** sont satisfaits du code et ajoutent tous deux des emojis de pouce levé à la discussion.

19- **George** supprime **Draft : du titre du problème**, indiquant qu'il considère le code prêt à être fusionné.

20- **George** mentionne les équipes de sécurité et d'assurance qualité dans la discussion du MR afin qu'elles puissent l'approuver. En attendant, les règles d’approbation du projet Mobile empêchent la fusion du MR.

21- Un membre de l'équipe de sécurité et deux membres de l'équipe d'assurance qualité marquent le MR comme **« approuvé »**. Cela réactive le bouton de fusion du MR. Avec une grande joie et un sentiment d'accomplissement, **George** supprime les étiquettes **Front-end** et **Status::In Progress** et clique sur le bouton de fusion du MR.

22- Toute l'équipe sort dans un pub pour faire la fête et mange une quantité inconfortable de pizza.