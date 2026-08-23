# DNS dans kubernetes

### Introduction

Le serveur de noms de domaine (DNS) du cluster permet aux conteneurs de découvrir les services par nom d'hôte.

Kubernetes crée des enregistrements DNS pour les services et les pods. Nous pouvons contacter les services avec des noms DNS cohérents au lieu d'adresses IP.

Kubernetes publie des informations sur les pods et les services qui sont utilisées pour programmer le DNS. Kubelet configure le DNS des pods afin que les conteneurs en cours d'exécution puissent rechercher les services par nom plutôt que par adresse IP.

Les services définis dans le cluster se voient attribuer des noms DNS. Par défaut, la liste de recherche DNS d'un pod client inclut le propre espace de noms du pod et le domaine par défaut du cluster.

> **Exemple concret**
> Au lieu d'écrire dans votre application `mysql.connect("10.107.45.12")` (une IP qui peut changer si le service est recréé), vous écrivez `mysql.connect("db-service")`. Le DNS résout automatiquement ce nom vers la bonne IP, même si elle change.

---

### Espaces de noms de services

Une requête DNS peut renvoyer des résultats différents en fonction de l'espace de noms du pod qui la crée. Les requêtes DNS qui ne spécifient pas d'espace de noms sont limitées à l'espace de noms du pod. Accédez aux services dans d'autres espaces de noms en le spécifiant dans la requête DNS.

Par exemple, considérez un pod dans un espace de noms **test**. Un service **data** se trouve dans l'espace de noms **prod**.

Une requête pour **data** ne renvoie aucun résultat, car elle utilise l'espace de noms **test** du pod.

Une requête pour **data.prod** renvoie le résultat attendu, car elle spécifie l'espace de noms.

Les requêtes DNS peuvent être étendues à l'aide du fichier **/etc/resolv.conf** du pod. Kubelet configure ce fichier pour chaque Pod. Par exemple, une requête portant uniquement sur le service **data** peut être étendue à **data.test.svc.cluster.local**.

> **Exemple concret — récapitulatif de la règle**
>
> | Depuis un pod dans `test`, requête pour… | Résultat | Pourquoi |
> |------------------------------------------|----------|----------|
> | `data` | ❌ Aucun résultat | Cherche dans `test`, mais `data` est dans `prod` |
> | `data.prod` | ✅ Trouvé | L'espace de noms `prod` est spécifié |
> | `data.prod.svc.cluster.local` (FQDN complet) | ✅ Trouvé | Nom complet et non ambigu |
>
> **Règle à retenir** : même espace de noms → nom court suffit ; espace de noms différent → il faut préciser le namespace.

---

### Service

#### Enregistrements A/AAAA

Les services "normaux" (pas **headless**) se voient attribuer des enregistrements DNS A et/ou AAAA, selon la famille ou les familles d'adresses IP du service, avec un nom de la forme **my-svc.my-namespace.svc.cluster-domain.example**. Cela résout l'adresse IP du cluster du service.

Les services headless (sans adresse IP de cluster) se voient également attribuer des enregistrements DNS A et/ou AAAA, avec un nom de la forme **my-svc.my-namespace.svc.cluster-domain.example**. Contrairement aux services normaux, cela se résout à l'ensemble des adresses IP de tous les pods sélectionnés par le service. On s'attend à ce que les clients consomment l'ensemble ou utilisent une sélection circulaire standard à partir de l'ensemble.

> **Exemple concret — service normal vs headless**
>
> Soit un service `web-svc` dans le namespace `default`, avec le domaine `cluster.local`. Son nom DNS est :
> ```
> web-svc.default.svc.cluster.local
> ```
> - **Service normal** : ce nom résout **une seule IP**, celle du cluster IP du service (ex. `10.96.0.10`). Le service répartit ensuite le trafic vers les pods.
> - **Service headless** : ce même nom résout **toutes les IP des pods** directement (ex. `10.244.1.2`, `10.244.2.5`, `10.244.3.7`). Le client reçoit la liste complète et choisit lui-même (ou en round-robin).

#### Enregistrements SRV

Les enregistrements SRV sont créés pour les ports nommés qui font partie de services normaux ou headless. Pour chaque port nommé, l'enregistrement SRV a la forme **_port-name._port-protocol.my-svc.my-namespace.svc.cluster-domain.example**. Pour un service standard, cela se résout au numéro de port et au nom de domaine : **my-svc.my-namespace.svc.cluster-domain.example**. Pour un service headless, cela se résout en plusieurs réponses, une pour chaque pod qui sauvegarde le service, et contient le numéro de port et le nom de domaine du pod sous la forme **hostname.my-svc.my-namespace.svc.cluster-domaine.exemple**.

> **Exemple concret — enregistrement SRV**
>
> Soit un service `web-svc` (namespace `default`) exposant un port nommé `http` en protocole `tcp`. L'enregistrement SRV est :
> ```
> _http._tcp.web-svc.default.svc.cluster.local
> ```
> - **Service normal** → résout vers le port (ex. `80`) et le nom : `web-svc.default.svc.cluster.local`.
> - **Service headless** → résout vers **plusieurs réponses**, une par pod, du type : `pod-hostname.web-svc.default.svc.cluster.local` + le numéro de port de chaque pod.

---

### Pods

#### Enregistrements A/AAAA

En général, un pod a la résolution DNS suivante :

```
pod-ip-address.my-namespace.pod.cluster-domain.example
```

Par exemple, si un pod dans l'espace de noms **default** a l'adresse IP 172.17.0.3 et que le nom de domaine de notre cluster est **cluster.local**, alors le pod a un nom DNS :

```
172-17-0-3.default.pod.cluster.local
```

Tous les pods exposés par un service disposent de la résolution DNS suivante :

```
pod-ip-address.service-name.my-namespace.svc.cluster-domain.example
```

> **Exemple concret — nom DNS d'un pod**
>
> Un pod d'IP `10.244.2.5`, dans le namespace `prod`, cluster `cluster.local` :
> ```
> 10-244-2-5.prod.pod.cluster.local
> ```
> **Point clé** : les **points de l'IP deviennent des tirets** (`10.244.2.5` → `10-244-2-5`), et on utilise le sous-domaine **`pod`** (et non `svc`).
>
> Si ce même pod est exposé par un service `web-svc` :
> ```
> 10-244-2-5.web-svc.prod.svc.cluster.local
> ```

#### Champs hostname et subdomain du pod

Actuellement, lorsqu'un pod est créé, son nom d'hôte (tel qu'observé depuis le pod) est la valeur **metadata.name** du pod.

La spécification de pod a un champ **hostname** facultatif, qui peut être utilisé pour spécifier un nom d'hôte différent. Lorsqu'il est spécifié, il a priorité sur le nom du pod pour être le nom d'hôte du pod (encore une fois, comme observé depuis l'intérieur du pod). Par exemple, étant donné un pod avec **spec.hostname** défini sur "my-host", le pod aura son nom d'hôte défini sur "my-host".

La spécification de pod comporte également un champ **subdomain** facultatif qui peut être utilisé pour indiquer que le pod fait partie d'un sous-groupe de l'espace de noms. Par exemple, un pod avec **spec.hostname** défini sur "foo" et **spec.subdomain** défini sur "bar", dans l'espace de noms "my-namespace", aura son nom d'hôte défini sur "foo" et son nom de domaine complet (FQDN) défini sur "foo.bar.my-namespace.svc.cluster.local".

S'il existe un service headless dans le même espace de noms que le pod, avec le même nom que le sous-domaine, le serveur DNS du cluster renvoie également des enregistrements A et/ou AAAA pour le nom d'hôte complet du pod.

> **Exemple concret — hostname et subdomain**
>
> Manifeste d'un pod utilisant ces champs :
> ```yaml
> apiVersion: v1
> kind: Pod
> metadata:
>   name: mon-pod
>   namespace: my-namespace
> spec:
>   hostname: foo
>   subdomain: bar
>   containers:
>     - name: nginx
>       image: nginx
> ```
> - Sans ces champs : le hostname interne du pod serait `mon-pod` (la valeur de `metadata.name`).
> - Avec `hostname: foo` → le hostname interne devient **`foo`** (prioritaire sur le nom du pod).
> - Avec `subdomain: bar` → le FQDN devient :
> ```
> foo.bar.my-namespace.svc.cluster.local
> ```
> - **Condition importante** : pour que ce FQDN soit **résolvable**, il faut qu'un **service headless nommé `bar`** existe dans le même namespace `my-namespace`. Dans ce cas, le DNS renvoie les enregistrements A/AAAA du nom d'hôte complet du pod.

---

### À retenir

- Le **DNS du cluster** permet de joindre les services **par nom** plutôt que par IP (plus stable) ; c'est le **kubelet** qui configure le DNS et le `/etc/resolv.conf` de chaque pod.
- **Même namespace** → nom court (`data`) ; **namespace différent** → préciser (`data.prod`) ou utiliser le FQDN complet.
- **Service normal** : `my-svc.my-namespace.svc.cluster-domain` → **une IP** (cluster IP). **Service headless** : le même nom → **toutes les IP des pods**.
- **Enregistrements SRV** : pour les **ports nommés**, forme `_port._protocole.my-svc.my-namespace.svc...`.
- **Nom DNS d'un pod** : IP avec tirets + sous-domaine **`pod`** (`10-244-2-5.prod.pod.cluster.local`), ou via son service (sous-domaine `svc`).
- Champs **`hostname`** (change le nom d'hôte, prioritaire sur `metadata.name`) et **`subdomain`** (FQDN `hostname.subdomain.namespace.svc.cluster.local`), résolvable si un **service headless** du même nom que le subdomain existe.

### Liens utiles

Documentation officielle Kubernetes : https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/