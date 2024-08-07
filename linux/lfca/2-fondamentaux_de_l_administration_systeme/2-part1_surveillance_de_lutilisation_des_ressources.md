# Surveillance de l'utilisation des ressources [Part1]

## Définition

- **sar** : c'est un utilitaire qui permet de collecter, rapporter ou enregistrer des informations sur l'activité du système. Fourni par le package **sysstat**, il crée un fichier binaire pour chaque jour du mois avec toutes les informations collectées, ainsi qu'un résumé quotidien. Ces fichiers sont écrasés le mois suivant.
<br>
Le service **sysstat** doit être démarré pour que **sar** commence à collecter des données, et la durée de la collecte peut être modifiée en modifiant **/etc/cron.d/sysstat**.
<br>
Certaines options notables sont **-f** pour extraire les enregistrements d'un nom de fichier, **-r** pour afficher l'utilisation de la mémoire et **-u** pour afficher l'utilisation du processeur.

- **vmstat** : c'est un utilitaire qui permet de faire des rapports des statistiques de mémoire virtuelle, ainsi que des statistiques sur la pagination et les blocs d'E/S. Par défaut, il imprime un résumé des statistiques d'utilisation depuis le dernier redémarrage.
<br>
Il peut être exécuté à un intervalle avec un compteur ou en continu. 
Le premier rapport de l'intervalle est le rapport récapitulatif. Certaines options notables sont : **-s** pour afficher un tableau des statistiques de la mémoire et **-d** pour afficher les statistiques du disque.

- **free** : c'est un utilitaire qui permet d'afficher la quantité de mémoire libre et utilisée dans le système (la valeur par défaut est en **ko**). Les informations affichées par **free** sont extraites du fichier **/proc/meminfo**.
<br>
Quelques options notables sont : **-h** pour afficher la sortie dans un format lisible, **-m/-g** pour afficher en mégaoctets/gigaoctets et **-w** pour utiliser le mode large

- **df** : c'est un utilitaire qui permet d'afficher un rapport sur l'utilisation de l'espace disque du système de fichiers. Il affiche la quantité d'espace disponible sur le système de fichiers de chaque nom de fichier donné en argument. si aucun nom de fichier n'est donné, il affiche l'espace disponible sur tous les systèmes de fichiers montés.
<br>
Certaines options notables sont : **-h** pour afficher la sortie dans un format lisible par l'homme et **-a** pour lister les systèmes de fichiers pseudo, dupliqués et inaccessibles.

## Pratiques

- Installons l'utilitaire **sysstat**

```
# Rocky
sudo yum install sysstat

# Ubuntu
sudo apt install sysstat
```

- Créons un cron pour l'utilitaire **sysstat**

```
sudo vi /etc/cron.d/sysstat
```

```
# Run system activity accounting tool every 10 minutes
*/10 * * * * root /usr/lib64/sa/sa1 1 1

# Generate a daily summary of process accounting at 23:53
53 23 * * * root /usr/lib64/sa/sa2 -A
```

Ces deux lignes permettent de collecter les informations sur l'activité du système à chaque 10 minutes et de générer un rapport de ce processus chaque jour à **23h:53**.

<br>

Un fichier sous le format **sa<numero_du_jour>** est créé dans le repertoire **/var/log/sa**. Il contient les informations collectées sur l'activité du système.

- Exécutons la commande **sar** sans option (même sortie avec l'option **-u**)

```
sar
```

ou 

```
sar -u
```

Elle affiche les informations de statistiques sur l'utilisation du cpu.

- Exécutons la commande **sar** avec l'option **-r**

```
sar -r
```

Elle affiche les informations de statistiques sur l'utilisation de la mémoire.

- Exécutons la commande **sar** avec l'option **-b**

```
sar -b
```

Générez des rapports sur les statistiques d'E/S et de taux de transfert. Les valeurs suivantes sont affichées : <br>

--- **tps** : nombre total de transferts par seconde émis vers des périphériques physiques. Un transfert est une requête d'E/S vers un périphérique physique. Plusieurs requêtes logiques peuvent être combinées en une seule requête d'E/S vers le périphérique. Un transfert est de taille indéterminée. <br>

--- **RTP** : nombre total de requêtes de lecture par seconde envoyées aux périphériques physiques. <br>

--- **wtps** : nombre total de demandes d'écriture par seconde envoyées aux périphériques physiques. <br>

--- **bread/s** : quantité totale de données lues à partir des périphériques en blocs par seconde. Les blocs sont équivalents à des secteurs et ont donc une taille de 512 octets. <br>

--- **brtn/s** : quantité totale de données écrites sur les périphériques en blocs par seconde. <br>

- Exécutons la commande **sar** avec les arguments **1, 10**

```
sar 1 10
```

Elle affiche les informations de statistiques sur l'utilisation du cpu à chaque 1 seconde sur 10 itérations.

- Exécutons la commande **sar** avec l'argument **3**

```
sar 3
```

Elle affiche les informations de statistiques sur l'utilisation du cpu à chaque 3 secondes de manière continue.

- Exécutons la commande **sar** avec l'option **-f** sur le fichier **/var/log/sa/sa31**

```
sar -f /var/log/sa/sa31
```

Elle affiche les informations de statistiques sur l'utilisation du cpu sauvegardées dans ce fichier. <br>

Pour les informations de statistiques sur l'utilisation de la mémoire, nous exécutons la commande :

```
sar -r -f /var/log/sa/sa31
```