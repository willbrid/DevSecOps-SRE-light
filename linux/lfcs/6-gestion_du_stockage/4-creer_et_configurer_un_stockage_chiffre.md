# Créer et configurer un stockage chiffré

Parfois, le contrôle de l'accès des utilisateurs ne suffit pas à protéger les données. Un administrateur système Linux doit donc être prêt à chiffrer le stockage sur les systèmes si nécessaire. <br>
La protection des données sensibles peut s'avérer difficile, et la simple restriction des privilèges des utilisateurs ne suffit pas toujours. Avoir un stockage qui peut être verrouillé et déverrouillé à volonté offre un autre niveau de sécurité.

- Vérifions si le module de chiffrement du noyau est chargé

```
grep -i config_dm_crypt /boot/config-$(uname -r)
```

L'on devrait avoir le résultat

```
CONFIG_DM_CRYPT=m
```

- Installons l'utilitaire **cryptsetup**

Sous Ubuntu

```
sudo apt install -y cryptsetup
```

Sous Rocky

```
sudo dnf install -y cryptsetup
```

- Créons une partition chiffrée avec la partition **/dev/sdb1**

```
sudo cryptsetup -y luksFormat /dev/sdb1
```

Nous répondons **YES** (en majuscule) et nous saisissons le mot de passe : **testTEST1234567**

- Ouvrons notre partition chiffrée en lui donnant le nom **secret**

```
sudo cryptsetup luksOpen /dev/sdb1 secret
```

En appliquant la commande **lsblk**, nous constatons le nom **secret** au niveau de la partition **/dev/sdb1** et aussi qu'un périphérique **/dev/mapper/secret** est créé.

```
lsblk
```

- Formatons ce phériphérique **/dev/mapper/secret** en **ext4**

```
sudo mkfs.ext4 /dev/mapper/secret
```

- Créons un répertoire de montage **encrypted** de ce phériphérique **/dev/mapper/secret**

```
sudo mkdir /mnt/encrypted
```

- Montons ce phériphérique **/dev/mapper/secret** au répertoire **/mnt/encrypted**

```
sudo mount /dev/mapper/secret /mnt/encrypted
```

Exécutons les commandes **lsblk** et **df** pour vérifier si ce montage a été bien effectué

```
lsblk
```

```
df -h
```

- Créons un fichier **secretfile.txt** dans le repertoire **/mnt/encrypted**

```
sudo -i
```

```
echo "I am an encrypted file !" > /mnt/encrypted/secretfile.txt
```

```
cat encrypted/secretfile.txt
```

```
exit
```

- Fermer la partition chiffrée préalablement ouverte sous le nom **secret**

```
sudo umount /mnt/encrypted
```

```
sudo cryptsetup luksClose secret
```

En listant le contenu du répertoire **/mnt/encrypted** nous constatons qu'il est vide.

```
ls -alh /mnt/encrypted
```

- Réouvrons la partition chiffrée à nouveau sous un autre nom de périphérique **urgence** (**/dev/mapper/urgence**), puis montons ce périphérique sur le répertoire **/mnt/encrypted**

```
sudo cryptsetup luksOpen /dev/sdb1 urgence
```

```
sudo mount /dev/mapper/urgence /mnt/encrypted
```

En listant le contenu du répertoire **/mnt/encrypted**, nous constatons qu'il contient notre fichier **secretfile.txt** préalablement créé avec le même contenu.

```
ls -alh /mnt/encrypted
```

```
cat /mnt/encrypted/secretfile.txt
```

- Fermons la partition chiffrée ouverte sous le nom **urgence**

```
sudo umount /mnt/encrypted
```

```
sudo cryptsetup luksClose urgence
```