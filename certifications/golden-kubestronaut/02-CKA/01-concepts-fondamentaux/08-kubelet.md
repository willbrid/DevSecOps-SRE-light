# Kubelet

> Responsabilités du Kubelet, son rôle dans le cluster, et son installation sur les nœuds de travail (worker nodes).

### Rôle du Kubelet

Le Kubelet est le **« capitaine du navire »** sur chaque nœud. Ses responsabilités :

- **Gérer les conteneurs** : démarrer/arrêter les conteneurs selon les instructions du **scheduler** (via l'API Server).
- **Enregistrer le nœud** dans le cluster Kubernetes.
- **Surveiller en continu** l'état des pods et de leurs conteneurs.
- **Remonter le statut** du nœud et de ses charges de travail à l'**API Server**.

Quand il reçoit l'ordre d'exécuter un pod, le Kubelet communique avec le **container runtime** (ex. containerd/Docker) pour **télécharger l'image** et **lancer le conteneur**, puis en **maintient la santé**.

> Le Kubelet est **l'intermédiaire** entre le **plan de contrôle** et le **container runtime**.

### Installation du Kubelet

> Point important : contrairement aux autres composants, le Kubelet **n'est PAS déployé automatiquement** par kubeadm. Il doit être **installé manuellement sur chaque worker node**.

#### Étape 1 — Télécharger le binaire

```bash
wget https://dl.k8s.io/v1.34.12/bin/linux/amd64/kubelet
```

#### Étape 2 — Configurer et lancer le Kubelet comme service

```bash
ExecStart=/usr/local/bin/kubelet \
  --config=/var/lib/kubelet/kubelet-config.yaml \
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --register-node=true \
  --v=2
```

| Option | Signification |
| ------ | ------------- |
| `--config=/var/lib/kubelet/kubelet-config.yaml` | Fichier de configuration **KubeletConfiguration** (méthode moderne) : cgroup driver, DNS, ports, réserves de ressources, etc. La plupart des réglages y migrent, à la place des flags. |
| `--container-runtime-endpoint=unix:///var/run/containerd/containerd.sock` | **Socket CRI** du container runtime à contacter (ici containerd). Seul flag « runtime » encore nécessaire. |
| `--kubeconfig=/var/lib/kubelet/kubeconfig` | Kubeconfig indiquant comment le kubelet **se connecte à l'API Server** (identité du nœud). Généralement généré par le **TLS bootstrapping**. |
| `--register-node=true` | Le kubelet **s'enregistre automatiquement** comme nœud auprès de l'API Server (comportement par défaut). |
| `--v=2` | **Niveau de verbosité** des logs. |

#### Étape 3 — Vérifier le processus

```bash
ps -aux | grep kubelet
```

On y voit notamment `--bootstrap-kubeconfig` (**TLS bootstrapping**), `--kubeconfig`, `--config`, `--cgroup-driver`.

### À retenir

- Le Kubelet = **agent présent sur chaque nœud** ; il **exécute réellement** les pods (le scheduler ne fait que décider).
- **Point d'examen crucial** : le Kubelet **n'est jamais installé par kubeadm** → installation **manuelle** obligatoire sur chaque worker.
- Boucle de fonctionnement : reçoit les instructions → parle au **container runtime** via **CRI** → surveille la santé → **remonte le statut** à l'API Server.
- La configuration moderne passe par **`--config`** (fichier `KubeletConfiguration`) plutôt que par des flags multiples.
- Notion à approfondir ensuite : **TLS bootstrapping** (`--bootstrap-kubeconfig`) et génération de certificats.

### Liens utiles

- Référence des flags kubelet : https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/
- Page de téléchargement des releases Kubernetes : https://kubernetes.io/releases/download/, https://dl.k8s.io/
- Configuration du Kubelet (KubeletConfiguration) : https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/
- TLS bootstrapping du Kubelet : https://kubernetes.io/docs/reference/access-authn-authz/kubelet-tls-bootstrapping/
