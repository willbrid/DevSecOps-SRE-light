# Prérequis

Nous allons fixer les prérequis avant installation de opensearch, en se penchant sur 2 points : les ports à ouvrir et les paramètres importants à configurer sur notre hôte.

### Configuration système

- Configuration du paramètre Linux vm.max_map_count

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

- Définir la taille du Java heap (nous recommandons la moitié de la RAM système).

```
# pour une mémoire de 1Go
OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m
```

- Désactiver le swap (avec **memlock**). Le swap peut réduire considérablement les performances et la stabilité, nous devons donc nous assurer qu'il est désactivé sur les clusters de production.

```
bootstrap.memory_lock=true
```

### Configuration réseau

Les ports suivants doivent être ouverts pour les composants OpenSearch.

```
5601 => Tableaux de bord OpenSearch
9200 => API REST OpenSearch
9300 => Communication et transport de nœuds (internes), recherche entre clusters
9600 => Analyseur de performances
```