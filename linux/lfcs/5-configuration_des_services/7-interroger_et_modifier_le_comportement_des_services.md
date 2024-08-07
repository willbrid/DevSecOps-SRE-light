# Interroger et modifier le comportement des services

La commande **systemctl** peut faire plus que simplement démarrer et arrêter des services. En tant qu'administrateur système Linux, nous pouvons également utiliser cet outil pour afficher et remplacer les paramètres du service.

- Afficher le contenu du fichier unit d'un service

Ici nous affichons le contenu du fichier service de dovecot

```
systemctl cat dovecot
```

- Modifier le contenu du fichier unit d'un service

```
sudo systemctl edit dovecot
```

```
Restart=on-abort
```

Cela ouvrira un fichier temporaire vide lié à la modification du service de dovecot en mode édition. Ce fichier temporaire sera créé à l'emplacement **/etc/systemd/system/dovecot.service.d/override.conf**.

En exécutant à nouveau la commmande **systemctl cat**, nous constaterons que la modification a été prise en compte aux 2 dernières lignes du fichier de service.

```
systemctl cat dovecot
```

- Supprimer le fichier temporaire de modification du service

Nous supprimons le repertoire du fichier temporaire de modification du service **dovecot**

```
sudo rm -r /etc/systemd/system/dovecot.service.d
```

```
sudo systemctl daemon-reload
```

En exécutant à nouveau la commmande **systemctl cat**, nous constaterons que les 2 dernières lignes du fichier de service ont été supprimées.

```
systemctl cat dovecot
```

- Modifier le contenu du fichier unit d'un service en mode **full**

En mode **full**, le fichier de service sera lui même ouvert en mode édition.

```
sudo systemctl edit --full dovecot
```

- Afficher tout ce qui est requis pour démarrer le service

Ici nous listerons tout ce qui est requis pour démarrer le service **dovecot**

```
sudo systemctl list-dependencies dovecot
```

- Lister tous les services unit

```
sudo systemctl list-units --type=service
```

- Lister tous les services unit inactifs existant ou non

```
sudo systemctl list-units --type=service --state=inactive
```

- Lister tous les services unit actifs en exécution ou non

```
sudo systemctl list-units --type=service --state=active
```