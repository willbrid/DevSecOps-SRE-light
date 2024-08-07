# Évaluer et comparer les fonctionnalités et options de base du système de fichiers

Un système de fichiers nous permet de stocker et de récupérer des données sur un ordinateur.

**Périphérique bloc** : support utilisé pour stocker des données (SSD, disque dur magnétique, CD, flash, disquette) <br>
**Système de fichiers** : méthode permettant au système d'exploitation d'interagir avec les données sur un **périphérique bloc**.

### Les systèmes de fichiers 

- **EXT4**

EXT4 est le meilleur choix en ce moment de système de fichiers. Il existe depuis longtemps et a fait l'objet de tests de production approfondis dans le monde Linux.

- **EXT2/EXT3/EXT3**

--- EXT - 1992, créé spécifiquement pour Linux <br>
--- EXT2 - 1993, pas de journalisation, mais prend en charge les attributs étendus et le stockage de 2 To. <br>
--- EXT3 - 2001, journalisation incluse, mise à niveau en place depuis EXT2 <br>
--- EXT4 - 2008, rétrocompatible, augmentation de la taille du système de fichiers (1 EB), augmentation de la taille maximale des fichiers (16 To), sommes de contrôle du journal et attribution différée <br>

- **BTRFS**

--- Souvent appelé BetterFS ou ButterFS <br>
--- Créé par Oracle en 2007, stable en 2013 <br>
--- Inclut l'extension et la réduction de FS en ligne, des instantanés en lecture seule pour des sauvegardes plus rapides, une gestion plus efficace des petits fichiers et des index de répertoires, la défragmentation en ligne et la conversion sur place de EXT FS <br>
--- Considéré par certains comme le futur remplaçant de l'EXT4 <br>

- **Reiser FS**

--- Introduit en 2001 <br>
--- Offre plusieurs améliorations par rapport à EXT4 <br>
--- Il a été livré en 2004 et était autrefois considéré comme le remplaçant de EXT4. <br>
- Le développement s'est arrêté lorsque le développeur principal a été envoyé en prison en 2008. <br>

- **ZFS**

--- Créé par Sun Microsystems pour Solaris, maintenant propriété d'Oracle <br>
--- Prend en charge la mise en commun de lecteurs, les instantanés FS, l'entrelacement du système de fichiers <br>
--- Chaque fichier a une somme de contrôle, ce qui permet de savoir facilement si un fichier a été corrompu. <br>
--- Rendu disponible sous le CDDL, ce qui signifie qu'il ne peut pas être inclus dans le noyau Linux, mais peut être facilement ajouté <br>

- **XFS**

--- Développé par Silicon Graphics pour Irix en 1994, porté sur Linux en 2001 <br>
--- Similaire à EXT4 à bien des égards, avec une allocation dynamique et d'autres fonctionnalités <br>
--- Peut être étendu à la volée, mais ne peut pas être réduit <br>
--- Gère bien les fichiers volumineux mais souffre de problèmes de performances avec tous les petits fichiers <br>

- **JFS**

--- Développé par IBM en 1990 pour AIX, porté sur Linux en 1999 <br>
--- Offre de bonnes performances sur les fichiers petits et volumineux, ainsi qu'une faible empreinte CPU <br>
--- De nombreuses fonctionnalités utiles, mais il manque les tests de production Linux étendus que d'autres systèmes de fichiers ont <br>

- **Swap**

--- Utilisé pour former un lecteur, mais pas techniquement un système de fichiers . <br>
--- Utilisé pour la mémoire virtuelle (échange de mémoire) et n'a pas de structure visible <br>
--- Emplacement temporaire pour les éléments en mémoire à stocker dans des situations de faible RAM <br>

- **FAT/FAT32/exFAT**

--- Système de fichiers développé par Microsoft <br>
--- N'offre pas de journalisation, mais est pris en charge par la plupart des systèmes d'exploitation, ce qui le rend très compatible <br>
--- La compatibilité entre les systèmes d'exploitation et l'absence de journalisation en font une bonne utilisation pour les clés USB ou d'autres supports partagés entre les systèmes <br>
--- exFAT est le meilleur choix car il prend en charge des tailles de fichiers et de partitions plus importantes. <br>