# Utilisation de notre repo local

Nous allons dans cette partie montrer comment utiliser notre repo local déjà configuré. Toutes les configurations se feront sur le serveur **rhel-server**.

- Désactivation de toute souscription active sur le système

Ici il s'agira de désenregistrer le système de **Red Hat Subscription Management**. Le système est retiré de l'inventaire de **Red Hat**, ce qui signifie qu'il ne sera plus associé au compte **Red Hat** et en plus toute souscription active pour le système sera désactivée.

```
sudo subscription-manager unregister
```

- Backup de tous les repos existants

```
mkdir $HOME/repo-backup && sudo mv /etc/yum.repos.d/*.repo $HOME/repo-backup
```

- Mise à jour du fichier **/etc/hosts**

```
sudo vi /etc/hosts
```

```
...
192.168.56.121 private-repo.willbrid.com
```

- Ajout des repos **appstream**, **baseos**, **kubernetes** et **cri-o**

```
cat <<EOF | sudo tee /etc/yum.repos.d/appstream.repo
[appstream]
name=appstream
baseurl=http://private-repo.willbrid.com/rhel/8.10/rhel-8-for-x86_64-appstream-rpms
enabled=1
EOF
```

```
cat <<EOF | sudo tee /etc/yum.repos.d/baseos.repo
[baseos]
name=baseos
baseurl=http://private-repo.willbrid.com/rhel/8.10/rhel-8-for-x86_64-baseos-rpms
enabled=1
EOF
```

```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=kubernetes
baseurl=http://private-repo.willbrid.com/kubernetes/1.30/kubernetes
enabled=1
EOF
```

```
cat <<EOF | sudo tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=cri-o
baseurl=http://private-repo.willbrid.com/cri-o/1.30/cri-o
enabled=1
EOF
```

A noter que chaque uri mentionné doit pointer vers le repertoire web du repo local (**rhel-repo-server**) contenant le repertoire **repodata**. C'est pourquoi nous avons cette correspondance ci-dessous :

```
rhel-repo-server : /var/www/html/rhel/8.10/rhel-8-for-x86_64-appstream-rpms -> rhel-server : http://private-repo.willbrid.com/rhel/8.10/rhel-8-for-x86_64-appstream-rpms

rhel-repo-server : /var/www/html/rhel/8.10/rhel-8-for-x86_64-baseos-rpms -> rhel-server : http://private-repo.willbrid.com/rhel/8.10/rhel-8-for-x86_64-baseos-rpms

rhel-repo-server : /var/www/html/kubernetes/1.30/kubernetes -> rhel-server : http://private-repo.willbrid.com/kubernetes/1.30/kubernetes

rhel-repo-server : /var/www/html/cri-o/1.30/cri-o -> rhel-server : http://private-repo.willbrid.com/cri-o/1.30/cri-o
```

- Test d'installation des packages : **httpd**, **kubeadm**, **kubelet**, **kubectl**, **cri-o**

```
sudo dnf install httpd kubeadm kubelet kubectl cri-o
```