# Gérer le processus de démarrage et les services (dans la configuration des services)

Les services Linux se lancent au démarrage du système. Les administrateurs système devront peut-être démarrer/arrêter et activer/désactiver divers services pour maintenir la stabilité du système.

Un service Linux est une application ou un ensemble d'applications configuré pour être lancé au démarrage du système et exécuté en arrière-plan. Sur les distributions Linux modernes, les services sont gérés par **systemctl**.

Exemple avec le service **cron**

- Verification du statut du service **cron**

Sous Ubuntu
```
sudo systemctl status cron
```

Sous Rocky
```
sudo systemctl status crond
```

La commande **systemctl status** renvoie de nombreuses informations sur un service. Elle nous indiquera d'où le service a été chargé, quel est son état de démarrage actuel et quel est l'état par défaut du fournisseur. Ainsi, pour le service **cron**, l'état de démarrage par défaut est défini sur **enabled**, et le démarrage par défaut du fournisseur est également défini sur **enabled**. Ensuite, la commande **systemctl status** nous indiquera l'état actuel du service, quand il a été démarré et depuis combien de temps il est exécuté. La commande **systemctl status** fournira également toutes les références à la documentation, telles que les pages de manuel, si elles existent. Et puis l’une des informations les plus importantes est le **PID**, ou **ID de processus** du service. Au bas de la sortie, la commande **systemctl status** affichera également toutes les entrées de logs récentes si elles sont disponibles.

- Arrêt du service **cron**

Sous Ubuntu
```
sudo systemctl stop cron
```

Sous Rocky
```
sudo systemctl stop crond
```

Nous pouvons voir que le service est désormais répertorié comme inactif (**inactive**) ou **dead**.

- Démarrage du service **cron**

Sous Ubuntu
```
sudo systemctl start cron
```

Sous Rocky
```
sudo systemctl start crond
```

En consultant le status du service, nous pouvons voir que le service est désormais répertorié comme actif (**active**) ou **running**.

- Redémarrage du service **cron**

Sous Ubuntu
```
sudo systemctl restart cron
```

Sous Rocky
```
sudo systemctl restart crond
```

- Désactivation du service au redémarrage du système

Sous Ubuntu
```
sudo systemctl disable cron
```

Sous Rocky
```
sudo systemctl disable crond
```

En consultant le status du service, nous constatons l'état de démarrage du service est défini sur **désactivé** (**disabled**).

- Activation du service au redémarrage du système

Sous Ubuntu
```
sudo systemctl enable cron
```

Sous Rocky
```
sudo systemctl enable crond
```