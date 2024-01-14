# Prérequis

Nous allons fixer les prérequis avant installation de opensearch, en se penchant sur 3 points : les systèmes d'exploitation compatibles avec OpenSearch, les ports à ouvrir et les paramètres importants à configurer sur notre hôte.

## Systèmes d'exploitation

La documentation officielle recommande d'installer OpenSearch sur Red Hat Enterprise Linux (RHEL) ou les distributions Linux basées sur Debian qui utilisent systemd, telles que CentOS, Amazon Linux 2 ou Ubuntu Long-Term Support (LTS). C'est pourquoi nous avons fait le choix du système rocky linux.

## Système de fichiers

Évitons d'utiliser un système de fichiers réseau (NFS) pour le stockage des nœuds dans un workflow de production. L'utilisation d'un système de fichiers réseau pour le stockage des nœuds peut entraîner des problèmes de performances dans notre cluster en raison de facteurs tels que les conditions du réseau (comme la latence ou le débit limité) ou les vitesses de lecture/écriture. Dans la mesure du possible, nous devons utiliser des disques SSD installés sur l'hôte pour le stockage des nœuds.

## Compatibilité Java

Selon les récommandations de la documentation officielle, pour la version **2.7.x** d'**opensearch** dont nous installerons, nous allons installer java 11 (java-11-openjdk) sur chaque noeud de notre cluster. 

```
sudo yum install epel-release -y
```

```
sudo yum install yum-utils
sudo yum-config-manager --enable epel
```

```
sudo yum install java-11-openjdk -y
```

NB: Cette installation s'applique uniquement pour l'architecture avec les machines virtuelles.

## Configuration réseau requise

Sur chacun de nos noeuds, nous allons ouvrir les ports : **9200** (port api rest), **9250** (port de recherche inter-clusters), **9300** (port de communication et de transport) et **9600** (port d'analyseur de performances).

```
sudo firewall-cmd --permanent --add-port=9200/tcp
sudo firewall-cmd --permanent --add-port=9250/tcp 
sudo firewall-cmd --permanent --add-port=9300/tcp
sudo firewall-cmd --permanent --add-port=9600/tcp  
```

Sur notre noeud de coordination, nous allons ouvrir les ports **443** (port https du dashboard opensearch) et **5601** (port du dashboard opensearch).

```
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=5601/tcp  
```

Puis après configuration, nous appliquons les modifications de notre parefeu sur chacun de nos noeuds avec la commande :

```
sudo firewall-cmd --reload
```

NB: Cette configuration est valable pour notre architecture avec machine virtuelle. Pour notre architecture avec conteneur, il suffira d'ouvrir uniquement les ports **443** et **5061**.

## Configuration du paramètre Linux vm.max_map_count

Nous allons configurer le paramètre Linux **vm.max_map_count** afin de le définr sur au moins **262144**.

```
sudo vi /etc/sysctl.conf
```

```
vm.max_map_count=262144
```

```
sudo sysctl -p
```

Puis nous vérifions la configuration effectuée avec la commande 

```
cat /proc/sys/vm/max_map_count
```

Pour notre architecture avec conteneur, en plus de la configuration ci-dessus, nous devons désactiver le swapp :

```
sudo swapoff -a
```

```
sudo vi /etc/fstab
```

Nous commentons la ligne qui contient l'entrée de **swap** en ajoutant "#" au début de la ligne. Puis nous redemarrons le système :

```
sudo reboot
```

Encore pour notre architecture avec conteneur, nous allons installer docker. Ci-dessous un lien contenant l'installation de docker sous Rocky Linux 8.

[Installation de docker sous Rocky Linux 8](https://github.com/willbrid/docker-light/blob/main/Installation-in-rocky.md)