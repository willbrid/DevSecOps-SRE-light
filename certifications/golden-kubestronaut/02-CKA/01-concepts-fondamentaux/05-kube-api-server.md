# Kube API Server

> Rôle du Kube API Server : composant central de gestion du cluster Kubernetes qui traite les requêtes, les authentifie et les valide, interagit avec etcd et coordonne les autres composants.

### Rôle central du Kube API Server

Quand on exécute une commande comme `kubectl get nodes`, l'outil envoie une requête à l'**API Server**. Celui-ci :
1. **Authentifie** l'utilisateur,
2. **Valide** la requête,
3. **Récupère** les données depuis le cluster **etcd**,
4. **Répond** avec l'information demandée.

C'est le **seul composant** qui interagit directement avec etcd ; tous les autres passent par lui.

### Cycle de vie d'une requête (création d'un pod)

Lorsqu'une requête `POST` directe est faite à l'API pour créer un pod, l'API Server :
1. **Authentifie et valide** la requête.
2. **Construit l'objet pod** (d'abord **sans nœud assigné**) et met à jour **etcd**.
3. **Notifie** le demandeur que le pod est créé.

Suite des opérations (coordination des composants) :
- Le **Scheduler** surveille en continu l'API Server pour détecter les pods **sans nœud**. Il choisit un nœud approprié et en informe l'API Server.
- L'**API Server** met à jour **etcd** avec cette assignation, puis transmet l'info au **Kubelet** du nœud de travail.
- Le **Kubelet** déploie le pod via le **container runtime**, puis **remonte le statut** du pod à l'API Server, qui **synchronise** avec etcd.

> Au cœur de toutes ces opérations, l'API Server garantit une communication **sécurisée et validée** entre les composants du cluster.

Les **6 étapes** clés : *Authenticate User → Validate Request → Retrieve Data → Update ETCD → Scheduler → Kubelet*.

### Déploiement et installation

- Avec un outil de bootstrap (**kubeadm**), ces détails sont **abstraits** (automatiques).
- En installation **manuelle**, il faut télécharger le **binaire kube-apiserver** depuis la page des releases, le configurer, et le lancer comme **service** sur le nœud maître.

### Configuration type du service

Le kube-apiserver se lance avec de nombreux paramètres. Options importantes à connaître :

Par exemple pour kubernetes v1.34.12

```
wget https://dl.k8s.io/v1.34.12/bin/linux/amd64/kube-apiserver

# kube-apiserver.service
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://127.0.0.1:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-account-signing-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-account-issuer=https://${INTERNAL_IP}:6443 \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --v=2
```

| Option | Signification |
| ------ | ------------- |
| `--advertise-address=${INTERNAL_IP}` | Adresse IP annoncée aux membres du cluster pour joindre l'API Server. |
| `--allow-privileged=true` | Autorise la création de conteneurs **privilégiés**. |
| `--authorization-mode=Node,RBAC` | Modes d'**autorisation** évalués dans l'ordre (Node puis RBAC). |
| `--bind-address=0.0.0.0` | Adresse d'écoute du trafic sécurisé (toutes les interfaces). |
| `--client-ca-file=/var/lib/kubernetes/ca.pem` | CA servant à **authentifier les clients** par certificat. |
| `--enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota` | **Plugins d'admission** activés (en plus de ceux activés par défaut). |
| `--etcd-cafile=/var/lib/kubernetes/ca.pem` | CA pour valider le certificat **serveur d'etcd** (TLS). |
| `--etcd-certfile=/var/lib/kubernetes/kubernetes.pem` | Certificat **client** présenté par l'API Server à etcd. |
| `--etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem` | Clé privée associée au certificat client etcd. |
| `--etcd-servers=https://127.0.0.1:2379` | URL(s) des serveurs **etcd** à contacter. |
| `--event-ttl=1h` | Durée de rétention des **Events** avant purge. |
| `--encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml` | Fichier de configuration du **chiffrement des secrets au repos** dans etcd. |
| `--kubelet-certificate-authority=/var/lib/kubernetes/ca.pem` | CA pour **vérifier le certificat des Kubelets** (connexion API Server → Kubelet). |
| `--kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem` | Certificat client présenté par l'API Server **au Kubelet**. |
| `--kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem` | Clé privée associée au certificat client Kubelet. |
| `--runtime-config=api/all` | Active/désactive des **groupes d'API** (ici : toutes les API). |
| `--service-account-key-file=/var/lib/kubernetes/service-account.pem` | Clé **publique** servant à **vérifier** les tokens de ServiceAccount. |
| `--service-account-signing-key-file=/var/lib/kubernetes/service-account-key.pem` | Clé **privée** servant à **signer** les tokens de ServiceAccount. **(Obligatoire)** |
| `--service-account-issuer=https://${INTERNAL_IP}:6443` | **Émetteur (issuer)** inscrit dans les tokens de ServiceAccount ; URL de découverte OIDC. **(Obligatoire)** |
| `--service-cluster-ip-range=10.32.0.0/24` | Plage d'**IP virtuelles** allouées aux objets **Service** (ClusterIP). |
| `--service-node-port-range=30000-32767` | Plage de ports autorisés pour les Services de type **NodePort**. |
| `--v=2` | **Niveau de verbosité** des logs. |

> Beaucoup d'options concernent les **certificats** : elles sécurisent les canaux entre les composants.

### Vérifier le déploiement

**Cluster monté avec kubeadm** → l'API Server tourne comme **pod** dans le namespace `kube-system` :
```bash
kubectl get pods -n kube-system
# ... kube-apiserver-master   1/1   Running ...
```

Trois façons d'inspecter la configuration active :
1. Le **manifeste du pod** (setup non-kubeadm : options listées sous `command:`).
2. Le **fichier de service systemd** sur le nœud maître :
```bash
cat /etc/systemd/system/kube-apiserver.service
```
3. Les options de commande directement dans la définition du pod.

Vérifier le processus et ses options actives :
```bash
ps -aux | grep kube-apiserver
```

### Tableau de référence rapide

| Composant | Rôle | Exemple d'action |
| --------- | ---- | ---------------- |
| **kubectl** | Outil CLI pour envoyer des requêtes à l'API | `kubectl get nodes` |
| **Kube API Server** | Composant central : traite, authentifie et valide les requêtes | Traite les requêtes API et interagit avec etcd |
| **Scheduler** | Surveille l'API Server pour les pods non assignés et les attribue à un nœud | Assigne automatiquement un nœud aux nouveaux pods |
| **Kubelet** | Sur les worker nodes : gère le cycle de vie des pods et remonte le statut | Interagit avec le container runtime pour déployer les images |
| **etcd** | Magasin clé-valeur distribué : sauvegarde la configuration du cluster | Stocke toutes les données d'état du cluster |

### À retenir

- Le **Kube API Server** = **point d'entrée unique** et **cœur** du plan de contrôle ; **seul** à écrire/lire directement dans **etcd**.
- **Rôles** : authentification, validation, accès aux données (etcd), et **coordination** entre Scheduler et Kubelet.
- **Point clé du cycle de vie** : un pod est d'abord créé **sans nœud** dans etcd ; c'est le **Scheduler** qui l'assigne ensuite, puis le **Kubelet** qui le déploie.
- **Modes d'inspection** selon le type de cluster : **pod** dans `kube-system` (kubeadm) ou **service systemd** (`/etc/systemd/system/kube-apiserver.service`) en manuel.
- Les options `--etcd-*` (connexion à etcd) et `--authorization-mode` (Node, RBAC) sont particulièrement importantes pour l'examen.
- `--allow-privileged`, les **admission plugins** et les plages `--service-*` reviennent souvent dans les scénarios de configuration.

### Liens utiles

- Page des releases Kubernetes : https://kubernetes.io/releases/
- Page de téléchargement des releases Kubernetes : https://kubernetes.io/releases/download/, https://dl.k8s.io/
- Documentation Kubernetes : https://kubernetes.io/docs/
