# Présentation des ressources Kubernetes

- Une ressource est un endpoint d'API Kubernetes qui stocke des objets RESTful d'un certain type.

- Nous pouvons répertorier tous les types de ressources disponibles dans le cluster avec la commande

```
kubectl api-resources
```

- Nous pouvons obtenir la documentation d'un type de ressource y compris ses champs à l'aide de 

```
kubectl explain
```

- Nous pouvons utiliser un conteneur init pour exécuter une tâche avant le démarrage du conteneur principal d'un pod.

- Nous pouvons créer nos propres types de ressources personnalisés à l'aide d'un **CustomResourceDefinition**.

#### Terminologie de l'API Kubernetes

Kubernetes utilise généralement la terminologie RESTful commune pour décrire les concepts d'API :

- Un type de ressource est le nom utilisé dans l'URL (**pods**, **namespaces**, **services**)

- Tous les types de ressources ont une représentation concrète (leur schéma d'objet) qui s'appelle **kind**

- Une liste d'instances d'une ressource est appelée **collection**.

- Une seule instance d'un type de ressource est appelée une **ressource** et représente également généralement un **objet**

- Pour certains types de ressources, l'API inclut une ou plusieurs sous-ressources, qui sont représentées sous forme de chemins d'URI sous la ressource.

La plupart des types de ressources de l'API Kubernetes sont des **objets** : ils représentent une instance concrète d'un concept sur le cluster, comme un pod ou un espace de noms. Un plus petit nombre de types de ressources d'API sont virtuels dans la mesure où ils représentent souvent des opérations sur des objets, plutôt que sur des objets, comme une vérification d'autorisation (utiliser un POST avec un corps encodé JSON de **SubjectAccessReview** à la ressource **subjectaccessreviews**), ou la sous- ressource d'un pod (utilisée pour déclencher l'éviction initiée par l'API).
<br>

- **Noms d'objet**

Tous les objets que nous pouvons créer via l'API ont un nom d'objet unique pour permettre la création et la récupération idempotentes, sauf que les types de ressources virtuelles peuvent ne pas avoir de noms uniques s'ils ne sont pas récupérables ou ne reposent pas sur l'idempotence. Dans un espace de noms, un seul objet d'un type donné peut avoir un nom donné à la fois. Cependant, si nous supprimons l'objet, nous pouvons créer un nouvel objet portant le même nom. Certains objets n'ont pas d'espace de noms (par exemple : les nœuds), et leurs noms doivent donc être uniques sur l'ensemble du cluster.

- **Verbes API**

Presque tous les types de ressources d'objet prennent en charge les verbes HTTP standard - GET, POST, PUT, PATCH et DELETE. Kubernetes utilise également ses propres verbes, qui sont souvent écrits en minuscules pour les distinguer des verbes HTTP.
<br><br>
Kubernetes utilise le terme **list** pour décrire le retour d'une collection de ressources à distinguer de la récupération d'une seule ressource, généralement appelée **get**. Si nous avons envoyé une requête HTTP GET avec le paramètre de requête **?watch**, Kubernetes appelle cela une surveillance et non un **get**.
<br><br>
Pour les requêtes **PUT**, Kubernetes les classe en interne comme création ou mise à jour en fonction de l'état de l'objet existant. Une mise à jour est différente d'un correctif ; le verbe HTTP pour un patch est **PATCH**.

[kubernetes-standard-api-terminology](https://kubernetes.io/docs/reference/using-api/api-concepts/#standard-api-terminology)

#### Comprendre les objets Kubernetes

Les objets Kubernetes sont des entités persistantes dans le système Kubernetes. Kubernetes utilise ces entités pour représenter l'état de notre cluster. Plus précisément, ils peuvent décrire :

- quelles applications conteneurisées sont en cours d'exécution (et sur quels nœuds)
- les ressources disponibles pour ces applications
- les politiques relatives au comportement de ces applications, telles que les politiques de redémarrage, les mises à niveau et la tolérance aux pannes.

Un objet Kubernetes est un "enregistrement d'intention" : une fois que nous avons créé l'objet, le système Kubernetes travaille en permanence pour s'assurer que cet objet existe. En créant un objet, nous indiquons effectivement au système Kubernetes à quoi nous voulons que la charge de travail de notre cluster ressemble ; il s'agit de l'état souhaité de notre cluster.
<br><br>
Pour travailler avec des objets Kubernetes, que ce soit pour les créer, les modifier ou les supprimer, nous devons utiliser l'API Kubernetes. Lorsque nous utilisons l'interface de ligne de commande **kubectl**, par exemple, la CLI effectue les appels d'API Kubernetes nécessaires pour nous. Nous pouvons également utiliser l'API Kubernetes directement dans nos propres programmes à l'aide de l'une des bibliothèques clientes.

[kubernetes-working-with-objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/)

#### pods

Les pods sont les plus petites unités informatiques déployables que vous pouvez créer et gérer dans Kubernetes.
<br><br>
Un pod (comme dans un pod de baleines ou un pod de pois) est un groupe d'un ou plusieurs conteneurs, avec des ressources de stockage et de réseau partagées, et une spécification sur la façon d'exécuter les conteneurs. Le contenu d'un pod est toujours colocalisé et coplanifié, et exécuté dans un contexte partagé. Un pod modélise un "hôte logique" spécifique à une application : il contient un ou plusieurs conteneurs d'applications qui sont relativement étroitement couplés.
<br><br>
Un pod est similaire à un ensemble de conteneurs avec des espaces de noms partagés et des volumes de système de fichiers partagés.

[kubernetes-pods](https://kubernetes.io/docs/concepts/workloads/pods/)

#### Conteneur Init

Un pod peut avoir plusieurs conteneurs exécutant des applications en son sein, mais il peut également avoir un ou plusieurs conteneurs init, qui sont exécutés avant le démarrage des conteneurs d'applications.
<br><br>
Les conteneurs init sont exactement comme les conteneurs normaux, sauf :

- les conteneurs d'initialisation s'exécutent toujours jusqu'à la fin.
- chaque conteneur d'initialisation doit se terminer avec succès avant que le suivant ne démarre.

Si le conteneur d'initialisation d'un pod échoue, le kubelet redémarre à plusieurs reprises ce conteneur d'initialisation jusqu'à ce qu'il réussisse. Cependant, si le pod a une **restartPolicy** de **Never** et qu'un conteneur d'initialisation échoue lors du démarrage de ce pod, Kubernetes traite le pod global comme ayant échoué.
<br><br>
Pour spécifier un conteneur d'initialisation pour un pod, on ajoute le champ **initContainers** dans la spécification du pod, en tant que tableau d'éléments de conteneur (similaire au champ **containers** d'application et à son contenu).
<br><br>
Le statut des conteneurs init est renvoyé dans le champ **.status.initContainerStatuses** sous la forme d'un tableau des statuts des conteneurs (similaire au champ **.status.containerStatuses**).

[kubernetes-init-containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)