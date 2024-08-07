# Gérer et configurer les machines virtuelles

Avant les conteneurs, les machines virtuelles étaient la réponse aux tests isolés. Comprendre les machines virtuelles en tant qu'administrateur système Linux nous fournira un autre outil puissant à utiliser. Pendant longtemps, les machines virtuelles ont été la seule option disponible pour isoler les applications et les processus.

Utilisation de **virt-manager**, **virt-install** et **virsh** pour créer, gérer, démarrer et arrêter nos propres machines virtuelles.

### Détails du serveur virtuel

- Vérifions si nous avons des extensions de machine virtuelle sur notre système

```
cat /proc/cpuinfo | egrep "vmx|svm"
```

Dans le résultat, si nous trouvons **vmx** (pour les processeurs Intel) ou **svm** (pour AMD), alors le système prend en charge la virtualisation matérielle.

- Téléchargeons l'image ISO de notre système d'exploitation cible

Nous devons utiliser les images x86 si nous souhaitons exécuter une machine virtuelle sur une machine virtuelle.

```
wget https://dl-cdn.alpinelinux.org/alpine/v3.10/releases/x86/alpine-standard-3.10.0-x86.iso
```

### Installation de KVM (Kernel-based Virtual Machine) + QEMU

Sous **Ubuntu**

```
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top virt-manager virt-viewer
```

Sous **Rocky**

```
sudo dnf install -y qemu-kvm libvirt virt-install virt-manager virt-viewer
```

### Gestion de machine virtuelle

Création du répertoire **virttemp** et d'une machine virtuelle avec notre iso **alpine-standard-3.10.0-x86.iso** préalablement téléchargé

```
mkdir virttemp && cd virttemp
```

```
virt-install --name=tiny --vcpus=1 --memory=1024 --cdrom=alpine-standard-3.10.0-x86.iso --disk size=5
```

Listons toutes les machines virtuelles

```
virsh list --all
```

Editons notre machine virtuelle préalablement installée

```
virsh edit tiny
```

Autorisons notre machine virtuelle **tiny** à démarrer automatiquement à chaque démarrage de notre serveur

```
virsh autostart tiny
```

Désactivons le démarrage automatique de notre machine virtuelle **tiny**

```
virsh autostart --disable tiny
```

Clonons notre machine virtuelle existante

```
sudo virt-clone --original=tiny --name=newtiny --file=/var/lib/libvirt/images/newtiny.qcow2
```

Listons à nouveau toutes les machines virtuelles

```
virsh list --all
```

Ouvrons un gestionnaire d'interface graphique pour les machines virtuelles

```
virt-manager
```