# Registres Docker
Docker Registry : un emplacement central pour stocker et distribuer des images.<br>
Docker Hub : le registre public par défaut géré par Docker.<br>
Nous pouvons exploiter gratuitement notre propre registre privé en utilisant l'image du registre. <br>
Exécutons un registre simple avec une variable d'environnement :
```
docker run -d -p 5000:5000 --restart=always --name registry -e REGISTRY_LOG_LEVEL=debug registry:2
```

## Utilisation des registres Docker
- Extraction et recherche d'images sur le hub Docker :
```
docker pull ubuntu
docker search ubuntu
```

Essayons de nous authentifier auprès du registre privé :
```
docker login <registry public hostname>
```

Connectons-nous avec les informations d'identification que nous avons créées (testuser et mot de passe). <br>
Un message de certificat signé par une autorité inconnue devrait apparaître, car nous utilisons un certificat auto-signé. <br>
Configurons Docker pour qu'il ignore la vérification des certificats lors de l'accès au registre privé :
```
sudo vi /etc/docker/daemon.json
```

```
{
  "insecure-registries" : ["<registry public hostname>"]
}
```

```
sudo systemctl restart docker
```

Essayons à nouveau de nous connecter à Docker :
```
docker login <registry public hostname>
```

Cette fois, ça devrait marcher !
Cependant, cette méthode d'accès au registre est très peu sûre. Il désactive entièrement la vérification des certificats, nous exposant à
attaques de l'homme du milieu. Alors, faisons cela de la bonne manière.<br>
Tout d'abord, déconnectons-nous du registre privé :
```
docker logout <registry public hostname>
```

Ensuite, supprimons la clé et la valeur *insecure-registries* de */etc/docker/daemon.json* et redémarrons Docker.<br>

Téléchargeons la clé publique du certificat depuis le registre et configurons le moteur docker local pour l'utiliser :
```
sudo mkdir -p /etc/docker/certs.d/<registry public hostname>
sudo cp domain.crt /etc/docker/certs.d/<registry public hostname>
```

Essayons la connexion docker :
```
docker login <registry public hostname>
```

Poussons vers et extrayons depuis votre registre privé :
```
docker pull ubuntu
docker tag ubuntu <registry public hostname>/ubuntu
docker push <registry public hostname>/ubuntu
docker image rm <registry public hostname>/ubuntu
docker image rm ubuntu
docker pull <registry public hostname>/ubuntu
```