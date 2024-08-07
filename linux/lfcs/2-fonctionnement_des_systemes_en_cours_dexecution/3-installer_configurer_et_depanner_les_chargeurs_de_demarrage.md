# Installer, configurer et dépanner les chargeurs de démarrage

Un **chargeur de démarrage** est une application permettant de charger le noyau Linux avec des paramètres facultatifs, comme les **configurations de niveau d'exécution**. Il peut être utilisé pour gérer différents noyaux ou le même noyau avec différentes options. Il peut également être utilisé pour gérer plusieurs systèmes d’exploitation sur une seule machine.

**GRUB2** (**GRand Unified Bootloader 2**) est le **chargeur de démarrage** installé sur les distributions les plus courantes disponibles. Le fichier **/boot/grub/grub.cfg** (Debian/Ubuntu) ou **/boot/grub2/grub.cfg** (RedHat/CentOS/Rocky) est le fichier de configuration et **/etc/grub.d/** contient les scripts de menu.

Sous Debian/Ubuntu
```
cat /boot/grub/grub.cfg
```

Sous RedHat/CentOS/Rocky
```
cat /boot/grub2/grub.cfg
```

```
cd /etc/grub.d
ls -alhF
cat 40_custom
```

Le fichier **/etc/default/grub** contient les paramètres qui contrôlent le comportement réel du menu **GRUB**. En utilisant ce fichier, nous pouvons mettre à jour des lignes de configuration telles que le **délai d'attente GRUB**, le **style du menu**, la **ligne de commande par défaut**...

Chaque fois que nous apportons des modifications à la configuration de GRUB, nous devons exécuter les commandes :

Sous Ubuntu/Debian
```
sudo update-grub
```

Sous RedHat/CentOS/Rocky
```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```