# Localiser et analyser les fichiers journaux du système

L'un des aspects du rôle d'administrateur système est de maintenir la santé du système. Quels journaux doivent être examinés lors du dépannage ?

En tant qu'administrateur système, il peut nous être demandé de surveiller de manière proactive un serveur, d'enquêter sur une application problématique ou de vérifier l'accès au système. Les journaux du système principal se trouvent dans **/var/log** sur les systèmes basés sur **Debian** et **RedHat**, cependant les fichiers journaux clés sont nommés différemment.

### Systèmes basés sur Debian/Ubuntu

- **syslog** - Informations système
- **auth.log** - Informations d'authentification des comptes

```
cat /etc/os-release
```

Cette commande permet d'afficher les informations sur un système d'exploitation linux.

```
ls /var/log/
```

En affichant le contenu du repertoire **/var/log/**, nous pouvons effectivement confirmer la présence des fichiers : **syslog** et **auth.log**.

- Consultation des logs

```
sudo less /var/log/syslog
```

```
sudo less /var/log/syslog | grep apparmor
```

### Systèmes basés sur RedHat/CentOS

- **messages** - Informations système
- **secure** - Informations d'authentification des comptes

```
ls /var/log/
```

En affichant le contenu du repertoire **/var/log/**, nous pouvons effectivement confirmer la présence des fichiers : **messages** et **secure**.

- Consultation des logs

```
sudo less /var/log/messages
```

```
sudo less /var/log/messages | grep acpi
```

```
sudo less /var/log/yum.log
```

### Les niveaux de priorité

- **emerg (Emergency) (0)**    ->  **Urgence** : le système est inutilisable. Exemples : panne critique, crash OS.
- **alert (Alert) (1)**	       ->  **Alerte** : action immédiate requise. Exemples : panne disque critique.
- **crit (Critical) (2)**      ->  **Critique** : conditions critiques affectant les services.
- **err (Error) (3)**          ->  **Erreur** : erreurs non critiques mais significatives.
- **warning (Warning) (4)**    ->  **Avertissement** : conditions nécessitant une attention particulière.
- **notice (Notice) (5)**	   ->  **Notice** : événements normaux mais importants.
- **info (Informational) (6)** ->  **Info** : messages informatifs.
- **debug (Debug) (7)**	       ->  **Débogage** : informations détaillées pour le diagnostic.

- Afficher le journal de la commande sudo

```
journalctl /usr/bin/sudo
```

- Afficher les logs générés par le service ssh.service

```
journalctl -u ssh.service
```

```
journalctl --unit=ssh.service -n 20 --no-pager
```

- Afficher le journal et aller en fin de la page

```
journalctl -e
```

- Afficher le journal avec le mode suivi

```
journalctl -f
```

- Afficher le journal avec le niveau err ou info

```
journalctl -p err
```

```
journalctl -p info -g '^b'
```

- Afficher le journal depuis une certaine heure ou jusqu'à une certaine heure

```
journalctl -S 01:00
```

```
journalctl -U 02:00
```

- Afficher le journal depuis une certaine date et heure

```
journalctl -S '2024-03-03 01:00:30'
```

- Afficher les logs du démarrage actuel

```
journalctl -b 0
```

- Afficher les logs du démarrage précédent

```
journalctl -b -1
```

- Afficher l'historique de qui s'est connecté au système

```
last
```

Les lignes commençant par **reboot** et **system boot** montrent également quand le système a été allumé.

- Afficher les connexions les plus récentes de tous les utilisateurs ou d'un utilisateur donné

```
lastlog
```