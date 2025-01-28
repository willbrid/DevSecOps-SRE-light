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

Un fichier service que nous créons doit se trouver dans le repertoire **/etc/systemd/system/** : par exemple **/etc/systemd/system/myapp.service** et un template peut être le service **ssh**.

### Quelques commandes

- Afficher une structure en arbre des unités **systemd** qui sont actives et inactives

```
systemctl list-dependencies
```

- Afficher la page manuelle de **systemd.service**

```
man systemd.service
```

- Recharger les fichiers de configuration des services **systemd**

```
systemctl daemon-reload
```

- Afficher le contenu complet du fichier d'unité du service ssh

```
systemctl cat ssh.service
```

- Ouvrir le fichier d'unité complet de **ssh.service** dans un éditeur (généralement vi ou nano) pour modification

```
systemctl edit --full ssh.service
```

- Redémarrer le service SSH

```
systemctl restart ssh.service
```

- Afficher le statut actuel du service SSH

```
systemctl status ssh.service
```

- Arrêter le service SSH

```
systemctl stop ssh.service
```

- Démarrer le service SSH

```
systemctl start ssh.service
```

- Recharger ou redemarrer le service SSH

```
systemctl reload-or-restart ssh.service
```

- Désactiver le service SSH pour qu'il ne démarre pas automatiquement au prochain redémarrage du système

```
systemctl disable ssh.service
```

- Activer le service SSH pour qu'il démarre automatiquement au prochain redémarrage

```
systemctl enable ssh.service
```

- Vérifier si le service SSH est activé ou non (indique **enabled** ou **disabled**)

```
systemctl is-enabled ssh.service
```

- Activer le service SSH pour démarrage automatique et le démarre immédiatement

```
systemctl enable --now ssh.service
```

- Désactiver le service SSH pour démarrage automatique et l'arrête immédiatement

```
systemctl disable --now ssh.service
```

- Masquer le service atd (service d'exécution des tâches planifiées at)

```
systemctl mask atd.service
```

Cela empêche le démarrage manuel ou automatique du service, même par un utilisateur avec des privilèges élevés.

- Démasquer le service atd, permettant son démarrage manuel ou automatique

```
systemctl unmask atd.service
```

- Afficher la liste complète de toutes les unités de service systemd

```
systemctl list-units --type service --all
```

Cela inclut les services actifs, inactifs, masqués ou arrêtés.