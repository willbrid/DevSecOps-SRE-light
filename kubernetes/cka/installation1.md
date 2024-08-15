# Installation d'un cluster k8s version 1.30 avec containerd sur ubuntu server 22.04

Dans cette section nous mettrons en place un cluster k8s à 4 noeuds avec **containerd**.

**Hypothèse**: On supposera que l'environnement **sandbox** est déjà mis en place.

[Mise en place de la Sandbox](https://github.com/willbrid/kubernetes-light/blob/main/cka/sandbox.md)

### Configuration du hostname et du fichier hosts

Avec Vagrant les hostname sur chaque machine sont déjà configurés. Donc l'on peut sauter cette section.

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
sudo hostnamectl set-hostname k8s-worker3
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

### Configuration du containerd

**Configuration des modules kernel : overlay et br_netfilter pour containerd**

```
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

**Activation du routage des paquets et permission de la communication par pont entre conteneurs**

```
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
```

**Installation et configuration de containerd**

--- installation de containerd

```
wget https://github.com/containerd/containerd/releases/download/v1.7.20/containerd-1.7.20-linux-amd64.tar.gz
sudo tar Czxvf /usr/local containerd-1.7.20-linux-amd64.tar.gz
```

```
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir -p /usr/local/lib/systemd/system
sudo mv containerd.service /usr/local/lib/systemd/system/
sudo chown root:root /usr/local/lib/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl status containerd
```

--- configuration de **containerd** avec prise en charge du **cgroup**

```
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
```

### Désactivation du Swap

Sur tous les noeuds, il faudrait désactiver le swap.

```
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

### Installation des packages kubeadm, kubelet et kubectl

Sur tous les noeuds, il faudrait installer les packages kubeadm, kubelet, et kubectl.

```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

```
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

```
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

NB: La dernière commande avec **apt-mark** permet de désactiver la mise à jour automatique des packages kubelet kubeadm et kubectl.

### Initialisation du cluster

Sur le nœud master (**k8s-control**) uniquement, initialisons le cluster et configurons l'accès kubectl.

```
sudo kubeadm init --pod-network-cidr 172.16.0.0/16 --apiserver-advertise-address 192.168.56.87 --kubernetes-version 1.30.4
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

L'option **--apiserver-advertise-address** permet de choisir l'adresse IP sur laquelle le serveur API écoutera.

NB: Ici **172.16.0.0/16** sera la plage du réseau privé de notre cluster. La version exacte de kubernetes **1.30.4** mentionnée dans la commande d'initialisation du cluster peut être obtenue avec la commande :

```
kubectl version
```

```
# Exemple de résultat
Client Version: v1.30.4
...
```

Nous pouvons vérifier si le cluster fonctionne.

```
kubectl get nodes
```

### Installation du module complémentaire réseau Calico.

```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### Ajout des noeuds worker au cluster

**Obtenir la commande de jointure**

```
kubeadm token create --print-join-command
```

NB: cette commande est également affichée à la fin de l'exécution de la commande **kubeadm init**.

**Jointure proprement dit**

Copiez la commande join (résultat de la commande ci-dessus) à partir du nœud master. Exécutez-le sur chaque nœud worker en tant que root (c'est-à-dire avec sudo ).

```
sudo kubeadm join ...
```

Sur le nœud master, vérifiez que tous les nœuds de votre cluster sont prêts. Notez que cela peut prendre quelques instants pour que tous les nœuds passent à l'état **PRÊT** (**READY**).

```
kubectl get nodes
```