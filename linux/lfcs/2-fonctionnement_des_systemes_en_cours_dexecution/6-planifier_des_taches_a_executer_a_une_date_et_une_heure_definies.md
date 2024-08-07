# Planifier des tâches à exécuter à une date et une heure définies

En tant qu'administrateurs système, nous devrons peut-être exécuter une commande ou un script à intervalles réguliers. Utilisons **cron** pour planifier ces tâches pour nous.

Le démon **cron** utilise les entrées du fichier crontab pour gérer les activités récurrentes telles que l'effacement des répertoires, la création de sauvegardes, la génération de rapports ou la mise à jour des configurations.

### Syntaxe de contenu crontab

```
[ Planification crontab ]
+- - - - - - - - - - - - - - - - minute (0 - 59)
|
|   +- - - - - - - - - - - - - heure (0 - 23)
|   |
|   |   +- - - - - - - - - - jour du mois (1 - 31)
|   |   |
|   |   |   +- - - - - - - mois (1 - 12)
|   |   |   |
|   |   |   |   +- - - - jour de la semaine (0 - 6) (Dimanche = 0)
|   |   |   |   |
|   |   |   |   |
*   *   *   *   *   commande à exécuter

NOTES:
mois - peut être un nombre, un nom ou un raccourci
- - 1, January , Jan

jour - peut être un numéro, un nom ou un raccourci
- - 0, Sunday , Sun

Commande - peut être une commande ou un script
```

### Exemple de contenu crontab

```
# Exécuté à 00h30 les 1er janvier, avril, juillet et octobre.
30  0  1  1,4,7,10  *  /scripts/quarterly-audit.sh

# Exécuté à 20h00 tous les jours du lundi à vendredi
0  20  *  *  1-5  /scripts/daily-report.sh

# Exécuté à 00h00 le 1er et le 15 du mois
0  0  1,15  *  *  /scripts/status.sh

# Exécuté toutes les heures de 8h à 17h, du lundi à vendredi
0  8-17  *  *  1-5  /scripts/roll-logs.sh
```

### Gestion de crontab

- Listons le contenu d'une crontab

```
crontab -l
```

- Editons le contenu de la crontab de l'utilisateur courant qui exécutera la commande **date** chaque minute et enverra le résultat dans un fichier **dateLogs** de notre repertoire home personnel

```
crontab -e
```

```
# Exécuter la commande date chaque minute
*/1  *  *  *  * date > ~/dateLogs
```

Nous pouvons vérifier le résultat en listant à nouveau notre contenu crontab et en vériant la présence du fichier **dateLogs**

```
crontab -l
```

```
cd ~/
ls -l
```