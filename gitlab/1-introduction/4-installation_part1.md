# Installation [Part1]

Ici nous installerons un cluster kubernetes à un seul noeud avec **kind** et un serveur de messagerie avec **mailserver/docker-mailserver**.

### Mise en place de notre cluster kubernetes à un seul noeud avec kind sur le serveur kubernetes

##### Installation de kind

```
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
```

```
chmod +x ./kind
```

```
sudo mv ./kind /usr/local/bin/kind
```

##### Démarrage du cluster avec kind pour la version v1.28 de kubernetes

```
sudo su
echo "export PATH=$PATH:/usr/local/bin" >> ~/.bashrc
source ~/.bashrc
```

```
kind create cluster --image=kindest/node:v1.28.0@sha256:b7a4cad12c197af3ba43202d3efe03246b3f0793f162afb40a33c923952d5b31
```

Par défaut, la configuration d'accès au cluster est stockée dans **\${HOME}/.kube/config** si la variable d'environnement **$KUBECONFIG** n'est pas définie.

##### Installation de kubectl pour la version v1.28 de kubernetes

```
sudo vi /etc/yum.repos.d/kubernetes.repo
```

```
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubectl
```

```
sudo dnf upgrade -y
```

```
sudo dnf install -y kubectl-1.28.0 --disableexcludes=kubernetes
```

```
kubectl version
```

Vérification du bon fonctionnement du cluster

```
kubectl get nodes
```

### Mise en place d'un serveur de messagerie avec mailserver/docker-mailserver

