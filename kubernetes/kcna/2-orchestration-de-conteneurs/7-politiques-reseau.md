# Politiques réseau

#### Definition politiques réseau

Si nous souhaitons contrôler le flux de trafic au niveau de l'adresse IP ou du port (couche OSI 3 ou 4), nous pouvons envisager d'utiliser Kubernetes NetworkPolicies pour des applications particulières de notre cluster. Les NetworkPolicies sont une construction centrée sur l'application qui nous permet de spécifier comment un pod est autorisé à communiquer avec diverses "entités" du réseau. Les NetworkPolicies s'appliquent à une connexion avec un pod à une extrémité ou aux deux, et ne sont pas pertinentes pour les autres connexions.
<br><br>
Les entités avec lesquelles un Pod peut communiquer sont identifiées par une combinaison des 3 identifiants suivants :

- Autres pods autorisés (exception : un pod ne peut pas bloquer l'accès à lui-même)
- Espaces de noms autorisés
- Blocages IP (exception : le trafic vers et depuis le nœud sur lequel un pod est en cours d'exécution est toujours autorisé, quelle que soit l'adresse IP du pod ou du nœud)
<br>
Lors de la définition d'une NetworkPolicy basée sur un pod ou un espace de noms, nous utilisons un sélecteur pour spécifier le trafic autorisé vers et depuis le ou les pods qui correspondent au sélecteur.
<br><br>
Pendant ce temps, lorsque des NetworkPolicies basées sur IP sont créées, nous définissons des politiques basées sur des blocs IP (plages CIDR).
<br><br>
Les politiques de réseau sont implémentées par le plugin réseau. Pour utiliser les stratégies réseau, nous devons utiliser une solution réseau qui prend en charge NetworkPolicy. La création d'une ressource NetworkPolicy sans contrôleur qui l'implémente n'aura aucun effet.

#### Les deux types d'isolement des pods

Il existe deux types d'isolation pour un pod : l'isolation pour la sortie (**egress**) et l'isolation pour l'entrée (**ingress**). Elles concernent les connexions qui peuvent être établies. "L'isolement" ici n'est pas absolu, cela signifie plutôt "certaines restrictions s'appliquent". L'alternative, "non isolé pour $direction", signifie qu'aucune restriction ne s'applique dans la direction indiquée. Les deux types d'isolement (ou non) sont déclarés indépendamment, et sont tous deux pertinents pour une connexion d'un pod à un autre.
<br><br>
Par défaut, un pod n'est pas isolé pour la sortie ; toutes les connexions sortantes sont autorisées. Un pod est isolé pour la sortie s'il existe une NetworkPolicy qui sélectionne à la fois le pod et la règle "Egress" dans ses policyTypes ; nous disons qu'une telle politique s'applique au pod pour la sortie. Lorsqu'un pod est isolé pour la sortie, les seules connexions autorisées à partir du pod sont celles autorisées par la liste de sortie de certaines NetworkPolicy qui s'appliquent au pod pour la sortie. Les effets de ces listes de sortie se combinent de manière additive.
<br><br>
Par défaut, un pod n'est pas isolé pour l'entrée ; toutes les connexions entrantes sont autorisées. Un pod est isolé pour l'entrée s'il existe une NetworkPolicy qui sélectionne à la fois le pod et la règle "Ingress" dans ses policyTypes ; nous disons qu'une telle politique s'applique au pod pour l'entrée. Lorsqu'un pod est isolé pour l'entrée, les seules connexions autorisées dans le pod sont celles du nœud du pod et celles autorisées par la liste d'entrée de certaines NetworkPolicy qui s'appliquent au pod pour l'entrée. Les effets de ces listes d'entrée se combinent de manière additive.
<br><br>
Les politiques de réseau ne sont pas en conflit ; ils sont additifs. Si une ou plusieurs politiques s'appliquent à un pod donné pour une direction donnée, les connexions autorisées dans cette direction à partir de ce pod sont l'union de ce que les politiques applicables autorisent. Ainsi, l'ordre d'évaluation n'affecte pas le résultat de la politique.
<br><br>
Pour qu'une connexion d'un pod source à un pod de destination soit autorisée, la politique de sortie sur le pod source et la politique d'entrée sur le pod de destination doivent autoriser la connexion. Si l'un ou l'autre des côtés n'autorise pas la connexion, cela n'arrivera pas.

[https://kubernetes.io/docs/concepts/services-networking/network-policies/](https://kubernetes.io/docs/concepts/services-networking/network-policies/)