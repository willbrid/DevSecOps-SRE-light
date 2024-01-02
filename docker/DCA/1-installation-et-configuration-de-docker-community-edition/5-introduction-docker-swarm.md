# Introduction à Docker Swarm
Docker Swarm : une solution de gestion de cluster fournie avec Docker. Il nous permet de créer et de gérer un cluster de serveurs Docker.<br>
Manager : Un serveur dans un Swarm qui contrôle le cluster Swarm et délègue le travail aux workers. <br>
Worker: un serveur dans le Swarm qui exécute les charges de travail du conteneur.<br>

## Configuration d'un Swarm Manager

Pour configurer un manager swarm, il faudrait au préalable Docker CE sur le noeud manager (voir installation dans ce repo).
<br>
Nous initialisons un cluster swarm :
```
docker swarm init --advertise-addr <swarm manager private IP>
```

Nous définissons *--advertise-addr* sur une adresse sous laquelle les autres nœuds swarm verront ce nœud. Généralement c'est l'adresse IP privée du noeud manager. 
<br>
Nous pouvons trouver des informations sur l'état actuel du swarm en utilisant :
```
docker info
```

Nous pouvons lister les noeuds du cluster swarm :
```
docker node ls
```

## Configuration des nœuds workers Swarm

Pour configurer un noeud worker swarm, il faudrait au préalable Docker CE sur le noeud worker (voir installation dans ce repo).
<br>

Nous devons récupérez un jeton de jointure auprès du manager en exécutant cette commande sur le manager Swarm :
```
docker swarm join-token worker
```

Nous copions maintenant le token de jointure fourni dans la sortie et exécutons la commande suivante sur tous les nœuds worker :
```
docker swarm join --token <token> <swarm manager private IP>:2377
```

Sur le Swarm Manager, vérifions que tous les noeuds worker se sont joints avec succès.
```
docker node ls
```

Tous les nœuds doivent apparaître dans la liste, y compris le manager.

## Sauvegarde et restauration Docker Swarm
- Sauvegardons les données du cluster Swarm

Sur le noeud manager, stoppons le démon docker :
```
sudo systemctl stop docker
```

Ensuite archivons les données swarm situées dans */var/lib/docker/swarm* , puis redémarrons Docker.
```
sudo tar -zvcf backup.tar.gz /var/lib/docker/swarm
sudo systemctl start docker
```

- Restore depuis une sauvergarde

Sur le noeud manager, stoppons le démon docker :
```
sudo systemctl stop docker
```

Supprimons toutes les données actuellement dans le répertoire de données swarm :
```
sudo rm -rf /var/lib/docker/swarm/*
```

Développons les données de sauvegarde archivées dans le répertoire de données swarm et démarrons Docker :
```
sudo tar -zxvf backup.tar.gz -C /var/lib/docker/swarm/
sudo systemctl start docker
```

Vérifions que tous les nœuds fonctionnent correctement dans le cluster swarm après la restauration :
```
docker node ls
```