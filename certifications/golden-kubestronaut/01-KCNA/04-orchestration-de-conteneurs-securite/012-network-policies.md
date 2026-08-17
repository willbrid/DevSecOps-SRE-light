# Network Policies

Les **network policies** permettent de **contrôler la communication entre pods** dans un cluster Kubernetes, pour renforcer la sécurité réseau.

### Concepts de base : Ingress vs Egress

Exemple d'application à 3 composants :
- **Web server** (front-end, port 80) ;
- **API server** (back-end, port 5000) ;
- **Database server** (données, port 3306).

Flux : utilisateur → web (80) → API (5000) → DB (3306).

Deux types de trafic :
- **Ingress** : trafic **entrant** vers un composant (ex. requêtes utilisateur vers le web server) ;
- **Egress** : trafic **sortant** depuis un composant (ex. web server interrogeant l'API).

> **Point important** : lors de la définition des règles, seule la **direction d'origine** du trafic est considérée. Le trafic de **réponse** n'est **pas** inclus dans la règle initiale.

#### Règles par composant

- **Web server** : Ingress port 80 ; Egress vers API port 5000.
- **API server** : Ingress port 5000 ; Egress vers DB port 3306.
- **Database server** : Ingress port 3306.

### La règle « All Allow » par défaut

- Dans Kubernetes, tous les pods résident sur un **réseau virtuel unique** couvrant le cluster ; ils peuvent communiquer **out-of-the-box** (par IP, nom ou service).
- **Par défaut**, Kubernetes applique une règle **« all-allow »** : communication **libre et non restreinte** entre tous les pods et services.

### Le rôle des Network Policies

Pour restreindre certains accès (ex. empêcher le web server d'accéder directement à la DB, n'autoriser que l'API) :
- Une **network policy** est un objet Kubernetes (comme les pods, ReplicaSets, services).
- Elle utilise des **labels et selectors** pour déterminer à quels pods elle s'applique.
- Une fois appliquée, elle **bloque tout trafic** qui ne correspond **pas** aux règles définies.
- Elle n'affecte **que les pods auxquels elle est appliquée**.

### Créer une Network Policy

Un exemple avec le pod **Database server**

- Cibler les pods via `podSelector`

```yaml
podSelector:
  matchLabels:
    role: db
```

- Autoriser uniquement le trafic entrant depuis l'API sur le port 3306 :

```yaml
policyTypes:
- Ingress
ingress:
- from:
  - podSelector:
      matchLabels:
        name: api-pod
  ports:
  - protocol: TCP
    port: 3306
```

### Configuration complète (exemple db-policy)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              name: api-pod
      ports:
        - protocol: TCP
          port: 3306
```

Décomposition :
- **`podSelector`** : la policy cible les pods `role: db` ;
- **`policyTypes: [Ingress]`** : seul le trafic **entrant** est géré ;
- **`ingress.from`** : autorise uniquement les pods `name: api-pod` ;
- **`ports`** : sur le port **3306 (TCP)**.

> Ici, seul l'**Ingress** est restreint ; l'**Egress** reste libre. Pour restreindre le sortant, ajouter une section **`egress`** dans `policyTypes`.

### Point crucial : la solution réseau (CNI) compte

L'**application** des network policies dépend de la **solution réseau (CNI)** du cluster :

| Support des Network Policies | Solutions |
|------------------------------|-----------|
| ✅ **Supportent** | **Kube-router, Calico, Romana, Weave Net** |
| ❌ **Ne supportent PAS** | **Flannel** |

> **Piège dangereux** : même avec une solution ne supportant pas les network policies, on peut **quand même créer** la policy, mais elle **ne sera PAS appliquée** — et **aucun message d'erreur** ne le signalera !

### À retenir

- **Ingress** = entrant, **Egress** = sortant ; seule la direction d'**origine** compte (réponse non incluse).
- Par défaut, Kubernetes = règle **« all-allow »** (communication libre entre pods).
- Une **NetworkPolicy** (apiVersion `networking.k8s.io/v1`) cible des pods via **`podSelector`** et bloque tout ce qui ne correspond pas aux règles.
- Structure : `podSelector` + `policyTypes` (Ingress/Egress) + règles `from`/`ports`.
- L'application dépend du **CNI** : **Calico, Weave Net, Kube-router, Romana** oui ; **Flannel** non (sans erreur !).
