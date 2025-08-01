# Configuration globale d'Alertmanager

Alertmanager inclut un certain nombre d'options de configuration globales que nous pouvons utiliser pour personnaliser son comportement. Afin de gérer une instance d'Alertmanager, nous devons connaître le fichier de configuration d'Alertmanager et savoir comment suivre le processus de gestion de sa configuration.

Nous configurons l'option **resolve_timeout** de la configuration globale d'Alertmanager. Nous procédons comme suit.

```
sudo vi /etc/alertmanager/alertmanager.yml
```

```
global:
 ...
 resolve_timeout: 10m
...
```

```
sudo systemctl restart alertmanager
```

Si nous le souhaitons, nous pouvons charger la nouvelle configuration sans redémarrer Alertmanager :

```
sudo killall -HUP alertmanager
```

Vérifions que notre configuration est valide en nous assurant qu'Alertmanager est en cours d'exécution. Accédons à Alertmanager dans notre navigateur à l'adresse : **http://192.168.56.230:9093** .

Une fois l'interface ui d'Alertmanager ouvert, cliquons sur **Status** et recherchons notre nouvelle configuration **resolve_timeout** dans la section **Config**.