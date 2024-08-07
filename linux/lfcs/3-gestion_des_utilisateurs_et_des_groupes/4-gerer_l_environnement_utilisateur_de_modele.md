# Gérer l'environnement modèle utilisateur

De nombreuses tâches et responsabilités occupent les administrateurs système Linux. L'utilisation de modèles peut nous faire gagner du temps lors de la configuration de nouveaux utilisateurs sur nos systèmes.

### /etc/skel

Le contenu de ce répertoire sera utilisé pour remplir le répertoire personnel de tous les nouveaux utilisateurs. Ce répertoire peut contenir :
- Fichiers de configuration tels qu'un **.bashrc**, **.bash_profile**,**.nanorc** ou fichiers similaires
- Répertoires de documents, journaux, scripts, etc.
- Documents, comme un message de bienvenue ou un README, des modèles de script ou des fichiers d'informations.

**REMARQUE** : Toute modification apportée à ce répertoire sera appliquée uniquement aux nouveaux comptes d'utilisateurs. Les utilisateurs existants ne recevront pas ces fichiers.

### Cas Pratique

- Affichons le contenu du repertoire **/etc/skel**

```
ls -ahl /etc/skel
```

- Créons deux repertoires **Documents** et **backup** et un fichier **WELCOME** dans le repertoire **/etc/skel**

```
cd /etc/skel
sudo mkdir Documents
sudo mkdir backup
```

```
sudo vi WELCOME
```

```
Welcome to the team !
```

- Ajoutons un alias dans le fichier **.bash_profile** sous Rocky ou **.profile** sous Ubuntu

```
sudo vi .bash_profile
```

```
alias li="ls -ali"
```

- Créons un utilisateur avec son repertoire home et son mot de passe **cooltest**

```
sudo useradd -m -s /bin/bash testuser
sudo passwd testuser
```

- Vérifions le contenu du repertoire home de l'utilisateur **testuser**

```
sudo ls -alh /home/testuser/
```

Nous constatons la présence de tous les fichiers et repertoires créés

- Connectons nous avec cet utilisateur

```
su - testuser
```

- Consultons le fichier **WELCOME**, les repertoires **Documents - backup** et exécutons la commande **li**

```
cat WELCOME
ls -ld Documents
ls -ld backup
li
```