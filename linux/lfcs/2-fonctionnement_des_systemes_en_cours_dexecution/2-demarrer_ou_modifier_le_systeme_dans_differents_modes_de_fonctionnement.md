# Démarrer ou modifier le système dans différents modes de fonctionnement

Comment configurer une machine Linux pour démarrer en mode graphique ou texte ?

Le **niveau d'exécution** (**runlevel**) de linux contrôle le choix des processus ou services qui sont démarrés automatiquement par le système (ou, plus exactement, par **Init**). Le **niveau d'exécution** est désigné par un chiffre de **0** à **6** ou la lettre **S**. Les niveaux d'exécution **0**, **6** et **S** sont réservés respectivement à l'**extinction du système**, au **redémarrage** et au **mode simple utilisateur**.

|                  | SysVinit    | Systemd                             |
| :---             |    :----:   |          ---:                       |
| System halt      | 0           | runlevel0.target,poweroff.target    |
| Single user mode | 1           | runlevel1.target,rescue.target      |
| Multi-user       | 2           | runlevel2.target,multi-user.target  |
| Multi-user with <br> network | 3    | runlevel3.target,multi-user.target |
| Experimental     | 4           | runlevel4.target,multi-user.target  |
| Multi-user, with network <br> and graphical mode | 5 | runlevel5.target, graphical.target |
| Reboot           | 6           | runlevel6.target,reboot.target      |

- Vérifier le niveau d'exécution actuel

```
# SysVinit
runlevel
```

```
# Systemd
systemctl get-default
```

- Changer le niveau d'exécution par défaut en **multi-user**

Avec **SysVinit**, on modifie le fichier **/etc/inittab** en remplaçant **initdefault** par **id:3:initdefault:** .

Avec **Systemd**, on exécute la commande 

```
systemctl set-default multi-user.target
```