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

- **\*** -> correspond à toutes les valeurs possibles (chaque heure)
- **,**  -> faire correspondre plusieurs valeurs (**15,45** : sans espace entre elles) 
- **-**  -> plage de valeurs (**1-7**)
- **/**  -> précise les étapes et par défaut l'étape c'est **1** (**\*** correspond à **\*/1**) (**\*/4** : toutes les valeurs possibles à interval de 4) (on peut aussi avoir **0-8/4** : **à 0h**, **à 04h** et **à 08h**)

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

Pour éditer la table **crontab** de l'utilisateur **vagrant** on a deux options :
- soit on se connecte avec cet utilisateur puis on saisit la commande : **"crontab -e"**
- soit on utilise l'option **-u** la fin de la commande : **"sudo crontab -e -u vagrant"**

- Supprimer complètement une table **crontab** de l'utilisateur courant **vagrant**

```
crontab -r
```

```
sudo crontab -r -u vagrant
```

Une autre façon d'éditer des cronjobs, c'est d'utiliser des repertoires :
- daily = /etc/cron.daily/
- hourly = /etc/cron.hourly/
- monthly = /etc/cron.monthly/
- weekly = /etc/cron.weekly/

Par exemple on peut créer un script bash (fichier par exemple **shellscript** sans extension) et le copier dans le repertoire **/etc/cron.hourly/** pour le faire exécuter toutes les heures.

```
touch shellscript
```

```
sudo cp shellscript /etc/cron.hourly/
```

```
sudo chmod +rx /etc/cron.hourly/shellscript
```

### Anacron

- Installer anacron sous Ubuntu

```
sudo apt install anacron
```

- Installer anacron sous Rocky

```
sudo dnf install cronie-anacron
```

Le fichier de configuration de l'utilitaire **anacron** est : **/etc/anacrontab**. <br>
Le fichier **/var/log/cron** contient les informations sur les tâches anacron exécutées.

- Ecrire une ligne anacron pour exécuter une fois tous les 3 jours avec un délai de 10 minutes la commande **"/usr/bin/touch /home/vagrant/test"**

```
...
3  10  test.job  /usr/bin/touch /home/vagrant/test
...
```

**"test.job"** est l'identifiant du job ou son nom.

- Ecrire une ligne anacron pour exécuter chaque semaine avec un délai de 10 minutes la commande **"/usr/bin/touch /home/vagrant/test"**

```
...
7  10  test.job  /usr/bin/touch /home/vagrant/test
...
```

- Ecrire une ligne anacron pour exécuter chaque mois avec un délai de 10 minutes la commande **"/usr/bin/touch /home/vagrant/test"**

```
@monthly  10  test.job  /usr/bin/touch /home/vagrant/test
```

Après avoir édité le fichier **/etc/anacrontab** on pourra valider son contenu avec la commande

```
anacron -T
```

Pour forcer **Anacron** à réexécuter tous les jobs, quelle que soit la date de leur dernière exécution, on utilise la commande

```
sudo anacron -n -f
```

L'option **-n** permet d'exécuter le job avec aucun retard.

### At

- Installer **at** sous Ubuntu

```
sudo apt install at
```

- Installer **at** sous Rocky

```
sudo dnf install at
```

- Exécuter un script à des dates et heures précises

La commande **at** ouvre une invite **"at"** où il faudrait saisir une commande (**Exemple: /usr/bin/touch /home/vagrant/test**), puis appuyer sur la touche **entrée** et enfin sur la prochaine ligne appuyer sur les touches **crtd+d** pour sauvegarder la configuration.

--- exécuter à 15h00

```
at '15:00'
```

--- exécuter le 20-08-2024

```
at 'August 20 2024'
```

--- exécuter le 20-08-2024 à 02h30

```
at '2:30 August 20 2024'
```

--- exécuter dans 30 minutes, dans 3 heures, dans 3 jours, dans 3 semaines, dans 3 mois

```
at 'now + 30 minutes'
at 'now + 3 hours'
at 'now + 3 days'
at 'now + 3 weeks'
at 'now + 3 months'
```

- Afficher les jobs qui sont actuellement programmés.

```
atq
```

Elle affiche entre autre l'identifiant de chaque job.

- Afficher le contenu du job à partir de son identifiant **1**

```
at -c 1
```

- Supprimer un job à partir de son identifiant **1**

```
atrm 1
```