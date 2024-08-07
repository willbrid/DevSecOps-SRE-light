# Comprendre le démarrage de Linux

## Comprendre le BIOS/UEFI

C'est un firmware qui est stocké dans une puce sur la carte mère.

- Il détecte et cartographie les périphériques connectés. 
- Il effectue un auto-test à la mise sous tension (POST : power-on-self-test) du matériel du système d'exploitation. 
- Il lance la séquence de démarrage à partir d'un périphérique connecté. 
- Les systèmes modernes utilisent l'UEFI.

En tout le BIOS/UEFI valide que le matériel fonctionne correctement et localise un périphérique amorçable. 

## Comprendre le chargeur de démarrage (bootloader)

- Le chargeur de démarrage est généralement stocké dans le premier bloc ou une partition spécifique du périphérique amorçable.
- Il charge l'image du noyau.
- Il charge l'image initrd (initramfs).
- Le GRand Unified Bootloader (GRUB) est le chargeur de démarrage principal pour la plupart des distributions Linux.

## Comprendre le noyau (kernel)

- Le composant central du système d'exploitation Linux.
- C'est une image compressée située dans le répertoire **/boot** du système de fichiers.
- Il configure le système d'exploitation.
- Il monte le système de fichiers racine.
- Il exécute le processus d'initialisation principal (c'est-à-dire : systemd)

## Comprendre le post kernel ou systemd

- **systemd** est le principal processus d'initialisation pour la plupart des distributions Linux.
- **systemd** est responsable du lancement de tous les autres processus.
- **systemd** crée des processus en parallèle.
- **systemd** place un système à un état prédéfini appelé **cible** (**target**).