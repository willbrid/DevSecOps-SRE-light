# Cas pratique

### Confirmer que notre utilisateur vagrant est dans le groupe wheel sous rocky ou sudo sous ubuntu

Utilisons les commandes **id** et **groups** pour confirmer l'adhésion au groupe **wheel**

```
id vagrant
```

```
groups
```

### Définir le groupe wheel sous rocky ou sudo sous ubuntu comme groupe propriétaire de /usr/bin/sudo et /usr/bin/su

```
sudo -i
```

Sous rocky
```
sudo chgrp wheel /usr/bin/sudo /usr/bin/su
```

Sous ubuntu
```
sudo chgrp sudo /usr/bin/sudo /usr/bin/su
```

### Permettre à l'utilisateur root et au groupe wheel sous rocky ou sudo sous ubuntu d'exécuter sudo et su


```
sudo chmod 4110 /usr/bin/sudo /usr/bin/su
```

Nous pouvons confirmer en exécutant 

```
ls -l /usr/bin/sudo
```

```
ls -l /usr/bin/su
```

### Vérifier que /etc/sudoers autorise le groupe wheel sous rocky ou sudo sous ubuntu à utiliser sudo

Sous rocky
```
sudo grep wheel /etc/sudoers
```

Sous ubuntu
```
sudo grep sudo /etc/sudoers
```

Si les lignes commençant **%wheel** sous rocky ou **%sudo** sous ubuntu sont commentées alors utilisons la commande **visudo** pour ouvrir le fichier **/etc/sudoers** et les décommenter

```
visudo
```

### Créer une ligne dans /etc/pam.d/su pour exiger l'adhésion au groupe wheel sous rocky ou sudo sous ubuntu pour l'utilisation de la commande su

```
vi /etc/pam.d/su
```

Sous rocky
```
...
auth            required        pam_wheel.so use_uid
```

Sous ubuntu
```
...
auth            required        pam_wheel.so group=sudo
```

### Créer un utilisateur sysadmin, ajouter le au membre du groupe wheel sous rocky ou sudo sous ubuntu, définir son mot de passe et vérifier que sysadmin est capable d'utiliser sudo et su

Créons un utilisateur **sysadmin** appartenant au groupe **wheel** sous rocky ou **sudo** sous ubuntu

Sous rocky
```
useradd -G wheel sysadmin
```

Sous ubuntu
```
useradd -G sudo sysadmin
```

Définissons le mot de passe **cooltest** de l'utilisateur **sysadmin**

```
passwd sysadmin
```

Vérifions que l'utilisateur **sysadmin** peut exécuter su et sudo

```
su - sysadmin
```

```
sudo tail -n1 /etc/shadow
```

```
# Le mot de passe de l'utilisateur vagrant est vagrant
su -l vagrant
```

```
exit
exit
```

### Créer un utilisateur sysuser qui n'est pas membre du groupe wheel sous rocky ou sudo sous ubuntu, définir son mot de passe et vérifier qu'il ne peut pas utiliser sudo et su

Créons un utilisateur **sysuser** appartenant au groupe **wheel** sous rocky ou **sudo** sous ubuntu

Sous rocky
```
useradd -G wheel sysuser
```

Sous ubuntu
```
useradd -G sudo sysuser
```

Définissons le mot de passe **cooltest** de l'utilisateur **sysuser**

```
passwd sysuser
```

Vérifions que l'utilisateur **sysuser** ne peut pas exécuter **su** et **sudo**

```
su --login sysuser
```

```
sudo tail -n1 /etc/shadow
```

```
su -l vagrant
```

```
exit
```