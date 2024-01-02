# Installation de jenkins 2 sur rocky linux 8.5

Dans ce tutoriel, nous installerons la version stable de jenkins 2.

## Installation des paquets de dépendances
```
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

sudo yum upgrade

sudo yum install epel-release -y

sudo yum install yum-utils

sudo yum-config-manager --enable epel

sudo yum install daemonize fontconfig java-11-openjdk -y
```

## Installation et configuration de jenkins
**- Installation**
```
sudo yum install jenkins

sudo systemctl enable jenkins
```

Si vous rencontrez une erreur avec la sortie de la commande ci-dessus avec systemctl, spécifiant que jenkins n'est pas un service natif, alors vous exécutez la commande :
```
sudo /usr/lib/systemd/systemd-sysv-install enable jenkins
```

Ensuite nous lançons le service jenkins :
```
sudo systemctl start jenkins
```

**- Vérification du statut de jenkins**
```
sudo systemctl status jenkins
```

**- Permission du port par défaut 8080 de jenkins au niveau du pare-feu**
```
JENKINSPORT=8080
PERM="--permanent"
SERV="$PERM --service=jenkins"

sudo firewall-cmd $SERV --set-short="jenkins ports"
sudo firewall-cmd $SERV --set-description="jenkins port exception"
sudo firewall-cmd $SERV --add-port=$JENKINSPORT/tcp
sudo firewall-cmd $PERM --add-service=jenkins
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --reload
```

**- Configuration post-installation**<br>
Lorsque vous accédez pour la première fois à une nouvelle instance Jenkins, vous êtes invité à la déverrouiller à l'aide d'un mot de passe généré automatiquement.
Vous saisissez la commande ci-dessous pour afficher le mot de passe temporaire d'administration de jenkins :
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Le répertoire **/var/lib/jenkins/secrets/initialAdminPassword** pourra être différent pour votre installation mais il sera affiché au dessus du champ de saisie du mot de passe temporaire.<br>

Après avoir déverrouillé Jenkins, la page **Personnaliser Jenkins** apparaît. Ici, vous pouvez installer n'importe quel nombre de plugins utiles dans le cadre de votre configuration initiale.

Cliquez sur l'une des deux options affichées :

- Installer les plugins suggérés - pour installer l'ensemble de plugins recommandé, basé sur les cas d'utilisation les plus courants.

- Sélectionnez les plugins à installer - pour choisir l'ensemble de plugins à installer initialement. Lorsque vous accédez pour la première fois à la page de sélection des plugins, les plugins suggérés sont sélectionnés par défaut.<br>

Enfin, après avoir personnalisé Jenkins avec des plugins, Jenkins vous demande de créer votre premier utilisateur administrateur.

- Lorsque la page **Créer un premier utilisateur administrateur** s'affiche, spécifiez les détails de votre utilisateur administrateur dans les champs respectifs et cliquez sur **Enregistrer et terminer**.

- Lorsque la page **Jenkins est prêt** s'affiche, cliquez sur **Commencer à utiliser Jenkins**.

<br>

Source : [Jenkins doc](https://www.jenkins.io/doc/book/installing/linux/#red-hat-centos)