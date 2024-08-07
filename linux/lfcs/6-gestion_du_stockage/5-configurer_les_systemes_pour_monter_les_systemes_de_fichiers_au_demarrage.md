# Configurer les systèmes pour monter les systèmes de fichiers au démarrage

Les utilisateurs ne peuvent pas accéder aux données si un système de fichiers n'est pas disponible. Un administrateur système Linux doit s'assurer que les systèmes de fichiers se montent correctement et sont accessibles. Les systèmes de fichiers Linux ne ressemblent pas à Windows. Ils nécessitent une planification et une réflexion pour déterminer ce qui devrait être disponible au démarrage.

La table du système de fichiers de notre système Linux, également appelée **fstab** (**/etc/fstab**), est une table de configuration conçue pour alléger le fardeau du montage et du démontage des systèmes de fichiers sur une machine. Il s'agit d'un ensemble de règles utilisées pour contrôler la manière dont les différents systèmes de fichiers sont traités à chaque fois qu'ils sont introduits dans un système. Le fichier **/etc/fstab** est conçu pour configurer une règle selon laquelle des systèmes de fichiers spécifiques sont détectés, puis automatiquement montés dans l'ordre souhaité par l'utilisateur à chaque démarrage du système.

### Structure de la table fstab

La table **fstab** est une structure à 6 colonnes, où chaque colonne désigne un paramètre spécifique et doit être configurée dans le bon ordre.

- **périphérique** : il définit le périphérique de stockage (**ex: /dev/sdb**)
- **point de montage** : il désigne le répertoire où est/sera monté le périphérique
- **type de système de fichiers** : il définit le type de système de fichiers du périphérique ou de la partition à monter
- **options** : il répertorie toutes les options de montage actives. Si nous utilisons plusieurs options, elles doivent être séparées par des virgules.
- **opération de sauvegarde** : il est utilisé par l'utilitaire de **dump** pour décider quand effectuer une sauvegarde. Une fois installé, **dump** vérifie l'entrée et utilise le numéro pour décider si un système de fichiers doit être sauvegardé. Les entrées possibles sont **0** et **1**. Si **0**, dump ignorera le système de fichiers, si **1**, dump effectuera une sauvegarde.
- **ordre de vérification du système de fichiers** : **fsck** lit le numéro d'**ordre de vérification** et détermine dans quel ordre les systèmes de fichiers doivent être vérifiés. Les entrées possibles sont **0**, **1** et **2**. Le système de fichiers racine doit avoir la priorité la plus élevée : **1**. Tous les autres systèmes de fichiers que nous souhaitons vérifier doivent avoir un **2**. Les systèmes de fichiers avec une valeur d'**ordre** **0** ne seront pas vérifiés par l'utilitaire **fsck**.

Certaines des **options** de la table **fstab** les plus courantes sont :

- **auto** : le système de fichiers sera monté automatiquement au démarrage ou lorsque la commande **'mount -a'** est émise.
- **noauto** : le système de fichiers est monté uniquement lorsque nous le lui demandons.
- **exec** : autorise l'exécution des binaires qui se trouvent sur cette partition (par défaut).
- **noexec** : n'autorise pas l'exécution de binaires sur le système de fichiers.
- **ro** : monte le système de fichiers en lecture seule.
- **rw** : monte le système de fichiers en lecture-écriture.
- **sync** : Les E/S doivent être effectuées de manière synchrone.
- **async** : Les E/S doivent être effectuées de manière asynchrone.
- **flush** : option spécifique permettant à FAT de vider les données plus souvent, ce qui permet de copier des boîtes de dialogue ou des barres de progression jusqu'à ce que les éléments soient sur le disque.
- **user** : autorise n'importe quel utilisateur à monter le système de fichiers (implique **noexec**, **nosuid**, **nodev** sauf remplacement).
- **nouser** : autorise uniquement root à monter le système de fichiers (par défaut).
- **defaults** : paramètres de montage par défaut (équivalents à **rw,suid,dev,exec,auto,nouser,async**).
- **suid** : autorise le fonctionnement des bits **suid** et **sgid**. Ils sont principalement utilisés pour permettre aux utilisateurs d'un système d'exécuter des exécutables binaires avec des privilèges temporairement élevés afin d'effectuer une tâche spécifique.
- **nosuid** : bloque le fonctionnement des bits **suid** et **sgid**.
- **noatime** : ne met pas à jour les temps d'accès aux inodes sur le système de fichiers. Peut aider à la performance.

### Montage d'une partition

- Affichons les identifiants **UUID** de toutes les partitions du phériphérique **/dev/sdb**

```
sudo blkid | grep sdb
```

- Montons la partition **/dev/sdb2** via le fichier **/etc/fstab**

```
sudo vi /etc/fstab
```

```
UUID=xxx /mnt/backup ext4 defaults 0 0
```

**xxx** est la valeur de **UUID** prise dans le résultat de la commande **blkid**.

Verifions si le fichier **/etc/fstab** est valide.

```
sudo findmnt --verify
```

Montons toutes les partitions se trouvant dans le fichier **/etc/fstab**

```
sudo mount -a
```

Exécutons la commande **lsblk** pour vérifier

```
lsblk
```

Dans les résultats nous verrons le répertoire de montage **/mnt/backup** au niveau de la ligne de la partition **/dev/sdb2**