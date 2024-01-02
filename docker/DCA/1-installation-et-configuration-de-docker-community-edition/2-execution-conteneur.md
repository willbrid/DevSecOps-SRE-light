# Exécution d'un conteneur
## *Docker Run* : quelques commandes et processus clés :

Pour lancer un container : 
```
docker run IMAGE[:TAG] [COMMAND] [ARGS]
```

- IMAGE : permet d'exécuter un conteneur à l'aide d'une image. Dans cet exemple, l'image est appelée *hello-world*, le tag n'est pas spécifié, le tag *latest* sera donc automatiquement utilisé.
```
docker run hello-world
```

- COMMANDE et ARGS : permet d'exécuter une commande à l'intérieur du conteneur. Cette commande exécute un conteneur à l'aide de l'image *busybox*. A l'intérieur du conteneur, il exécute en plus la commande *echo* avec les arguments *hello world!* .
```
docker run busybox echo hello world!
```

- TAG : cette commande spécifie un certain tag. Exécutons un conteneur avec le tag *1.15.11* de l'image *nginx*.
```
docker run nginx:1.15.11
```

- -d : permet d'exécuter le conteneur en mode détaché. La commande se ferme immédiatement et le conteneur continue de s'exécuter en arrière-plan.
```
docker run -d nginx:1.15.11
```

- --name NAME : permet de donner au conteneur un nom spécifié au lieu du nom habituel attribué de manière aléatoire.
```
docker run --name nginx nginx:1.15.11
```

- --restart RESTART : permet de spécifier quand Docker doit automatiquement redémarrer le conteneur. <br>
--- no (par défaut): ne jamais redémarrer le conteneur. <br>
--- on-failure: uniquement si le conteneur échoue (sortie avec un code de sortie différent de zéro). <br>
--- always : permet de redémarrer toujours le conteneur, qu'il réussisse ou échoue. Permet de démarrer également le conteneur automatiquement au démarrage du démon.<br>
--- unless-stopped : permet de redémarrer toujours le conteneur, qu'il réussisse ou échoue, et au démarrage du démon, sauf si le conteneur est arrêté manuellement.<br>

- -p HOST_PORT:CONTAINER_PORT : permet de publier le port d'un conteneur. Ce processus est nécessaire pour accéder à un port sur un conteneur en cours d'exécution. Le *HOST_PORT* est le port qui écoute sur la machine hôte, et le trafic vers ce port est mappé au *CONTAINER_PORT* sur le conteneur.<br>

- -memory MEMORY : permet de définir une limite stricte sur l'utilisation de la mémoire.<br>

- --memory-reservation MEMORY : permet de définir une limite logicielle sur l'utilisation de la mémoire. Cette limite est utilisée uniquement si Docker détecte une contention de mémoire sur l'hôte.

Ci-après un exemple complet :
```
docker run -d --name nginx --restart unless-stopped -p 8080:80 --memory 500M --memory-reservation 256M nginx
```

## Gestion des conteneurs
Certaines des commandes de gestion des conteneurs en cours d'exécution : <br>

- lister les conteneurs en cours d'exécution.
```
docker ps
```

- lister tous les conteneurs, y compris les conteneurs arrêtés.
```
docker ps -a 
```

- arrêter un conteneur en cours d'exécution.
```
docker container stop <nom ou ID du conteneur> 
```

- démarre un conteneur arrêté.
```
docker container start <nom ou ID du conteneur>
```

- supprimer un conteneur (il doit d'abord être arrêté).
```
docker container rm <container name or ID>
```