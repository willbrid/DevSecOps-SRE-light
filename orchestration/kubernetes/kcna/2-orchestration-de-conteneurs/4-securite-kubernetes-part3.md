# Sécurité kubernetes (Part3)

#### Déterminer si une demande est autorisée ou refusée

Kubernetes autorise les demandes d'API à l'aide du serveur d'API. Il évalue tous les attributs de la demande par rapport à toutes les politiques et autorise ou refuse la demande. Toutes les parties d'une demande d'API doivent être autorisées par une politique pour continuer. Cela signifie que les autorisations sont refusées par défaut.

(Bien que Kubernetes utilise le serveur API, les contrôles d'accès et les politiques qui dépendent de champs spécifiques de types d'objets spécifiques sont gérés par les contrôleurs d'admission.)

Lorsque plusieurs modules d'autorisation sont configurés, chacun est vérifié dans l'ordre. Si un approbateur approuve ou refuse une demande, cette décision est immédiatement rendue et aucun autre approbateur n'est consulté. Si tous les modules n'ont pas d'opinion sur la demande, alors la demande est refusée. Un refus renvoie un code d'état HTTP 403.

#### Kubernetes n'examine que les attributs de requête d'API suivants

- **user** - la chaîne d'utilisateur fournie lors de l'authentification.
- **group** - la liste des noms de groupe auxquels appartient l'utilisateur authentifié.
- **extra** - une map de clés de chaîne arbitraires en valeurs de chaîne, fournie par la couche d'authentification.
- **API** - indique si la demande concerne une ressource API.
- **Request path** - chemin vers divers points de terminaison non liés aux ressources comme /api ou /healthz.
- **API request verb** - les verbes d'API tels que get, list, create, update, patch, watch, delete et deletecollection sont utilisés pour les demandes de ressources. 
- **HTTP request verb** - les méthodes HTTP en minuscules telles que get, post, put et delete sont utilisées pour les requêtes sans ressource.
- **Resource** - id ou nom de la ressource à laquelle nous accédons (uniquement pour les demandes de ressources) -- Pour les demandes de ressources utilisant les verbes get, update, patch et delete, nous devons fournir le nom de la ressource.
- **Subresource** - la sous-ressource à laquelle nous accédons (pour les demandes de ressources uniquement).
- **Namespace** - l'espace de noms de l'objet en cours d'accès (uniquement pour les demandes de ressources avec espace de noms).
- **API group** - le groupe d'API en cours d'accès (pour les demandes de ressources uniquement). Une chaîne vide désigne le groupe d'API principal.

#### Déterminer le verbe de requête

- **Requêtes sans ressources** : les requêtes adressées à des points de terminaison autres que **/api/v1/...** ou **/apis/<groupe>/<version>/...** sont considérées comme des "requêtes sans ressources" et utilisent la méthode HTTP en minuscules de la requête comme verbe. Par exemple, une requête GET à des points de terminaison tels que /api ou /healthz utiliserait get comme verbe.

- **Requêtes de ressources** : pour déterminer le verbe de requête pour un point de terminaison d'API de ressource, examiner le verbe HTTP utilisé et si la requête agit ou non sur une ressource individuelle ou un ensemble de ressources :
**POST**, **GET**, **HEAD**, **PUT**, **PATCH**, **DELETE**, **deletecollection**

#### Modes d'autorisation

Le serveur d'API Kubernetes peut autoriser une requête en utilisant l'un des modes d'autorisation suivants :

- **Node** - Un mode d'autorisation à usage spécial qui accorde des autorisations aux kubelets en fonction des pods qu'ils doivent exécuter.

- **ABAC** - Le contrôle d'accès basé sur les attributs (ABAC) définit un paradigme de contrôle d'accès dans lequel des droits d'accès sont accordés aux utilisateurs via l'utilisation de politiques qui combinent des attributs. Les politiques peuvent utiliser n'importe quel type d'attributs (attributs d'utilisateur, attributs de ressource, objet, attributs d'environnement, etc.).

- **RBAC** - Le contrôle d'accès basé sur les rôles (RBAC) est une méthode de régulation de l'accès aux ressources informatiques ou réseau en fonction des rôles des utilisateurs individuels au sein d'une entreprise. Dans ce contexte, l'accès est la capacité d'un utilisateur individuel à effectuer une tâche spécifique, telle que visualiser, créer ou modifier un fichier. <br>
--- Lorsqu'il est spécifié, RBAC (Role-Based Access Control) utilise le groupe d'API rbac.authorization.k8s.io pour piloter les décisions d'autorisation, permettant aux administrateurs de configurer dynamiquement les politiques d'autorisation via l'API Kubernetes. <br>
--- Pour activer RBAC, démarrer l'apiserver avec **--authorization-mode=RBAC**.

- **Webhook** - Un WebHook est un rappel HTTP : un HTTP POST qui se produit lorsque quelque chose se produit ; une simple notification d'événement via HTTP POST. Une application Web implémentant WebHooks publiera un message sur une URL lorsque certaines choses se produiront.