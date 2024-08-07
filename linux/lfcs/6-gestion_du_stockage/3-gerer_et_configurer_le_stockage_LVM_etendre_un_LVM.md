# Gérer et configurer le stockage LVM - Etendre un LVM

Avec LVM, un administrateur système Linux contrôle le stockage disponible et peut augmenter ou réduire le stockage disponible selon ses besoins.

### Création d'une nouvelle partition primaire de type LVM de taille 500M

Précédemment nous avons créé 2 partitions primaires de type LVM de taille 500M sur le phériphérique de bloc **/dev/sdc**. Ici, nous créons une 3ème partition primaire en suivant la procédure précédente : [creer une partition LVM](./2-gerer_et_configurer_le_stockage_LVM_creer_un_LVM.md).

### Outils de gestion LVM

- Créer un volume physique pour la 3ème partition LVM

```
sudo pvcreate /dev/sdc3
```

- Lister les volumes physiques

```
sudo pvs
```

Pour l'instant, nous pouvons constater que le volume physique **/dev/sdc3** n'est attribué à aucun groupe de volume.

- Lister les groupes de volumes

```
sudo vgs
```

Nous constatons que pour le groupe de volume **vg01**, nous avons 2 volumes physiques et un volume logique.

- Etendre un groupe de volume en ajoutant un autre volume physique (**/dev/sdc3**)

```
sudo vgextend vg01 /dev/sdc3
```

Nous listons à nouveau les volumes physiques et nous constatons que le volume physique **/dev/sdc3** est attribué au groupe de volume **vg01**. 

```
sudo pvs
```

Nous listons à nouveau les groupes de volume et nous constatons que le groupe de volume **vg01** possède un espace libre (colonne **VFree**) de taile **496,00m**.

```
sudo vgs
```

- Lister les volumes logiques

```
sudo lvs
```

- Etendre un volume logique

Nous allons étendre notre volume logique **/dev/vg01/lv01** de **348M** (taille maximale de l'espace libre **496,00m**)

```
sudo lvextend -l 348 /dev/vg01/lv01
```

Nous listons à nouveau les volumes logiques et nous constatons que sa taille a augmenté (**LSize=1,36g**).

```
sudo lvs
```

- Appliquer l'extension du volume logique au système de fichier

Nous vérifions d'abord un système de fichiers Linux **ext2/ext3/ext4**.

```
sudo e2fsck -f /dev/vg01/lv01
```

Nous appliquons l'extension proprement dit

```
sudo resize2fs /dev/vg01/lv01
```

**NB:** Si le volume était préablement monté alors il faudrait d'abord le démonter avant d'appliquer la commande **resize2fs**.

Nous pouvons vérifier notre point de montage **/mnt/data**

```
sudo df -h
```

### Commandes additionnelles LVM

- Volume physique

--- **pvmove** : déplace les extensions physiques (PE) allouées sur un PV source vers un ou plusieurs PV de destination. <br>
--- **pvremove** : efface l'étiquette sur un périphérique afin que LVM ne le reconnaisse plus comme un PV. Un PV ne peut pas être supprimé d'un VG tant qu'il est utilisé par un LV actif.

- Groupe de volume

--- **vgreduce** : supprime un ou plusieurs PV inutilisés d'un VG. <br>
--- **vgremove** : supprime un ou plusieurs VG. Si des LV existent dans le VG, une invite est utilisée pour confirmer la suppression du LV.

- Volume logique

--- **lvreduce** : réduit la taille d'un LV. Les extensions logiques libérées sont renvoyées au VG pour être utilisées par d'autres LV. <br>
--- **lvremove** : supprime un ou plusieurs LV. Pour les LV standard, cela renvoie les extensions logiques utilisées par le LV au VG pour qu'elles soient utilisées par d'autres LV.


NB: Il faudrait toujours faire un backup de données existantes avant d'effectuer toute modification sur un volume logique.