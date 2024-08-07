# Modifier les paramètres d'exécution du kernel, persistants et non persistants

Sous Linux, tout est un fichier. En tant qu'administrateur système, nous pouvons contrôler les paramètres du kernel de manière temporaire ou permanente en modifiant les fichiers de configuration.

Un paramètre de kernel est une chaîne de texte interprétée par le kernel du système pour contrôler la manière dont les périphériques et les systèmes interagissent avec le système d'exploitation.

### Changement non persistant

Les modifications non persistantes sont temporaires et seront réinitialisées une fois le système redémarré. Après avoir apporté des modifications, exécutons la commande ci-dessous pour charger la nouvelle configuration.

```
sudo sysctl -p
```

L'un des avantages d'une modification non persistante est qu'elle nous permet de tester et d'évaluer une nouvelle configuration sans redémarrer le système.

Nous pouvons utiliser la commande de contrôle du système (**sysctl**) pour afficher les paramètres, ainsi que pour apporter des modifications temporaires aux paramètres. Nous pouvons également modifier manuellement les fichiers de configuration pour apporter une modification temporaire.

Pour afficher la configuration actuelle des paramètres :

```
sudo sysctl -a
```

Pour afficher le paramètre spécifique **dev.cdrom.autoclose** 

```
sudo sysctl dev.cdrom.autoclose
```

Nous voyons la valeur **1** à ce paramètre, cela signifie que la fonctionnalité **cdrom.autoclose** est activée. 

Les paramètres du kernel sont également stockés sous forme de fichiers sur le système. Nous pouvons trouver les fichiers de paramètres dans le répertoire **/proc/sys**.

Nous pouvons constater que le paramètre **autoclose** se trouve dans le repertoire **/proc/sys/dev/cdrom**.

```
cat /proc/sys/dev/cdrom/autoclose
```

Nous pouvons mettre à jour ce paramètre avec la commande :

```
sudo sysctl -w dev.cdrom.autoclose=0
```

L'option **-w** permet d'activer l'écriture d'une valeur dans une variable.

```
cat /proc/sys/dev/cdrom/autoclose
```

Nous pouvons aussi modifier ce paramètre directement dans le fichier

```
sudo echo 0 > /proc/sys/dev/cdrom/autoclose
```

ou avec un éditeur de fichier tel que **vim**

```
sudo vim /proc/sys/dev/cdrom/autoclose
```

### Changement persistant

Un changement persistant est un changement qui persistera après le redémarrage du serveur. Pour rendre le changement permanent, nous devons éditer les fichiers de configuration principaux dans le répertoire **/etc/sysctl.d**.

Par exemple jetons un oeil à la configuration de la sécurité du réseau :

```
cat /etc/sysctl.d/10-network-security.conf
```

Activons le transfert IPv4

```
sudo vi /etc/sysctl.d/10-network-security.conf
```

```
# Added by willbrid administrator to enable IPv4 Forwarding
net.ipv4.ip_forward=1
```

Pour charger la nouvelle configuration du fichier, nous avons plusieurs méthodes.

- Charger la configuration via le fichier spécifique **10-network-security.conf**

```
sudo sysctl -p /etc/sysctl.d/10-network-security.conf
```

L'option **-p** permet de charger un fichier de configuration spécifique du répertoire **/etc/sysctl.d/**.

- Charger toutes les fichiers de configuration du repertoire **/etc/sysctl.d**

```
sudo sysctl --system
```

```
sudo systemctl status procps.service
```