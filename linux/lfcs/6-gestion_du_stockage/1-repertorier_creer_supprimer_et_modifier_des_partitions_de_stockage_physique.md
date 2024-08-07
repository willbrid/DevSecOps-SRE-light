# Répertorier, créer, supprimer et modifier des partitions de stockage physique

S'assurer que les systèmes disposent de suffisamment de stockage pour fonctionner correctement est une compétence importante que les administrateurs système Linux doivent acquérir. Les systèmes modernes axés sur les données nécessitent aujourd'hui de plus en plus de stockage afin de fournir les services pour lesquels ils ont été conçus. Un administrateur système Linux doit savoir comment voir quel stockage est disponible sur un système et comment le gérer.

### Utilitaire lsblk

Utilitaire utilisé pour lister les périphériques de blocs.

```
lsblk
```

### Utilitaire fdisk

Utilitaire utilisé pour gérer les partitions de disque. Limite de taille de partition à **2 To** et impossible d'agrandir ou de réduire les partitions.

- **Créons une partition sur le périphérique sans partition /dev/sdb**

```
sudo fdisk /dev/sdb
```

--- Nous saisissons la lettre **'g'** pour créer une nouvelle table de partition GPT vide et attribuer une nouvelle étiquette de disque <br>
--- Nous saisissons la lettre **'n'** pour créer une nouvelle partition <br>
--- Nous validons pour accepter la valeur par défaut (**'1'**) du numéro de la partition <br>
--- Nous validons pour accepter la valeur par défaut de la taille du premier secteur de disque <br>
--- Nous saisissons **'+800M'** pour définir la valeur de la taille du dernier secteur de disque <br>
--- Nous saisissons la lettre **'p'** pour voir la nouvelle partition créée <br>
--- Nous créons une 2ème partition en validant tous les paramètres par défaut : ce qui permettra d'attribuer la taille restante du disque à cette partition <br>
--- Nous saisissons la lettre **'w'** pour enregistrer tous les changements effectués

Nous pouvons vérifier que les nouvelles partitions ont créées sur le périphérique **/dev/sdb**

```
lsblk
```

- **Supprimons une partition (2ème partition créée)**

```
sudo fdisk /dev/sdb
```

--- Nous saisissons la lettre **'d'** pour supprimer une partition <br>
--- Nous saisissons la valeur **'2'** pour préciser le numéro de la partition à supprimer <br>
--- Nous saisissons la lettre **'p'** pour voir les modifications apportées <br>
--- Nous saisissons la lettre **'w'** pour enregistrer tous les changements effectués <br>

Nous pouvons vérifier que la partition **2** a été supprimée sur le périphérique **/dev/sdb**

```
lsblk
```

### Utilitaire parted

Un autre utilitaire utilisé pour gérer les partitions de disque et l'on peut agrandir ou réduire une partition et gérer des partitions > **2 To**.

```
sudo parted /dev/sdb
```

- Nous saisissons la commande **print** de **parted** pour afficher les partitions
- Nous saisissons la commande **help** de **parted** pour afficher l'aide
- Nous saisissons la commande **mkpart** de **parted** pour démarrer la création d'une nouvelle partition
--- Nous validons pour accepter la valeur par défaut du nom de la partition <br>
--- Nous saisissons **ext4** pour préciser le type de système de fichier de la partition <br>
--- Nous saisissons **'801'** pour définir la valeur de la taille de départ et **'901'** pour la taille de fin <br>
--- Nous saisissons **'yes'** pour enregistrer nos modifications
- Nous saisissons à nouveau la commande **print** de **parted** pour afficher les partitions et voir la 2ème partition recréée
- Nous saisissons la commande **quit** de **parted** pour quitter l'invite **parted**

Au niveau de la première commande (**print**), si nous rencontrons une erreur

```
Error: Unable to open /dev/sdb - unrecognized disk label
```

alors nous devons créer une nouvelle étiquette de disque de type **gpt** avec la commande **mklabel** de **parted**

```
mklabel gpt
```

- Nous pouvons redimensionner la taille d'une partition (par exemple celui de la 2ème partition)

```
sudo parted /dev/sdb
```

--- Nous saisissons la commande **resizepart** de **parted** pour démarrer le redimensionnement d'une partition <br>
--- Nous saisissons la valeur **'2'** pour préciser le numéro de la partition à redimensionner <br>
--- Nous saisissons **'1024'** pour définir la taille de fin <br>
--- Nous saisissons à nouveau la commande **print** de **parted** pour afficher les partitions et voir la 2ème partition redimensionnée <br>
--- Nous saisissons la commande **quit** de **parted** pour quitter l'invite **parted**

Nous pouvons aussi vérifier le résultat du redimensionnement de la 2ème partition avec la commande ci-dessous

```
lsblk
```