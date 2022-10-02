# Livraison continue et déploiement continu

## Qu'est-ce que la livraison continue ?

- Livraison continue (CD) : la pratique consistant à maintenir en 
permanence le code dans un état déployable

- Que la décision soit prise ou non de déployer, le code est toujours dans un état pouvant être déployé.

- Certains utilisent indifféremment les termes livraison continue et déploiement continu, ou utilisent simplement l'abréviation CD.

![cdelivery](./images/cdelivery.png)

## Qu'est-ce que le déploiement continu ?

- Déploiement continu : la pratique consistant à déployer fréquemment de petites modifications de code en production

- La livraison continue maintient le code dans un état déployable. Le déploiement continu effectue en fait le déploiement fréquemment.

- Certaines entreprises qui effectuent un déploiement continu effectuent un déploiement en production plusieurs fois par jour

-  Il n'y a pas de norme quant à la fréquence de déploiement, mais en général, plus nous déployons souvent, mieux c'est !

- Avec le déploiement continu, les déploiements en production sont routiniers et courants. Ils ne sont pas un grand événement effrayant.

![cdeployment](./images/cdeployment.png)

## À quoi ressemblent la livraison continue et le déploiement continu ?

- Chaque version du code passe par une série d'étapes telles que la construction automatisée, les tests automatisés et les tests d'acceptation manuels. Le résultat de ce processus est un artefact ou un package pouvant être déployé.

- Lorsque la décision est prise de déployer, le déploiement est automatisé. L'aspect du déploiement automatisé dépend de l'architecture, mais quelle que soit l'architecture, le déploiement est automatisé.

- Si un déploiement pose un problème, il est annulé rapidement et de manière fiable à l'aide d'un processus automatisé (espérons-le avant même qu'un client ne remarque le problème !)

- Les restaurations ne sont pas un gros problème car les développeurs peuvent redéployer une version fixe dès qu'ils en ont une disponible.

- Personne ne saisit son bureau par peur lors d'un déploiement, même si le déploiement cause un problème.

## Pourquoi faire de la livraison continue et du déploiement continu ?

- Mise sur le marché plus rapide - Mettre les fonctionnalités entre les mains des clients plus rapidement plutôt que d'attendre un long processus de déploiement qui ne se produit pas souvent.

- Moins de problèmes causés par le processus de déploiement – Étant donné que le processus de déploiement est fréquemment utilisé, tout problème avec le processus est plus facilement découvert.

- Risque réduit – Plus il y a de changements déployés en même temps, plus le risque est élevé. Les déploiements fréquents de quelques modifications seulement sont moins risqués.

- Rollbacks fiables - Une automatisation robuste signifie que les rollbacks sont un moyen fiable d'assurer la stabilité pour les clients, et les rollbacks ne nuisent pas aux développeurs car ils peuvent avancer avec un correctif dès qu'ils en ont un.

- Déploiements sans peur – Une automatisation robuste et la possibilité de revenir rapidement en arrière signifient que les déploiements sont des événements courants et quotidiens plutôt que de grands événements effrayants.