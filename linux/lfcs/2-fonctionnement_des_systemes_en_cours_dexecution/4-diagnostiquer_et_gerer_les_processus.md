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

- Afficher tous les processus associé au terminal courant avec leur valeur **nice**

```
ps l
```

- Afficher tous les processus avec leur valeur **nice**

```
ps lax
```

- Afficher les processus sous forme d'arborescence (parent - enfant)

```
ps af
```

- Afficher tous les processus sous forme d'arborescence sous format utilisateur

```
ps faux
```

- Afficher les informations sur le processus de pid 1

```
ps u 1
```

- Afficher les processus lancés par l'utilisateur **vagrant**

```
ps u -U vagrant
```

- Afficher le processus ayant le nom **syslog**

```
pgrep -a syslog
```

Elle affiche aussi la commande via laquelle le processus a été demarré.


- Afficher tous les fichiers et les repertoires utilisés par le processus de pid 1

```
sudo lsof -p 1 
```

- Afficher les processus utilisant le fichier **/etc/hosts**

```
sudo lsof /etc/hosts
```

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

**15241** est le PID d'un processus **/bin/bash** en cours d'exécution. <br>

- Les utilisateurs réguliers peuvent attribuer une valeur nice uniquement entre **0** et **19**. Pour assigner une valeur nice entre **-20** et **-1**, on doit avoir les privilèges root.
- Un utilisateur régulier ne peut pas mettre à jour la valeur d'un **nice** inférieur à la valeur de l'existant. Pour le faire, on doit avoir les privilèges root.

Pour vérifier si le changement a été appliqué, nous pouvons exécuter la commande et filtrer le processus de PID **15241**

```
htop
```

- Mettre en pause pour 180 secondes

```
sleep 180
```

- Mettre en pause un programme en cours d'exécution et cela le met en arrière plan

```
ctrl-z
```

- Mettre une commande en arrière plan avec le **&** : exemple avec la commande **sleep**

```
sleep 300 & 
```

- Afficher les jobs actifs (issus des commandes) en arrière plan avec leur id (identifiant du job)

```
jobs
```

- mettre un job existant en arrière plan comme s'il avait été démarré avec « & »

```
bg id
```

- Mettre un job avant plan grace à son id

```
fg id
```

- Stopper un programme actuellement exécuté au **premier plan** dans le terminal

```
ctrl-c
```

Il envoie un signal **SIGINT (Signal Interrupt)** qui demande au programme de s'arrêter immédiatement.

Linux a ce concept d'envoyer des processus appelés **signaux**. ce sont comme des messages de haute priorité envoyés aux processus auxquel ils doivent répondre. Mais une application ne peut agir sur un signal spécifique que si elle a été programmé pour répondre à ce signal. Cependant il y'a des signaux d'exception auxquel une application doit toujours répondre.

- afficher la liste des signaux qui peuvent être envoyer à un processus

```
kill -L
```

Pour envoyer un signal à un processus, soit on utilise son **nom** ou soit on utilise son **numéro**.

- Tuer un processus via son nom (exemple : **bash**)

```
pkill -KILL bash
```

- Tuer un processus via son pid

```
kill -SIGKILL 9313
kill -KILL 9313
kill -9 9313
```