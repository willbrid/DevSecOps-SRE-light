# Création de notre propre fichier vagrant box [Part2]

Vagrant inclut un moyen simple de faire un package des boîtes de base de VirtualBox. Une fois que les préliminaires de la **partie 1** ont été bien suivis, Nous pouvons exécuter la commande : 
```
vagrant package --base willbrid/rockylinux8 --output rockylinux8.box
```

Ici **willbrid/rockylinux8** est le nom de notre machine virtuelle précédemment créée et configurée. <br>
Grace à l'option **--output**, un fichier **rockylinux8.box** sera créé dans le répertoire courant. Ainsi pour importer notre propre box à partir de ce répertoire courant, nous pouvons exécuter la commande :

```
vagrant box add rockylinux8
```