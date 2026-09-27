# Kube Controller Manager

> Rôle, configuration et importance du Kube Controller Manager, le composant qui gère l'ensemble des **controllers** (contrôleurs) d'un cluster Kubernetes.

### Vue d'ensemble

Un **controller** agit comme un **département** dans une organisation : chacun a une **responsabilité précise** et observe en continu les changements du système pour **ramener le cluster vers l'état désiré**.

- **Node Controller** : surveille la santé des nœuds.
- **Replication Controller** : garantit que le **nombre voulu de pods** est toujours en cours d'exécution (recrée des pods si besoin).

Les controllers sont le **« cerveau »** derrière de nombreuses opérations : Deployments, Services, Namespaces, Persistent Volumes, etc.

### Le Node Controller en détail (timings importants)

- Il vérifie l'état des nœuds **toutes les 5 secondes** via le Kube API Server.
- Si un nœud cesse d'envoyer ses **heartbeats**, il **n'est pas marqué immédiatement** comme injoignable :
  - **période de grâce de 40 secondes** (`--node-monitor-grace-period`),
  - puis **5 minutes supplémentaires** de récupération possible (`--pod-eviction-timeout`),
  - avant que ses pods ne soient **replanifiés** sur un nœud sain.

Exemple d'un nœud défaillant :
```bash
kubectl get nodes
# worker-2   NotReady   <none>   8d   v1.34.12
```

### Comment les controllers sont packagés

Tous les controllers individuels sont **regroupés dans un seul processus** : le **Kube Controller Manager**. En le déployant, **tous les controllers démarrent ensemble** → gestion et configuration simplifiées.

### Installation et configuration

1. Télécharger le binaire depuis la page des releases.
2. L'extraire et le lancer comme **service**.
3. Ajuster les options selon les besoins.

Exemple de configuration de service :
```bash
wget https://dl.k8s.io/v1.34.12/bin/linux/amd64/kube-controller-manager

# kube-controller-manager.service
ExecStart=/usr/local/bin/kube-controller-manager \
    --bind-address=127.0.0.1 \
    --cluster-cidr=10.200.0.0/16 \
    --cluster-name=kubernetes \
    --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \
    --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \
    --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \
    --authentication-kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \
    --authorization-kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \
    --leader-elect=true \
    --root-ca-file=/var/lib/kubernetes/ca.pem \
    --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \
    --service-cluster-ip-range=10.32.0.0/24 \
    --use-service-account-credentials=true \
    --v=2
```

| Option | Signification |
| ------ | ------------- |
| `--bind-address=127.0.0.1` | Adresse d'écoute du **port sécurisé** (`10257` par défaut) pour les endpoints HTTPS (métriques, santé). Remplace l'ancien `--address`. |
| `--cluster-cidr=10.200.0.0/16` | Plage d'**IP allouées aux pods** à l'échelle du cluster (utilisée par les controllers réseau, ex. allocation des CIDR par nœud). |
| `--cluster-name=kubernetes` | **Nom du cluster**, utilisé notamment pour préfixer certaines ressources cloud. |
| `--cluster-signing-cert-file=/var/lib/kubernetes/ca.pem` | Certificat de la **CA** utilisé pour **signer les CSR** (ex. certificats des Kubelets). |
| `--cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem` | **Clé privée** de la CA associée, pour signer les CSR. |
| `--kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig` | Fichier **kubeconfig** indiquant comment se **connecter à l'API Server** (identité du controller-manager). |
| `--authentication-kubeconfig=...` | Kubeconfig utilisé pour **déléguer l'authentification** des requêtes entrantes à l'API Server (sécurise le port `10257`). |
| `--authorization-kubeconfig=...` | Kubeconfig utilisé pour **déléguer l'autorisation** des requêtes entrantes à l'API Server. |
| `--leader-elect=true` | Active l'**élection de leader** : en HA multi-masters, une seule instance est active à la fois. |
| `--root-ca-file=/var/lib/kubernetes/ca.pem` | CA **incluse dans les tokens de ServiceAccount** (permet aux pods de faire confiance à l'API Server). |
| `--service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem` | **Clé privée** servant à **signer** les tokens de ServiceAccount (le pendant de la clé publique `--service-account-key-file` côté API Server). |
| `--service-cluster-ip-range=10.32.0.0/24` | Plage d'**IP des Services** (ClusterIP) ; doit correspondre à celle de l'API Server. |
| `--use-service-account-credentials=true` | Fait tourner **chaque controller avec son propre ServiceAccount** (meilleure granularité RBAC / sécurité). |
| `--v=2` | **Niveau de verbosité** des logs. |

### Activer / désactiver des controllers (`--controllers`)

> Par défaut, **tous les controllers activables sont activés**. Syntaxe : `foo` pour **activer**, `-foo` pour **désactiver**.
> Exemple : `--controllers=*,-tokencleaner` désactive `tokencleaner`.

- `*` = active tous les controllers activés par défaut.
- Liste (extrait) : pour voir la liste des controllers : `./kube-controller-manager --help | grep -i controllers`, puis on consulte l'option `--controllers`
- **Désactivés par défaut** : on voit le commentaire `Disabled-by-default controller` de l'aide de l'option `--controllers` (`bootstrap-signer-controller, selinux-warning-controller, token-cleaner-controller`)

### Observer le Controller Manager en fonctionnement

Selon le type de cluster :
- **kubeadm** → tourne comme **pod** dans `kube-system` ; définition dans **`/etc/kubernetes/manifests`**.
- **Non-kubeadm** → **service systemd** (ex. avec `Restart=on-failure`, `RestartSec=5`).

Vérifier le processus et ses options actives :
```bash
ps -aux | grep kube-controller-manager
```

### À retenir

- Le **Kube Controller Manager** = **un seul processus** qui embarque **tous** les controllers du cluster.
- Principe fondamental : chaque controller **observe → compare à l'état désiré → agit** (boucle de réconciliation).
- **Timings du Node Controller** (fréquents à l'examen) : vérification **toutes les 5 s**, grâce de **40 s**, puis **5 min** avant éviction/replanification des pods.
- **`--controllers=*,-foo`** : `*` active tout, `-foo` désactive ; `bootstrapsigner` et `tokencleaner` sont **off par défaut**.
- **Lien crypto avec l'API Server** : Controller Manager **signe** les tokens SA (clé **privée**) ↔ API Server les **vérifie** (clé **publique**).
- `--leader-elect=true` est essentiel en **HA** multi-masters.
- Inspection : **pod** (`/etc/kubernetes/manifests`, kubeadm) ou **service** + `ps -aux | grep`.

### Liens utiles

- Documentation Kubernetes : https://kubernetes.io/docs/
- Qu'est-ce que Kubernetes (bases) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Page de téléchargement des releases Kubernetes : https://kubernetes.io/releases/download/, https://dl.k8s.io/
- Référence des flags kube-controller-manager : https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
