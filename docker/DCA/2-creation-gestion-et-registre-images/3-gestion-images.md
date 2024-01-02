# Gestion des images
Voici quelques commandes clés pour la gestion des images : <br>

- Liste les images sur le système
```
docker image ls
```

- Liste les images en incluant les images intermédiaires
```
docker image ls -a
```

- Obtenir des informations détaillées sur une image.
```
docker image inspect IMAGE 
```

- Obtenir des informations détaillées sur une image avec un format précisé pour récupérer des champs de données spécifiques sur l'image.
```
docker image inspect IMAGE --format "format"
```

Exemple :
```
docker image inspect nginx:1.14.0 --format "{{.Architecture}}"
docker image inspect nginx:1.14.0 --format "{{.Architecture}} {{.Os}}"
```

- Supprimer une image. Une image ne peut être supprimée que si aucun conteneur ou autre balise d'image ne la référence.
```
docker image rm IMAGE
docker rmi IMAGE
```

- Force la suppression d'une image, même si elle est référencée par autre chose.
```
docker image rm -f IMAGE
```

- recherchez et supprimez les images pendantes ou inutilisées.
```
docker image prune
```

- Docker ne fournit pas de méthode officielle pour transformer une image multicouche en une seule couche. Nous pouvons contourner ce problème en exécutant un conteneur à partir de l'image, en exportant le système de fichiers du conteneur, puis en important ces données en tant que nouvelle image.
<br>

Exemple :
1. Configurons un nouveau répertoire de projet pour créer une image de base :
```
cd ~/
mkdir alpine-hello
cd alpine-hello
vi Dockerfile
```

2. Créeons un Dockerfile qui se traduira par une image multicouche :
```
FROM alpine:3.9.3
RUN echo "Hello, World!" > message.txt
CMD cat message.txt
```

3. Créeons l'image et vérifiez le nombre de couches qu'elle contient :
```
docker build -t nonflat .
docker image history nonflat
```

4. Exécutons un conteneur à partir de l'image et exportons son système de fichiers vers une archive :
```
docker run -d --name flat_container nonflat
docker export flat_container > flat.tar
```

5. Importons l'archive dans une nouvelle image et vérifions le nombre de couches de la nouvelle image :
```
cat flat.tar | docker import - flat:latest
docker image history flat
```