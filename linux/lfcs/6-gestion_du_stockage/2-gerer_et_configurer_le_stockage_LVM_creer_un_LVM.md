# Gérer et configurer le stockage LVM - Créer un LVM

La combinaison de plusieurs disques en un seul volume est un moyen pour les administrateurs système Linux d'optimiser le stockage en utilisant les disques disponibles. La gestion des volumes logiques (**Logical Volume Management**) nous permet de joindre plusieurs disques physiques de manière à ce qu'ils soient présentés au système d'exploitation comme un seul périphérique.

### Création de deux partitions primaires de type LVM de taille 500M

```
sudo fdisk /dev/sdc
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
--- Nous saisisons **8e** correspondant au type de partition **LVM Linux** <br>
--- Nous saisissons la lettre **'p'** pour confirmer que le type de partition de la nouvelle partition a été modifié <br>
--- Nous saisissons la lettre **'w'** pour enregistrer tous les changements effectués

Nous créons la 2ème partition exactement de la même manière.

### Outils de gestion LVM

- Créer les volumes physiques pour les partitions LVM **/dev/sdc1** et **/dev/sdc2**

```
sudo pvcreate /dev/sdc1 /dev/sdc2
```

- Lister les volumes physiques

```
sudo pvdisplay
```

Elle affiche les informations détaillées des volumes physiques parmi lesquel : <br>
--- **PV Name** : nom du volume physique <br>
--- **VG Name** : nom du groupe de volumes <br>
--- **PV Size** : taille du volume physique <br>
--- **PV UUID** : l'identifiant unique universel (UUID) du volume physique

- Créer un groupe de volumes à partir de volumes physiques (**/dev/sdc1** et **/dev/sdc2**)

```
sudo vgcreate vg01 /dev/sdc1 /dev/sdc2
```

Nous pouvons à nouveau lister les volumes physiques et constater que le champ **VG Name** a désormais une valeur **vg01** correspondant au nom de groupe créé.

```
sudo pvdisplay
```

Nous pouvons aussi afficher les volumes de groupe

```
sudo vgdisplay
```

- Créer un (ou plusieurs) volume logiques à partir d'un groupe de volume physique (**VG : vg01**)

```
sudo lvcreate --name lv01 --size 992M vg01
```

- Lister les volumes logiques existantes

```
sudo lvdisplay
```

Elle affiche les informations détaillées des volumes logiques parmi lesquel : <br>
--- **LV Path** : chemin du volume logique <br>
--- **LV Name** : nom du volume logique <br>
--- **VG Name** : nom du groupe de volumes <br>
--- **LV UUID** : l'identifiant du volume logique <br>
--- **LV Size** : taille du volume logique <br>
--- **LV Write Access** : type d'accès du volume logique <br>
--- **LV Status** : statut du volume logique

- Formater le chemin du volume logique **/dev/vg01/lv01** en ext4

```
sudo mkfs.ext4 /dev/vg01/lv01
```

- Monter le volume formaté vers le repertoire **/mnt/data**

```
sudo mkdir /mnt/data
```

```
sudo mount /dev/vg01/lv01 /mnt/data
```

Pour garantir la persistance, nous ajoutons ce montage dans le fichier **/etc/fstab**

```
sudo vi /etc/fstab
```

```
/dev/vg01/lv01          /mnt/data               ext4    defaults        0 0
```

Pour vérifier si le montage a été bien effectué, nous exécutons

```
sudo df -h
```

Créons un fichier **test.txt** dans le repertoire **/mnt/data**

```
cd /mnt/data
```

```
sudo vi test.txt
```

```
Ceci est un fichier test !
```

```
ls -lah
```