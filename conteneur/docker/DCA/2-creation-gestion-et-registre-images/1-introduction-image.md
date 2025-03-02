# Introduction des images Docker

Image : un package exécutable contenant tous les logiciels nécessaires à l'exécution d'un conteneur.

Exécutons un conteneur à l'aide d'une image avec :

```
docker run IMAGE
```

Exemple :

```
docker run nginx:1.15.8
```

Téléchargeons une image avec :

```
docker image pull IMAGE
docker pull IMAGE
```

Exemple :

```
docker image pull nginx:1.15.8
```

Système de fichiers en couches : les images et les conteneurs utilisent un système de fichiers en couches. Chaque couche ne contient que les différences par rapport à la couche précédente.

Affichons les couches du système de fichiers dans une image avec :

```
docker image history IMAGE
```

Exemple :

```
docker image history nginx
```