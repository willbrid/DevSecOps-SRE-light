# Affichage et gestion des fichiers journaux

## Définition

Les catégories de fichiers journaux :
- journaux système
- journaux de service
- journaux d'événements
- journaux des applications

#### **Les journaux système**

- **/var/log/syslog** : le journal système principal pour les hôtes basés sur Debian. Il stocke toutes les activités globales du système et les messages de démarrage. Les options sont contrôlées par **/etc/syslog.conf** ou **/etc/rsyslog.conf** dans les versions plus récentes. Des fichiers de configuration supplémentaires peuvent être ajoutés à **/etc/rsyslog.d/**.

- **/var/log/messages** : le journal système principal pour les hôtes basés sur RHEL. Il stocke toutes les activités globales du système et les messages de démarrage. Les options sont contrôlées par **/etc/rsyslog.conf**. Des fichiers de configuration supplémentaires peuvent être ajoutés à **/etc/rsyslog.d/**.

Le format d'une ligne dans les logs est le suivant :

```
[date] [hostname] [application] [message]
```

#### **Journal systemd**

Un système de journalisation introduit par **systemd** et implémenté par le démon **journald**, qui stocke les journaux dans un format binaire qui peut être visualisé à l'aide de l'utilitaire **journalctl**. <br> 
Les options notables pour **journalctl** :

- **-u unit** : afficher les messages pour une unité **systemd** particulière
- **-f** : suiver le journal pour les derniers messages
- **-e** : sauter à la fin du journal
- **-x** : ajouter des textes d'explication à partir du catalogue de messages
- **-S -U** : afficher les entrées à partir d'une date spécifiée (since et until)

Les paramètres du journal systemd peuvent être mis à jour en modifiant le fichier **/etc/systemd/journald.conf** ou en ajoutant des fichiers de configuration à **/etc/systemd/journald.conf.d**.

#### **logrotate**

**logrotate** est un utilitaire qui peut être installé (et est installé par défaut sur de nombreuses distributions) afin de gérer les fichiers journaux. Cette aide garantit que les fichiers journaux ne deviennent pas trop volumineux et dicte comment ils seront stockés sur l'hôte.
<br>
Le fichier de configuration principal pour **logrotate** est **/etc/logrotate.conf**, et des configurations supplémentaires peuvent être ajoutées à **/etc/logrotate.d** .

## Pratiques

- exécutons la commande **less** pour visualiser le fichier de log système

```
# Famille Débian
sudo less /var/log/syslog

# Famille Redhat
sudo less /var/log/messages
```

- exécutons la commande **journactl** avec les options **-e**, **-x**, **-f**

```
journactl -e
```

```
journactl -x
```


```
journactl -f
```

- Affichons la fichier de configuration du fichier **logrotate.conf**

```
cat /etc/logrotate.conf
```

Elle contient les options par défaut pour la rotation des logs, qui peuvent être définies spécifiquement pour un service précis.

```
cat /etc/logrotate.d/chrony
```