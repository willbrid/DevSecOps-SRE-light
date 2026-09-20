# Déploiements de type « Push » ou « Pull »

Le **déploiement (deployment)** est le processus de mise à disposition de nouvelles versions d'une application aux utilisateurs. Il implique typiquement : **construire** l'application, **exécuter les tests**, et **déployer** en production. Ce contenu compare deux méthodes courantes dans Kubernetes : les déploiements **en mode push (push-based)** et **en mode pull (pull-based)**.

### Déploiement en mode push (Push-Based Deployment)

Dans le modèle **push-based**, un **système externe** — généralement partie d'un pipeline de **continuous delivery** — **initie** le déploiement.

**Fonctionnement** :
- Un déclencheur (ex. un **commit réussi** sur un dépôt Git ou un **pipeline CI** antérieur) lance le processus ;
- Ce système externe nécessite un **accès direct en lecture-écriture (read-write)** au cluster Kubernetes, pour y **pousser** les changements.

**Point de sécurité crucial** : le push-based oblige à **exposer les identifiants (credentials) du cluster à l'extérieur** de celui-ci. Il faut les **stocker de manière sécurisée** dans le système CI/CD pour prévenir tout accès non autorisé.

**Bonnes pratiques de sécurité** :
- **Chiffrer** les credentials pour les protéger de l'exposition ;
- Appliquer des **contrôles d'accès stricts** (limiter qui peut y accéder) ;
- **Rotationner régulièrement** les credentials pour minimiser les risques.

### Déploiement en mode pull (Pull-Based Deployment)

Dans le modèle **pull-based**, les changements sont appliqués **depuis l'intérieur** du cluster Kubernetes.

**Fonctionnement** :
- Un **operator** tournant **dans le cluster** surveille en continu les dépôts Git et registres Docker associés ;
- Quand l'operator **détecte un changement**, il **synchronise** l'état du cluster en conséquence.

> **Avantage majeur : la sécurité renforcée**. Avec le pull-based, **aucun client externe** ne détient d'accès administratif au cluster → cela **réduit l'exposition** des credentials sensibles et **minimise la surface d'attaque (attack surface)**.

### Push vs Pull (distinction clé)

| Aspect | **Push-Based** | **Pull-Based** |
|--------|----------------|----------------|
| Initiateur | Système **externe** (pipeline CI/CD) | **Operator interne** au cluster |
| Accès au cluster | Le système externe a un accès **read-write** | Aucun accès externe ; tout reste **dans le cluster** |
| Credentials | **Exposés à l'extérieur** (à sécuriser) | **Non exposés** à l'extérieur |
| Sécurité | Nécessite une gestion rigoureuse des secrets | **Plus sécurisé** (surface d'attaque réduite) |
| Déclencheur | Commit Git / pipeline CI | Détection de changement par l'operator |

### Comment choisir ?

Le **push-based** offre un processus **rationalisé** initié par des systèmes externes, mais exige une **gestion soigneuse** des credentials sensibles. À l'inverse, le **pull-based** confine tous les changements **dans le cluster**, offrant une alternative **plus sécurisée**. Choisir la stratégie qui correspond aux **exigences de sécurité** et aux **pratiques opérationnelles** de l'organisation.

### À retenir

- Le **déploiement** = build → test → mise en production ; deux modèles dans Kubernetes : **push** et **pull**.
- **Push-based** : un système **externe** (CI/CD) **pousse** les changements → nécessite un accès **read-write** au cluster et l'**exposition des credentials** (à chiffrer, contrôler, rotationner).
- **Pull-based** : un **operator interne** (ex. Flux, Argo CD) **surveille** Git/registres et **tire (pull)** les changements → **plus sécurisé** (pas d'accès externe, surface d'attaque réduite).
- Le **pull-based** est l'approche privilégiée par **GitOps** pour sa sécurité.
- Le choix dépend des **besoins de sécurité** et des **pratiques opérationnelles**.
