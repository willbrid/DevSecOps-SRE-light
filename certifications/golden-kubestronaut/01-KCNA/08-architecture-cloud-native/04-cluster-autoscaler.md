# Cluster autoscaler

Le **Cluster Autoscaler** optimise l'allocation des ressources d'un cluster en **scalant automatiquement les nœuds**.

**Rappel du contexte** :
- Les pods consomment des ressources, et le **scheduler** les assigne aux nœuds ayant assez de capacité ;
- À mesure que plus de pods sont déployés, les ressources deviennent **rares** ;
- Quand les nœuds manquent de ressources, les pods entrent en état **`Pending`** ;
- Le **Cluster Autoscaler** intervient alors pour **scaler le cluster** en **ajoutant de nouvelles instances de calcul (nœuds)**.

> Contrairement au HPA (nombre de pods) et au VPA (ressources des pods), le Cluster Autoscaler agit au niveau des **nœuds**.

### Intégration avec le cloud provider

Le Cluster Autoscaler s'intègre avec l'**infrastructure sous-jacente** du cloud provider. Chaque provider supporté a ses **propres exigences et capacités**. Il faut consulter la documentation officielle pour la liste à jour des providers compatibles.

> Sur **Google Cloud**, on peut facilement configurer le Cluster Autoscaler en définissant les options d'autoscaling **lors de la création** du cluster Kubernetes.

### Exemple concret (Google Cloud)

Lors de la création d'un cluster sur GCP, on peut spécifier un **minimum de 3 nœuds** et un **maximum de 10 nœuds** :
- Si des pods restent en **`Pending`** faute de ressources → le Cluster Autoscaler **augmente** automatiquement le nombre de nœuds ;
- À l'inverse, il **réduit** le cluster quand moins de ressources sont nécessaires.

```bash
gcloud container clusters create my-cluster --cluster-autoscaler=min-nodes=3,max-nodes=10
```

> **Point important** : les paramètres de configuration **varient significativement** selon le cloud provider → toujours consulter la documentation **spécifique** de son provider.

### Tableau récapitulatif

| Aspect | Description | Commande/Référence |
|--------|-------------|--------------------|
| **Resource Scaling** | Ajoute automatiquement des nœuds quand des pods sont **Pending** faute de ressources | `gcloud container clusters create --cluster-autoscaler` |
| **Provider Specific Setup** | Varie selon le cloud provider → consulter sa documentation | Google Cloud Autoscaling |

### Les 3 autoscalers de Kubernetes

| Autoscaler | Niveau | Action |
|------------|--------|--------|
| **HPA** | Pods | Ajuste le **nombre de pods** |
| **VPA** | Pods | Ajuste les **ressources** (CPU/mémoire) des pods |
| **Cluster Autoscaler** | **Nœuds** | Ajoute/retire des **nœuds** du cluster |

### À retenir

- Le **Cluster Autoscaler** scale le cluster au niveau des **nœuds** : il en **ajoute** quand des pods sont en **`Pending`** (manque de ressources) et en **retire** quand ils sont sous-utilisés.
- Il s'intègre à l'**infrastructure du cloud provider** ; la configuration **varie** selon le provider.
- Sur GCP, il se configure à la **création du cluster** (ex. `--cluster-autoscaler=min-nodes=3,max-nodes=10`).
- Complète le **HPA** (nombre de pods) et le **VPA** (ressources des pods) → ensemble, ils couvrent l'autoscaling **complet** (pods + nœuds).

### Liens utiles

- Documentation Cluster Autoscaler (providers compatibles) : https://kubernetes.io/docs/tasks/cluster-management/cluster-autoscaler/
- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Google Cloud : https://cloud.google.com/

