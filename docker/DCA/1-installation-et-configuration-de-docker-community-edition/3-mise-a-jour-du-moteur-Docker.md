# Mise à jour du moteur Docker sous Ubuntu 20.04

- Pour mettre à jour le moteur Docker, nous devons d'abord arrêter le service Docker, lister les versions disponibles et installer les nouvelles (ou anciennes) versions de **docker-ce** et **docker-ce-cli**.

```
sudo systemctl stop docker
```

```
apt-cache madison docker-ce
```

```
sudo apt-get install -y docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
```

```
sudo systemctl start docker
```

- Vérifions la version actuelle
```
docker version
```