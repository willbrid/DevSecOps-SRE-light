# Installation spécifique sur les os centos7 et ubuntu18.04
## Installation de docker sur centos 7
**Installer les packages requis**

```
sudo yum install -y device-mapper-persistent-data lvm2
```

**Ajouter le référentiel Docker CE**

```
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

**Installer les packages Docker CE**

```
sudo yum install -y docker-ce docker-ce-cli containerd.io
```

**Démarrer et activer le service Docker**

```
sudo systemctl start docker
sudo systemctl enable docker
```

**Ajouter un utilisateur au groupe docker**

Pour accorder à un utilisateur l'autorisation d'exécuter des commandes Docker, ajoutez l'utilisateur au groupe Docker. L'utilisateur aura accès à Docker après sa prochaine connexion.

```
sudo usermod -a -G docker <user>
```

**Tester l'installation de docker**

Nous pouvons tester notre installation Docker en exécutant un simple conteneur.

```
docker run busybox
```


## Installation de docker sur Ubuntu 18.04
**Installer les packages requis**

```
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```

**Ajoutez la clé GNU Privacy Guard (GPG) du référentiel Docker et vérifier l'empreinte digitale**

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
```

NB: C'est une bonne idée de vérifier l'empreinte digitale de la clé. Il s'agit d'une étape facultative, mais fortement recommandée. Nous devrions recevoir une sortie indiquant que la clé a été trouvée.

**Ajouter le référentiel Docker Ubuntu**

```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

**Installer les packages Docker CE**

```
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
```

**Ajouter un utilisateur au groupe docker**

Pour accorder à un utilisateur l'autorisation d'exécuter des commandes Docker, ajoutez l'utilisateur au groupe Docker. L'utilisateur aura accès à Docker après sa prochaine connexion.

```
sudo usermod -a -G docker <user>
```

**Tester l'installation de docker**

Nous pouvons tester notre installation Docker en exécutant un simple conteneur.

```
docker run hello-world
```



# Installation multiplatforme de docker
**Télécharger le script sh**

```
curl -fsSL https://get.docker.com -o get-docker.sh
```

**Exécuter le script**
```
sudo sh get-docker.sh
```

**Ajouter un utilisateur au groupe docker**

Pour accorder à un utilisateur l'autorisation d'exécuter des commandes Docker, ajoutez l'utilisateur au groupe Docker. L'utilisateur aura accès à Docker après sa prochaine connexion.

```
sudo usermod -a -G docker <user>
```

**Démarrer et activer le service Docker**

```
sudo systemctl start docker
sudo systemctl enable docker
```