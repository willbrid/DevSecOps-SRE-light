# Deployments Rolling Updates et Rollbacks

Ce contenu explique comment gérer les mises à jour de déploiements Kubernetes : **rolling updates**, **rollbacks** et gestion des **révisions**.

### Rollouts et révisions (concept clé)

- La création d'un déploiement déclenche un **rollout** et établit la **révision 1**.
- Une mise à jour (ex. changement de version d'image) déclenche un **nouveau rollout** et crée la **révision 2**.
- L'**historique des révisions** permet de suivre les changements et de revenir à une version antérieure.

Surveiller et consulter les rollouts :

```bash
kubectl rollout status deployment/myapp-deployment   # état en cours
kubectl rollout history deployment/myapp-deployment  # historique des révisions
```

### Les deux stratégies de déploiement

| Stratégie | Fonctionnement | Downtime |
|-----------|---------------|----------|
| **Recreate** | Termine **tous** les anciens pods avant de créer les nouveaux | ❌ Provoque une **interruption** (downtime) |
| **Rolling Update** | Remplace les pods **progressivement** (termine les anciens tout en démarrant les nouveaux) | ✅ **Disponibilité continue** |

> Le **Rolling Update est la stratégie par défaut** de Kubernetes, pour minimiser les interruptions.

### Mettre à jour un Deployment (plusieurs méthodes)

#### Méthode 1 : Modifier le fichier puis appliquer

Modifier le fichier (ex. `image: nginx:1.7.1`), puis :

```bash
kubectl apply -f deployment-definition.yml
```

→ déclenche un nouveau rollout et une nouvelle révision.

#### Méthode 2 : Changer l'image directement

```bash
kubectl set image deployment/myapp-deployment nginx-container=nginx:1.9.1
```

> **Attention** : `kubectl set image` modifie la config **live** ; le changement **n'est pas répercuté** dans le fichier de définition. À utiliser avec prudence si l'on veut garder la cohérence via les fichiers.

### Examiner les détails d'un Deployment

```bash
kubectl describe deployment myapp-deployment
```

Affiche notamment le **StrategyType** :
- **Recreate** : l'ancien ReplicaSet est réduit à 0 **avant** que le nouveau soit augmenté.
- **RollingUpdate** : transition **progressive** (l'ancien et le nouveau ReplicaSet coexistent temporairement, ex. `4 available | 2 unavailable`).

### Fonctionnement en interne

- À la création, Kubernetes crée un **ReplicaSet** qui génère les pods.
- Lors d'une mise à jour, un **nouveau ReplicaSet** est créé pour les conteneurs mis à jour, tandis que les pods de l'ancien ReplicaSet sont **progressivement terminés** (rolling update).
- On peut le vérifier avec :

```bash
kubectl get replicasets
```

Avant : l'ancien ReplicaSet contient les pods actifs. Après : le nouveau ReplicaSet affiche les pods mis à jour.

### Effectuer un Rollback

En cas de problème avec une nouvelle version :

```bash
kubectl rollout undo deployment/myapp-deployment
```

Résultat : `deployment "myapp-deployment" rolled back`.
Le processus **inverse les comptes** de pods entre l'ancien et le nouveau ReplicaSet.

Effectuer un rollback version une révision précise via son

```bash
kubectl rollout undo deployment/myapp-deployment --to-revision=<revision number>
```

### Récapitulatif des commandes essentielles

| Commande | Description |
|----------|-------------|
| `kubectl create -f deployment-definition.yml` | Créer un déploiement |
| `kubectl get deployments` | Lister les déploiements |
| `kubectl apply -f deployment-definition.yml` | Mettre à jour via le fichier |
| `kubectl set image deployment/myapp-deployment nginx-container=nginx:1.9.1` | Changer l'image (config live) |
| `kubectl rollout status deployment/myapp-deployment` | Suivre l'état du rollout |
| `kubectl rollout history deployment/myapp-deployment` | Voir l'historique des révisions |
| `kubectl rollout undo deployment/myapp-deployment` | Revenir à la révision précédente |

### À retenir

- Chaque mise à jour crée une **nouvelle révision**, permettant un **rollback** facile.
- Deux stratégies : **Recreate** (avec downtime) et **Rolling Update** (sans downtime, par défaut).
- En interne, la mise à jour repose sur la création d'un **nouveau ReplicaSet** et la terminaison progressive de l'ancien.
- `kubectl apply` (via fichier) vs `kubectl set image` (config live, non répercuté dans le fichier).

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
