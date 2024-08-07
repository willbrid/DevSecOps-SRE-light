# Créer et gérer des périphériques RAID

Le stockage consolidé et la redondance sont essentiels à une gestion réussie des données. **RAID** est un outil précieux que les administrateurs système Linux peuvent utiliser pour les aider dans les deux cas. <br>
**LVM** (**Logical Volume Management**) permet à un administrateur système Linux de combiner des disques et de les présenter comme un seul périphérique de stockage. **RAID** (**Redundant Array of Independent Disks**) est une autre option qui combinera les disques et les présentera comme un seul périphérique. Mais il offre également une redondance pour garantir la durabilité des fichiers.

### Qu’est-ce que le RAID ?

**RAID (Redundant Array of Independent Disks)** est un moyen de stocker les mêmes données à différents endroits sur plusieurs disques durs ou disques SSD pour protéger les données en cas de panne de disque. Il existe cependant différents niveaux de **RAID**, et tous n'ont pas pour objectif d'assurer la redondance.

### Comment fonctionne le RAID

**RAID** fonctionne en plaçant les données sur plusieurs disques et en permettant aux opérations d'entrée/sortie (E/S) de se chevaucher de manière équilibrée, améliorant ainsi les performances. Étant donné que l'utilisation de plusieurs disques augmente le temps moyen entre les pannes, le stockage des données de manière redondante augmente également la tolérance aux pannes.

Les matrices RAID apparaissent au système d'exploitation (OS) comme un seul disque logique.

- **Contrôleur RAID**

Un **contrôleur RAID** est un périphérique utilisé pour gérer les disques durs dans une matrice de stockage. Il peut être utilisé comme niveau d'abstraction entre le système d'exploitation et les disques physiques, présentant des groupes de disques comme des unités logiques. L'utilisation d'un contrôleur RAID peut améliorer les performances et aider à protéger les données en cas de panne.

Un **contrôleur RAID** peut être matériel ou logiciel. Dans un produit RAID matériel, un contrôleur physique gère l'ensemble de la matrice. Le contrôleur peut également être conçu pour prendre en charge des formats de lecteur tels que **Serial Advanced Technology Attachment** (**SATA**) et **Small Computer System Interface** (**SCSI**). Un **contrôleur RAID** physique peut également être intégré à la carte mère d'un serveur.

Avec le RAID logiciel, le contrôleur utilise les ressources du système matériel, telles que le processeur central et la mémoire. Bien qu'ils remplissent les mêmes fonctions qu'un contrôleur RAID matériel, les **contrôleurs RAID** logiciels peuvent ne pas permettre une telle amélioration des performances et peuvent affecter les performances d'autres applications sur le serveur.

### Niveaux RAID

Les périphériques RAID utilisent différentes versions, appelées **niveaux**. Le nombre de niveaux a depuis augmenté et a été divisé en trois catégories : **niveaux RAID standard**, **imbriqués** et **non standard**.

| |RAID 0 (Répartition)| RAID 1 (Mise en miroir) | RAID 10 (1+0)| RAID 5| RAID 50 (5+0)| RAID 6 (Double parité)| RAID 60 (6+0)|
|:----------:|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:|:-----------:|
|nombre minimum de disques|2|2|4|3|6|4|8|
|Tolérance aux pannes|None|1 disque|1 disque|1 disque|1 disque|2 disques|2 disques|
|Surcharge d'espace disque|None|50%|50%|1 disque|2 disques|2 disques|4 disques|

### Gestion des disques RAID

- Créons 2 partitions primaires de type RAID de taille 500M sur le phériphérique de bloc **/dev/sdd**

```
sudo fdisk /dev/sdd
```

--- Nous saisissons la lettre **'n'** pour créer une nouvelle partition <br>
--- Nous saisissons la lettre **'p'** pour définir la partition comme **primaire** <br>
--- Nous validons pour accepter la valeur par défaut (**'1'**) du numéro de la partition <br>
--- Nous validons pour accepter la valeur par défaut de la taille du premier secteur de disque <br>
--- Nous saisissons **'+500M'** pour définir la valeur de la taille du dernier secteur de disque <br>
--- Nous saisissons la lettre **'p'** pour voir la nouvelle partition créée <br>
--- Nous saisissons la lettre **'t'** pour modifier le type d'une partition <br>
--- Nous saisissons le numéro de la partition à modifier <br>
--- Nous saisissons la lettre **'l'** pour afficher tous les code hexa de tous les types de partition <br>
--- Nous saisisons **fd** correspondant au type de partition **RAID Linux auto** <br>
--- Nous saisissons la lettre **'p'** pour confirmer que le type de partition de la nouvelle partition a été modifié <br>
--- Nous saisissons la lettre **'w'** pour enregistrer tous les changements effectués

Nous créons la 2ème et la 3ème partition exactement de la même manière.

- Installons l'utilitaire **mdadm**

Sous Ubuntu

```
sudo apt-get install mdadm
```

Sous Rocky linux

```
sudo dnf install -y mdadm
```

- Créons un phériphérique **/dev/md0/** de type **RAID 0** avec les phériphériques **/dev/sdd1** et **/dev/sdd2**

```
sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sdd1 /dev/sdd2
```

L'option **--level** permet de préciser le niveau de RAID. L'option **-raid-devices** permet de préciser le nombre de phériphériques à utiliser.

- Vérifions que le phériphérique **RAID 0** a été bien créé

```
sudo cat /proc/mdstat
```

```
sudo mdadm --detail /dev/md0
```

Le résultat de cette commande fournit beaucoup plus de détails. Nous pouvons voir quand il a été créé, le type de matrice, la taille, le nombre de périphériques dans la matrice, quel est l'état du RAID, les périphériques actifs, etc.

- Formattons le phériphérique **/dev/md0** en **ext4**

```
sudo mkfs.ext4 /dev/md0
```

- Montons le phériphérique **/dev/md0** sur le repertoire **/mnt/raid**

```
sudo mkdir /mnt/raid
```

```
sudo mount /dev/md0 /mnt/raid
```

Pour vérifier que le phériphérique a été monté, nous pouvons exécuter

```
df -h
```

Si nous voulions en faire un montage permanent, nous devions effectuer quelques étapes supplémentaires.

--- Assurons que mdadm continuera à surveiller l'état des phériphériques

```
sudo mdadm --detail --scan
```

Cela nous donnera des informations sur le RAID que nous venons de créer.

--- Editons le fichier de configuration **mdadm.conf** en mettant comme contenu le résultat de la commande précédente

Sous Ubuntu

```
sudo vi /etc/mdadm/mdadm.conf
```

```
ARRAY /dev/md0 metadata=1.2 name=ubuntu-server:0 UUID=c574791b:b8fd29c5:828df8f4:748af923
```

Sous Rocky linux

```
sudo vi /etc/mdadm.conf
```

```
ARRAY /dev/md0 metadata=1.2 name=rocky-server:0 UUID=c574791b:b8fd29c5:828df8f4:748af923
```

--- Faisons savoir à **mdadm** que nous avons apporté des modifications

```
sudo mdadm --assemble --scan
```

Aucune erreur s'affiche.

Sous ubuntu après l'exécution de cette commande il faudrait exécuter la commande ci-dessous pour garantir qu'**initramfs** dispose d'une copie à jour

```
sudo update-initramfs -u
```

--- Ajoutons la configuration de montage **/dev/md0** dans le fichier **/etc/fstab**

```
sudo vi /etc/fstab
```

```
...
/dev/md0  /mnt/raid  ext4  defaults,nofail,discard  0  0
```

Si à tout moment nous devons ajouter un nouveau périphérique au RAID pour remplacer un périphérique endommagé ou étendre une matrice, nous pouvons simplement utiliser l'option **--add** avec **mdadm**. Par exemple ajoutons le 3ème phériphérique **/dev/sdd3** à notre phériphérique RAID 0 **/dev/md0**

```
sudo mdadm --grow /dev/md0 --level=0 --raid-devices=3 --add /dev/sdd3
```