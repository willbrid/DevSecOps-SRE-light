# Configurer les systèmes pour monter des systèmes de fichiers à la demande

Toutes les données et tous les fichiers ne résideront pas localement sur un système, un administrateur système Linux doit donc comprendre comment monter des systèmes distants et les rendre disponibles à la demande. Linux ne peut pas vraiment toucher à quoi que ce soit sur le disque tant qu'il n'est pas monté et prêt.

### Installation d'un client samba

Sous Ubuntu

```
sudo apt install -y smbclient cifs-utils
```

Sous Rocky linux

```
sudo dnf install -y samba-client samba-common cifs-utils
```

### Configuration d'un serveur samba avec accès sécurisé

- Installation du service **samba**

Sous Ubuntu

```
sudo apt install -y samba
```

Sous Rocky linux

```
sudo dnf install -y samba
```

- Configuration du repertoire de partage samba

--- création du repertoire **/home/sharedsamba**

```
sudo mkdir /home/sharedsamba
```

--- création du groupe **smbgroup**

```
sudo groupadd smbgroup
```

--- attribuons le groupe **smbgroup** au repertoire **/home/sharedsamba**

```
sudo chgrp smbgroup /home/sharedsamba
```

--- attribuons les autorisations 770 au repertoire **/home/sharedsamba**

```
sudo chmod 770 /home/sharedsamba
```

- Configuration du fichier **/etc/samba/smb.conf**

```
sudo vi /etc/samba/smb.conf
```

```
[global]
    workgroup = SAMBA
    security = user
    unix charset = UTF-8
    server min protocol = SMB3
    log file = /var/log/samba/%m.log
    log level = 1
    hosts allow = 127.0.0.1 192.168.56.0/24 
...
...
[sharedsamba]
    path = /home/sharedsamba
    writable = yes
    guest ok = no
    valid users = @smbgroup
    force group = smbgroup
    force create mode = 770
    force directory mode = 770
    inherit permissions = yes
```

Vérifions que le fichier de configuration est correct

```
sudo testparm -s /etc/samba/smb.conf
```

Activons le service samba

Sous Ubuntu
```
sudo systemctl enable --now smbd
```

Sous Rocky
```
sudo systemctl enable --now smb
```

- Configuration de l'utilisateur **smbuser**

--- ajoutons un utilisateur **smbuser**

```
sudo useradd smbuser
```

--- attribuons l'utilisateur **smbuser** et un mot de passe comme paramètre d'authentification pour le serveur samba

```
sudo smbpasswd -a smbuser
```

Mot de passe utilisé : **testtest**

--- ajoutons l'utilisateur **smbuser** au groupe **smbgroup**

```
sudo usermod -aG smbgroup smbuser
```

- Pour Rocky linux, configurons **selinux** pour le repertoire de partage **sharedsamba**

```
sudo setsebool -P samba_enable_home_dirs on
```

```
sudo restorecon -R /home/sharedsamba
```

- Pour Rocky linux, configurons **firewalld** pour autoriser le service **samba**

```
sudo firewall-cmd --permanent --add-service=samba
```

```
sudo firewall-cmd --reload
```

### Utilisation du client smb depuis notre serveur Ubuntu pour tester notre service samba sur notre serveur rocky linux

- Listons les partages distants

```
smbclient -L //192.168.56.110 -W SAMBA -U smbuser
```

- Connectons nous au repertoire de partage de notre service samba

```
smbclient //192.168.56.110/sharedsamba -W SAMBA -U smbuser
```

- Montons le repertoire de partage **sharedsamba** de notre service samba sur le repertoire **/mnt/samba**

```
sudo mkdir /mnt/samba
```

Créons le fichier **/mnt/.smbcredentials** pour les paramètres d'authentification à notre service samba

```
sudo vi /mnt/.smbcredentials
```

```
username=smbuser
password=testtest
```

```
sudo chmod 600 /mnt/.smbcredentials
```

Editons le fichier **/etc/fstab** pour ajouter le point de montage de **//192.168.56.110/sharedsamba**

```
sudo vi /etc/fstab
```

```
...
//192.168.56.110/sharedsamba  /mnt/samba  cifs  credentials=/mnt/.smbcredentials,defaults  0  0
```

```
sudo mount -a
```

Pour vérifier que le montage a été effectué avec succès nous exécutons

```
sudo df -h
```

Sur notre serveur rocky-server ayant notre service samba, créons un fichier **test.txt** sans le repertoire de partage **/home/sharedsamba**

```
sudo su
```

```
echo "test du service samba" > test.txt
```

Nous pouvons ainsi visualiser ce fichier sur notre point de montage **/mnt/samba/** depuis notre machine client ubuntu-server.

```
ls -alh /mnt/samba/
```

```
cat /mnt/samba/test.txt
```