# Construction d'une image de conteneur

Nous prendrons l'exemple de la construction de l'image d'une application web basique affichant le message *Welcome to my blog !*<br>

## Construction de l'image
- Nous créons notre répertoire de travail
```
mkdir website
cd website
``` 

- Nous créons un fichier *index.html* avec le contenur du message
```
vi index.html
```

```
Welcome to my blog !
```

- Nous créons notre fichier *Dockerfile*
```
vi Dockerfile
```

```
FROM nginx:stable
COPY index.html /usr/share/nginx/html/
```

- Nous construisons notre image version 0.0.1
```
docker build -t website:0.0.1 .
```

## Exploitation du container de l'image
- Nous créons un conteneur à partir de l'image *website:0.0.1* créé ci-dessus

```
docker run --rm --name website -d -p 8080:80 website:0.0.1
```

- Nous pouvons vérifier si le conteneur écoute bien sur le port 8080
```
curl localhost:8080
```

- Nous pouvons stopper et supprimer notre conteneur
```
docker container stop website
```

```
docker container rm website
```

- Nous pouvons sauvegarder notre image dans un fichier archivé
```
docker save -o $HOME/website:0.0.1.tar website:0.0.1
```

L'option *-o* permet d'indiquer la destination de la sauvegarde.<br>

- Nous pouvons aussi vérifier si le fichier de sauvegarde a été créé
```
ls $HOME
```