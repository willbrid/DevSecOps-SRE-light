# Cluster networking

Ce contenu détaille la **configuration réseau** des nœuds master et worker d'un cluster Kubernetes : paramètres réseau et **ports** requis pour une communication optimale.

### Configuration des nœuds

Chaque nœud doit disposer d'au moins une **interface réseau** configurée avec :
- une **adresse IP unique** ;
- un **hostname unique** ;
- une **adresse MAC distincte**.

> **Point important** : vérifier ces paramètres avec soin si les **VMs ont été clonées** à partir d'autres machines (risque de doublons d'IP/MAC/hostname).

### Les ports essentiels

| Port | Composant | Description |
|------|-----------|-------------|
| **6443** | **kube-apiserver** (master) | Doit être ouvert pour : worker nodes, `kubectl`, utilisateurs externes, autres composants du control plane |
| **10250** | **kubelet** (master ET worker) | Opérations au niveau du nœud |
| **10259** | **kube-scheduler** | Fonctionnement du scheduler |
| **10257** | **kube-controller-manager** | Fonctionnement du controller manager |
| **30000–32767** | **worker nodes** | Exposition des services aux utilisateurs externes (plage NodePort) |
| **2379** | **etcd** | Stockage clé-valeur du cluster |
| **2380** | **etcd** (peer) | Communication entre clients etcd si **plusieurs masters** |

### Aide-mémoire par catégorie

- **API server** → **6443**
- **kubelet** → **10250** (sur tous les nœuds)
- **kube-scheduler** → **10259**
- **kube-controller-manager** → **10257**
- **etcd** → **2379** (+ **2380** en multi-master)
- **NodePort (services externes)** → **30000-32767**

### Sécurité réseau

Lors de la mise en place, veiller à inclure dans la configuration de sécurité :
- **Firewall** : autoriser les ports appropriés ;
- **Règles iptables** : permettre la communication entre composants ;
- **Security Groups cloud** : sur GCP, Azure, AWS, vérifier que les groupes de sécurité autorisent les ports requis.

> **Astuce de dépannage** : en cas de problème de communication entre composants, la **première étape** est de **vérifier et ajuster la configuration des ports**.

### À retenir

- Chaque nœud a besoin d'une **IP, un hostname et une MAC uniques** (attention aux **VMs clonées**).
- Ports clés : **6443** (API server), **10250** (kubelet), **10259** (scheduler), **10257** (controller manager), **2379/2380** (etcd), **30000-32767** (NodePort).
- La sécurité réseau passe par le **firewall**, les **iptables** et les **security groups cloud**.
- Un problème de communication = vérifier d'abord les **ports**.

### Liens utiles

- Documentation officielle Kubernetes (liste complète des ports) : https://kubernetes.io/docs/reference/networking/ports-and-protocols/
