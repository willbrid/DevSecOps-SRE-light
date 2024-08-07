# Démarrer, redémarrer et arrêter un système en toute sécurité

Une machine Linux nécessite une maintenance pour les mises à jour du matériel et du système d'exploitation. Comment arrêter ou redémarrer la machine ?

### shutdown

Il s’agit de la commande incontournable pour arrêter, mettre hors tension ou redémarrer une machine. Il fonctionne sur les systèmes d'exploitation basés sur **System 5** et **systemd**.

- **shutdown -r <TIME>** : Redémarre le serveur à l'heure spécifiée
- **shutdown -H <TIME>** : Arrête toutes les activités du processeur à l'heure spécifiée.
- **shutdown -P <TIME>** : Arrête le système d'exploitation et envoie une commande pour éteindre la machine à l'heure spécifiée.

La chaîne d'heure peut être au format **« hh:mm »** pour les **heures/minutes** spécifiant l'heure à laquelle exécuter l'arrêt, spécifiée au format d'horloge **24 heures**. Alternativement, il peut s'agir de la syntaxe **"+m"** faisant référence au **nombre de minutes** spécifié dans **m** à partir de maintenant. **"now"** est un alias pour "+0", c'est-à-dire pour déclencher un **arrêt immédiat**. Si aucun argument temporel n'est spécifié, **"+1"** est implicite.

```
shutdown -r +2
```

```
shutdown -H +5
```

```
shutdown -P +7
```

Nous pouvons annuler l'action du processus **shutdown** en cours d'exécution avec la commande 

```
shutdown -c
```

### reboot

Cette commande remplit la même fonction que **shutdown -r** , mais peut également être utilisé pour arrêter ou mettre hors tension le serveur lorsque les paramètres corrects sont envoyés.

```
reboot
```

### halt

Cette commande remplit la même fonction que **shutdown -H** et peut également être utilisé pour redémarrer ou mettre hors tension le serveur lorsque les paramètres corrects sont envoyés.

```
halt
```

### poweroff

Cette commande remplit la même fonction que **shutdown -P** et peut également être utilisé pour redémarrer ou arrêter le serveur lorsque les paramètres corrects sont envoyés.

```
poweroff
```