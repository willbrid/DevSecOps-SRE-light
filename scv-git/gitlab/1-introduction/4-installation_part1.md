# Installation [Part1]

Ici nous installerons un cluster kubernetes à un seul noeud avec **kind** et un serveur de messagerie avec **mailserver/docker-mailserver** et **roundcubemail**.

### Configuration du fichier /etc/hosts sur tous les serveurs de notre architecture

Sur chaque serveur de notre architecture, configurons le fichier **/etc/hosts** comme suit :

```
sudo vi /etc/hosts
```

```
192.168.56.170  gitlab.willbrid.com
192.168.56.171  gitlab-runner.willbrid.com
192.168.56.173  mail.willbrid.com
```

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

### Mise en place d'un serveur de messagerie avec mailserver/docker-mailserver et roundcubemail sur le serveur mail

- Créons les repertoires de mail pour docker-mailserver

```
mkdir dms && mkdir dms/mail-data dms/mail-state dms/mail-logs dms/config
```

- Activons **podman.socket** dans l'espace utilisateur de systemd avec un utilisateur non root : **vagrant**.

```
systemctl enable --now --user podman.socket
```

```
export DOCKER_HOST="unix:///var/run/user/$(id -u)/podman/podman.sock"
```

- Démarrons **docker-mailserver**

```
podman run -d \
       -e OVERRIDE_HOSTNAME=mail.willbrid.com \
       -e POSTMASTER_ADDRESS=postmaster@willbrid.com \
       -e POSTFIX_INET_PROTOCOLS=ipv4 \
       -e PERMIT_DOCKER=none \
       -e ONE_DIR=1 \
       -e NETWORK_INTERFACE=tap0 \
       -p 1025:25 \
       -p 1143:143 \
       -p 1587:587 \
       --tz local \
       -v $HOME/dms/mail-data:/var/mail:z \
       -v $HOME/dms/mail-state:/var/mail-state:z \
       -v $HOME/dms/mail-logs:/var/log/mail:z \
       -v $HOME/dms/config:/tmp/docker-mailserver:z \
       --name mailserver \
       mailserver/docker-mailserver:13.2.0
```

Puis on se connecte au container mailserver et on exécute la commande permettant d'ajouter une boîte mail : **gitlab-dev@willbrid.com**

```
podman exec -it mailserver /bin/sh
```

```
setup email add gitlab-dev@willbrid.com
```

Le mot de passe entré pour cette boîte email est **test**.

- Créons les repertoires d'installation de **roundcubemail**

```
mkdir roundcubemail && mkdir roundcubemail/www roundcubemail/sqlite
```

- Démarrons **roundcubemail**

```
podman run -d \
       -v $HOME/roundcubemail/www:/var/www/html:z \
       -v $HOME/roundcubemail/sqlite:/var/roundcube/db:z \
       -e ROUNDCUBEMAIL_DEFAULT_HOST=mail.willbrid.com \
       -e ROUNDCUBEMAIL_DEFAULT_PORT=1143 \
       -e ROUNDCUBEMAIL_SMTP_SERVER=mail.willbrid.com \
       -e ROUNDCUBEMAIL_SMTP_PORT=1025 \
       -e ROUNDCUBEMAIL_DB_TYPE=sqlite \
       -p 8080:80 \
       --name roundcubemail \
       roundcube/roundcubemail:1.5.6-apache
```

- Autorisons les ports 1025 et 8080 sur le serveur **mail**

```
sudo firewall-cmd --permanent --add-port=1025/tcp --add-port=8080/tcp
sudo firewall-cmd --reload
```

Au niveau de notre fichier **/etc/hosts** de notre machine hôte ubuntu 20.04, nous ajoutons :

```
sudo vi /etc/hosts
```

```
...
192.168.56.173  mail.willbrid.com
```

Nous accédons à l'interface web du serveur **roundcubemail** via l'url : http://mail.willbrid.com:8080/ et nous saisissons les paramètres d'authentification de notre compte créé **gitlab-dev@willbrid.com**.

```
Login : gitlab-dev@willbrid.com
Password : test
```