# Diagnostiquer et gérer les processus

Nous avons un processus qui consomme plus de ressources qu’il ne le devrait. Comment pouvons-nous gérer le comportement des processus pour réduire leur utilisation ?

### top et htop

- **top**

--- Affiche les processus Linux <br>
--- Fournit une vue dynamique en temps réel d'un système d'exploitation en cours d'exécution

```
top
```

Nous pouvons voir un résumé en haut de la sortie, puis un tableau avec la sortie du processus lui-même, triée par utilisation du processeur. Nous pouvons voir depuis combien de temps le serveur est opérationnel, combien d'utilisateurs sont actifs, combien de tâches sont en cours d'exécution, nous pouvons vérifier l'activité du processeur, la mémoire et même le swap. Et si nous regardons le résultat, nous pouvons voir que le PID est la première entrée, le propriétaire du processus (**USER**), la priorité (**PR**), le niveau de qualité (**NI**), le dimensionnement de la mémoire virtuelle (**VIRT**), la resident set memory (**RES**), l'utilisation du processeur (**CPU**), l'utilisation de la mémoire (**MEM**), la durée pendant laquelle le processus a été actif (**TIME**), puis le processus ou la commande elle-même (**COMMAND**).

La colonne **"RES"** ou **"resident set size"** affichée par la commande **top** représente la quantité de mémoire physique (RAM) actuellement utilisée par un processus. Cela inclut la quantité de mémoire résidente réellement allouée au processus dans la RAM, ce qui exclut toute mémoire partagée ou paginée. En d'autres termes, il s'agit de la quantité de mémoire que le processus occupe actuellement en RAM et qui n'est pas partagée avec d'autres processus.

- **htop**

Développe les capacités de **Top**, offrant la mise en évidence des couleurs, l'intégration de la souris, la possibilité de rechercher, filtrer, trier et supprimer des processus, le tout depuis l'application.

```
htop
```

En haut, nous pouvons voir un résumé des informations comme celles de la commande **top** mais avec une interface plus colorée et interactive.
Avec l'intégration de la souris, nous pouvons cliquer sur l'en-tête et cela changera le tri de la colonne. Nous pouvons trier par **mémoire virtuelle** ou par **Nice**. Si nous souhaitons rechercher un processus spécifique, nous pouvons également accéder à l'option de filtre (**filter**); nous pouvons simplement saisir le processus que nous recherchons. Nous recherchons par exemple **cron** et il récupère l'instance **cron**. Nous pouvons continuer, effacer le filtre et revenir à la vue standard. Nous pouvons également obtenir une arborescence des processus; si nous cliquons sur la commande **tree**, elle nous montrera le processus parent et tous les processus enfants qui s'exécutent en dessous. Cela peut être très pratique lorsque nous résolvons un problème. Si nous connaissons le nom du processus et que nous essayons de déterminer ce qui l'a généré, l'arborescence nous aidera à comprendre ces informations. Si nous souhaitons en savoir plus sur **htop** ou voir ce qu'il peut faire d'autre, nous pouvons toujours cliquer sur la commande **help**. La page d'aide nous montrera certaines des commandes que nous pouvons utiliser dans **htop**, ainsi que des détails sur l'en-tête du résumé. Et puis pour quitter **htop**, il nous suffit de cliquer sur le bouton **Quit** et nous voilà de retour à la console.

Sous Ubuntu
```
sudo apt install htop
```

Sous Rocky
```
sudo dnf install htop
```

### ps

- Affiche un instantané des processus à un moment précis dans le temps
- Utile pour capturer les processus en cours, vérifier la propriété des processus et les PID des processus.

```
ps
```

```
ps -ef
```

Nous pouvons voir qu'une grande partie des informations fournies par la commande **ps** sont très similaires. Nous pouvons voir le propriétaire, le PID, l'heure de démarrage, la durée d'exécution et la commande elle-même.

- **-e** : cette option sélectionne tous les processus. En l'absence de cette option, **ps** n'affiche que les processus associés au terminal en cours.
- **-f** : cette option affiche une sortie formatée de manière étendue, incluant des informations supplémentaires telles que l'utilisateur, l'UID, le PID, le PPID (identifiant du processus parent), le statut du processus, le temps CPU utilisé

```
ps aux
```

Nous pouvons voir que l’argument **aux** renvoie un peu plus d’informations que l'argument **-ef**. Une grande partie des informations sont toujours les mêmes. Nous voyons l'utilisateur, le PID, mais cette fois nous pouvons voir les informations sur le CPU et la mémoire. Nous pouvons voir la mémoire virtuelle et la **resident set size**. Nous pouvons voir le statut de la commande, la date à laquelle le processus a été démarré, depuis combien de temps il est exécuté, puis la commande elle-même.

- **a** : cette option sélectionne tous les processus sur le système, sans tenir compte de l'association avec un terminal.
- **u** : cette option affiche une sortie formatée de manière étendue, incluant des informations supplémentaires telles que l'utilisateur, l'UID, le PID, le PPID (identifiant du processus parent), le statut du processus, le temps CPU utilisé, etc.
- **x** : cette option affiche les processus sans terminal associé.

```
ps aux | grep cron
```

```
ps aux | grep -v grep | grep -i -e cron
```

### nice et renice

- **nice**

--- Modifie la priorité d'un nouveau processus <br>
--- **-20** est la priorité la plus élevée et **19** est la priorité la plus basse.

```
sudo nice -n -10 /bin/bash
```

Pour vérifier si le changement a été appliqué, nous pouvons exécuter la commande et filtrer le processus **bash**

```
htop
```

- **renice**

Modifie la priorité d'un processus en cours d'exécution.

```
sudo renice -n -20 15241
```

**15241** est le PID d'un processus **/bin/bash** en cours d'exécution.

Pour vérifier si le changement a été appliqué, nous pouvons exécuter la commande et filtrer le processus de PID **15241**

```
htop
```