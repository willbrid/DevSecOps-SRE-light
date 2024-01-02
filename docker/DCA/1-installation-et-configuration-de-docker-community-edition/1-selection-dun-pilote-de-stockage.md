# Sélection d'un pilote de stockage
Pilote de stockage : un pilote enfichable qui gère le stockage interne des conteneurs. <br>
Actuellement, le pilote par défaut pour les systèmes Rocky Linux 8, CentOS et Ubuntu est *overlay2* . <br>
Le pilote de stockage *devicemapper* est parfois utilisé sur les systèmes CentOS/RedHat, en particulier dans les anciennes versions de Docker.

Nous pouvons déterminer le pilote de stockage actuel avec la commande *docker info* :
```
docker info | grep "Storage"
```

## Utilisation d'une option du démon docker pour définir le pilote de stockage
Une façon de sélectionner un autre pilote de stockage consiste à transmettre l'indicateur *--storage-driver* au démon Docker. <br>
Par exemple, nous pouvons modifier le fichier d'unité *systemd* de Docker : /usr/lib/systemd/system/docker.service . N'oublions pas d'ajouter l'indicateur *--storage-driver \<nom du pilote\>* à l'appel à dockerd .
```
sudo vi /usr/lib/systemd/system/docker.service
```

```
ExecStart=/usr/bin/dockerd --storage-driver <nom du pilote> ...
```

Après toute modification du fichier *docker.service*, rechargeons Systemd et redémarrons Docker :
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## Utilisation du fichier de configuration du démon pour définir le pilote de stockage
Nous pouvons également définir explicitement le pilote de stockage à l'aide du fichier de configuration du démon. C'est la méthode recommandée par Docker. <br>
Notons que nous ne pouvons pas faire cela et passer l'indicateur *--storage-driver* au démon en même temps :
```
sudo vi /etc/docker/daemon.json
```

```
{
  "storage-driver": "nomDuPilote"
}
```

Une fois les modifications apportées à */etc/docker/daemon.json* , n'oublions pas de redémarrer Docker. C'est également une bonne idée de vérifier l'état de Docker après le redémarrage, car un fichier de configuration mal formé entraînera un échec de démarrage de Docker. Utilisons les commandes suivantes :
```
sudo systemctl restart docker
sudo systemctl status docker
```