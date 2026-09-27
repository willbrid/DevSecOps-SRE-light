# Kube Scheduler

> Rôle du Kube Scheduler dans le **placement des pods** : sur quel nœud un pod doit être exécuté. Le scheduler **décide** ; c'est le **Kubelet** qui **crée réellement** le pod sur le nœud choisi.

### Vue d'ensemble du processus

La responsabilité première du scheduler est d'**assigner les pods aux nœuds** selon une série de critères, en s'assurant que le nœud retenu dispose de **ressources suffisantes** et respecte les **exigences** du pod (ex. nœuds dédiés à certaines applications, capacités variables).

Quand plusieurs pods et nœuds sont en jeu, le scheduler évalue chaque pod via un **processus en deux phases : filtrage puis classement**.

#### 1. Phase de filtrage (Filtering)

Le scheduler **élimine les nœuds** qui ne satisfont pas les besoins en ressources du pod. Exemple : les nœuds manquant de **CPU ou de mémoire** sont immédiatement exclus.

→ Il ne reste que les **nœuds candidats** capables d'accueillir le pod.

#### 2. Phase de classement (Ranking)

Parmi les nœuds restants, le scheduler utilise une **fonction de priorité** qui attribue un **score de 0 à 10** à chaque nœud, puis choisit le meilleur.

Exemple : si placer le pod sur un nœud y laisse **6 CPU libres** (4 de plus qu'un nœud alternatif), ce nœud obtient un **score plus élevé** et est sélectionné.

> Le scheduler est **hautement personnalisable** : on peut développer son **propre scheduler** si nécessaire. Pour des configurations avancées (limites de ressources, **taints & tolerations**, **node selectors**, règles d'**affinity**), voir la documentation Kubernetes.

### Installation et exécution

Télécharger le binaire depuis la page des releases, l'extraire, puis le lancer comme **service** en pointant vers son fichier de configuration :

```bash
wget https://dl.k8s.io/v1.34.12/bin/linux/amd64/kube-scheduler

# File: kube-scheduler.service
ExecStart=/usr/local/bin/kube-scheduler \
  --bind-address=127.0.0.1 \
  --authentication-kubeconfig=/etc/kubernetes/scheduler.conf \
  --authorization-kubeconfig=/etc/kubernetes/scheduler.conf \
  --kubeconfig=/etc/kubernetes/scheduler.conf \
  --leader-elect=true \
  --config=/etc/kubernetes/config/kube-scheduler.yaml \
  --v=2
```

**Avec kubeadm** : le scheduler est déployé comme **pod** dans le namespace `kube-system` sur le nœud maître. On inspecte sa configuration via le manifeste :
```bash
cat /etc/kubernetes/manifests/kube-scheduler.yaml
```

Vérifier le processus et ses options effectives :
```bash
ps -aux | grep kube-scheduler
# ex : kube-scheduler --kubeconfig=/etc/kubernetes/scheduler.conf --leader-elect=true
```

### À retenir

- **Scheduler = décision, Kubelet = exécution** : le scheduler choisit le nœud, il ne crée jamais le pod lui-même.
- **Deux phases** à mémoriser :
  1. **Filtering** → écarte les nœuds inadaptés (ressources insuffisantes).
  2. **Ranking** → note les nœuds restants (0 à 10) et retient le meilleur.
- Le **ranking** favorise typiquement le nœud qui laisse le plus de **ressources libres** après placement.
- Les critères avancés de placement relèvent d'autres mécanismes à approfondir : **taints/tolerations, node selectors, node affinity, resource requests/limits**.
- Kubernetes autorise des **schedulers personnalisés** (multi-schedulers).
- **Inspection** selon le setup : **pod** (`/etc/kubernetes/manifests/kube-scheduler.yaml`, kubeadm) ou **service** + `ps -aux | grep kube-scheduler`.

### Liens utiles

- Documentation Kubernetes : https://kubernetes.io/docs/
- Page de téléchargement des releases Kubernetes : https://kubernetes.io/releases/download/, https://dl.k8s.io/
- Référence des flags kube-scheduler : https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/
