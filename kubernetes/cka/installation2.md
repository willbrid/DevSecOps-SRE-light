# Installation d'un cluster k8s version 1.30 avec cri-o sur Rocky linux 8

Dans cette section nous mettrons en place un cluster k8s à 4 noeuds avec podman.

**Hypothèse**: On supposera que l'environnement **sandbox** est déjà mis en place pour **Rocky linux 8**.

[Mise en place de la Sandbox](https://github.com/willbrid/kubernetes-light/blob/main/cka/sandbox.md)

### Configuration du hostname et du fichier hosts

**Sur le nœud master (k8s-control)**

```
sudo hostnamectl set-hostname k8s-control
```

**Sur le nœud worker 1 (k8s-worker1)**

```
sudo hostnamectl set-hostname k8s-worker1
```

**Sur le nœud worker 2 (k8s-worker2)**

```
sudo hostnamectl set-hostname k8s-worker2
```

**Sur le nœud worker 3 (k8s-worker3)**

```
sudo hostnamectl set-hostname k8s-worker2
```

**Configuration du fichier hosts**

Sur tous les nœuds, configurez le fichier hosts pour permettre à tous les nœuds de se joindre à l'aide de ces noms d'hôte.
```
sudo vi /etc/hosts
```

Sur tous les nœuds, ajoutez ce qui suit à la fin du fichier. Vous devrez fournir l'adresse IP privée pour chaque nœud.
```
192.168.56.87   k8s-control
192.168.56.88   k8s-worker1
192.168.56.89   k8s-worker2
192.168.56.90   k8s-worker3
```

### Configuration de base sur tous les noeuds

**Mettons à jour selinux en mode permissive**

```
sudo setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux
```

**Désactivation du swap**

```
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

### Mise en place des préréquis pour l'exécuteur de conteneur cri-o version 1.30

**Configuration du module kernel br_netfilter pour cri-o**

```
cat << EOF | sudo tee /etc/modules-load.d/cri-o.conf
br_netfilter
EOF

sudo modprobe br_netfilter
```

**Activation du routage des paquets et permission de la communication par pont entre conteneurs**

```
cat <<EOF | sudo tee /etc/sysctl.d/cri-o.conf
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
```

**Installation de container-selinux**

```
sudo dnf install -y container-selinux
```

## Configuration du parefeu firewall-cmd pour autoriser les ports de k8s

**Sur le noeud master**

```
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10252/tcp
sudo firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --reload
```

**Sur les noeuds worker**

```
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=30000-32767/tcp
sudo firewall-cmd --add-masquerade --permanent
sudo firewall-cmd --reload
```

Cette configuration de parefeu est basée sur la liste de ports par défaut des composants de k8s dont vous pouvez consulter via ce lien : [k8s-ports-and-protocols](https://kubernetes.io/docs/reference/ports-and-protocols/) .

### Installation du cluster k8s

**Ajout du repo k8s sur tous les noeuds**

```
sudo vi /etc/yum.repos.d/kubernetes.repo
```

```
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
```

L'on pourra vérifier les versions disponibles pour *1.30* de chacun des packages *kubelet*, *kubeadm*, *kubectl* et *cri-o* :

```
sudo dnf --showduplicates list kubelet --disableexcludes=kubernetes
sudo dnf --showduplicates list kubeadm --disableexcludes=kubernetes
sudo dnf --showduplicates list kubectl --disableexcludes=kubernetes
```

**Installation des packages *kubelet*, *kubeadm*, *kubectl* et *cri-o* sur tous les noeuds**

```
sudo dnf install -y kubelet kubeadm kubectl cri-o --disableexcludes=kubernetes
```

**Configuration de cri-tools**

La commande d'installation de *kubelet*, *kubeadm*, *kubectl* et *cri-o* installera aussi le binaire **crictl** de **cri-tools**.

Testons l'installation de **crictl** en exécutant

```
sudo crictl image ls
```

**Démarrage et activation du kubelet sur tous les noeuds**

```
sudo systemctl enable --now kubelet
```

**Initialisation du cluster sur le noeud master**

Sur le nœud master (k8s-control) uniquement, initialisons le cluster et configurons l'accès kubectl.

```
sudo kubeadm init --pod-network-cidr 172.16.0.0/16 --apiserver-advertise-address 192.168.56.87 --kubernetes-version 1.30
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

NB: Ici **172.16.0.0/16** sera la plage du réseau privé de notre cluster.

Nous pouvons vérifier si le cluster fonctionne :

```
kubectl get nodes
```

**Installation du module complémentaire réseau Calico**

```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

**Ajout des noeuds worker au cluster**

L'on peut obtenir la commande de jointure avec la commande :

```
kubeadm token create --print-join-command
```

Le résultat de cette commande est également affichée à la fin de l'exécution de la commande *kubeadm init*.<br>

Copiez la commande join (résultat de la commande ci-dessus) à partir du nœud master. Exécutez-le sur chaque nœud worker en tant que root (c'est-à-dire avec sudo ).

```
sudo kubeadm join ...
```

Sur le nœud master, vérifiez que tous les nœuds de votre cluster sont prêts. Notez que cela peut prendre quelques instants pour que tous les nœuds passent à l'état PRÊT (READY).

```
kubectl get nodes
```