# Configurer les quotas de disque d'utilisateur et de groupe pour les systèmes de fichiers

Parfois, un administrateur système Linux doit gérer l'utilisation du stockage sur un système administré, afin d'optimiser les performances et la disponibilité des ressources. Bien que l'espace disque soit beaucoup moins cher aujourd'hui qu'avant, si nous avons de nombreux utilisateurs ou une solution très utilisée, nous constaterons peut-être que nous devrons limiter la quantité de stockage utilisée par un utilisateur ou un groupe d'utilisateurs.

### Installation de l'utilitaire de quota

Sous ubuntu

```
sudo apt install -y quota
```

Pour vérifier que le module **quota** est chargé

```
sudo find /lib/modules/`uname -r` -type f -name '*quota_v*.ko*'
```

Sous Rocky linux

```
sudo dnf install -y quota
```

### Création d'une simple partition (/dev/sde1) de 2Go sur le périphérique /dev/sde

```
sudo fdisk /dev/sde
```

--- Nous saisissons la lettre **'n'** pour créer une nouvelle partition <br>
--- Nous saisissons la lettre **'p'** pour définir la partition comme **primaire** <br>
--- Nous validons pour accepter la valeur par défaut (**'1'**) du numéro de la partition <br>
--- Nous validons pour accepter la valeur par défaut de la taille du premier secteur de disque <br>
--- Nous saisissons **'+2048M'** pour définir la valeur de la taille du dernier secteur de disque <br>
--- Nous saisissons la lettre **'p'** pour voir la nouvelle partition créée <br>
--- Nous saisissons la lettre **'w'** pour enregistrer tous les changements effectués

Formattons la partition **/dev/sde1** en **ext4**

```
sudo mkfs.ext4 /dev/sde1
```

Affichons l'identifiant **UUID** de la partition **/dev/sde1**

```
sudo blkid | grep sde1
```

### Montage de la partition /dev/sde1 au niveau du repertoire /mnt/quotadata, avec les options de quota

- Créons le repertoire **/mnt/quotadata**

```
sudo mkdir /mnt/quotadata
```

- Activons les quotas d'utilisateurs et de groupes sur la partition **/dev/sde1** depuis le fichier **/etc/fstab**

```
sudo vi /etc/fstab
```

```
...
UUID=686a3fd3-e0c3-4f3e-86a4-2c01173be227  /mnt/quotadata  ext4  usrquota,grpquota  0  0
```

- Activons le montage sur le repertoire **/mnt/quotadata**

```
sudo mount -a
```

- Vérifions si le montage a été effectué

```
sudo cat /proc/mounts | grep '/mnt/quotadata'
```

La sortie de la commande contiendra les deux chaines : **usrquota**, **grpquota**.

### Gestion de quota sur le repertoire /mnt/quotadata

- Créons les fichiers de quotas d'utilisateurs et/ou de groupes pour le repertoire **/mnt/quotadata**

```
sudo quotacheck -cugm /mnt/quotadata
```

```
ls -alh /mnt/quotadata
```

- Activons les quotas (utilisateur et groupe) sur le repertoire **/mnt/quotadata**

```
sudo quotaon -v /mnt/quotadata
```

- Créons deux utilisateurs **willbrid** et **rodriguo** auxquel nous appliquerons un quota

```
sudo useradd willbrid
```

```
sudo useradd rodriguo
```

- Créons aussi deux groupes **dev** et **ops** auxquel nous appliquerons un quota

```
sudo groupadd dev
```

```
sudo groupadd ops
```

- Avec la commande **edquota** appliquons un quota sur l'utilisateur **willbrid** et sur le groupe **dev**, avec une limite **soft (souple)** de 100M et une limite **hard (stricte)** de 150M, sur la partition **/dev/sde1**

```
sudo edquota -u willbrid
```

```
sudo edquota -g dev
```

--- Cette commande ouvrira un fichier dont la 1ère colonne indique le **Système de fichiers** : nous devons nous rassurer que la partition **/dev/sde1** soit mentionnée.

```
Quotas disque pour user willbrid (uid 1001) :
 Système de fichiers           blocs       souple     stricte   inodes    souple   stricte
  /dev/sde1                         0      100000     150000        0        0        0
```

Vérifions les informations sur ce quota utilisateur **willbrid** et groupe **dev**

```
sudo quota -vs willbrid
```

```
sudo quota -vgs dev
```

Nous pouvons voir que la limite de quota souple est fixée à **100 000 Ko**, soit **100 Mo**, et la limite stricte est fixée à **147 Mo**. Même si nous fixons la limite à **150 Mo** en raison de la surcharge, cela nous montre **147 Mo**.

- Avec la commande **setquota** appliquons un quota sur l'utilisateur **rodriguo** et sur le groupe **ops**, avec une limite **soft (souple)** de 150M et une limite **hard (stricte)** de 200M, sur le repertoire **/mnt/quotadata**

```
sudo setquota -u rodriguo 150M 200M 0 0 /mnt/quotadata
```

```
sudo setquota -g ops 150M 200M 0 0 /mnt/quotadata
```

Vérifions les informations sur ce quota utilisateur **rodriguo**

```
sudo quota -vs rodriguo
```

```
sudo quota -vgs ops
```

Une fois les quotas activés et les utilisateurs et groupes configurés, nous pouvons exécuter des rapports d'utilisation pour surveiller l'activité.

- Affichons les rapports d'utilisation

```
sudo repquota -asgu
```

Cela renverra des informations sur toutes les montures avec des quotas dans un format lisible et fournira un rapport sur les utilisateurs ainsi que sur les groupes. Puisque nous venons d'activer les quotas et d'activer les utilisateurs, nous n'avons aucune donnée dans notre rapport, mais nous pouvons voir que les utilisateurs root répertoriés, la section supérieure est destinée aux utilisateurs et la section inférieure est destinée au groupe. Nous pouvons voir que l’utilisateur root n’a pas de limites souples ou de limites strictes en place.