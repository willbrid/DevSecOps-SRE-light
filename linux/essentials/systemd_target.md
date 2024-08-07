# Notion de base sur les cibles systemd

## Définition
Une cible systemd représente l'état d'exécution actuel ou souhaité d'un système Linux. Tout comme les scripts de démarrage SystemV, les cibles définissent les services qui doivent être présents pour que le système s'exécute et soit actif dans cet état.

Les cibles systemd sont représentées par des unités cibles. Les fichiers des unités cibles se terminent par l'extension de fichier **.target** et leur seul but est de regrouper d'autres unités systemd via une chaîne de dépendances. Par exemple, l'unité graphic.target, qui est utilisée pour démarrer une session graphique, démarre des services système tels que le gestionnaire d'affichage GNOME (gdm.service) ou le service de comptes (accounts-daemon.service) et active également l'unité multi-user.target . De même, l'unité multi-user.target démarre d'autres services système essentiels tels que NetworkManager (NetworkManager.service) ou D-Bus (dbus.service) et active une autre unité cible nommée basic.target .

## Affichage de la cible par défaut
```
systemctl get-default
```

## Exemple de création d'une cible custom.target
```
cd /usr/lib/systemd/system
vi custom.target
```

On y met par exemple le contenu
```
[Unit]
Description=Custom's Target
Requires=multi-user.target
Wants=custom.service // Service associé
Conflicts=rescue.service rescue.target
After=multi-user.target rescue.service rescue.target // hierarchie des isolements
AllowIsolate=yes
```

Puis on recharge la configuration du gestionnaire systemd
```
systemctl daemon-reload
```

## Configuration du service httpd pour être gérer par la cible custom.target
**- Créer le repertoire custom.target.wants**
```
mkdir /usr/lib/systemd/system/custom.target.wants
cd /usr/lib/systemd/system/custom.target.wants
```

**-Créer un lien symbolique du service /usr/lib/systemd/system/httpd.service**
On considèrera que le package httpd est installé.
```
ln -s /usr/lib/systemd/system/httpd.service .
```

En passant à une autre unité cible custom.target dans la session en cours, cela permettra de demarrer automatiquement le service httpd
```
systemctl isolate custom.target
```

Si on passe à une autre unité cible qui ne gère pas le service httpd (par exemple multi-user.target) alors le service httpd sera automatiquement arrêté.

## Définir la cible custom.target comme cible par défaut
```
systemctl set-default custom.target
```


Source: [Working with systemd targets](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/working-with-systemd-targets_configuring-basic-system-settings)