# Affichage et arrêt des processus système

## Définition

- **ps** : afficher un instantané des processus actuels. Par défaut, ps sélectionne tous les processus avec le même ID utilisateur effectif que l'utilisateur actuel et le terminal associé. <br>

ps accepte plusieurs types d'options : <br>
--- UNIX : peuvent être regroupés et doivent être précédés d'un tiret <br>
--- BSD : peut être groupé mais ne doit pas utiliser de tiret <br>
--- GNU long : précédé de deux tirets <br>

- **kill** : mettre fin à un processus système. Par défaut, la commande envoie le signal **TERM** (15) (**SIGTERM**), qui permet au processus d'effectuer n'importe quel nettoyage avant de se terminer. D'autres signaux peuvent être envoyés en utilisant **-n**, où **n** est le numéro du signal. Un exemple de ceci est **-9** (**SIGKILL**), qui mettra immédiatement fin au processus sans permettre le nettoyage.

- **top** : afficher une vue dynamique en temps réel des processus en cours d'exécution sur le système. Le programme fournit une interface interactive limitée pour la manipulation de processus, ainsi qu'une interface beaucoup plus étendue pour la configuration personnelle.

## Pratiques

- Exécutons la commande **ps** sans option

```
ps
```

Elle affiche les processus actuels sous forme de tableau avec 4 colonnes : PID (identifiant du processus), TTY (numéro d'ordre du terminal), TIME (temps d'exécution CPU pour le processus), CMD (commande derrière le processus). <br>

NB: Le plus petit numéro d'ordre du terminal est **0**.

- Exécutons la commande **ps** avec l'option **-f**

```
ps -f
```

Elle affiche les processus actuels sous forme de tableau avec 8 colonnes : UID (identifiant de l'utilisateur ayant exécuté le processus), PID (identifiant du processus), PPID (identifiant du processus parent), C (utilisation CPU), STIME (l'heure de début : c'est donc à ce moment que le processus a réellement démarré), TTY (numéro d'ordre du terminal), TIME (temps d'exécution CPU pour le processus), CMD (commande derrière le processus).

- Exécutons la commande **ps** avec les options **-ef**

```
ps -ef
```

L'option **-e** permet d'afficher tous les processus.
<br>
Avec la command **head** nous pouvons afficher les 10 premières lignes de processus.

```
ps -ef | head
```

- Exécutons la commande **ps** avec l' option **-u**

```
ps -u willbrid
```

Elle permet d'afficher tous les processus liés à l'utilisateur **willbrid**.

```
ps -u willbrid -f
```

- étant donnée que nous avons lancé plusieurs instances de terminal, tuons un processus parent du processus de l'instance de terminal numéro 3.

```
kill 3304
```

ou

```
kill -15 3304
```

- tuons le processus d'une instance de terminal avec l'option **-9**

```
kill -9 13119
```

Pour tuer un processus définitivement, l'on doit commencer par tuer tous les processus parent.
<br>
L'ID de processus **1** est celui pour systemd, qui est utilisé pour générer tous les autres processus.

- Exécutons la commande **top** pour voir les processus en temps réel

```
top
```

Au préalable nous pouvons exécutons une commande permettant de consommer plus en cpu et de voir le résultat via la commande **top**.

```
cat /dev/urandom | gzip -9 > /dev/null
```

Au cours de l'exécution de la commande **top**, nous pouvons utiliser la clé **h** pour afficher la fenêtre d'aide pour les commandes interactives. Pour quitter cette interface d'aide ou alors terminer l'exécution de la commande **top** elle-même, on utilise la clé **q**. <br>
La clé **l** permet d'afficher ou de supprimer la première ligne. La clé **t** va basculer une sortie différente pour le CPU, où nous pouvons le (ligne d'information du cpu) supprimer entièrement. <br>
Nous pouvons tuer un processus avec la clé **k** qui affiche par défaut le PID du processus le plus gourmand en ressource et dont nous pouvons modifier; puis, après sélection du PID (**saisi du PID et touche entrée**), la clé nous demande le type de signal à utiliser pour tuer ce processus; une fois le type de signal sélectionné, le processus est tué.