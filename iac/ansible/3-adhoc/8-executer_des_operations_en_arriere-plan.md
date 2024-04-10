# Exécuter des opérations en arrière-plan

Certaines opérations prennent un certain temps (des minutes voire des heures). Par exemple, lorsque nous exécutons **yum update** ou **apt-get update && apt-get dist-upgrade** , il peut s'écouler quelques minutes avant que tous les packages de nos serveurs soient mis à jour.<br>
Dans ces situations, nous pouvons dire à Ansible d'exécuter les commandes de manière asynchrone et d'interroger les serveurs pour voir quand les commandes se terminent. Lorsque nous ne gérez qu'un seul serveur, ce n'est pas vraiment utile, mais si nous avons plusieurs serveurs, Ansible lance la commande très rapidement sur tous nos serveurs (surtout si nous définissons une valeur **--forks** plus élevée), puis interroge les serveurs pour statut jusqu'à ce qu'ils soient tous à jour. <br>
Pour exécuter une commande en arrière-plan, nous définissons les options suivantes :

- **-B** **secondes** : la durée maximale (en secondes) pour laisser le job s'exécuter.
- **-P** **secondes** : la durée (en secondes) d'attente entre les interrogations des serveurs pour un état de job mis à jour.
<br>


**Exemple** : Exécutons **yum -y update** sur tous nos serveurs pour les mettre à jour. Si nous définissons **-P 0** , Ansible déclenche la commande sur les serveurs, puis imprime les informations de job en arrière-plan à l'écran et quitte :

```
ansible multi -b -B 3600 -P 0 -a "yum -y update"
```

Pendant que le job en arrière-plan est en cours d'exécution, nous pouvons vérifier l'état ailleurs à l'aide du module Ansible **async_status**, tant que nous avons la valeur **ansible_job_id** à transmettre en tant que **jid** :

```
ansible multi -b -m async_status -a "jid=67536939493.4863"
```