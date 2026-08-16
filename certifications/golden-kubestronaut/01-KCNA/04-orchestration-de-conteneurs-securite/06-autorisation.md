# Autorisation

Alors que l'**authentification** détermine **comment** un utilisateur accède au cluster, l'**autorisation** définit **quelles actions** une entité authentifiée est **autorisée à effectuer**.

### Le principe du moindre privilège

Dans un environnement multi-utilisateurs (admins, développeurs, testeurs, applications externes comme Jenkins, agents de monitoring), chaque entité doit recevoir **uniquement les permissions minimales** nécessaires à son rôle. Exemple : un développeur peut déployer des applications, mais **pas** modifier les configurations critiques (gestion des nœuds, réseau).

Quand un utilisateur n'a pas les droits, l'API renvoie une **erreur Forbidden** :

```bash
kubectl get pods
# Error from server (Forbidden): User "Bot-1" cannot list "pods"

kubectl delete node worker-2
# Error from server (Forbidden): User "developer" cannot delete resource "nodes"
```

Dans un cluster partagé par **namespaces**, l'autorisation restreint les utilisateurs aux **namespaces** où ils ont des permissions.

### Les mécanismes d'autorisation

Kubernetes supporte plusieurs méthodes :

#### 1. Node Authorization

Un **node authorizer** spécialisé traite les requêtes internes des **kubelets** (qui ont besoin d'accéder aux infos de services, pods, nœuds pour rapporter leur statut). Les kubelets s'authentifient par certificat, ce qui les place dans le groupe **`system:nodes`** (noms préfixés par **`system:node:`**).

```
Node Authorization — l'autorisation des nœuds (machines internes)
À qui ça s'adresse ?

Pas aux humains, mais aux kubelets — l'agent qui tourne sur chaque nœud de travail.

- Le problème résolu

Chaque kubelet doit parler à l'API server en permanence pour :

--- lire des infos : quels pods dois-je exécuter ? quels services, endpoints, secrets me concernent ?
--- écrire des infos : rapporter le statut de son nœud et de ses pods (« je suis en bonne santé », « ce pod tourne »).

Il faut donc autoriser ces échanges, mais de façon restreinte : un kubelet ne devrait pouvoir lire/écrire que ce qui concerne son propre nœud, pas tout le cluster.

- Comment ça marche (point clé)

C'est automatique et basé sur l'identité du certificat :

Le kubelet s'authentifie avec un certificat dont le nom est system:node:<nomDuNœud> et qui appartient au groupe system:nodes.
Le node authorizer reconnaît cette identité et accorde uniquement les permissions dont un nœud a besoin.

> En résumé : Node Authorization = un mode spécialisé et interne, qui gère les droits des machines (kubelets), pas des personnes. On n'a rien à configurer manuellement : Kubernetes s'en occupe via les certificats.
```

#### 2. ABAC (Attribute-Based Access Control)

Associe des utilisateurs/groupes à des permissions via un **fichier de politique JSON** :

```json
{"kind": "Policy", "spec": {"user": "dev-user", "namespace": "*", "resource": "pods", "apiGroup": "*"}}
```

Traduction : « l'utilisateur **dev-user** peut agir sur la ressource **pods**, dans tous les namespaces (`*`), pour tous les apiGroups (`*`).

> **Inconvénient** : toute modification exige d'**éditer le fichier JSON** ET de **redémarrer l'API server** → gestion **lourde**.

#### 3. RBAC (Role-Based Access Control) — méthode privilégiée

Simplifie la gestion : on définit des **rôles** regroupant des permissions, puis on les **lie (bind)** à des utilisateurs/groupes. Avantage clé : toute modification d'un rôle s'applique **instantanément** à tous les utilisateurs liés.

#### 4. Webhook Authorization

Approche **extensible** : l'API server délègue la décision à un **service externe** (ex. **Open Policy Agent**), qui accorde ou refuse l'accès selon sa réponse.

### La différence fondamentale : ABAC vs RBAC

C'est ici que tout devient clair. Les deux gèrent des utilisateurs externes, mais **différemment** :

| Aspect | **ABAC** | **RBAC** |
|--------|----------|----------|
| Principe | Lie **directement** l'utilisateur → permissions | Lie l'utilisateur → **rôle** → permissions |
| Configuration | Fichier **JSON** | Objets Kubernetes (Role, RoleBinding) |
| Modification | Éditer le fichier **+ redémarrer** l'API server | Appliquée **instantanément**, sans redémarrage |
| Réutilisabilité | Faible (tout est répété par user) | Forte (un rôle partagé par plusieurs users) |
| Recommandation | Obsolète, à éviter | ✅ Méthode standard |

### Récapitulatif des 3 modes Node,ABAC,RBAC

| Mode | Public | Comment |
|------|--------|---------|
| **Node** | Machines internes (**kubelets**) | Automatique, via certificat `system:node:<nom>` |
| **ABAC** | Humains/apps externes | Fichier JSON figé (**+ redémarrage**) → obsolète |
| **RBAC** | Humains/apps externes | Rôles + bindings, dynamique → **recommandé** |

### Modes Always Allow / Always Deny

Deux modes simples :
- **AlwaysAllow** : accorde toutes les requêtes sans vérification (**mode par défaut** si non spécifié).
- **AlwaysDeny** : bloque toutes les requêtes.

### Configuration via `--authorization-mode` (point important)

Le mode se définit sur le **kube-apiserver** via l'option **`--authorization-mode`**.
Mode unique :

```
--authorization-mode=AlwaysAllow
```

Plusieurs modes (liste séparée par des virgules) :

```
--authorization-mode=Node,RBAC,Webhook
```

### L'évaluation en chaîne (point essentiel)

Quand **plusieurs modes** sont activés, Kubernetes évalue chaque requête **séquentiellement** :
1. La requête passe d'abord par le **node authorizer** ;
2. Si un module **refuse**, la vérification **passe au module suivant** (ex. RBAC) ;
3. Dès qu'**un module approuve**, l'évaluation **s'arrête** et l'accès est accordé.

→ Un refus par un module **n'est pas définitif** : les modules suivants peuvent encore accorder l'accès.

### À retenir

- **Authentification** = qui accède ; **Autorisation** = quelles actions autorisées.
- Principe du **moindre privilège** ; refus = erreur **Forbidden**.
- **4 mécanismes** : **Node** (kubelets, groupe `system:nodes`), **ABAC** (JSON + redémarrage, lourd), **RBAC** (rôles liés, souple et privilégié), **Webhook** (externe, ex. OPA).
- Modes simples : **AlwaysAllow** (défaut), **AlwaysDeny**.
- Configuration via **`--authorization-mode`** (liste possible : `Node,RBAC,Webhook`).
- **Évaluation en chaîne** : refus → module suivant ; première approbation → accès accordé.

### Liens utiles

- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Docker Hub : https://hub.docker.com/
- Terraform Registry : https://registry.terraform.io/
