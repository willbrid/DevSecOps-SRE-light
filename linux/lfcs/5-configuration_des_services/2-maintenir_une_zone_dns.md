# Maintenir une zone DNS

La résolution DNS est un élément clé d'un environnement réseau/serveur. En tant qu'administrateur système Linux, nous devons être en mesure de fournir une réactivité DNS fiable. DNS est la liste de contacts d'Internet, et si nous disposons d'un domaine, nous devrons peut-être créer les fichiers de zone appropriés pour notre serveur DNS.

Nous configurons ici un serveur DNS avec le domaine **willbrid.com**. Nous supposerons deux serveurs de nom principal : **ns1.willbrid.com** (192.168.56.110) et **ns2.willbrid.com** (192.168.56.111). Nous supposersons aussi les enregistrements de type A **www -> 192.168.56.100**, **mail -> 192.168.56.150** et **file -> 192.168.56.200**.

- Ajout d'une zone DNS

Sous Ubuntu

```
sudo vi /etc/bind/named.conf.local
```

```
...
zone "willbrid.com" IN {
        type master;
        file "/etc/bind/willbrid.com";
        allow-update { none; };
};
zone "56.168.192.in-addr.arpa" IN {
        type master;
        file "/etc/bind/56.168.192.db";
        allow-update { none; };
};
```

Sous Rocky linux

```
sudo vi /etc/named.conf
```

```
...
zone "willbrid.com" IN {
        type master;
        file "willbrid.com";
        allow-update { none; };
};
zone "56.168.192.in-addr.arpa" IN {
        type master;
        file "56.168.192.db";
        allow-update { none; };
};
```

- Configuration des fichiers **willbrid.com**

Sous Ubuntu

```
sudo vi /etc/bind/willbrid.com
```

Sous Rocky linux

```
sudo vi /var/named/willbrid.com
```

Contenu du fichier **willbrid.com**

```
;
; BIND data file for local loopback interface
;
$TTL    604800
@    IN    SOA    ns1.willbrid.com.    root.willbrid.com. (
		         20                ;Serial
                     604800                ;Refresh
                      86400                ;Retry
                    2419200                ;Expire
                    604800 )               ;Negative Cache TTL
;

;Name server Information
@    IN    NS    ns1.willbrid.com.
@    IN    NS    ns2.willbrid.com.

;IP address of Name Server 
ns1    IN    A    192.168.56.110
ns2    IN    A    192.168.56.111

;Mail Server
willbrid.com. IN  MX  10  mail.willbrid.com.

;A - Record Hostname To IP Address
www    IN    A    192.168.56.100
mail   IN    A    192.168.56.150
file   IN    A    192.168.56.200

;CNAME record
ftp    IN    CNAME    file.willbrid.com.
```

- Configuration des fichiers **56.168.192.db**

Sous Ubuntu

```
sudo vi /etc/bind/56.168.192.db
```

Sous Rocky linux

```
sudo vi /var/named/56.168.192.db
```

Contenu du fichier **56.168.192.db**

```
;
; BIND data file for local loopback interface
;
$TTL    604800
@    IN    SOA    ns1.willbrid.com.    root.willbrid.com. (
		         20                ;Serial
                     604800                ;Refresh
                      86400                ;Retry
                    2419200                ;Expire
                    604800 )               ;Negative Cache TTL
;

;Name server Information
@    IN    NS    ns1.willbrid.com.
@    IN    NS    ns2.willbrid.com.

;Reverse lookup for Name Server
110    IN    PTR    ns1.willbrid.com.
111    IN    PTR    ns2.willbrid.com.

;PTR Record IP Address to Hostname
100    IN    PTR    www.willbrid.com.
150    IN    PTR    mail.willbrid.com.
200    IN    PTR    file.willbrid.com.
```

- Exécution d'un test de vérification des configurations

```
sudo named-checkconf
```

- Redémarrons le service **named**

```
sudo systemctl restart named
sudo systemctl status named
```

- Exécution des tests de vérification des zones

Sous Ubuntu

```
sudo named-checkzone willbrid.com /etc/bind/willbrid.com
```

Sous Rocky linux

```
sudo named-checkzone willbrid.com /var/named/willbrid.com
```

Les résultats de ces commandes doivent afficher **OK**.

- Exécution des tests de vérification des noms de domaine configurés, avec la commande **dig**

```
dig @localhost www.willbrid.com
```

```
dig @localhost ftp.willbrid.com
```

Il faudrait regarder la partie **;; ANSWER SECTION:** afin de confirmer les enregistrements de nom.

- Exécution des tests de vérification inverse à partir des IP configurées, avec la commande **dig**

```
dig @localhost -x 192.168.56.100
```

```
dig @localhost -x 192.168.56.200
```

Il faudrait regarder la partie **;; ANSWER SECTION:** afin de confirmer les enregistrements inverses d'IP.