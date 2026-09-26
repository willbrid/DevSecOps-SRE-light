# ETCD dans Kubernetes

> Rôle d'etcd dans Kubernetes : stockage de l'état du cluster, méthodes de déploiement (manuel vs kubeadm) et considérations de haute disponibilité (HA).

### Le rôle d'etcd dans Kubernetes

**etcd** est un magasin clé-valeur distribué qui conserve les **données de configuration, l'état et les métadonnées** du cluster. **Chaque objet** — nœuds, pods, configurations, secrets, comptes, rôles, *role bindings* — est stocké dans etcd. Quand on exécute une commande comme `kubectl get`, les données sont **lues depuis etcd**.

Point fondamental : **tout changement** (ajout de nœud, déploiement de pod, configuration de ReplicaSet…) est **d'abord écrit dans etcd**. Le changement n'est considéré **complet** qu'**une fois etcd mis à jour**.

> Le serveur etcd écoute généralement sur le **port `2379`** pour les requêtes clients. L'URL cliente annoncée (option `--advertise-client-urls`) doit être **correctement configurée** pour la communication entre le **Kube API Server** et **etcd**.

### Les méthodes de déploiement

Deux approches principales :
- **Manuel (from scratch)** → plus de **contrôle** sur la configuration (notamment les certificats TLS), meilleure compréhension.
- **Automatique avec kubeadm** → déploiement **simplifié**.

### Déployer etcd manuellement (from scratch)

Il faut télécharger les binaires etcd, les installer et configurer etcd **comme un service** sur le nœud maître. Le mode manuel donne le contrôle des options, en particulier la mise en place des **certificats TLS**.

Extrait de configuration du service (paramètres clés) :
```bash
ExecStart=/usr/local/bin/etcd \
  --name ${ETCD_NAME} \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \
  --listen-peer-urls https://${INTERNAL_IP}:2380 \
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://${INTERNAL_IP}:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster controller-0=https://${CONTROLLER0_IP}:2380,controller-1=https://${CONTROLLER1_IP}:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
```

Voici la signification de chaque option du binaire `etcd` utilisée dans cette configuration de service.

| Option | Signification |
| ------ | ------------- |
| `--name ${ETCD_NAME}` | Nom **unique** de ce membre etcd au sein du cluster (doit correspondre au nom utilisé dans `--initial-cluster`). |
| `--cert-file=/etc/etcd/kubernetes.pem` | Certificat TLS **serveur** présenté aux clients (ex. le Kube API Server) pour sécuriser la communication client. |
| `--key-file=/etc/etcd/kubernetes-key.pem` | **Clé privée** associée au certificat serveur ci-dessus. |
| `--peer-cert-file=/etc/etcd/kubernetes.pem` | Certificat TLS utilisé pour la communication **entre pairs** (peer-to-peer, entre membres etcd). |
| `--peer-key-file=/etc/etcd/kubernetes-key.pem` | **Clé privée** associée au certificat de pair ci-dessus. |
| `--trusted-ca-file=/etc/etcd/ca.pem` | Certificat de l'**autorité de certification (CA)** servant à valider les certificats des **clients**. |
| `--peer-trusted-ca-file=/etc/etcd/ca.pem` | Certificat de la **CA** servant à valider les certificats des **pairs** (membres du cluster). |
| `--peer-client-cert-auth` | **Active l'authentification par certificat** pour les connexions entre pairs (un pair doit présenter un certificat valide). |
| `--client-cert-auth` | **Active l'authentification par certificat** pour les connexions **clientes** (le client doit présenter un certificat valide signé par la CA). |
| `--initial-advertise-peer-urls https://${INTERNAL_IP}:2380` | URL(s) **annoncée(s)** aux autres membres pour que ceux-ci contactent ce pair (port **2380**). |
| `--listen-peer-urls https://${INTERNAL_IP}:2380` | URL(s) sur lesquelles ce membre **écoute** le trafic **entre pairs** (port **2380**). |
| `--listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379` | URL(s) sur lesquelles ce membre **écoute les requêtes clientes** (port **2379**) ; ici l'IP interne **et** la loopback locale. |
| `--advertise-client-urls https://${INTERNAL_IP}:2379` | URL cliente **annoncée** aux clients (notamment au Kube API Server) pour joindre etcd (port **2379**). |
| `--initial-cluster-token etcd-cluster-0` | **Jeton** identifiant le cluster lors de l'amorçage (*bootstrap*) ; isole les membres d'un même cluster et évite les collisions entre clusters distincts. |
| `--initial-cluster controller-0=https://${CONTROLLER0_IP}:2380,controller-1=https://${CONTROLLER1_IP}:2380` | **Liste initiale de tous les membres** du cluster (nom=URL de pair) ; c'est ce qui permet la **haute disponibilité** en faisant connaître les pairs entre eux. |
| `--initial-cluster-state new` | État initial lors du démarrage : **`new`** = création d'un nouveau cluster (on utilise `existing` pour rejoindre un cluster déjà en place). |
| `--data-dir=/var/lib/etcd` | **Répertoire de données** où etcd stocke sa base (données du cluster, WAL/logs). |

À noter sur les ports :
- **`2380`** → communication **entre pairs** (peer-to-peer, `--listen-peer-urls`).
- **`2379`** → communication **client** (`--listen-client-urls` / `--advertise-client-urls`).
- **`--data-dir=/var/lib/etcd`** → répertoire de stockage des données.
- Le suffixe **`peer-`** concerne toujours la communication **entre membres etcd** (port **2380**) ; sans ce préfixe, il s'agit de la communication **client ↔ etcd** (port **2379**).
- **`listen-*`** = « où j'écoute » (adresses locales de bind) ; **`advertise-*`** / **`initial-advertise-*`** = « quelle adresse j'annonce aux autres pour me joindre ».
- Le trio **cert-file / key-file / trusted-ca-file** met en place le **TLS mutuel** ; les flags **`*-cert-auth`** rendent cette authentification par certificat **obligatoire**.
- Pour un cluster HA, les paramètres décisifs sont **`--initial-cluster`** (liste des pairs), **`--initial-cluster-token`** et **`--initial-cluster-state`**.

### Considérations de haute disponibilité (HA)

En production, la **HA est primordiale** : on exécute **plusieurs nœuds maîtres** avec leurs instances etcd respectives → le cluster reste **résilient** même si un nœud tombe.

Pour activer la HA, **chaque instance etcd doit connaître ses pairs**, via le paramètre **`--initial-cluster`** qui liste tous les membres :
```bash
  --initial-cluster controller-0=https://${CONTROLLER0_IP}:2380,controller-1=https://${CONTROLLER1_IP}:2380
```

> Certains déploiements utilisent des **certificats séparés** pour la communication entre pairs (ex. `/etc/etcd/peer.pem` et `/etc/etcd/peer-key.pem`). À adapter selon la posture de sécurité voulue.

### Déployer etcd avec kubeadm

Avec **kubeadm**, etcd est configuré **automatiquement** et s'exécute comme un **pod** dans le namespace **`kube-system`** (les détails du setup manuel sont masqués).

Lister les pods du namespace kube-system (dont etcd) :
```bash
kubectl get pods -n kube-system
# ... etcd-master   1/1   Running ...
```

Examiner les clés stockées dans etcd (organisées sous le répertoire **registry**) :
```bash
kubectl exec etcd-master -n kube-system -- etcdctl get / --prefix --keys-only
```
Exemple de sortie :
```text
/registry/apiregistration.k8s.io/apiservices/v1
/registry/apiregistration.k8s.io/apiservices/v1.apps
...
```

Le répertoire racine d'etcd (le **registry**) contient des sous-répertoires pour les composants Kubernetes : **nodes, pods, ReplicaSets, Deployments**, etc.

### À retenir

- etcd = **source de vérité** de Kubernetes : tout objet y est stocké ; `kubectl get` lit depuis etcd.
- **Règle d'or** : un changement n'est *effectif* que lorsqu'il est **écrit dans etcd**.
- **Deux ports clés** : `2379` (clients) et `2380` (communication entre pairs).
- **Deux modes de déploiement** :
  - *Manuel* → contrôle total (TLS, options) ; etcd tourne comme **service systemd**.
  - *kubeadm* → automatique ; etcd tourne comme **pod** dans `kube-system`.
- **HA** = plusieurs masters + instances etcd qui se connaissent via **`--initial-cluster`**.
- Les données de Kubernetes sont organisées sous le préfixe **`/registry`** dans etcd.
- Commande utile pour inspecter les clés : `etcdctl get / --prefix --keys-only`.

### Liens utiles

- Configuration TLS (doc Kubernetes) : https://kubernetes.io/docs/concepts/cluster-administration/transport-layer-security/
- Documentation Kubernetes : https://kubernetes.io/docs/
- Qu'est-ce que Kubernetes (bases) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Docker Hub : https://hub.docker.com/
- Terraform Registry : https://registry.terraform.io/
