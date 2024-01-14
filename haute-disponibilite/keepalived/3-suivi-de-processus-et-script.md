# Suivi de processus et script

## Suivi de processus

L'une des configurations **Keepalived** les plus courantes consiste à suivre un processus sur le serveur pour déterminer la santé de l'hôte. Par exemple, nous pouvons configurer une paire de serveurs Web hautement disponibles et déclencher un basculement si **Apache** cesse de s'exécuter sur l'un d'entre eux.
<br>
Keepalived facilite cela grâce à ses directives de configuration **track_process**. 
<br>
<br>
Pour cette configuration, nous partirons de la section précédente sur **2-configuration-de-base.md**, nous installerons apache2, puis nous configurons le suivi du processus **httpd** avec un poids de 10.

- Installation et simple configuration d'apache sur chaque serveur

```
sudo dnf -y install httpd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

Démarrons apache, activons son redémarrage automatique et vérifions son statut

```
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd
```

Pour tester la page par défaut d'apache, nous exécutons
```
curl localhost
```

- Configurons le suivi d'apache sur chaque serveur

--- Configuration du serveur principal srv1 -> 192.168.56.4

```
sudo vi keepalived.conf
```

```
vrrp_track_process track_apache {
    process httpd
    weight 10
}

vrrp_instance VI_1 {
    state MASTER
    interface enp0s8
    virtual_router_id 52
    priority 244
    advert_int 1
    unicast_src_ip 192.168.56.4 # adresse IP de la master
    unicast_peer {
        192.168.56.5 # adresse IP du serveur secondaire
    }
    authentication {
        auth_type PASS
        auth_pass 12345678
    }
    virtual_ipaddress {
        192.168.56.7/24
    }
    track_process {
        track_apache
    }
}
```

```
sudo systemctl restart keepalived
```

--- Configuration du serveur secondaire srv2 -> 192.168.56.5

```
sudo vi keepalived.conf
```

```
vrrp_track_process track_apache {
    process httpd
    weight 10
}

vrrp_instance VI_1 {
    state BACKUP
    interface enp0s8
    virtual_router_id 52
    priority 244
    advert_int 1
    unicast_src_ip 192.168.56.5 # adresse IP du serveur secondaire 
    unicast_peer {
        192.168.56.4 # adresse IP de la master
    }
    authentication {
        auth_type PASS
        auth_pass 12345678
    }
    virtual_ipaddress {
        192.168.56.7/24
    }
    track_process {
        track_apache
    }
}
```

```
sudo systemctl restart keepalived
```

NB: Les deux configurations de **keepalived** sur chaque serveur (srv1 et srv2) doivent avoir la même priorité par exemple 244. De ce fait la priorité totale pour chaque serveur sera 244 + 10 (poids apache). Ainsi lorsque le processus apache s'arrête sur un serveur alors sa priorité totale diminue par la perte du poids d'apache et ainsi le trafic est basculé sur le serveur ayant la plus grande priorité.

- Test de notre configuration

Pour tester notre configuration, nous pouvons stopper **apache** sur le serveur principal et vérifier que la VIP bascule vers le serveur secondaire.
<br>
serveur principal srv1
```
sudo systemctl stop httpd
```

serveur secondaire srv2
```
ip addr show | grep enp0s8
```

## Suivi de script

Keepalived a également la capacité d'exécuter un script arbitraire pour déterminer la santé d'un hôte. Pour cet exemple : un script qui renvoie 0 indiquera le succès, tandis qu'un script qui renvoie autre chose indiquera que l'instance Keepalived doit entrer dans l'état d'erreur.
<br>
Le script à configurer sur chaque serveur **srv1** et **srv2** est un simple ping vers le serveur DNS Google **8.8.8.8**.

```
sudo vi /usr/local/bin/keepalived_check.sh
```

```
#!/bin/bash

/usr/bin/ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1
```

```
sudo chmod +x /usr/local/bin/keepalived_check.sh
```

Un timeout de 1 seconde pour le ping (-W 1) a été précisé car lors de l'écriture de scripts de vérification Keepalived, c'est une bonne idée de les garder légers et rapides. Nous ne souhaiterons pas qu'un serveur cassé reste le maître pendant longtemps parce que notre script est lent.

- Configuration du serveur principal srv1 -> 192.168.56.4

```
sudo vi keepalived.conf
```

```
vrrp_script keepalived_check {
    script "/usr/local/bin/keepalived_check.sh"
    interval 1
    timeout 5
    rise 3
    fall 3
}

vrrp_instance VI_1 {
    state MASTER
    interface enp0s8
    virtual_router_id 52
    priority 244
    advert_int 1
    unicast_src_ip 192.168.56.4 # adresse IP de la master
    unicast_peer {
        192.168.56.5 # adresse IP du serveur secondaire
    }
    authentication {
        auth_type PASS
        auth_pass 12345678
    }
    virtual_ipaddress {
        192.168.56.7/24
    }
    track_script {
        keepalived_check
    }
}
```

```
sudo systemctl restart keepalived
```

- Configuration du serveur secondaire srv2 -> 192.168.56.5

```
sudo vi keepalived.conf
```

```
vrrp_script keepalived_check {
    script "/usr/local/bin/keepalived_check.sh"
    interval 1
    timeout 5
    rise 3
    fall 3
}

vrrp_instance VI_1 {
    state BACKUP
    interface enp0s8
    virtual_router_id 52
    priority 244
    advert_int 1
    unicast_src_ip 192.168.56.5 # adresse IP du serveur secondaire 
    unicast_peer {
        192.168.56.4 # adresse IP de la master
    }
    authentication {
        auth_type PASS
        auth_pass 12345678
    }
    virtual_ipaddress {
        192.168.56.7/24
    }
    track_script {
        keepalived_check
    }
}
```

```
sudo systemctl restart keepalived
```

Le bloc vrrp_script a quelques directives uniques :

- **interval**: fréquence d'exécution du script (1 seconde).
- **timeout** : combien de temps attendre le retour du script (5 secondes).
- **rise** : combien de fois le script doit être renvoyé avec succès pour que l'hôte soit considéré comme « sain ». Dans cet exemple, le script doit réussir 3 fois. Cela permet d'éviter une condition de «battement» où un seul échec (ou succès) fait basculer rapidement l'état Keepalived d'avant en arrière.
- **fall** : combien de fois le script doit échouer (ou expirer) pour que l'hôte soit considéré comme "malsain". Cela fonctionne comme l'inverse de la directive de **rise**.

<br>

Nous pouvons tester cette configuration en forçant le script à échouer. Dans l'exemple ci-dessous, nous ajoutons une règle **iptables** sur le serveur **srv1** qui empêche la communication avec **8.8.8.8**. Cela va provoquer l'échec du bilan de santé et la disparition du VIP après quelques secondes sur le serveur **srv1**. 

```
iptables -I OUTPUT -d 8.8.8.8 -j DROP
```

En supprimant la règle la VIP va réapparaître sur le serveur **srv1**.

```
iptables -D OUTPUT -d 8.8.8.8 -j DROP
```

## Script de notification

Keepalived fournit plusieurs directives de notification pour appeler uniquement des scripts sur des états particuliers (**notify_master**, **notify_backup**, etc.). Nous prendrons l'exemple sur la directive de **notify**. Lorsqu'un script dans la directive **notify** est appelé, il reçoit quatre arguments supplémentaires (après tous les arguments passés au script lui-même).

- Groupe ou instance : indique si la notification est déclenchée par un groupe VRRP ou une instance VRRP particulière.
- Nom du groupe ou de l'instance
- Etat : indique que l'état d'un groupe ou d'une instance
- Priorité

Le script de notification à configurer sur chaque serveur **srv1** et **srv2**

```
sudo vi /usr/local/bin/keepalived_notify.sh
```

```
#!/bin/bash

echo "$1 $2 has transitioned to the $3 state with a priority of $4" > /var/run/keepalived_status
```

```
sudo chmod +x /usr/local/bin/keepalived_notify.sh
```

- Configuration du serveur principal srv1 -> 192.168.56.4

```
sudo vi keepalived.conf
```

```
vrrp_script keepalived_check {
    script "/usr/local/bin/keepalived_check.sh"
    interval 1
    timeout 5
    rise 3
    fall 3
}

vrrp_instance VI_1 {
    state MASTER
    interface enp0s8
    virtual_router_id 52
    priority 244
    advert_int 1
    unicast_src_ip 192.168.56.4 # adresse IP de la master
    unicast_peer {
        192.168.56.5 # adresse IP du serveur secondaire
    }
    authentication {
        auth_type PASS
        auth_pass 12345678
    }
    virtual_ipaddress {
        192.168.56.7/24
    }
    track_script {
        keepalived_check
    }
    notify "/usr/local/bin/keepalived_notify.sh"
}
```

```
sudo systemctl restart keepalived
```

- Configuration du serveur secondaire srv2 -> 192.168.56.5

```
sudo vi keepalived.conf
```

```
vrrp_script keepalived_check {
    script "/usr/local/bin/keepalived_check.sh"
    interval 1
    timeout 5
    rise 3
    fall 3
}

vrrp_instance VI_1 {
    state BACKUP
    interface enp0s8
    virtual_router_id 52
    priority 244
    advert_int 1
    unicast_src_ip 192.168.56.5 # adresse IP du serveur secondaire 
    unicast_peer {
        192.168.56.4 # adresse IP de la master
    }
    authentication {
        auth_type PASS
        auth_pass 12345678
    }
    virtual_ipaddress {
        192.168.56.7/24
    }
    track_script {
        keepalived_check
    }
    notify "/usr/local/bin/keepalived_notify.sh"
}
```

```
sudo systemctl restart keepalived
```