# Répertorier et identifier les contextes de fichiers et de processus SELinux/AppArmor [PART2]

Pour éviter les problèmes potentiels causés par les faiblesses et les exploits d'une application, les administrateurs système s'appuient sur des outils tels que **SELinux** et **AppArmor** pour renforcer la sécurité du système.

### AppArmor

- Semblable à SELinux, il s'agit d'une amélioration du kernel utilisée pour limiter les applications à un ensemble sélectionné de ressources.
- **AppArmor** est différent de certains systèmes similaires car il est basé sur un chemin. Cela permet une combinaison de profils de mode **enforce** et de mode **complaint**.
- Il a tendance à être plus simple et plus facile à mettre en œuvre et à apprendre que les autres systèmes MAC populaires.
- Commun sur les systèmes **Debian/Ubuntu**. Les profils sont stockés dans le répertoire **/etc/apparmor.d/**.

--- Affichons diverses informations sur la stratégie **apparmor** actuelle.

```
sudo aa-status
```

Nous pouvons voir combien de profils sont chargés, quels profils sont configurés pour être en mode **enforce**, quels profils sont en mode **complain**, si des processus ont un profil défini, si des processus sont en mode **enforce** et quels processus sont en mode **complain**.

Nous pouvons consulter les profils **apparmor** (par exemple pour le cas de **lsb_release**) dans le repertoire **/etc/apparmor.d/**

```
cat /etc/apparmor.d/lsb_release
```

--- Listons les profils **apparmor** pour les processus avec la commande **ps**

```
ps auxZ
```

--- Listons les profils **apparmor** avec la commande **ls** sur le repertoire **/var**

```
ls -Z /var
```

Si les commandes **aa-enforce**, **aa-disable**, **aa-complain** n'existe pas, nous pouvons les installer avec la commande 

```
sudo apt install apparmor-utils
```

Nous pouvons utiliser la commande **aa-enabled** pour vérifier que **apparmor** est activé.

```
aa-enabled
```

Nous pouvons utiliser la commande **aa-disable** pour désactiver un profil de sécurité **apparmor**.

```
sudo aa-disable /etc/apparmor.d/lsb_release
```

Nous pouvons utiliser la commande **aa-enforce** pour activer un profil de sécurité **apparmor** en mode **enforce**.

```
sudo aa-enforce /etc/apparmor.d/lsb_release
```

Nous pouvons utiliser la commande **aa-complain** pour activer un profil de sécurité **apparmor** en mode **complain**.

```
sudo aa-complain /etc/apparmor.d/lsb_release
```

### Selinux sur Ubuntu

- Installer selinux

```
sudo systemctl stop apparmor.service

sudo systemctl disable apparmor.service

sudo apt install selinux-basics auditd
```

- Vérifier si selinux est activé

```
sestatus
```

- Activer selinux

```
sudo selinux-activate
```

Après cette activation, l'on doit redemarrer le serveur. Dans le fichier **/etc/default/grub** nous pouvons vérifier la ligne **GRUB_CMDLINE_LINUX=" security=selinux"**. <br>
Si nous faisons un **ls** sur le système de fichier racine (**/**) nous verrons un fichier caché appelé : **.autorelabel** qui indique que selinux va mettre les étiquettes au redemarrage du système.