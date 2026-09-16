# Kubernetes Enhancement Proposals

### Introduction : le besoin d'un processus standard

À mesure que Kubernetes gagne en popularité, les gens ont plein d'**idées différentes** pour l'améliorer. Il faut donc une **procédure standard** pour :
- **recueillir** les idées ;
- les **documenter** ;
- **identifier pourquoi** elles sont nécessaires ;
- en **discuter** et les **implémenter** ;
- s'assurer qu'elles passent par les différents **release cycles** : **alpha, beta, et enfin GA (Generally Available)**.

C'est là qu'interviennent les **Kubernetes Enhancement Proposals (KEPs)**.

**Exemple concret** : un changement majeur récent où les **service account tokens n'étaient plus créés automatiquement** — à la place, il fallait les créer manuellement. Pour connaître la **motivation** derrière ce changement, on consulte le **KEP associé**.

Si vous avez une idée de nouvelle feature ou un moyen d'améliorer la sécurité, vous écrivez un **KEP** pour expliquer votre idée, et d'autres personnes peuvent alors le lire et donner leurs suggestions/feedback.

### Pourquoi les KEPs et pas les GitHub issues ?

Le processus KEP permet de suivre facilement les développements et améliorations, tout en permettant à Kubernetes de **rester à jour** face aux évolutions de l'industrie. Les KEPs sont un moyen pour la communauté de **partager leurs idées** et de **travailler ensemble**.

Kubernetes utilise déjà les **GitHub issues** (pour signaler des bugs ou créer des feature requests). Alors **pourquoi des KEPs** ?

1. **Moyen standard** : les KEPs offrent une manière standardisée de **proposer et discuter** des idées → facilite la compréhension et la participation de tous.
2. **Discussions structurées** : les KEPs permettent des discussions plus **détaillées et structurées** → la communauté examine et évalue plus soigneusement les changements proposés.
3. **Approbation/rejet par les SIG** : les GitHub issues ne suffisent pas aux SIG pour signaler leur **approbation ou rejet** (n'importe qui peut ouvrir une issue à tout moment).
4. **Gestion multi-releases** : gérer les changements sur plusieurs releases via les issues est **laborieux** (labéliser, définir un milestone pour chacune, tout mettre à jour à chaque release) → nombre croissant d'issues à gérer.
5. **Recherche et navigation** : la recherche textuelle dans une issue est difficile, et la **hiérarchie plate** des issues limite navigation et catégorisation.

### La convention de nommage et la structure d'un KEP

Désormais, tous les KEPs suivent une **convention de nommage standard** :
- Un **numéro à quatre chiffres** suivi d'un **titre court et descriptif** ;
- Chaque KEP doit être **correctement documenté**.

Un KEP doit contenir :
- un **summary** (résumé) ;
- un ensemble de **goals** (objectifs) et **non-goals** (ce qui n'est PAS visé), définissant clairement la **motivation** ;
- une **user story** ;
- les **risques et mitigations** ;
- comme toute feature request : des **test plans** et des **graduation criteria** (critères de progression).

### Les SIG (Special Interest Groups)

Désormais, les KEPs sont **regroupés par SIG**. Un **SIG** est un **Special Interest Group** pour Kubernetes : des groupes qui s'occupent des différents aspects de l'écosystème.

Exemples de SIG :
- SIG **applications** ;
- SIG **cluster lifecycle** ;
- SIG **data management** ;
- SIG **networking** ;
- SIG **storage** ;
- SIG **security**.

**Fonctionnement** : chaque SIG a son **propre répertoire (directory)** où sont stockés les KEPs liés à son domaine d'expertise. Les membres du SIG **votent** pour accepter ou non une proposition. Si acceptée, le changement est implémenté dans les futures releases de Kubernetes. Ce processus garantit que les changements proposés sont **soigneusement examinés** avant d'être acceptés.

### Exemples de KEPs (illustrations concrètes)

#### KEP « dry run »

Ce KEP, créé il y a plus de 2 ans, détaille le besoin de la fonctionnalité de **dry run**, très bénéfique : elle permet d'**envoyer des requêtes aux endpoints** et de voir ce qui **se serait passé sans que cela ne se produise réellement**. Cette proposal inclut un **test plan**, les **graduation criteria**, et détaille quels **verbs / API endpoints** seront concernés, la manière dont ce sera implémenté, et des **exemples d'utilisation** avec `kubectl`.

#### KEP 1205 – Bound Service Account Tokens (exemple sécurité)

Proposé pour atténuer certains **problèmes de sécurité** liés à la façon dont les tokens étaient provisionnés.

**Le problème avec les anciens JWT (JSON Web Tokens)** :
- Les JWT, c'était un peu le « **Far West de l'authentification** » : dès que quelqu'un met la main dessus, il peut se faire passer pour n'importe qui ;
- Les JWT n'étaient **pas liés à une audience spécifique** ;
- La façon dont les service account tokens étaient **stockés et délivrés** revenait à « laisser une cible géante dans le dos du control plane » pour les attaquants ;
- Un token JWT volé = un **accès gratuit à vie** à tout ce qu'il protégeait, à moins de **rotate les keys manuellement** (ce que personne ne fait car c'est une galère) ;
- Utiliser des JWT ainsi nécessitait de créer une **tonne de Secrets** → **pas scalable**.

**La solution** : ce KEP a introduit une **API TokenRequest** qui génère des tokens **à la demande**, **liés à une audience** avec une **date d'expiration**. Le KEP propose l'implémentation avec des exemples de code, des **test plans** et des **graduation criteria**.

**Progression vers la GA** de l'API TokenRequest :
- **Alpha** : version **1.10** ;
- **Beta** : version **1.12** ;
- **GA** : version **1.20**.

### Le cycle de vie d'un KEP

Chaque KEP suit le cycle de vie suivant :

| État | Description |
|------|-------------|
| **provisional** | Le KEP est **proposé** et en cours de **définition** |
| **implementable** | Le SIG a accepté que ce travail doit être fait, et les **approvers** ont approuvé le KEP pour l'implémentation |
| **implemented** | Le KEP est **implémenté** |
| **deferred** | Le KEP n'est **pas en cours de traitement** (reporté) |
| **rejected** | Les approvers ont décidé de **ne pas donner suite** au KEP |
| **withdrawn** | L'**auteur retire** le KEP |
| **replaced** | Le KEP est **remplacé** par un nouveau KEP |

**Flux typique** : `provisional` → `implementable` → `implemented` (ou bifurcation vers `deferred`, `rejected`, `withdrawn`, `replaced`).

### À retenir

- Un **KEP (Kubernetes Enhancement Proposal)** = processus **standard** pour proposer, documenter, discuter et implémenter une amélioration, à travers les cycles **alpha → beta → GA**.
- **Pourquoi pas les GitHub issues** : les KEPs offrent standardisation, discussions **structurées**, approbation par les **SIG**, meilleure gestion multi-releases et navigation.
- **Structure d'un KEP** : numéro à 4 chiffres + titre, **summary**, **goals/non-goals**, **user story**, **risques/mitigations**, **test plans**, **graduation criteria**.
- Les KEPs sont regroupés par **SIG** (Special Interest Group : applications, networking, storage, security…), qui **votent** et gèrent leur propre répertoire.
- **Exemples** : KEP dry run, KEP **1205 Bound Service Account Tokens** (API **TokenRequest** : tokens à durée limitée et liés à une audience — alpha 1.10, beta 1.12, GA 1.20).
- **Cycle de vie** : `provisional` → `implementable` → `implemented` ; autres états : `deferred`, `rejected`, `withdrawn`, `replaced`.

### Liens utiles

- Dépôt officiel des KEPs (GitHub) : https://github.com/kubernetes/enhancements
- KEP 1205 – Bound Service Account Tokens : https://github.com/kubernetes/enhancements/tree/master/keps/sig-auth/1205-bound-service-account-tokens
- Liste des SIG Kubernetes : https://github.com/kubernetes/community/blob/master/sig-list.md
