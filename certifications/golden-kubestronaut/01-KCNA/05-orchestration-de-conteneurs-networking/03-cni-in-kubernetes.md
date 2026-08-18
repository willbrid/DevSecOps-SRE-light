# CNI dans Kubernetes

Ce contenu explique comment Kubernetes utilise le **CNI (Container Network Interface)** pour configurer les **plugins réseau** des conteneurs.

### « Le CNI définit les responsabilités des container runtimes »

Le **CNI** n'est pas un logiciel, c'est une **norme (une spécification)** — un ensemble de règles écrites. Cette norme dit essentiellement : *« Voici ce qu'un système qui gère des conteneurs doit faire pour configurer le réseau, et voici comment il doit dialoguer avec les plugins. »*

Autrement dit, le CNI **répartit les rôles** : <br>
--- **Ce que le runtime doit faire** : créer le conteneur, créer son network namespace, puis appeler un plugin.<br>
--- **Ce que le plugin doit faire** : configurer concrètement le réseau (IP, interfaces, routes).

C'est un **contrat** entre les deux parties. Tant que chacun respecte le contrat, n'importe quel plugin (Calico, Flannel, Weave…) fonctionne avec n'importe quel runtime.

- **Kubernetes crée les network namespaces des conteneurs**

Un **network namespace** est un **espace réseau isolé** fourni par le noyau Linux. Chaque conteneur reçoit le sien : c'est comme lui donner sa propre « pile réseau » privée (ses propres interfaces, sa propre table de routage, sa propre IP), séparée de celle des autres.

→ Kubernetes (via le runtime) crée cette « bulle réseau vide » pour chaque conteneur. Mais à ce stade, elle est **vide** : pas encore d'IP, pas encore de connectivité.

- **Kubernetes relie les network namespaces aux plugins réseau appropriés**

C'est ici qu'intervient le **plugin CNI**. La bulle réseau étant vide, il faut la **connecter** au réseau du cluster. Le plugin s'en charge :<br>
--- il crée une **paire veth** (le câble virtuel) reliant le namespace au bridge du nœud ;<br>
--- il **assigne une IP** au conteneur ;<br>
--- il configure les **routes**.

→ « Relier au plugin » = confier au bon plugin la tâche de **remplir et connecter** cette bulle réseau.

- **Un composant dédié crée d'abord les conteneurs, puis invoque le plugin CNI**

C'est la **chronologie (l'ordre des opérations)**, point important :

1. **D'abord** : le composant (le container runtime, ex. **containerd**) crée le **conteneur** et son **network namespace** vide ;
2. **Ensuite** : il **invoque (appelle)** le plugin CNI indiqué dans le fichier de configuration (ex. `10-bridge.conf`), en lui passant les infos du conteneur (nom, namespace) ;
3. Le plugin fait alors le travail réseau (IP, veth, routes).

→ **Le réseau est configuré APRÈS la création du conteneur, pas pendant.** Le runtime ne configure jamais le réseau lui-même : il **délègue** systématiquement cette tâche au plugin.

- **Une analogie pour tout relier**

Imaginons la construction d'un appartement dans un immeuble :<br>
--- Le **CNI** = le **règlement de copropriété** qui dit qui fait quoi (« le promoteur construit l'appartement vide, l'électricien branche l'électricité »).<br>
--- Le **container runtime** = le **promoteur** : il construit l'appartement (le conteneur) avec des **pièces vides mais sans électricité** (le network namespace vide).<br>
--- Le **plugin CNI** = l'**électricien** : une fois l'appartement construit, on **l'appelle** pour tirer les câbles et brancher le courant (assigner l'IP, créer la veth, poser les routes).<br>
--- L'**ordre** compte : on construit d'abord, on branche ensuite.

### Configuration du kubelet pour le CNI

Le **kubelet** de chaque nœud est le composant clé pour configurer le plugin CNI. Dans le fichier de service du kubelet, le network plugin est réglé sur **CNI**, avec des options indiquant les **répertoires** des plugins et des fichiers de configuration.

Exemple d'extrait du fichier de service kubelet :

```plaintext
ExecStart=/usr/local/bin/kubelet \
    --config=/var/lib/kubelet/kubelet-config.yaml \
    --container-runtime=remote \
    --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \
    --image-pull-progress-deadline=2m \
    --kubeconfig=/var/lib/kubelet/kubeconfig \
    --network-plugin=cni \
    --cni-bin-dir=/opt/cni/bin \
    --cni-conf-dir=/etc/cni/net.d \
    --register-node=true \
    --v=2
```

En inspectant le processus kubelet en cours (`ps -aux | grep kubelet`), on voit le network plugin réglé sur CNI, avec notamment :
- **`--cni-bin-dir=/opt/cni/bin`** : répertoire des **binaires** (exécutables) des plugins supportés (ex. **bridge, DHCP, flannel**) ;
- **`--cni-conf-dir=/etc/cni/net.d`** : répertoire des **fichiers de configuration**, lus par le kubelet pour déterminer quel plugin utiliser.

Commandes utiles :

```bash
ps -aux | grep kubelet     # voir le processus kubelet et ses options CNI
ls /opt/cni/bin            # lister les exécutables des plugins CNI
ls /etc/cni/net.d          # lister les fichiers de configuration CNI
```

> **Point important** : si **plusieurs fichiers** de configuration existent dans le répertoire, le kubelet sélectionne le **premier par ordre alphabétique**. Un fichier courant est **`10-bridge.conf`**.

### Exemple de configuration bridge

Exemple de fichier de configuration bridge (`10-bridge.conf`) conforme au standard CNI :

```json
{
  "cniVersion": "0.2.0",
  "name": "mynet",
  "type": "bridge",
  "bridge": "cni0",
  "isGateway": true,
  "ipMasq": true,
  "ipam": {
    "type": "host-local",
    "subnet": "10.22.0.0/16",
    "routes": [
      { "dst": "0.0.0.0/0" }
    ]
  }
}
```

Afficher son contenu :

```bash
cat /etc/cni/net.d/10-bridge.conf
```

**Composants clés du fichier (point essentiel)** :
- **`"bridge"`** : nom de l'interface bridge (ici **`cni0`**) ;
- **`"isGateway"`** : détermine si le bridge doit avoir une IP pour servir de **passerelle (gateway)** ;
- **`"ipMasq"`** : configure l'**IP masquerading** (règles NAT) pour le trafic sortant ;
- **`"ipam"`** : gestion des adresses IP (**IP Address Management**) :
  - **`"type": "host-local"`** : gestion locale des IP ;
  - **`"subnet"`** : plage IP allouée aux pods (ex. `10.22.0.0/16`) ;
  - **`"routes"`** : définit le routage par défaut.

> **Attention** : modifier les paramètres **IPAM** avec prudence — une mauvaise configuration peut provoquer des **conflits réseau** ou rendre les pods **inaccessibles**.

> **Alternative** : on peut basculer le type IPAM sur **`"dhcp"`** pour utiliser un serveur DHCP externe pour l'allocation des IP (au lieu de `host-local`).

### À retenir

- Le **CNI** définit les responsabilités du runtime ; Kubernetes crée les namespaces et **invoque le plugin** CNI selon la config (JSON).
- Le **kubelet** est le composant qui configure le CNI, via **`--network-plugin=cni`**, **`--cni-bin-dir=/opt/cni/bin`** (binaires) et **`--cni-conf-dir=/etc/cni/net.d`** (configs).
- Si plusieurs configs existent, le kubelet prend la **première par ordre alphabétique** (ex. `10-bridge.conf`).
- Un fichier CNI définit : le **type** de plugin (`bridge`), le nom du bridge (`cni0`), `isGateway`, `ipMasq` (NAT), et la section **`ipam`** (`host-local` ou `dhcp`, `subnet`, `routes`).
- Prudence avec l'**IPAM** : erreurs = conflits ou pods inaccessibles.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
