# Définition GitOps

**GitOps** est une approche innovante de gestion des environnements Kubernetes utilisant les **dépôts Git comme source unique de vérité (single source of truth)** pour l'**infrastructure as code**. Cette méthode :
- **suit et versionne** chaque changement ;
- **automatise la synchronisation** entre le dépôt de code et les clusters Kubernetes live.

### Le problème sans GitOps (exemple concret)

**Scénario** : une équipe gère un site e-commerce avec des objets Kubernetes (Deployments, Services, ConfigMaps).

Un jour :
- Un membre modifie **directement dans l'environnement live** le ConfigMap des **couleurs de branding** (pour une campagne marketing), sans coordination ;
- Simultanément, un autre membre met à jour le Deployment du service **Checkout** vers une nouvelle version.

**Résultat : un conflit** → les couleurs de branding du checkout ne correspondent plus au design du site, le service mis à jour peine à fonctionner avec les anciens réglages. Les clients rencontrent des problèmes et l'équipe perd du temps à déboguer.

### La solution GitOps

Avec GitOps, les membres gèrent les objets Kubernetes en **committant les changements dans un dépôt Git central**. Quand un changement est commité, un **outil GitOps** (comme **Flux** ou **Argo CD**) **récupère automatiquement (pull)** les mises à jour et les déploie dans l'environnement live.

**Le workflow GitOps** :
1. Pour modifier les couleurs, on modifie le ConfigMap **dans le dépôt Git** et on crée une **pull request (PR)** ;
2. La PR **notifie l'équipe pour approbation** avant le merge ;
3. Une fois **approuvée**, l'outil GitOps **synchronise** les changements vers le cluster.

Dans l'exemple : le membre modifiant le checkout crée aussi une PR, mais l'équipe, **voyant le changement de branding**, décide de **retarder le merge** du checkout jusqu'à la fin de la campagne → cohérence préservée, perturbation client minimisée.

> GitOps exploite Git pour garantir **reproductibilité, traçabilité et automatisation**.

### Comment GitOps fonctionne

GitOps traite le **dépôt Git comme la source de vérité faisant autorité** :
- Tous les changements étant **versionnés dans Git**, il est simple de **revoir, suivre et annuler** les modifications ;
- Les outils GitOps **surveillent toute divergence** entre l'état défini dans Git et l'état réel du cluster ;
- En cas de **divergence (discrepancy)**, les **reconcilers** Kubernetes peuvent **automatiquement mettre à jour ou rollback** l'état du cluster selon les spécifications définies.

→ En automatisant les mises à jour via le **continuous delivery**, GitOps permet des déploiements **efficaces et précis**.

### Les principaux outils GitOps

#### Flux (Flux CD)

- Outil **Kubernetes-native** qui synchronise en continu l'état de Kubernetes avec les fichiers de config d'un dépôt Git ;
- Développé par **Weaveworks**, désormais **projet CNCF graduated** ;
- Utilise un **modèle pull-based**.
- **Limite** : ne surveille qu'**un seul dépôt Git** et ne déploie que vers **un seul cluster et namespace** → scalabilité restreinte dans les environnements complexes.

#### Argo CD

- Outil GitOps **déclaratif** conçu spécifiquement pour Kubernetes ;
- **Plus flexible que Flux** : une seule installation peut surveiller **plusieurs dépôts Git** et déployer vers **plusieurs namespaces** ;
- Développé initialement chez **Intuit**, désormais projet **CNCF** ;
- Application **Kubernetes-native** en **modèle pull-based**.

#### Jenkins X

- Se concentre sur GitOps pour Kubernetes en couvrant le **processus CI/CD complet** ;
- Combine plusieurs outils open-source ;
- Configuration et opération **plus complexes** que Flux et Argo CD.

### Comparaison Flux vs Argo CD

| Aspect | **Flux** | **Argo CD** |
|--------|----------|-------------|
| Dépôts surveillés | **Un seul** | **Plusieurs** |
| Déploiement | Un seul cluster/namespace | **Plusieurs namespaces** |
| Modèle | Pull-based | Pull-based |
| Origine | Weaveworks (CNCF graduated) | Intuit (CNCF) |
| Flexibilité | Limitée | **Supérieure** |


GitOps révolutionne la gestion d'infrastructure en utilisant **Git comme source de vérité centralisée et fiable**. Tous les changements sont **suivis, versionnés et audités**. En synchronisant et déployant automatiquement, GitOps aide à maintenir la **cohérence**, réduire les **erreurs manuelles** et rationaliser le **continuous delivery**.

### À retenir

- **GitOps** = gérer Kubernetes via un **dépôt Git comme source unique de vérité** (infrastructure as code), avec synchronisation automatique vers les clusters.
- **Workflow** : commit → **PR** → revue/approbation → l'outil GitOps **pull** et déploie ; évite les changements manuels non coordonnés (source de conflits).
- Les outils GitOps **surveillent les divergences** entre Git et le cluster, et **reconcilent** (mise à jour ou rollback automatique).
- **3 outils clés** : **Flux** (Kubernetes-native, 1 dépôt/1 namespace, CNCF graduated), **Argo CD** (déclaratif, multi-dépôts/multi-namespaces, plus flexible), **Jenkins X** (CI/CD complet, plus complexe).
- Bénéfices : **reproductibilité, traçabilité, automatisation, rollbacks faciles**, cohérence et audit.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Docker Hub : https://hub.docker.com/
