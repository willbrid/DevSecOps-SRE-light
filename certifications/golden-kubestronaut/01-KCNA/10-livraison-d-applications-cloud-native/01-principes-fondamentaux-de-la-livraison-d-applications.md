# Principes fondamentaux de la livraison d'applications

**Scénario** : vous travaillez pour une société développant une app de **mobile banking** populaire. Votre équipe crée une nouvelle fonctionnalité permettant de **transférer de l'argent** entre comptes en quelques taps. Cette amélioration est clé pour rester compétitif et offrir une expérience utilisateur supérieure.

### Les défis des processus de release traditionnels

Historiquement, la release de nouvelles fonctionnalités reposait sur le **build et test manuels** du code. Ce processus obsolète était :
- **chronophage (time-intensive)** ;
- **très sujet aux erreurs (error-prone)** ;
- source de **bugs lors du déploiement** malgré les tests → délais et frustration des utilisateurs ;
- caractérisé par de **longs délais (lead times)** et des **risques importants** pour la stabilité.

### Implémenter le CI/CD pour plus d'efficacité

Pour surmonter ces défis, l'équipe adopte une stratégie **CI/CD (Continuous Integration / Continuous Deployment)** afin d'**automatiser** le build, le test et le déploiement.

| Étape | Description |
|-------|-------------|
| **Continuous Integration (CI)** | Tout changement de code est automatiquement **buildé, testé et conteneurisé**. Cette automatisation détecte les problèmes **tôt** dans le cycle → réduit les bugs en aval. |
| **Continuous Deployment (CD)** | Rationalise les déploiements en poussant le code mis à jour **directement vers un cluster Kubernetes de production** via un **modèle push-based** → minimise les erreurs manuelles et accélère les releases. |

> Un pipeline CI/CD permet de **répondre rapidement** aux changements du marché tout en maintenant une **haute qualité et fiabilité** logicielle.

### Exploiter GitOps pour la gestion de l'infrastructure

Adopter les pratiques **GitOps** transforme l'infrastructure ET les processus de déploiement en **code versionné (version-controlled code)**. Cela permet de :
- **suivre chaque changement** ;
- réduire significativement les risques liés aux **déploiements manuels** et au **configuration drift** (dérive de configuration) ;
- **simplifier les rollbacks** : en cas de problème, revenir en arrière devient simple → minimise le downtime et assure la stabilité.

### Les pièges des changements manuels

Les modifications manuelles via la **CLI** peuvent entraîner :
- du **configuration drift** (dérive de configuration) ;
- un **risque accru d'erreur humaine** ;
- une **instabilité ou une panne** globale du système.

> **Point crucial** : s'appuyer sur des changements manuels **complique la reprise après sinistre (disaster recovery)**. En cas d'événement naturel, de panne technique ou d'erreur humaine, les configurations manuelles **entravent la restauration rapide**. Identifier et reproduire les changements manuels est **long et sujet aux erreurs**, retardant la restauration.

### Les bénéfices de l'approche GitOps

Une stratégie GitOps offre de nombreux avantages, surtout pour la **disaster recovery** et la gestion du système :
- Fournit une **source unique de vérité (single source of truth)** via **Git**, pour l'infrastructure ET les applications ;
- Permet un **suivi précis** de chaque changement appliqué ;
- Autorise un **rollback rapide** en cas de problème détecté ;
- Rationalise la **restauration** en revenant à une configuration **connue et stable**.

→ Cette approche **minimise les risques**, améliore l'**efficacité opérationnelle** et assure une **reprise plus rapide** face aux perturbations imprévues.

### À retenir

- Les **releases manuelles** traditionnelles sont **lentes, sujettes aux erreurs** et risquées.
- Le **CI/CD** automatise le cycle : **CI** (build + test + conteneurisation, détection précoce des bugs) et **CD** (déploiement automatique vers Kubernetes en **push-based**).
- **GitOps** transforme infrastructure et déploiements en **code versionné dans Git** → **source unique de vérité**, suivi des changements, **rollbacks rapides**.
- Les **changements manuels (CLI)** causent **configuration drift**, erreurs humaines et instabilité → compliquent la **disaster recovery**.
- Bénéfices GitOps : traçabilité, rollback rapide, restauration simplifiée vers un état stable → efficacité opérationnelle accrue.
