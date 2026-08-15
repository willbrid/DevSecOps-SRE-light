# Pods statics

Un **static pod** est un pod créé et géré **directement par le kubelet**, **sans** l'intervention du control plane (pas d'API server, scheduler, controllers ni etcd). C'est utile quand le kubelet fonctionne sur un **nœud autonome**.

### Rappel : le fonctionnement normal

Habituellement, le **kubelet** communique avec l'**API server** pour recevoir les spécifications de pods, générées par le **kube-scheduler** et stockées dans **etcd**. Question centrale : **que se passe-t-il sans API server, scheduler, controllers ni etcd** ?

### Le principe des static pods

Sur un serveur avec seulement **kubelet + un container runtime** (Docker/containerd) :
- On configure le kubelet pour **lire les définitions de pods directement dans un dossier désigné** de l'hôte.
- Le kubelet **surveille en continu** ce dossier et :
  - **crée** les pods à partir des fichiers trouvés ;
  - les **redémarre** s'ils plantent ;
  - les **supprime** quand les fichiers sont retirés.

Ces pods sont appelés **static pods**.

> **Limite majeure** : les static pods ne supportent **QUE des objets Pod**. Les objets avancés (ReplicaSets, Deployments, Services) nécessitent le control plane complet et **ne peuvent pas** être créés ainsi.

### Configurer le dossier des static pods

L'emplacement est fourni au kubelet de deux façons :

**Option 1 — Directement via le flag `--pod-manifest-path`** :

```bash
ExecStart=/usr/local/bin/kubelet \
  --pod-manifest-path=/etc/Kubernetes/manifests \
  ...
```

**Option 2 — Via un fichier de configuration** (`--config`), courant avec **kubeadm** :

```bash
ExecStart=/usr/local/bin/kubelet \
  --config=/var/lib/kubelet/config.yaml \
  ...
```

Le fichier de config contient alors :

```yaml
staticPodPath: /etc/kubernetes/manifests
```

> Pour trouver où sont stockés les static pods d'un cluster existant : vérifier si le chemin est dans le service (consulter le statut du service : `systemctl status kubelet.service`) ou référencé dans un fichier de config (fichier de configuration du kubelet `/var/lib/kubelet/config.yaml`).

### Vérifier les static pods

Créés **sans API server**, ils **n'apparaissent pas** dans un `kubectl` classique (sur un nœud autonome). On les vérifie via le runtime :

```bash
docker ps
```

On y voit notamment le conteneur `pause` (infrastructure du pod).

### Static pods dans un cluster

Quand le nœud fait partie d'un cluster avec API server, le kubelet crée des pods depuis **deux sources simultanément** :
1. les fichiers du **dossier des pods static** ;
2. les spécifications fournies par l'**API server** (via HTTP).

Dans ce cas :

```bash
kubectl get pods
# static-web-node01   0/1   ContainerCreating   ...
```

- Les static pods **apparaissent** dans `kubectl get pods` car le kubelet crée un **mirror pod** (pod miroir) dans l'API server.
- Ces **mirror pods** sont en **lecture seule** : impossible de les modifier/supprimer via l'API server.
- Pour modifier/supprimer un static pod, il faut **éditer le fichier de définition** dans le dossier des manifests.
- Le **nom du pod est suffixé par le nom du nœud** (ex. `-node01`) pour identifier son origine.

### Usage principal : les composants du control plane

Les static pods servent à **déployer les composants du control plane** :
- Installer le kubelet sur tous les nœuds master ;
- Y placer des fichiers de définition pour **kube-apiserver, kube-controller-manager, etcd**, etc. ;
- Le kubelet gère et redémarre automatiquement ces services.

→ C'est ainsi que **kubeadm** déploie le control plane. Ces composants apparaissent comme des pods dans le namespace **kube-system** :

```bash
kubectl get pods -n kube-system
# etcd-master, kube-apiserver-master, kube-controller-manager-master, kube-scheduler-master...
```

### Static Pods vs DaemonSets (comparaison clé)

| Aspect | Static Pods | DaemonSets |
|--------|-------------|------------|
| Créé par | Le **kubelet** directement | Le **DaemonSet controller** (via l'API server) |
| Control plane requis ? | ❌ Non | ✅ Oui |
| But typique | Composants du **control plane** | Agents sur **chaque nœud** (monitoring, logging, réseau) |
| Scheduler | **Ignoré** (bypass) | **Ignoré** (bypass) |

> Point commun : **les deux contournent le kube-scheduler**.

### À retenir

- **Static pod** = pod géré directement par le **kubelet** depuis un dossier de manifests (ex. `/etc/kubernetes/manifests`), sans control plane.
- **Uniquement des Pods** (pas de ReplicaSet/Deployment/Service).
- Dans un cluster, un **mirror pod** en lecture seule apparaît dans l'API server ; le vrai contrôle se fait via le **fichier** (nom suffixé du nœud).
- **Usage principal** : bootstrapper les **composants du control plane** (méthode de kubeadm), visibles dans **kube-system**.
- vs **DaemonSet** : static pod = kubelet seul ; DaemonSet = controller via API server. **Tous deux ignorent le scheduler**.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
