# Gérer l'accès au compte root

Le compte **root** a accès pour gérer et modifier l'ensemble du système. Pour sécuriser et protéger le système, comment restreindre l'accès au root ?

### Comment éviter le root

Connectons-nous toujours en tant que nous-même ou en utilisant un autre compte non privilégié !
- **sudo - superuser do** : accorde des privilèges élevés temporaires pour exécuter une commande
- **su - substitute user** : modifications apportées au compte **root** jusqu'à la déconnexion

### Comment gérer l'accès sudo

- L'accès est accordé via les entrées du fichier **/etc/sudoers**
- L'accès peut être géré par compte ou par groupe

- Commande **whoami** : Imprime le nom d'utilisateur associé à l'ID utilisateur effectif actuel.

```
whoami
```

Il est équivalent à la commande

```
id -un
```

- Commande **id** : imprime les informations sur l'utilisateur et le groupe pour l'utilisateur spécifié ou (lorsque l'utilisateur est omis) pour l'utilisateur actuel.

```
id root
```

```
id
```

- Affichons le contenu du fichier **/etc/sudoers**

```
sudo cat /etc/sudoers
```

- Section de spécification des privilèges utilisateur

Sous Ubuntu
```
root	ALL=(ALL:ALL) ALL
```

Sous Rocky
```
root	ALL=(ALL) 	ALL
```

En règle générale, c'est ici que nous entrons les comptes d'utilisateurs individuels pour leur accorder l'accès. Dans ce fichier sudoers particulier, seul le compte **root** a obtenu l'accès individuellement et les privilèges qui ont été accordés à **root** nous définissent : <br>
--- le premier **ALL** indique que le compte **root** peut s'exécuter à partir de n'importe quelle session de terminal. <br>
--- la section suivante, entre parenthèses (**ALL:ALL** pour Ubuntu ou **ALL** pour Rocky), indique que le compte **root** peut s'exécuter avec tous les utilisateurs et tous les groupes. <br>
--- et le **ALL** final signifie que l'utilisateur **root** peut exécuter n'importe quelle commande.

- Section des membres du groupe d'administrateurs (**admin** ou **wheel**) qui peuvent obtenir les privilèges **root**

Sous Ubuntu
```
%admin ALL=(ALL) ALL
```

Sous Rocky
```
%wheel	ALL=(ALL)	NOPASSWD: ALL
```

sous **Ubuntu**, nous pouvons voir que le groupe **admin** (reconnu avec le symbole pourcentage devant le nom du groupe) a obtenu toutes les autorisations et sous **Rocky**, nous pouvons voir que le groupe **%wheel** a obtenu toutes les autorisations.

- Section autorisant les membres du groupe **sudo** à exécuter n'importe quelle commande

Sous Ubuntu
```
%sudo	ALL=(ALL:ALL) ALL
```

Créons un utilisateur **basicuser** avec un mot de passe **test@test**

Sous Ubuntu
```
sudo adduser basicuser
```

Sous Rocky
```
sudo adduser basicuser && sudo passwd basicuser
```

Connectons nous avec l'utilisateur **basicuser** depuis notre utilisateur courant ayant les privilèges **sudo**

```
su basicuser
```

Une fois connecté, en exécutant les commandes ci-dessous.

```
cat /etc/sudoers
```

Ici, nous pouvons constater que nous n'avons pas les droits avec cet utilisateur.

```
sudo cat /etc/sudoers
```

Ici, Un message d'erreur s'affiche indiquant l'absence de l'utilisateur **basicuser** dans le fichier **/etc/sudoers**.

Déconnectons nous de la session de l'utilisateur **basicuser**

```
exit
```

Donnons les droits **sudo** à l'utilisateur **basicuser**

```
sudo visudo
```

Sous Ubuntu
```
...
# User privilege specification
...
basicuser   ALL=(ALL:ALL) ALL
...
```

Sous Rocky
```
...
## Allow root to run any commands anywhere
...
basicuser ALL=(ALL)       ALL
...
```

Reconnectons nous à nouveau au compte d'utilisateur **basicuser** et affchons le contenu du fichier **/etc/sudoers** avec **sudo**

```
su basicuser
```

```
sudo cat /etc/sudoers
```

Nous constatons que le contenu du fichier s'affiche.

Déconnectons nous de la session de l'utilisateur **basicuser**

```
exit
```

Créons un autre utilisateur **newuser** avec un mot de passe **test@test**

Sous Ubuntu
```
sudo adduser newuser
```

Sous Rocky
```
sudo adduser newuser && sudo passwd newuser
```

Ajoutons l'utilisateur **newuser** au groupe **sudo** pour Ubuntu ou **wheel** pour Rocky, présent dans le fichier **/etc/sudoers**

Sous Ubuntu
```
sudo gpasswd -a newuser sudo
```

Sous Rocky
```
sudo gpasswd -a newuser wheel
```

La commande **gpasswd** est utilisée pour administrer **/etc/group** et **/etc/gshadow**. Chaque groupe peut avoir des administrateurs, des membres et un mot de passe. Nous pouvons vérifier que l'utilisateur **newuser** appartient désormais au groupe **sudo** pour Ubuntu ou **wheel** pour Rocky, en exécutant la commande

```
id newuser
```

Si nous nous connectons au compte **newuser** et nous exécutons avec **sudo**, la commande affichant le contenu du fichier **/etc/sudoers**, nous constaterons que le contenu du fichier s'affiche car nous appartenons désormais au groupe **sudo** pour Ubuntu ou **wheel** pour Rocky.

Enlevons l'utilisateur **newuser** au groupe **sudo**

```
sudo gpasswd -d newuser sudo
```