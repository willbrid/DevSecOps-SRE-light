# Analyse des domaines d'activité

Nous apprendrons comment les entreprises fonctionnent : pourquoi elles existent, quels objectifs elles poursuivent et leurs stratégies pour atteindre leurs objectifs.

## Qu'est-ce qu'un domaine d'entreprise ?

Un domaine d'activité définit le domaine d'activité principal d'une entreprise. D'une manière générale, c'est le service que l'entreprise fournit à ses clients. Par exemple :
- **FedEx** assure la livraison par courrier.
- **Starbucks** est surtout connu pour son café.
- **Walmart** est l'un des établissements de vente au détail les plus reconnus.

Une entreprise peut opérer dans plusieurs domaines d'activité. Par exemple, **Amazon** fournit à la fois des services de vente au détail et de cloud computing. **Uber** est une entreprise de covoiturage qui propose également des services de livraison de nourriture et de partage de vélos.
<br>
Il est important de noter que les entreprises peuvent souvent changer de domaine d'activité.

## Qu'est-ce qu'un sous-domaine ?

Pour atteindre les objectifs et les cibles de son domaine d'activité, une entreprise doit opérer dans plusieurs sous-domaines. Un sous-domaine est un domaine d'activité commerciale à grain fin. L’ensemble des sous-domaines d’une entreprise forme son domaine métier : le service qu’elle rend à ses clients. La mise en œuvre d'un seul sous-domaine n'est pas suffisante pour qu'une entreprise réussisse ; ce n'est qu'un élément constitutif du système global. Les sous-domaines doivent interagir les uns avec les autres pour atteindre les objectifs de l'entreprise dans son domaine d'activité.

#### Types de sous-domaines

La conception pilotée par domaine distingue trois types de sous-domaines : principal (core), générique et support. Voyons en quoi ils diffèrent du point de vue de la stratégie de l'entreprise.

- **Sous-domaines principaux**

Un sous-domaine principal est ce qu'une entreprise fait différemment de ses concurrents. Cela peut impliquer d'inventer de nouveaux produits ou services ou de réduire les coûts en optimisant les processus existants.
<br>
Prenons Uber comme exemple. Au départ, l'entreprise proposait un nouveau moyen de transport : le covoiturage. Au fur et à mesure que ses concurrents rattrapaient leur retard, Uber a trouvé des moyens d'optimiser et de faire évoluer son cœur de métier : par exemple, réduire les coûts en faisant correspondre les passagers allant dans la même direction.
<br>
Pour conserver un avantage concurrentiel, les sous-domaines principaux impliquent des **inventions**, des **optimisations intelligentes**, un **savoir-faire commercial** ou d'autres **propriétés intellectuelles**.
<br>
**Complexité** : un sous-domaine principal simple à mettre en œuvre ne peut fournir qu'un avantage concurrentiel de courte durée. Par conséquent, les sous-domaines principaux sont naturellement **complexes**.
<br>
**Sources d'avantage concurrentiel** : il est important de noter que les sous-domaines principaux ne sont pas nécessairement techniques. Tous les problèmes commerciaux ne sont pas résolus par des algorithmes ou d'autres solutions techniques. L'avantage concurrentiel d'une entreprise peut provenir de plusieurs sources.

- **Sous-domaines génériques**

Les sous-domaines génériques sont des activités commerciales que toutes les entreprises exercent de la même manière. Comme les sous-domaines principaux, les sous-domaines génériques sont généralement complexes et difficiles à mettre en œuvre. Cependant, les sous-domaines génériques n'offrent aucun avantage concurrentiel à l'entreprise. Il n'y a pas besoin d'innovation ou d'optimisation ici : les implémentations éprouvées sont largement disponibles et toutes les entreprises les utilisent.
<br>
Par exemple, la plupart des systèmes doivent authentifier et autoriser leurs utilisateurs. Au lieu d'inventer un mécanisme d'authentification propriétaire, il est plus logique d'utiliser une solution existante. Une telle solution est susceptible d'être plus fiable et sécurisée puisqu'elle a déjà été testée par de nombreuses autres entreprises ayant les mêmes besoins.

- **Sous-domaines support**

Comme son nom l'indique, les sous-domaines support soutiennent les activités de l'entreprise. Cependant, contrairement aux sous-domaines principaux, les sous-domaines support ne fournissent aucun avantage concurrentiel. <br>
Par exemple, considérons une société de publicité en ligne dont les principaux sous-domaines incluent la mise en correspondance des publicités avec les visiteurs, l'optimisation de l'efficacité des publicités et la minimisation du coût de l'espace publicitaire. Cependant, pour réussir dans ces domaines, l'entreprise doit cataloguer ses matériaux créatifs. La façon dont l'entreprise stocke et indexe ses supports créatifs physiques, tels que les bannières et les pages de destination, n'a pas d'impact sur ses bénéfices. Il n'y a rien à inventer ou à optimiser dans ce domaine. D'autre part, le catalogue créatif est essentiel pour mettre en œuvre les systèmes de gestion et de diffusion publicitaires de l'entreprise. Cela fait de la solution de catalogage de contenu l'un des sous-domaines de support de l'entreprise.

#### Comparaison des sous-domaines

Maintenant que nous avons une meilleure compréhension des trois types de sous-domaines commerciaux, explorons leurs différences sous des angles supplémentaires et voyons comment ils affectent les **décisions stratégiques** de conception de logiciels.

- **Avantage compétitif**

--- Seuls les sous-domaines principaux offrent un avantage concurrentiel à une entreprise. Les sous-domaines principaux sont la stratégie de l'entreprise pour se différencier de ses concurrents. <br>
--- Les sous-domaines génériques, par définition, ne peuvent être source d'aucun avantage concurrentiel. Ce sont des solutions génériques, les mêmes solutions utilisées par l'entreprise et ses concurrents. <br>
--- Les sous-domaines de support ont de faibles barrières à l'entrée et ne peuvent pas non plus fournir un avantage concurrentiel. Habituellement, une entreprise ne verrait pas d'inconvénient à ce que ses concurrents copient ses sous-domaines de support - cela n'affectera pas sa compétitivité dans l'industrie. Au contraire, stratégiquement, l'entreprise préférerait que ses sous-domaines de support soient des solutions génériques et prêtes à l'emploi, éliminant ainsi le besoin de concevoir et de construire leur mise en œuvre.

- **Complexité**

D'un point de vue plus technique, il est important d'identifier les sous-domaines de l'organisation, car les différents types de sous-domaines ont différents niveaux de complexité. Lors de la conception de logiciels, nous devons choisir des outils et des techniques qui s'adaptent à la complexité des besoins de l'entreprise. Par conséquent, l'identification des sous-domaines est essentielle pour concevoir une solution logicielle solide.
<br>
--- Les sous-domaines support sont simples. Ce sont des opérations ETL de base et des interfaces CRUD, et la logique métier est évidente. Souvent, cela ne va pas au-delà de la validation des entrées ou de la conversion des données d'une structure à une autre. <br>
--- Les sous-domaines génériques sont beaucoup plus compliqués. Il devrait y avoir une bonne raison pour laquelle d'autres ont déjà investi du temps et des efforts dans la résolution de ces problèmes. Ces solutions ne sont ni simples ni triviales. Considérons, par exemple, les algorithmes de chiffrement ou les mécanismes d'authentification. <br>
--- Les sous-domaines principaux sont complexes. Ils doivent être aussi difficiles à copier que possible pour les concurrents - la rentabilité de l'entreprise en dépend. C'est pourquoi, stratégiquement, les entreprises cherchent à résoudre des problèmes complexes en tant que sous-domaines principaux.
<br><br>
Parfois, il peut être difficile de différencier les sous-domaines de principaux des sous-domaines support. La complexité est un principe **directeur** utile. Demandons si le sous-domaine en question peut être transformé en activité secondaire. Est-ce que quelqu'un le paierait tout seul ? Si tel est le cas, il s'agit d'un sous-domaine principal. Un raisonnement similaire s'applique pour différencier les sous-domaines de support et génériques : serait-il plus simple et moins coûteux de pirater votre propre implémentation, plutôt que d'en intégrer une externe ? Si tel est le cas, il s'agit d'un sous-domaine de support.