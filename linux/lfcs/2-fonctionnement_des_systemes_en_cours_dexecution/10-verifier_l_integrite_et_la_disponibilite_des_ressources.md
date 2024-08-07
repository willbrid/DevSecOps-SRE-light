# Vérifier l'intégrité et la disponibilité des ressources

Les performances et la stabilité sont au cœur d'un système Linux. Un administrateur système doit être capable de surveiller ou de dépanner ces ressources pour garantir la santé du système.

Que sont exactement les ressources système ? Les ressources système sont des composants d'un système d'ordinateur et incluent la mémoire (RAM), les disques durs, le processeur et les E/S réseau (entrée/sortie), pour n'en citer que quelques-uns.

### Mémoire (RAM)

Les problèmes liés à la mémoire peuvent parfois être difficiles à détecter. Un problème de mémoire peut être un processus consommant trop de mémoire, des applications qui se bloquent avec des erreurs de mémoire aléatoires ou une disparition soudaine de la mémoire du système lui-même. <br>
Linux inclut un outil, **Memtest86**, que nous pouvons utiliser pour tester la mémoire physique d'un serveur. Nous ne pouvons pas effectuer un test de mémoire complet pendant que le système d'exploitation est en cours d'exécution. Nous devons redémarrer le système et sélectionner l'option **Memtest86** dans le menu **GRUB**.

**Exemple sous ubuntu** :

- Exécuter la routine de test de mémoire (nécessite un redémarrage)
- Redémarrer dans le menu GRUB
- Sélectionner l'entrée **Test mémoire** pour exécuter les tests

### Disque dur

Suppons que nous souhaiterons tester l'intégrité du système de fichier **/dev/sdb** avec son point de montage **/media/linux/data**. Nous suivons ces différentes étapes.

- Vérifions les systèmes de fichier montés pour détecter le point de montage de **/dev/sdb**

```
df -h
```

- Démontons le système de fichiers problématique via le point de montage **/media/linux/data**

```
sudo umount /media/linux/data
```

Nous pouvons vérifier en exécutant à nouveau la commande permettant de lister l'ensemble des points de montage. <br>
Ne vérifier jamais un système de fichiers monté.

- Utilisons **fsck** pour vérifier le système de fichiers **/dev/sdb** et le lecteur

```
sudo fsck /dev/sdb
```

Nous pouvons utiliser **tune2fs** pour planifier la vérification au redémarrage :

```
sudo tune2fs -c 1 /dev/sdb
```

Le paramètre **-c** est le nombre de fois que le système de fichiers a été monté. Si le système de fichiers a été monté plus d'une fois, il exécutera la vérification du système de fichiers au prochain redémarrage.

Pour désactiver cette planification, nous exécutons

```
sudo tune2fs -c 0 /dev/sdb
```

- Le démarrage à partir d'un support externe est une bonne option.