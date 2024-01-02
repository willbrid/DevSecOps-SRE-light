# Utilisation d'un simple registre privé docker

Hypothèses
1.    On supposera que la configuration d'un registre est déjà faite sur un serveur de domaine **example.com**. (voir configuration)
2.    On supposera que docker est déjà installé depuis un hôte (ubuntu ou centos) qui nous permettra d'utiliser notre registre. 

## Installation du certification du registre privé sur l'hôte
**Création du répertoire du certification du registre**

```
sudo mkdir -p /etc/docker/certs.d/example.com:443
```

**Copie du certificat dans le répertoire example.com:443**

```
sudo scp cloud_user@example.com:<HOME>/registry/certs/example.com.crt /etc/docker/certs.d/example.com:443
```

NB: Remplacez le **\<HOME\>** par celui de votre serveur de registre.

## Authentification au registre privé depuis l'hôte

```
docker login example.com:443
```

NB: Vous mettrez le login et le password précédemment configuré sur le serveur de registre.

## Pousser vers et extraire de votre registre privé

```
docker pull busybox
docker tag busybox example.com:443/busybox
docker push example.com:443/busybox
docker image rm example.com:443/busybox
docker image rm busybox
docker pull example.com:443/busybox
```