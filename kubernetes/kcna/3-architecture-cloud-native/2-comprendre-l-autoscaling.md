# Comprendre l'autoscaling

Les clients utilisant Kubernetes répondent rapidement aux demandes des utilisateurs finaux et expédient les logiciels plus rapidement que jamais. Mais que se passe-t-il lorsque vous créez un service encore plus populaire que prévu et que vous manquez de calcul ? d'où vient la notion d'autoscaling où Kubernetes augmentera automatiquement notre cluster dès que nous en aurons besoin et le réduira pour nous faire économiser de l'argent lorsque nous ne le faisons pas.

- scaling vertical : ajoute des ressources aux applications et serveurs existants.
- scaling horizontal : ajoute des instances supplémentaires d'applications et de serveurs.

#### Horizontal Pod Autoscaler et Vertical Pod Autoscaler

Dans Kubernetes, un HorizontalPodAutoscaler met automatiquement à jour une ressource de charge de travail (telle qu'un Deployment ou StatefulSet), dans le but de mettre automatiquement à l'échelle la charge de travail pour répondre à la demande.
<br>
La mise à l'échelle horizontale signifie que la réponse à une charge accrue consiste à déployer plus de pods. Ceci est différent de la mise à l'échelle verticale, qui pour Kubernetes signifierait l'attribution de plus de ressources (par exemple : mémoire ou processeur) aux pods qui sont déjà en cours d'exécution pour la charge de travail.
<br>
Si la charge diminue et que le nombre de pods est supérieur au minimum configuré, HorizontalPodAutoscaler demande à la ressource de charge de travail (déploiement, StatefulSet ou autre ressource similaire) de réduire.
<br>
La mise à l'échelle horizontale automatique des pods ne s'applique pas aux objets qui ne peuvent pas être mis à l'échelle (par exemple : un DaemonSet.)
<br>
HorizontalPodAutoscaler est implémenté en tant que ressource d'API Kubernetes et en tant que contrôleur. La ressource détermine le comportement du contrôleur. Le contrôleur de mise à l'échelle horizontale du pod, exécuté dans le plan de contrôle Kubernetes, ajuste périodiquement l'échelle souhaitée de sa cible (par exemple, un déploiement) pour correspondre aux métriques observées telles que l'utilisation moyenne du processeur, l'utilisation moyenne de la mémoire ou toute autre métrique personnalisée que nous spécifions.

#### Cluster Autoscaler

**Cluster autoscaler** : ajoute/supprime automatiquement des nœuds de cluster en fonction des données d'utilisation en temps réel.
<br><br>
**Cluster Autoscaler** est un outil qui ajuste automatiquement la taille du cluster Kubernetes lorsque l'une des conditions suivantes est vraie :
- certains pods n'ont pas pu s'exécuter dans le cluster en raison de ressources insuffisantes.
- certains nœuds du cluster ont été sous-utilisés pendant une période prolongée et leurs pods peuvent être placés sur d'autres nœuds existants.

[https://kubernetes.io/blog/2016/07/autoscaling-in-kubernetes/](https://kubernetes.io/blog/2016/07/autoscaling-in-kubernetes/)

[https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

[https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)