# Configuration du repo privé

Nous allons dans cette partie configurer un repo privé pour les packages **Red Hat 8.10**, les packages de kubernetes (**kubeadm**, **kubectl**, **kubelet**) et du moteur d'exécution de conteneurs **cri-o**. Toutes les configurations se feront sur le serveur **rhel-repo-server**.

### Installation et configuration de Apache pour héberger tous les packages

- Installation

```
sudo dnf -y install httpd
```

- Configuration

--- Mise à jour du fichier **/etc/hosts**

```
sudo vi /etc/hosts
```

```
...
192.168.56.121 private-repo.willbrid.com
```

--- Configuration du fichier **/etc/httpd/conf/httpd.conf**

```
sudo vi /etc/httpd/conf/httpd.conf
```

```
...
ServerAdmin root@willbrid.com
...
ServerName private-repo.willbrid.com:80
...
ServerTokens Prod
```

```
sudo systemctl enable --now httpd
```

```
sudo firewall-cmd --permanent --add-service=http
```

```
sudo firewall-cmd --reload
```

```
sudo vi /var/www/html/index.html
```

```
<html>
    <body>
      <div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
      REPO PRIVE RED HAT 8.10
      </div>
    </body>
</html>
```

### Repo privé Red Hat 8.10

Etant donné que nous souhaiterons un repo privé spécifique **Red Hat 8.10**, alors le système du serveur **rhel-repo-server** doit être configuré sur la version mineure spécifique **8.10**.

```
sudo su
```

```
subscription-manager release --set=8.10 && rm -rf /var/cache/dnf
```

Créons le repertoire d'hergement des packages RHEL dans **/var/www/html**

```
mkdir -p /var/www/html/rhel/8.10
```

Exécutons la commande **reposync** pour télécharger tous les packages **x86_64** à partir du référentiel mentionné :

```
reposync -p /var/www/html/rhel/8.10 --download-metadata --repoid=rhel-8-for-x86_64-appstream-rpms
```

```
reposync -p /var/www/html/rhel/8.10 --download-metadata --repoid=rhel-8-for-x86_64-baseos-rpms
```

**Important**

- L'option **-n** peut être utilisée pour télécharger uniquement la version la plus récente des packages au lieu de chaque version de chaque package.

- L'option **--delete** peut être utilisée pour supprimer tous les packages qui ne font pas partie de la synchronisation actuelle. (Comme les packages plus anciens lorsque **-n** télécharge une nouvelle version). Nous aurons besoin d'un système pour chaque version majeure que nous synchronisons. **RHEL 8** ne peut pas accéder au contenu de **RHEL 9** et vice versa.

- Sur **RHEL 8**, s'assurer d'installer **yum-utils-4.0.8-3.el8.noarch** ou une version supérieure afin que **reposync** télécharge correctement tous les packages.

- L'utilitaire **reposync** ne peut mettre en miroir que les référentiels auxquels le système a droit.

### Repo privé kubernetes 1.30 et cri-o 1.30

Nous créons les fichiers **/etc/yum.repos.d/kubernetes.repo** et **/etc/yum.repos.d/cri-o.repo** pour kubernetes et cri-o pour leur version **1.30**.


```
sudo su
```

```
vi /etc/yum.repos.d/kubernetes.repo
```

```
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
```

```
vi /etc/yum.repos.d/cri-o.repo
```

```
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/stable:/v1.30/rpm/repodata/repomd.xml.key
```

Pour avoir l'exactitude des identifiants des repo kubernetes et cri-o, nous pouvons exécuter les commandes :

```
yum repolist all | grep -i kubernetes
```

```
yum repolist all | grep -i cri-o
```

Créons les repertoires d'hergement des packages de kubernetes et cri-o dans **/var/www/html**

```
mkdir -p /var/www/html/kubernetes/1.30
```

```
mkdir -p /var/www/html/cri-o/1.30
```

Exécutons la commande **reposync** pour télécharger tous les packages kubernetes et cri-o :

```
reposync -p /var/www/html/kubernetes/1.30 --download-metadata --repoid=kubernetes
```

```
reposync -p /var/www/html/cri-o/1.30 --download-metadata --repoid=cri-o
```