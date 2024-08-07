# Configurer et gérer l'espace swap

Parfois, un système peut manquer de mémoire. Un administrateur système Linux peut avoir besoin d'utiliser de l'espace **swap** pour que ce système continue de fonctionner dans une telle situation. L'espace **swap** est utilisé lorsque le noyau a besoin de plus de RAM, mais qu'il n'y a plus de RAM disponible. Le noyau "échangera" des pages de mémoire sur le disque dans un fichier **swap** ou une partition **swap** afin de libérer de la RAM.

### Qu’est-ce que le swap ?

- Un fichier, une partition ou une combinaison des deux utilisé pour stocker les pages de mémoire inactives afin de libérer de la RAM pour l'utilisation du système.
- Pas une alternative à la RAM, juste une solution temporaire car le swap est beaucoup plus lent car les pages sont écrites sur un disque et ne résident plus en mémoire.

### Taille du swap ?

- Pour les distributions modernes, la taille varie en fonction du rôle du système.
- **RedHat** : Pour un système avec < 2Go de RAM, **égal ou deux fois à la quantité de RAM**. Pour un système > 4Go, **20%** de la taille de la RAM est recommandé.
- **CentOS** : Pour un système avec < 2Go de RAM, le swap doit être **deux fois la taille de la RAM**. Si la RAM est > 2Go, le swap doit être de taille **RAM + 2Go**.
- **Ubuntu** : Pour un système avec < 1Go, **supérieur ou égal à la quantité de RAM** et pas plus du double. Si RAM > 1 Go, le swap doit être **supérieur ou égal à la racine carrée de la taille de la RAM** et pas plus du double de la taille de la RAM. Si nous utilisons l'**hibernation**, elle doit être égale à **la taille de la RAM + la racine carrée de la taille de la RAM**.

### Gestion du swap

- Consulter le phériphérique du swap

```
cat /etc/fstab | grep swap
```

- Afficher un tableau définissant les zones de swap

```
swapon --show
```

Cette commande affiche un tableau avec les colonnes suivantes : <br>
--- **NAME** : fichier de périphérique ou chemin de partition <br>
--- **TYPE** : type de périphérique <br>
--- **SIZE** : taille de la zone de swap <br>
--- **USED** : octets utilisés <br>
--- **PRIO** : priorité d'espace swap <br>
--- **UUID** : UUID d’espace swap <br>
--- **LABEL**: étiquette d’espace swap

les commandes **free**, **top** et **htop** permettent aussi d'afficher les informations sur l'espace swap

```
free
```

```
top
```

```
htop
```

- Désactiver le swap sur tous les phériphériques marqués comme « swap » dans le fichier **/etc/fstab**

```
sudo swapoff -a
```

Nous pouvons vérifier cette désactivation en exécutant

```
swapon --show
```

Aucune sortie ne sera affiché.

- Activer le swap sur tous les phériphériques marqués comme « swap » dans le fichier **/etc/fstab**

```
sudo swapon -a
```

Nous pouvons vérifier cette activation en exécutant

```
swapon --show
```

La sortie de cette commande présentera les zones de swap.

- Créer deux fichiers de swap à la racine : **swapfile1** et **swapfile2**

--- Utilisons la commande **fallocate** pour allouer un espace disque de 1G au fichier **/swapfile1**

```
sudo fallocate -l 1G /swapfile1
```

--- Utilisons la commande **dd** pour générer le fichier **/swapfile2** d'une taille de 1G à partir des flux de données du phériphérique **/dev/zero**

```
sudo dd if=/dev/zero of=/swapfile2 bs=1024 count=1048576
```

--- Vérifions que nos deux fichiers sont créés

```
ls -lah /
```

--- Attribuons les bons droits d'un fichier swap à nos deux fichiers

```
sudo chmod 600 /swapfile1
sudo chmod 600 /swapfile2
```

--- Configurons une zone de swap Linux dans nos 2 fichiers

```
sudo mkswap /swapfile1
sudo mkswap /swapfile2
```

--- Activons le swap sur ces 2 fichiers

```
sudo swapon /swapfile1
sudo swapon /swapfile2
```

Nous pouvons vérifier que le swap a été activé sur les 2 fichiers **/swapfile1** et **/swapfile2**

```
swapon --show
```