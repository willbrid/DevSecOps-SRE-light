# Installation de docker sur rocky linux 8
Dans ce tutoriel nous installerons docker-ce sur rocky linux 8.

**- Suppression de podman et ses dépendances**
```
sudo dnf -y remove podman runc
```

**- Installation de yum-utils**
```
sudo dnf install -y yum-utils
```

Ce qui nous permettra d'utiliser la commande *yum-config-manager*.

**- Installation du repo docker**
```
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

**- Vérification de la présence du repo docker**
```
sudo dnf repolist | grep docker
```

**- Installation de docker-ce**
```
sudo dnf -y install docker-ce docker-ce-cli containerd.io
```

**- Démarrage et activation du service docker**
```
sudo systemctl start docker
sudo systemctl enable docker
```

**- Ajout de l'utilisateur courant dans le groupe docker**
```
sudo usermod -a -G docker <user>
```

L'utilisateur *user* aura accès à Docker après sa prochaine connexion.

source: [docker-doc-install](https://docs.docker.com/engine/install/centos/)