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