# Comprendre les systèmes de fichiers Linux et les répertoires par défaut

## Comprendre les systèmes de fichiers Linux

Le système de fichiers virtuel (également connu sous le nom de commutateur de système de fichiers virtuel) est la couche logicielle du noyau qui fournit l'interface du système de fichiers aux programmes de l'espace utilisateur. Il fournit également une abstraction dans le noyau qui permet à différentes implémentations de systèmes de fichiers de coexister.
<br>
- systèmes de fichiers linux courants : famille ext* (ext2, ext3, ext4,...), XFS, btrfs, ZFS,...
- Il fournit un moyen structuré de stocker des données.
- Il détermine la quantité et la taille des fichiers pouvant être stockés.
<br>

## Comprendre les répertoires par défaut

Pour afficher la structure des repertoires linux par défaut depuis la racine (**/**), nous saisissons les commandes :

```
cd /
tree -L 1
```

```
.
├── bin -> usr/bin
├── boot
├── cdrom
├── dev
├── etc
├── home
├── lib -> usr/lib
├── lib64 -> usr/lib64
├── media
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin -> usr/sbin
├── snap
├── srv
├── sys
├── tmp
├── usr
└── var
```

- **/** : le système de fichiers linux est structuré selon une hiérarchie commençant à la racine.

- **/home** : répertoires personnels des utilisateurs. Il contient des fichiers et des données de configuration spécifiques à un utilisateur.

- **/etc** : répertoire des fichiers de configuration à l'échelle du système. Ces fichiers sont utilisés pour contrôler le fonctionnement d'un programme.

- **/usr/local** : Il contient des logiciels installés localement. La structure du répertoire est volontairement similaire à celle du répertoire racine.

- **/opt** : répertoire réservé à l'installation de progiciels d'application complémentaires.

- **/root** : répertoires personnels de l'utilisateur **root**. Il contient des fichiers et des données de configuration spécifiques à l'utilisateur **root**.

- **/srv** : Il contient les données pour les services fournis par le système.