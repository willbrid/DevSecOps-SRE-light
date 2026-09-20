# CI/CD avec GitOps

GitOps est devenu une méthodologie de premier plan pour gérer l'infrastructure et les applications Kubernetes en utilisant **Git comme source unique de vérité**. Cette approche s'appuie sur la **configuration déclarative** et la **livraison automatisée** pour des déploiements **rapides, prévisibles et sûrs**.

### Les deux dépôts Git

Un workflow GitOps typique emploie **deux dépôts Git** :

| Dépôt | Contenu |
|-------|---------|
| **Dépôt applicatif (app code)** | Le **code de l'application**, les définitions de ressources, les données de configuration et les **images de conteneurs** |
| **Dépôt des manifests** | Les **manifests Kubernetes** (fichiers YAML) décrivant l'**état désiré** du cluster : Deployments, Services, Ingresses, ConfigMaps, Secrets |

Une fois les dépôts en place, un **operator** comme **ArgoCD** est déployé **dans le cluster**. ArgoCD **surveille en continu** le dépôt des manifests et **réconcilie** l'état réel du cluster avec l'état désiré (déploiement auto des mises à jour, gestion du cycle de vie des ressources).

### Le workflow CI (Continuous Integration)

Scénario typique :
1. Un développeur **commit** de nouveaux changements dans le **dépôt du code applicatif** ;
2. Un **pipeline CI** est déclenché, exécutant plusieurs étapes :
   - lancer les **tests unitaires** ;
   - **construire les artefacts** ;
   - **construire l'image Docker** ;
   - **pousser l'image** vers un **container registry**.

### Le workflow CD (Continuous Deployment) via GitOps

Après que la nouvelle image est disponible dans le registry :
1. Le **dépôt des manifests** est mis à jour avec la **nouvelle version d'image** (les YAML référençant l'image sont modifiés) ;
2. Les changements sont **commités** ;
3. Une **pull request (PR)** est créée pour merger ces mises à jour dans la branche **master** ;
4. Après **revue et approbation** (par un project manager ou architecte), la PR est **mergée** ;
5. Une fois mergée, **ArgoCD détecte automatiquement** les changements et **synchronise** l'état du cluster pour correspondre à la config désirée → déploie la nouvelle version.

→ Ce processus assure un déploiement **sûr et contrôlé**.

### Le mécanisme de Rollback

Au-delà des déploiements automatisés, GitOps avec ArgoCD offre un **mécanisme de rollback fiable**. En cas de problème, on peut revenir à une version stable antérieure :
```bash
argocd app history
argocd app rollback <APP_NAME> <REVISION>
```

### Schéma du pipeline complet (CI + CD)

```
Développeur → commit (dépôt code app)
   │
   ▼
PIPELINE CI : tests unitaires → build artefacts → build image Docker → push vers registry
   │
   ▼
Mise à jour du dépôt manifests (nouvelle version d'image) → commit → PR → revue/approbation → merge
   │
   ▼
ArgoCD (dans le cluster) détecte → synchronise → déploie la nouvelle version
```

### À retenir

- Le CI/CD avec GitOps utilise **deux dépôts Git** : un pour le **code applicatif** (+ images), un pour les **manifests Kubernetes** (état désiré).
- **CI** : commit → tests unitaires → build artefacts → build image Docker → push vers le **registry**.
- **CD** : mise à jour du dépôt manifests → **PR** → revue/approbation → merge → **ArgoCD** détecte et **synchronise/déploie** automatiquement.
- **ArgoCD** est un **operator** déployé dans le cluster qui **réconcilie** en continu l'état réel avec l'état désiré (modèle **pull-based**).
- **Rollback** facile via `argocd app history` et `argocd app rollback <APP_NAME> <REVISION>`.

### Liens utiles

- Documentation officielle ArgoCD : https://argo-cd.readthedocs.io/en/stable/
- ArgoCD Image Updater : https://argocd-image-updater.readthedocs.io/
- ArgoCD – Multiple Sources : https://argo-cd.readthedocs.io/en/stable/user-guide/multiple_sources/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
