# Gérer et configurer les conteneurs

Les conteneurs peuvent faciliter grandement le test des solutions et la gestion des applications. Les compétences en matière de conteneurs sont une bonne chose pour tout administrateur système Linux. <br>
Les conteneurs permettent à un administrateur système Linux de collecter une application, des dépendances et des données dans une seule image qui peut être facilement transférée et gérée de manière identique sur différents systèmes.

### Installation de docker sur notre serveur ubuntu-server et podman sur notre serveur rocky-server

Sous **Ubuntu**

```
curl -fsSL https://get.docker.com -o get-docker.sh
```

```
sudo sh get-docker.sh
```

Sous **Rocky**

```
sudo dnf -y install podman
```

### Utilisation de docker et podman

- Listons les conteneurs actifs

Sous **Ubuntu**

```
sudo docker container ps
```

Sous **Rocky**

```
sudo podman container ps
```

- Exécutons un conteneur apache2 et exposons le sous le port 8080

```
mkdir /home/vagrant/html
```

```
vi /home/vagrant/html/index.html
```

```
<html>
<body>
<div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
Container Page
</div>
</body>
</html>
```

Sous **Ubuntu**

```
sudo docker container run -itd --name test-web -p 8080:80 -v /home/vagrant/html/:/usr/local/apache2/htdocs/ httpd
```

Sous **Rocky**

```
sudo podman container run -itd --name test-web -p 8080:80 -v /home/vagrant/html/:/usr/local/apache2/htdocs/:z httpd
```

Vérifions si le conteneur **test-web** a bien démarré

Sous **Ubuntu**

```
sudo docker container ps
```

Sous **Rocky**

```
sudo podman container ps
```

Testons la page herbégé avec l'utilitaire **lynx**

```
lynx localhost:8080
```

- Mettons à jour la page web du conteneur **test-web**

Sous **Ubuntu**

```
sudo docker container stop test-web
```

```
echo "New Page" > /home/vagrant/html/index.html
```

```
sudo docker container start test-web
```

Sous **Rocky**

```
sudo podman container stop test-web
```

```
echo "New Page" > /home/vagrant/html/index.html
```

```
sudo podman container start test-web
```

- Arrêtons et supprimons le conteneur **test-web**

Sous **Ubuntu**

```
sudo docker container stop test-web
```

```
sudo docker container rm test-web
```

Sous **Rocky**

```
sudo podman container stop test-web
```

```
sudo podman container rm test-web
```

- Affichons les images téléchargées en local

Sous **Ubuntu**

```
sudo docker image list
```

Sous **Rocky**

```
sudo podman image list
```

- Supprimons l'image **httpd** préalablement téléchargée

Sous **Ubuntu**

```
sudo docker image rm httpd
```

Sous **Rocky**

```
sudo podman image rm httpd
```