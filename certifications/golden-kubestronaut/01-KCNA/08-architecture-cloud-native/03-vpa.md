# VPA

Le **Vertical Pod Autoscaler (VPA)** ajuste **dynamiquement les allocations de ressources** (CPU et mémoire) des pods selon les demandes en temps réel. Contrairement au HPA (qui change le **nombre** de pods), le VPA change les **ressources** de chaque pod.

### Prérequis pour Pods

Dans la spec d'un pod, on définit **deux paramètres critiques** :

| Paramètre | Rôle |
|-----------|------|
| **Resource Requests** | **Garantit** qu'un container reçoit une quantité minimale de ressources. Kubernetes ne planifie le pod que sur un nœud pouvant fournir ces ressources (ex. 64Mi mémoire, 250m CPU). |
| **Resource Limits** | **Empêche** un container d'utiliser plus que la limite autorisée (ex. 128Mi mémoire, 500m CPU). |

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: 250m
  limits:
    memory: "128Mi"
    cpu: 500m
```

> **Le problème** : sous forte charge, l'allocation prédéfinie peut devenir **insuffisante**. Quand l'usage approche ou dépasse les limites, les pods peuvent devenir **instables** ou **crasher** par manque de ressources (resource starvation).

### Introduction au VPA

Le **VPA** ajuste CPU et mémoire selon la charge en temps réel : il **surveille en continu** l'utilisation et **recommande ou applique** des changements pour maintenir des performances optimales.

**Exemple** : si le composant **recommender** remarque qu'un pod pousse fréquemment ses limites (ex. 190Mi sur 192Mi de mémoire, ou 700m sur 750m CPU), il peut suggérer d'**augmenter** les allocations mémoire et CPU pour garantir stabilité et performance.

#### Les composants du VPA

| Composant | Rôle |
|-----------|------|
| **Recommender** | Surveille l'usage des ressources et **fournit des suggestions** d'ajustement des requests/limits selon le comportement observé. |
| **Updater** | Compare la config actuelle du pod aux recommandations. En cas de différence, il **agit** (ex. **évince/evicts** le pod) pour appliquer les nouvelles allocations. |
| **Admission Controller** | **Intercepte** les créations de nouveaux pods. Quand un pod est recréé (ex. après éviction), il **met à jour** sa config de ressources selon les recommandations du **recommender**. |

> **Point important** : Kubernetes n'autorisait traditionnellement **pas** la modification directe des ressources d'un pod en cours d'exécution (d'où les évictions). **Depuis Kubernetes 1.28**, les **in-place updates** des ressources réduisent ou éliminent le besoin d'évictions.

#### Les modes de mise à jour (Update Policy Modes)

| Mode | Comportement |
|------|--------------|
| **Off** | Fournit uniquement des **recommandations**, sans modifier les pods. **Intervention manuelle** requise pour appliquer. |
| **Initial** | Applique automatiquement les ressources optimales **à la création** du pod, mais **ne modifie pas** les pods en cours. |
| **Auto** | Applique automatiquement les ajustements **à la création ET pendant tout le cycle de vie** du pod. Avant la 1.28, ce mode nécessitait des **évictions**. Plus agressif, mais garantit une config optimale. |

### Déployer le VPA

Le VPA **n'est PAS activé par défaut** dans les clusters Kubernetes. Étapes de déploiement :
```bash
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler/
./hack/vpa-up.sh
```

Ce script déploie les composants VPA sous forme de **Deployments**, configure le **RBAC** nécessaire et crée les autres objets requis.

### Configurer un objet VPA

Après déploiement des composants, créer un **objet VPA** ciblant le pod et définissant ses paramètres. Exemple avec le mode **`Off`** (recommandations seulement) :

Le pod :
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-color
  labels:
    name: simple-webapp-color
spec:
  containers:
    - name: simple-webapp-color
      image: simple-webapp-color
      ports:
        - containerPort: 8080
  resources:
    requests:
      memory: "64Mi"
      cpu: 250m
    limits:
      memory: "128Mi"
      cpu: 500m
```

L'objet VPA :
```yaml
apiVersion: "autoscaling.k8s.io/v1"
kind: VerticalPodAutoscaler
metadata:
  name: webapp-vpa
spec:
  targetRef:
    apiVersion: "v1"
    kind: Pod
    name: simple-webapp-color
  updatePolicy:
    updateMode: "Off"
```

Décomposition : **`targetRef`** (le pod ciblé) + **`updatePolicy.updateMode`** (le mode, ici `Off`).

Voir les recommandations :
```bash
kubectl describe vpa webapp-vpa
```

La sortie détaille les recommandations CPU/mémoire avec des bornes :
- **Target** : les recommandations **actuelles** ;
- **Lower Bound** / **Upper Bound** : la **plage faisable** basée sur l'usage observé ;
- **Uncapped Target** : cible sans plafonnement.

### HPA vs VPA (distinction clé)

| Aspect | **HPA** | **VPA** |
|--------|---------|---------|
| Scaling | **Horizontal** (nombre de pods) | **Vertical** (ressources par pod) |
| Action | Ajoute/retire des **replicas** | Ajuste **requests/limits** CPU/mémoire |
| Activé par défaut ? | Oui (controller natif) | **Non** (à déployer manuellement) |

### À retenir

- Le **VPA** ajuste **verticalement** les ressources (CPU/mémoire) des pods selon l'usage réel — évite l'instabilité par manque de ressources.
- Rappel : **requests** = garantie minimale (influence le scheduling) ; **limits** = plafond maximal.
- **3 composants** : **Recommender** (suggère), **Updater** (applique, via éviction), **Admission Controller** (met à jour à la recréation).
- **3 modes** : **Off** (recommandations seules), **Initial** (à la création), **Auto** (création + cycle de vie).
- Depuis **Kubernetes 1.28** : **in-place updates** → moins d'évictions.
- Le VPA **n'est pas activé par défaut** → déploiement via le repo `kubernetes/autoscaler` (`./hack/vpa-up.sh`).
- Objet VPA : **`targetRef`** (pod ciblé) + **`updatePolicy.updateMode`** ; consultation via **`kubectl describe vpa`** (Target, Lower/Upper Bound).

### Liens utiles

- Repo officiel Kubernetes Autoscaler : https://github.com/kubernetes/autoscaler
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
