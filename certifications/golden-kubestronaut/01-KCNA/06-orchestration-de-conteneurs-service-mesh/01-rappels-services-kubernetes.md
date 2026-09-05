# Rappel : Les Services Kubernetes

Les **pods** sont les plus petites unités déployables dans Kubernetes. Pour faire tourner une application, on crée un **Pod** et on y place l'application. Les pods sont **éphémères** : ils peuvent être **créés et supprimés** pour correspondre à l'**état déclaré (cluster state)**. Une fois déployés, les pods doivent pouvoir **se trouver et communiquer** au sein du cluster.

### Le problème résolu par les Services

- Les pods ont leurs **propres adresses IP**, mais ces IP **changent en permanence** car les pods sont **éphémères**.
- **Exemple concret** : comment un service **front-end** trouve-t-il et communique-t-il avec un **back-end**, alors que les IP des pods back-end changent tout le temps ?
- **Solution** : les **Services Kubernetes**. Un service peut être créé pour **pointer vers les pods back-end**, afin que n'importe quelle autre application du cluster puisse utiliser ce service pour les atteindre.
- Le service a sa **propre IP (stable)** : on n'a donc **plus besoin de se fier aux IP de chaque pod**.

### Le rôle des Services

- Les Services sont une **abstraction** qui détermine **à quels pods se connecter** et la **politique** pour y parvenir.
- Les **pods portent des labels** pour que le service puisse les **sélectionner** parmi un grand pool d'autres pods.

### Les trois types de Services

| Type | Portée / Accès |
|------|----------------|
| **ClusterIP** | Service **interne uniquement**, accessible **seulement au sein du cluster**. Permet la communication entre applications à l'intérieur du cluster. **(type par défaut)** |
| **NodePort** | Rend l'application **accessible depuis l'extérieur** du cluster, sur un **port prédéfini** sur **tous les nœuds** du cluster. |
| **LoadBalancer** | Uniquement supporté par **certains cloud providers**. Comme un NodePort, mais il fait appel à un **load balancer externe** supporté pour créer un load balancer qui route vers l'application exposée sur les nœuds du cluster. |

#### Détail des types

- **ClusterIP** (défaut) : service **interne** uniquement → communication **entre applications au sein du cluster**.
- **NodePort** : pour rendre une application **accessible à l'extérieur** → accessible sur un **port prédéfini sur tous les nœuds**.
- **LoadBalancer** : supporté seulement par **certains cloud providers** → provisionne un **load balancer externe** qui route le trafic vers l'application exposée sur les nœuds.

### À retenir

- Les **pods** sont **éphémères** et leurs **IP changent** → d'où le besoin des **Services**.
- Un **Service** = **abstraction** avec une **IP stable** qui pointe vers un ensemble de pods, sélectionnés via leurs **labels**, et définit la politique de connexion.
- **3 types de services** :
  - **ClusterIP** (par défaut) → interne au cluster ;
  - **NodePort** → accès externe via un port sur tous les nœuds ;
  - **LoadBalancer** → load balancer externe (cloud providers uniquement).
- Un pod atteint un service simplement en utilisant son **nom** (via le DNS), sans dépendre des IP changeantes des pods.
