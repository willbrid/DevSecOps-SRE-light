# Autoscaling

L'**autoscaling** est l'**ajustement automatisé** du nombre de ressources (serveurs, machines virtuelles, instances d'application) en fonction de la **demande en temps réel**. Cette allocation dynamique permet aux applications de gérer élégamment les **pics ou baisses** soudains de trafic, assurant une **utilisation optimale des ressources** sans sur-provisionnement ni sous-utilisation.

### Les 3 éléments clés de l'autoscaling Cloud Native

Pour un autoscaling Cloud Native véritable, **trois éléments** sont nécessaires :
1. **Conçu pour être scalable** : l'application et son infrastructure doivent être **conçues pour la scalabilité**, permettant des ajustements rapides ;
2. **Automatique** : le processus doit être **automatisé**, surveillant en continu les charges et provisionnant les ressources **sans intervention manuelle** ;
3. **Bidirectionnel** : l'autoscaling doit être **bidirectionnel** — **scale up** pour gérer la charge accrue et **scale down** en période de faible demande (ce qui améliore l'**efficacité des coûts**).

### Les deux stratégies de scaling

| Stratégie | Principe | Caractéristiques |
|-----------|----------|------------------|
| **Vertical Scaling** | **Augmenter les ressources** (CPU, RAM…) d'une instance **existante** | Efficace, mais **limité** par la capacité maximale du serveur |
| **Horizontal Scaling** | **Ajouter plus d'unités** (serveurs, instances) pour répartir la charge | Plus de **flexibilité** et meilleure **tolérance aux pannes** |

> Moyen mnémotechnique : **Vertical** = rendre une machine **plus puissante** ; **Horizontal** = ajouter **plus de machines**.

### Les 3 fonctionnalités d'autoscaling de Kubernetes

| Fonctionnalité | Rôle |
|----------------|------|
| **Horizontal Pod Autoscaler (HPA)** | Ajuste **automatiquement le nombre de pods** d'un deployment selon des métriques (CPU, mémoire) |
| **Vertical Pod Autoscaler (VPA)** | Ajuste les **limits et requests** de ressources des pods selon leur **consommation réelle** |
| **Cluster Autoscaler** | Gère le cluster en **ajoutant ou retirant des nœuds** selon les besoins de charge |

> Comprendre les différences entre **HPA, VPA et Cluster Autoscaler** est crucial pour concevoir une architecture Kubernetes **robuste et économique**.

#### Lien avec les stratégies de scaling

- **HPA** → scaling **horizontal** au niveau des **pods** (plus de pods) ;
- **VPA** → scaling **vertical** au niveau des **pods** (pods plus puissants) ;
- **Cluster Autoscaler** → scaling **horizontal** au niveau des **nœuds** (plus de nœuds).

### À retenir

- **Autoscaling** = ajustement **automatique** des ressources selon la **demande en temps réel** (gère pics et creux).
- **3 conditions** du vrai autoscaling Cloud Native : **conçu pour scaler**, **automatique**, **bidirectionnel** (up **et** down).
- **2 stratégies** : **verticale** (plus de ressources par instance, mais limitée) et **horizontale** (plus d'instances, plus flexible et tolérante aux pannes).
- **3 outils Kubernetes** : **HPA** (nombre de pods), **VPA** (ressources des pods), **Cluster Autoscaler** (nombre de nœuds).
