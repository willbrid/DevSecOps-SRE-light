# Les composants d'un Dockerfile
Dockerfile : un fichier qui définit une série de directives et est utilisé pour créer une image.

Un exemple de Dockerfile :
```
# Simple nginx image
FROM ubuntu:bionic
ENV NGINX_VERSION 1.14.0-0ubuntu1.2
RUN apt-get update && apt-get install -y curl
RUN apt-get update && apt-get install -y nginx=$NGINX_VERSION
CMD ["nginx", "-g", "daemon off;"]
```

Construire une image avec ce dockerfile :
```
docker build -t TAG_NAME DOCKERFILE_LOCATION
```

Quelques directives Dockerfile : <br>
- **FROM** : Spécifie l'image de base à partir de laquelle construire.

- **ENV** : définit les variables d'environnement qui sont visibles dans les étapes de construction ultérieures ainsi que pendant l'exécution du conteneur.

- **RUN** : exécute une commande et valide le résultat dans le système de fichiers image.

- **CMD** : Définit la commande par défaut pour les conteneurs, et cela est remplacé si une commande est spécifiée lors de l'exécution du conteneur.

- **ENTRYPOINT** : Définit l'exécutable par défaut pour les conteneurs. Cela peut toujours être remplacé lors de l'exécution du conteneur, mais nécessite un indicateur spécial. Lorsque ENTRYPOINT et CMD sont tous deux utilisés, ENTRYPOINT définit l'exécutable par défaut et CMD définit les arguments par défaut.

- **EXPOSE** : Documente les ports destinés à être publiés lors de l'exécution.
Remarque : cela ne publie pas réellement les ports.

- **WORKDIR** : définit le répertoire de travail, à la fois pour les étapes de construction suivantes et pour le conteneur au moment de l'exécution. Nous pouvons utiliser WORKDIR plusieurs fois. Si le WORKDIR commence par une barre oblique / , il définira un chemin absolu. Sinon, il définira le répertoire de travail par rapport au répertoire de travail précédent.

- **COPY** : copie les fichiers de l'hôte de construction dans le système de fichiers image.

- **ADD** : copie les fichiers de l'hôte de construction dans le système de fichiers image. Contrairement à COPY , ADD peut également extraire une archive dans le système de fichiers image et ajouter des fichiers à partir d'une URL distante.

- **STOPSIGNAL** : Définit un signal personnalisé qui sera utilisé pour arrêter le processus du conteneur.

- **HEALTHCHECK** : Définit une commande qui sera utilisée par le démon Docker pour vérifier si le conteneur est sain.
<br>

Exemple :
```
vi Dockerfile
```

```
FROM golang:1.12.4
WORKDIR /helloworld
COPY helloworld.go .
RUN GOOS=linux go build -a -installsuffix cgo -o helloworld .
CMD ["./helloworld"]
```

```
docker build -t inefficient .
docker run inefficient
docker image ls
```

Construction en plusieurs étapes (Multi-Stage Build) : une construction à partir d'un Dockerfile avec plusieurs directives FROM. Il est utilisé pour copier sélectivement les fichiers dans l'étape finale, en gardant l'image résultante aussi petite que possible.
<br>
Exemple :
```
vi Dockerfile
```

```
FROM golang:1.12.4 AS compiler
WORKDIR /helloworld
COPY helloworld.go .
RUN GOOS=linux go build -a -installsuffix cgo -o helloworld .

FROM alpine:3.9.3
WORKDIR /root
COPY --from=compiler /helloworld/helloworld .
CMD ["./helloworld"]
```