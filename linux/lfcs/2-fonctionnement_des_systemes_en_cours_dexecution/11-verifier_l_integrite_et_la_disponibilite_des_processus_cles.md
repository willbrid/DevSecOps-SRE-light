# Vérifier l'intégrité et la disponibilité des processus clés

Les processus système sont au cœur d'un système d'exploitation, fournissant les fonctionnalités de base. Un administrateur système doit être capable de gérer les processus efficacement.

Les processus sont des applications activement chargées et/ou exécutées dans un système d'exploitation. Ces processus consomment de la mémoire et des cycles de processeur et peuvent parfois rencontrer des problèmes.

### Commande ps

- Statut du processus - afficher des informations sur les processus actifs

- Utilisations courantes :

```
ps -e
```

L'option **-e** permet de sélectionner tous les processus.

La commande ci-dessus fournit comme informations sur les procesus : le **PID**, le **type de terminal**, le **temps CPU du processus** et le **processus lui même**. Cette sortie nous indique ce que nous avons en cours d'exécution mais ne fournit pas vraiment beaucoup de détails.

```
ps -ef
```

L'option **-f** permet d'afficher une liste en format complet. Cette option peut être combinée avec de nombreuses autres options de style UNIX pour ajouter des colonnes supplémentaires.

La commande ci-dessus fournit définitivement plus d'informations sur chaque processus en cours d'exécution sur notre système. Si nous regardons les en-têtes de colonnes, nous pouvons voir le **propriétaire du processus**, l'**ID du processus**, l'**ID du processus parent**, la **date de démarrage du processus**, le **type de terminal** si cette information est disponible, le **temps CPU du processus**, puis le **processus lui-même**.

```
ps aux
```

L'option **a** lève la restriction de style BSD "**only yourself**", qui est imposée à l'ensemble de tous les processus lorsque certaines options de style BSD (sans "-") sont utilisées ou lorsque le paramètre de personnalité **ps** est de type BSD. Une autre description est que cette option amène **ps** à lister tous les processus avec un terminal (tty), ou à lister tous les processus lorsqu'il est utilisé avec l'option **x**.

L'option **u** affiche un format orienté utilisateur.

L'option **x** lève la restriction de style BSD "**must have a tty**", qui est imposée à l'ensemble de tous les processus lorsque certaines options de style BSD (sans "-") sont utilisées ou lorsque le paramètre de personnalité **ps** est de type BSD. Une autre description est que cette option amène **ps** à répertorier tous les processus dont nous sommes propriétaire (même **EUID** que **ps**), ou à répertorier tous les processus lorsqu'il est utilisé avec l'option **a**.

La commande ci-dessus fournit l'**utilisateur**, l'**ID du processus**, l'**utilisation actuelle du processeur et de la mémoire**, la **taille de la mémoire virtuelle** (**VZS : Virtual Memory Size**), la **RSS: Resident Set Size** (Il s'agit de la taille de mémoire qu'un processus a actuellement utilisée pour charger toutes ses pages), les **informations sur le type de terminal**, l'**état du processus**, la **date de démarrage du processus**, le **temps CPU du processus** et le **processus lui-même**. <br>
Concernant l'**état du processus**, il fournit les informations : un **S** majuscule signifie que le processus est **en veille** et attend juste une entrée pour le réveiller, un **I** majuscule signifie qu'il s'agit d'un processus noyau inactif, un **N** majuscule signifie qu'il s'agit d'un processus agréable, un **l** minuscule signifie qu'il s'agit d'un **processus multithread** et un **s** minuscule signifie qu'il s'agit d'un **leader de session**. D'autres valeurs d'état possibles incluent un **R** majuscule pour l'exécution, un **T** majuscule pour **arrêté** et un **Z** pour un processus zombie.

```
ps aux | grep cron
```

```
ps aux | grep -v grep | grep cron
```

```
ps aux | grep -v grep | grep -e VSZ -e cron
```

```
ps aux --forest
```

L'option **--forest** permet d'afficher en plus les relations parent-enfant de processus sous forme d'arborescence.

```
ps aux --forest | grep sshd
```

### top

- Affiche l'activité du processus en temps réel, similaire au Gestionnaire des tâches sous Windows

### htop

- Semblable à **top**, mais interactif et propose plus d'options.
- Généralement non installé par défaut sur la plupart des distributions

Les informations affichées par **htop** semblent assez similaires à **top**, mais elles sont beaucoup plus colorées et les informations récapitulatives ont changé. Nous pouvons toujours voir des informations sur la **mémoire** et le **swap**, la **disponibilité** et l'**état du processus**, et nos informations d'en-tête de sortie sont dans un format coloré. **htop** offre de nombreux avantages par rapport à **top** : <br>
--- le mode interactif <br>
Nous pourrions utiliser notre souris pour changer la vue d'affichage. Si nous nous déplaçons et cliquons sur **CPU**, cela changera la vue de tri en utilisation du **CPU**. Nous pourrions faire la même chose avec la **mémoire**. Nous pourrions faire la même chose avec le **temps**. Donc nous avons la possibilité de manipuler la sortie de plusieurs manières. Si nous descendons vers le bas de l’écran, nous pouvons voir différentes options disponibles. Chacune de ces options peut être utilisée en utilisant la touche de fonction ou en utilisant une souris. Donc, pour la recherche, nous pouvons cliquer sur le lien **Rechercher**, et cela fera apparaître le menu **Rechercher**.

--- la manière dont il affiche les informations utilisateur <br>
En étant connecté au système en tant que **vagrant** et nous avons lancé **htop** en tant que **vagrant**. La sortie **htop** affiche **vagrant** en surbrillance, ce qui facilite l'identification des processus que l'utilisateur **vagrant** utilise. Les processus appartenant à tout autre compte apparaîtront grisés.