# Surveillance de l'utilisation des ressources [Part2]

- Exécutons la commande **vmstat** sans option

```
vmstat
```

Elle affiche un résumé de statistiques mémoire, pagination, E/S depuis le dernier redémarrage. Nous avons quelques colonnes : **procs**, **mémoire(memory)**, **swap**, **io**, **système(system)** et **cpu** : <br>
--- sous **procs**, nous avons des processus en cours d'exécution, qui sont représentés par **r**, puis **b** va représenter des processus ininterruptibles. <br>
--- sous **mémoire(memory)**, nous avons **swpd**, **free(libre)**, **buff(tampon)** et **cache**. <br>
--- sous **swap**, nous avons **swap in(si)** et **swap out(so)**. <br>
--- sous **io**, nous avons des blocs entrants (**bi : blocks in**) et des blocs sortants (**bo : blocks out**). <br> 
--- sous **système(system)**, nous allons avoir les **interruptions(in : interrupts)** et les **commutateurs de contact(cs : contact switches)**. <br> 
--- sous **cpu**, cela présente un pourcentage de temps d'utilisation du processeur et nous avons : <br>
----- **us(user)** <br>
----- **sy(system)** <br>
----- **id(idle)** <br>
----- **wa(wait)** <br>
----- **st(stolen)** <br>

- Exécutons la commande **vmstat** avec l'option **-s**

```
vmstat -s
```

Cela va nous donner un apperçu très détaillé des statistiques de la mémoire.

- Exécutons la commande **vmstat** avec l'option **-d**

```
vmstat -d
```

Cela va nous donner un apperçu sur les statistiques du disque, nous allons donc voir les colonnes **disq**, **reads**, **writes**, **IO**. 

- Exécutons la commande **vmstat** avec les paramètres **1 7**

```
vmstat 1 7
```

Cela permet d'afficher un résumé de statistiques mémoire, pagination, E/S par interval d'une seconde sur 7 itérations.

- Exécutons la commande **vmstat** avec l'option **-d** et le paramètre **1**

```
vmstat -d 1
```

Cela va nous donner un apperçu, en temps réel et par interval d'une seconde, sur les statistiques du disque.


- Exécutons la commande **free** sans option

```
free
```

Cela affiche la quantité de mémoire libre et utilisée dans le système (la valeur par défaut est en **ko**). Elle affiche deux lignes : une ligne pour la mémoire et une autre pour le swap (Partition d'échange).

- Exécutons la commande **free** avec l'option **-m** et l'option **-g**

```
free -m
```

```
free -g
```

Elle affiche les informations avec **-m** pour les valeurs en megabytes et **-g** pour les valeurs en gigabytes.

- Exécutons la commande **free** avec l'option **-h**

```
free -h
```

Elle affiche les valeurs avec les unités appropriées (megabytes, gigabytes,...).

- Exécutons la commande **free** avec l'option **-w**


```
free -w
```

Elle permet de séparer la colonne **buff/cache** en deux colonnes **buff** et **cache**.

- Exécutons la commande **df** sans option

```
df
```

Elle affiche les statistiques d'utilisation de l'espace disque du système de fichiers. Nous avons 6 colonnes : **Filesystem**, **1K-blocks**, **Used**, **Available**, **Use%**, **Mounted on**. <br>

Avec l'option **-h** les valeurs sont affichées avec les unités appropriées (megabytes, gigabytes,...).

```
df -h
```

- Exécutons la commande **df** l'argument **/var/log**

```
df -h /var/log
```

Elle affiche les statistiques d'utilisation de l'espace disque uniquement sur le répertoire **/var/log**.

- Exécutons la commande **df** l'option **-a**

```
df -a
```

Elle affiche les statistiques d'utilisation de l'espace disque du système de fichiers en incluant les systèmes de fichiers pseudo, en double et inaccessibles.