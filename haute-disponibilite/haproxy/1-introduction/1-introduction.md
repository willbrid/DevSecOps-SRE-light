# Introduction à HAProxy

HAProxy, qui signifie High Availability Proxy, est un logiciel open source TCP/HTTP Load Balancer et une solution de proxy qui peut être exécuté sur Linux, macOS et FreeBSD. Son utilisation la plus courante consiste à améliorer les performances et la fiabilité d'un environnement de serveur en répartissant la charge de travail sur plusieurs serveurs (par exemple, Web, application, base de données). Il est utilisé dans de nombreux environnements de haut niveau, notamment : GitHub, Imgur, Instagram et Twitter.

## Terminologie HAProxy
De nombreux termes et concepts sont importants pour discuter de l'équilibrage de charge et du proxy. <br>

- Access Control List (ACL)

En ce qui concerne l'équilibrage de charge, les ACL sont utilisées pour tester certaines conditions et effectuer une action (par exemple, sélectionner un serveur ou bloquer une demande) en fonction du résultat du test. L'utilisation d'ACL permet un transfert flexible du trafic réseau en fonction de divers facteurs tels que la correspondance de modèles (regexp) et le nombre de connexions à un backend.
<br>
Exemple :
```
acl url_blog path_beg /blog
```

Cette liste de contrôle d'accès est mise en correspondance si le chemin de la demande d'un utilisateur commence par **/blog**. Cela correspondrait à une demande de **http://votredomaine.com/blog/blog-entry-1**

- Backend

Un backend est un ensemble de serveurs qui reçoit les requêtes transmises. Les backends sont définis dans la section backend de la configuration HAProxy. Dans sa forme la plus basique, un backend peut être défini par : <br>
--- quel algorithme d'équilibrage de charge utiliser <br>
--- une liste de serveurs et de ports <br><br>

Un backend peut contenir un ou plusieurs serveurs. De manière générale, ajouter plus de serveurs à notre backend augmentera votre capacité de charge potentielle en répartissant la charge sur plusieurs serveurs. Une fiabilité accrue est également obtenue de cette manière, au cas où certains de nos serveurs principaux deviendraient indisponibles.
<br>
Exemple :

```
backend web-backend
   balance roundrobin
   server web1 web1.yourdomain.com:80 check
   server web2 web2.yourdomain.com:80 check
   
backend blog-backend
   balance roundrobin
   mode http
   server blog1 blog1.yourdomain.com:80 check
   server blog1 blog1.yourdomain.com:80 check
```

La ligne **balance roundrobin** spécifie l'algorithme d'équilibrage de charge.
<br>
La ligne **mode http** spécifie que le proxy de couche 7 sera utilisé.
<br>
L'option **check** à la fin des directives de serveur spécifie que des vérifications de l'état doivent être effectuées sur ces serveurs principaux.


## Types d'équilibrage de charge
Les types de base d'équilibrage de charge : <br>

- **Pas d'équilibrage de charge**

L'utilisateur se connecte directement à notre serveur web, via notre domaine et il n'y a pas d'équilibrage de charge. Si notre serveur Web unique tombe en panne, l'utilisateur ne pourra plus accéder à notre serveur Web. De plus, si de nombreux utilisateurs tentent d'accéder simultanément à notre serveur et qu'il est incapable de gérer la charge, ils peuvent avoir une expérience lente ou ne pas pouvoir se connecter du tout.

- **Équilibrage de charge de couche 4**

Le moyen le plus simple d'équilibrer la charge du trafic réseau vers plusieurs serveurs consiste à utiliser l'équilibrage de charge de couche 4 (couche de transport). L'équilibrage de charge de cette manière transférera le trafic utilisateur en fonction de la plage IP et du port (c'est-à-dire que si une requête arrive pour **http://votredomaine.com/anything**, le trafic sera transmis au backend qui gère toutes les requêtes pour **votredomaine.com** sur port 80).

L'utilisateur accède à l'équilibreur de charge, qui transmet la demande de l'utilisateur au groupe web-backend de serveurs backend. Quel que soit le serveur principal sélectionné, il répondra directement à la demande de l'utilisateur. En règle générale, tous les serveurs du backend Web doivent servir un contenu identique, sinon l'utilisateur pourrait recevoir un contenu incohérent. Notons que les deux serveurs Web se connectent au même serveur de base de données.

- **Équilibrage de charge de couche 7**

Une autre façon, plus complexe, d'équilibrer la charge du trafic réseau consiste à utiliser l'équilibrage de charge de la couche 7 (couche application). L'utilisation de la couche 7 permet à l'équilibreur de charge de transférer les demandes vers différents serveurs principaux en fonction du contenu de la demande de l'utilisateur. Ce mode d'équilibrage de charge nous permet d'exécuter plusieurs serveurs d'applications Web sous le même domaine et le même port.
<br>
Exemple :

```
frontend http
  bind *:80
  mode http

  acl url_blog path_beg /blog
  use_backend blog-backend if url_blog
 
  default_backend web-backend
```

Cela configure une interface nommée **http**, qui gère tout le trafic entrant sur le port 80.
<br>
**acl url_blog path_beg /blog** correspond à une demande si le chemin de la demande de l'utilisateur commence par **/blog**.
<br>
**use_backend blog-backend if url_blog** utilise l'ACL pour diriger le trafic vers **blog-backend**.
<br>
**default_backend web-backend** spécifie que tout le reste du trafic sera transmis au **web-backend**.


## Algorithmes d'équilibrage de charge

L'algorithme d'équilibrage de charge utilisé détermine quel serveur, dans un backend, sera sélectionné lors de l'équilibrage de charge. HAProxy offre plusieurs options pour les algorithmes. En plus de l'algorithme d'équilibrage de charge, les serveurs peuvent se voir attribuer un paramètre de poids pour manipuler la fréquence à laquelle le serveur est sélectionné, par rapport aux autres serveurs.
<br>
Voici quelques-uns des algorithmes couramment utilisés : <br>

- **roundrobin**

L'algorithme **Round Robin** sélectionne les serveurs à tour de rôle. C'est l'algorithme par défaut.

- **leastconn**

L'alogrithme **leastconn** sélectionne le serveur avec le moins de connexions. Ceci est recommandé pour les sessions plus longues. Les serveurs dans le même backend sont également sélectionnés à tour de rôle.

- **source**

Cela sélectionne le serveur à utiliser en fonction d'un hachage de l'adresse IP source à partir de laquelle les utilisateurs font des demandes. Cette méthode garantit que les mêmes utilisateurs se connecteront aux mêmes serveurs.


## Sessions persistantes

Certaines applications nécessitent qu'un utilisateur continue de se connecter au même serveur principal. Cela peut être réalisé via des sessions persistantes, en utilisant le paramètre **appsession** dans le backend qui le nécessite.


## Bilan de santé
HAProxy utilise des vérifications de l'état pour déterminer si un serveur principal est disponible pour traiter les demandes. Cela évite d'avoir à supprimer manuellement un serveur du backend s'il devient indisponible. La vérification de l'état par défaut consiste à essayer d'établir une connexion TCP au serveur.
<br>
Si un serveur échoue à une vérification de l'état et ne peut donc pas répondre aux demandes, il est automatiquement désactivé dans le backend et le trafic ne lui sera pas transféré tant qu'il ne redeviendra pas sain. Si tous les serveurs d'un backend échouent, le service deviendra indisponible jusqu'à ce qu'au moins un de ces serveurs backend redevienne sain.
<br>
Pour certains types de backends, comme les serveurs de base de données, la vérification de l'état par défaut ne consiste pas nécessairement à déterminer si un serveur est toujours sain.
<br>
Le serveur Web Nginx peut également être utilisé comme serveur proxy autonome ou équilibreur de charge, et est souvent utilisé conjointement avec HAProxy pour ses capacités de mise en cache et de compression.


## La haute disponibilité

Les configurations d'équilibrage de charge des couches 4 et 7 utilisent toutes deux un équilibreur de charge pour diriger le trafic vers l'un des nombreux serveurs principaux. Cependant, notre équilibreur de charge est un point de défaillance unique dans ces configurations ; s'il tombe en panne ou est submergé de demandes, cela peut entraîner une latence élevée ou des temps d'arrêt pour notre service.
<br>
Une configuration à haute disponibilité (HA) est généralement définie comme une infrastructure sans point de défaillance unique. Il empêche qu'une panne de serveur unique ne soit un événement d'indisponibilité en ajoutant de la redondance à chaque couche de notre architecture. Un équilibreur de charge facilite la redondance pour la couche dorsale (serveurs Web/applications), mais pour une véritable configuration à haute disponibilité, nous devons également disposer d'équilibreurs de charge redondants.
<br>
Voici un schéma d'une configuration haute disponibilité :

![ha-diagram-animated.gif](../images/ha-diagram-animated.gif)

Dans cet exemple, nous avons plusieurs équilibreurs de charge (un actif et un ou plusieurs passifs) derrière une adresse IP statique qui peut être remappée d'un serveur à un autre. Lorsqu'un utilisateur accède à notre site Web, la demande passe par l'adresse IP externe vers l'équilibreur de charge actif. Si cet équilibreur de charge échoue, notre mécanisme de basculement le détectera et réattribuera automatiquement l'adresse IP à l'un des serveurs passifs. Il existe plusieurs façons d'implémenter une configuration HA active/passive.

Source: [Introduction-to-haproxy-and-load-balancing-concepts](https://www.digitalocean.com/community/tutorials/an-introduction-to-haproxy-and-load-balancing-concepts)