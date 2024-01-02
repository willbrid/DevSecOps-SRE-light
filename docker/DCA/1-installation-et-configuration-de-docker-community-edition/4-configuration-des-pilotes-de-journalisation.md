# Configuration des pilotes de journalisation (Splunk, Journald, ...)
Pilote de journalisation : un pilote enfichable qui gère les données de journal des services et des conteneurs dans Docker. <br> 
Pour déterminer le pilote de journalisation par défaut actuel :
```
docker info | grep Logging
```

Pour définir un nouveau pilote par défaut, nous devons modifions le fichier */etc/docker/daemon.json* . L'option *log-driver* définit le pilote, et *log-opts* peut être utilisé pour fournir une configuration spécifique au pilote.

```
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "labels": "production_status",
    "env": "os,customer"
  }
}
```

Après avoir apporté des modifications au fichier */etc/docker/daemon.json*, nous devons redemarrer le moteur docker
```
sudo systemctl restart docker
```

Nous pouvons également remplacer le paramètre de pilote par défaut pour les conteneurs individuels à l'aide des indicateurs *--log-driver* et *--log-opt* avec la commande *docker run* .
```
docker run --log-driver json-file --log-opt max-size=10m nginx
```