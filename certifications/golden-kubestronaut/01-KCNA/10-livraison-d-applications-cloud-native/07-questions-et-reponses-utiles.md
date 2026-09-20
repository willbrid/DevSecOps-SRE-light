# Questions et réponses utiles

Voici quelques points clés à retenir, organisés par thème.

### GitOps : principes et fonctionnement

- **Comment GitOps garantit que les changements des objets Kubernetes sont déployés dans l'environnement live** : en utilisant un **operator/outil GitOps** comme **Flux** ou **Argo CD**.
- **Ce qui se passe quand des changements approuvés sont poussés dans Git** : les changements sont **automatiquement appliqués** au système.
- **Principal avantage d'utiliser Git comme source unique de vérité** (pour l'infrastructure ET les applications) : il **suit les changements** de l'infrastructure et des ressources applicatives **sous forme de code (as code)**.
- **Avantage clé de GitOps pour gérer les changements d'infrastructure** : une **efficacité et une précision accrues** (greater efficiency and accuracy).

### Déploiement pull-based

- **Comment une approche pull-based supporte un modèle multi-tenant** : en **distribuant les outils à travers des namespaces** ayant des **droits d'accès distincts** et des **dépôts Git correspondants**.
- **Inconvénient potentiel de l'approche pull-based** : être **lié à des outils spécifiques** et nécessiter l'**installation/configuration d'un agent** pour chaque cluster.

### CI/CD et outils

- **Principal bénéfice du Continuous Deployment (CD)** pour livrer de nouvelles fonctionnalités : il **automatise le processus de déploiement** vers les environnements de production.
- **Ce sur quoi FluxCD se concentre principalement** : le **continuous delivery** vers un cluster Kubernetes.

### Gouvernance

- **Organisation servant d'organe de gouvernance du projet Kubernetes** : la **CNCF** (Cloud Native Computing Foundation).
