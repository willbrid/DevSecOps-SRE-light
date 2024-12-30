# Prérequis

Nous allons fixer les prérequis avant installation de opensearch, en se penchant sur 2 points : les ports à ouvrir et les paramètres importants à configurer sur notre hôte.

### Configuration du paramètre Linux vm.max_map_count

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

Pour notre architecture avec conteneur, en plus de la configuration ci-dessus, nous devons désactiver le swap :

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