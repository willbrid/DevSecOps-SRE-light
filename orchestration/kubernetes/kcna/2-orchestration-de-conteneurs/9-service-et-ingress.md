# Service et Ingress

#### Service

Dans Kubernetes, un service est une méthode permettant d'exposer une application réseau qui s'exécute en tant qu'un ou plusieurs pods dans notre cluster.

L'API de service, qui fait partie de Kubernetes, est une abstraction pour nous aider à exposer des groupes de pods sur un réseau. Chaque objet Service définit un ensemble logique de points de terminaison (généralement ces points de terminaison sont des pods) ainsi qu'une politique sur la façon de rendre ces pods accessibles.
<br>
Par exemple, considérons un backend de traitement d'image sans état qui s'exécute avec 3 réplicas. Ces réplicas sont fongibles - les frontends ne se soucient pas du backend qu'ils utilisent. Bien que les pods réels qui composent l'ensemble backend puissent changer, les clients frontaux ne devraient pas avoir besoin d'en être conscients, et ils ne devraient pas non plus avoir besoin de suivre eux-mêmes l'ensemble des backends.
<br>
L'abstraction Service permet ce découplage :
- L'ensemble de pods ciblés par un service est généralement déterminé par un sélecteur que nous définissons.
- Si notre charge de travail parle HTTP, nous pouvons choisir d'utiliser une entrée pour contrôler la manière dont le trafic Web atteint cette charge de travail. Ingress n'est pas un type de service, mais il agit comme point d'entrée pour notre cluster. Un ingress nous permet de consolider nos règles de routage dans une seule ressource, afin que nous puissions exposer plusieurs composants de notre charge de travail, s'exécutant séparément dans notre cluster, derrière un seul listener.
<br><br>
L'API Gateway pour Kubernetes fournit des fonctionnalités supplémentaires au-delà de l'ingress et du service. nous pouvons ajouter une gateway à notre cluster - il s'agit d'une famille d'API d'extension, implémentées à l'aide de CustomResourceDefinitions - puis les utiliser pour configurer l'accès aux services réseau qui s'exécutent dans notre cluster.

<br>

Les types de service :

- **ClusterIP**

Expose le service sur une adresse IP interne au cluster. Le choix de cette valeur rend le service uniquement accessible depuis le cluster. Il s'agit de la valeur par défaut utilisée si nous ne spécifions pas explicitement un type pour un service. Nous pouvons exposer le service à l'Internet public à l'aide d'un ingress ou d'une passerelle.

- **NodePort**

Expose le service sur l'IP de chaque nœud à un port statique (le NodePort). Pour rendre disponible le port du nœud, Kubernetes configure une adresse IP de cluster, comme si nous avions demandé un Service de type : ClusterIP.

- **LoadBalancer**

Expose le service en externe à l'aide d'un équilibreur de charge externe. Kubernetes n'offre pas directement de composant d'équilibrage de charge ; nous devons en fournir un, ou nous pouvons intégrer notre cluster Kubernetes à un fournisseur de cloud.

- **ExternalName**

Mappe le service au contenu du champ **externalName** (par exemple, au nom d'hôte **api.foo.bar.example**). Le mappage configure le serveur DNS de notre cluster pour renvoyer un enregistrement CNAME avec cette valeur de nom d'hôte externe. Aucun proxy d'aucune sorte n'est mis en place.
<br><br>
**Services headless :**

- Parfois, nous n'avons pas besoin d'équilibrage de charge et d'une seule IP de service. Dans ce cas, nous pouvons créer ce que l'on appelle des services headless, en spécifiant explicitement "None" pour l'adresse IP du cluster (**.spec.clusterIP**).

- Nous pouvons utiliser un service headless pour nous interfacer avec d'autres mécanismes de découverte de service, sans être lié à l'implémentation de Kubernetes.

- Pour les services headless, une adresse IP de cluster n'est pas allouée, kube-proxy ne gère pas ces services et il n'y a pas d'équilibrage de charge ou de proxy effectué par la plate-forme pour eux. La configuration automatique du DNS dépend de la définition ou non des sélecteurs du service : <br>

--- avec sélecteurs <br>
Pour les services headless qui définissent des sélecteurs, le contrôleur de points de terminaison crée des **EndpointSlices** dans l'API Kubernetes et modifie la configuration DNS pour renvoyer des enregistrements A ou AAAA (adresses IPv4 ou IPv6) qui pointent directement vers les pods soutenant le service. <br>
--- Sans sélecteurs <br>
Pour les services headless qui ne définissent pas de sélecteurs, le plan de contrôle ne crée pas d'objets **EndpointSlice**. Cependant, le système DNS recherche et configure soit : <br>

----- Enregistrements DNS CNAME pour le type : **ExternalName Services**. <br>
----- Enregistrements DNS A / AAAA pour toutes les adresses IP des points de terminaison prêts du service, pour tous les types de service autres que ExternalName. <br>
------- Pour les points de terminaison IPv4, le système DNS crée des enregistrements A. <br>
------- Pour les points de terminaison IPv6, le système DNS crée des enregistrements AAAA.

<br>

**Découverte des services** <br>
Pour les clients s'exécutant à l'intérieur de notre cluster, Kubernetes prend en charge deux modes principaux de recherche d'un service : 

- les variables d'environnement

Lorsqu'un pod est exécuté sur un nœud, le kubelet ajoute un ensemble de variables d'environnement pour chaque service actif. Il ajoute les variables **{SVCNAME}_SERVICE_HOST** et **{SVCNAME}_SERVICE_PORT**, où le nom du service est en majuscule et les tirets sont convertis en traits de soulignement. <br>
Par exemple, le service **redis-primary** qui expose le port TCP 6379 et s'est vu attribuer l'adresse IP du cluster 10.0.0.11, produit les variables d'environnement suivantes :

```
REDIS_PRIMARY_SERVICE_HOST=10.0.0.11
REDIS_PRIMARY_SERVICE_PORT=6379
REDIS_PRIMARY_PORT=tcp://10.0.0.11:6379
REDIS_PRIMARY_PORT_6379_TCP=tcp://10.0.0.11:6379
REDIS_PRIMARY_PORT_6379_TCP_PROTO=tcp
REDIS_PRIMARY_PORT_6379_TCP_PORT=6379
REDIS_PRIMARY_PORT_6379_TCP_ADDR=10.0.0.11
```

- le DNS

Nous pouvons (et devrions presque toujours) configurer un service DNS pour notre cluster Kubernetes à l'aide d'un module complémentaire.
<br>
Un serveur DNS compatible avec les clusters, tel que **CoreDNS**, surveille l'API Kubernetes pour les nouveaux services et crée un ensemble d'enregistrements DNS pour chacun. Si le DNS a été activé dans notre cluster, tous les pods devraient automatiquement être en mesure de résoudre les services par leur nom DNS.

#### Ingress

L'ingress expose les routes HTTP et HTTPS de l'extérieur du cluster aux services au sein du cluster. Le routage du trafic est contrôlé par des règles définies sur la ressource Ingress.
<br>
Un Ingress peut être configurée pour donner aux Services des URL accessibles de l'extérieur, équilibrer la charge du trafic, mettre en place le SSL/TLS et offrir un hébergement virtuel basé sur le nom. Un contrôleur d'ingress est chargé de remplir l'ingress, généralement avec un équilibreur de charge, bien qu'il puisse également configurer notre routeur de périphérie ou des interfaces supplémentaires pour aider à gérer le trafic.
<br>
Un ingress n'expose pas de ports ou de protocoles arbitraires. L'exposition de services autres que HTTP et HTTPS à Internet utilise généralement un service de type **Service.Type=NodePort** ou **Service.Type=LoadBalancer**.

[https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)

[https://kubernetes.io/docs/concepts/services-networking/ingress/](https://kubernetes.io/docs/concepts/services-networking/ingress/)