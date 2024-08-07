# Créer et configurer des systèmes de fichiers

Un administrateur système Linux doit être familier avec les différents types de systèmes de fichiers, comment les créer et comment les rendre accessibles aux utilisateurs. Sous Linux, tout est un fichier. Créer des systèmes de fichiers sains pour répondre aux besoins d'utilisation est une tâche importante pour tout administrateur système Linux.

### Informations requises

Avant de créer un système de fichiers, nous devons collecter un peu d'informations afin d'être prêts à créer le bon système de fichiers pour répondre aux exigences d'utilisation.

- Quelle est la partition à utiliser pour le système de fichiers ?
- A quoi sert le système de fichiers ? Cela aidera à déterminer le type de système de fichiers.
- Avez-vous installé les utilitaires pour le système de fichiers ? Si nous prévoyons d'utiliser un système de fichiers **non-EXT** comme **BTRFS** ou **JFS**, les composants sont-ils installés pour créer et prendre en charge le système de fichiers ?

### Création de 3 partitions (/dev/sde2, /dev/sde3, /dev/sde4) de 500Mo sur le périphérique /dev/sde et formattage de ces fichiers

Nous suivons la procédure ci-dessous pour créer les 3 partitions **/dev/sde2, /dev/sde3, /dev/sde4**

```
sudo fdisk /dev/sde
```

--- Nous saisissons la lettre **'n'** pour créer une nouvelle partition <br>
--- Nous saisissons la lettre **'p'** pour définir la partition comme **primaire** <br>
--- Nous validons pour accepter la valeur par défaut (**'1'**) du numéro de la partition <br>
--- Nous validons pour accepter la valeur par défaut de la taille du premier secteur de disque <br>
--- Nous saisissons **'+500M'** pour définir la valeur de la taille du dernier secteur de disque <br>
--- Nous saisissons la lettre **'p'** pour voir la nouvelle partition créée <br>
--- Nous saisissons la lettre **'w'** pour enregistrer tous les changements effectués

Pour vérifier nos partitions créées nous exécutons

```
lsblk
```

- Formattons les périphériques respectivement en **btrfs**, **exfat** et **ext4**

```
sudo mkfs.btrfs /dev/sde2
```

```
sudo mkfs.exfat /dev/sde3
```

```
sudo mkfs.ext4 /dev/sde4
```

### Montage des partitions /dev/sde2, /dev/sde3, /dev/sde4 respectivement sur les repertoires /mnt/btrfs, /mnt/exfat, /mnt/ext4

- Créons les repertoires **/mnt/btrfs**, **/mnt/exfat**, **/mnt/ext4**

```
cd /mnt/
```

```
sudo mkdir btrfs exfat ext4
```

- Montons nos partitions sur ces repertoires

```
sudo mount /dev/sde2 /mnt/btrfs
```

```
sudo mount /dev/sde3 /mnt/exfat
```

```
sudo mount /dev/sde4 /mnt/ext4
```

Pour vérifier nos montages, nous exécutons

```
df -hT
```

L'option **-T** permet d'afficher une colonne correspondant au type de système de fichiers.

Pour afficher les informations similaires que la commande **df**, l'on peut aussi exécuter ces commandes ci-dessous

```
lsblk -f
```

```
sudo mount | grep "^/dev"
```

- Ajoutons ces points de montage dans le fichier **/etc/fstab** afin de persister les configurations de montage

```
sudo vi /etc/fstab
```

```
...
/dev/sde2  /mnt/btrfs  btrfs  defaults  0  0
/dev/sde3  /mnt/exfat  exfat  defaults  0  0
/dev/sde4  /mnt/ext4   ext4   defaults  0  0
```