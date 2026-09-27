# Kube Proxy

> Rôle de Kube Proxy dans le réseau Kubernetes : assurer une communication fiable entre les pods et permettre le fonctionnement des **Services** à travers le cluster.

### Le réseau des pods dans Kubernetes

Kubernetes déploie une solution de **pod networking** qui crée un **réseau virtuel interne** couvrant tous les nœuds et connectant tous les pods entre eux.

**Le problème des IP de pods** : une application web sur un nœud peut joindre une base de données sur un autre nœud via son **IP de pod**… mais ces IP sont **éphémères** et peuvent changer.

**La solution : le Service.** En exposant la base via un Service (ex. nommé « DB »), l'application web garde une **connexion stable** sans dépendre des IP fluctuantes. Chaque Service reçoit une **IP stable**, et le trafic qui lui est destiné est **automatiquement redirigé** vers le bon pod backend.

> Un **Service** est une **entité virtuelle** : il ne correspond à **aucun conteneur ni interface réseau**. C'est un **endpoint persistant** en mémoire du cluster qui donne un accès stable aux pods sous-jacents.

### Comment fonctionne Kube Proxy

Kube Proxy est un **processus léger** qui tourne sur **chaque nœud** du cluster. Sa fonction clé :
- **Surveiller** la création des Services,
- **Configurer les règles réseau** qui redirigent le trafic vers les pods correspondants.

Méthode courante : les **règles iptables**.

**Exemple** : si un Service reçoit l'IP `10.96.0.12`, Kube Proxy configure les iptables de chaque nœud pour que **tout trafic vers cette IP** soit **transféré vers l'IP réelle du pod** (ex. `10.32.0.15`). Cette redirection rend les Services **transparents** dans tout le cluster, quel que soit le nœud émetteur.

### Installation de Kube Proxy

1. Télécharger le binaire depuis la page des releases.
2. L'extraire et le lancer comme **service** sur les nœuds.

> Avec **kubeadm**, Kube Proxy est déployé comme **DaemonSet** → garantit **une instance de Kube Proxy sur chaque nœud**, automatiquement.

Exemple de configuration de service :
```bash
wget https://dl.k8s.io/v1.34.12/bin/linux/amd64/kube-proxy

# kube-proxy.service
ExecStart=/usr/local/bin/kube-proxy \
    --config=/var/lib/kube-proxy/config.conf \
    --hostname-override=control # hostname du noeud
```

### Vérifier le déploiement

```bash
kubectl get pods -n kube-system
kubectl get daemonset -n kube-system
```
Ces commandes confirment que Kube Proxy est déployé et fonctionne.

Vérifier le processus et ses options actives :
```bash
ps -aux | grep kube-proxy
```

### À retenir

- **Service = IP stable ; Pod = IP éphémère.** Kube Proxy fait le lien entre les deux.
- Un **Service** est une abstraction virtuelle (endpoint persistant), **pas** un conteneur ni une interface réseau.
- **Kube Proxy tourne sur chaque nœud** : il observe les Services et programme les **règles réseau** (souvent **iptables**, parfois **IPVS**) pour rediriger `IP de Service → IP de pod`.
- Avec **kubeadm**, il est déployé en **DaemonSet** dans `kube-system` → un pod par nœud, garanti.
- Vérification : `kubectl get pods -n kube-system` et `kubectl get daemonset -n kube-system`.
- À ne pas confondre : le **DNS du cluster** (CoreDNS) résout le *nom* du Service en IP ; **Kube Proxy** route ensuite cette IP vers le pod.

### Liens utiles

- Page des releases Kubernetes : https://github.com/kubernetes/kubernetes/releases
- Page de téléchargement des releases Kubernetes : https://kubernetes.io/releases/download/, https://dl.k8s.io/
- Référence des flags kube-proxy : https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/
- Concept des Services : https://kubernetes.io/docs/concepts/services-networking/service/
