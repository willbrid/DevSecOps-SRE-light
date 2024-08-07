# Configurer un serveur DNS de mise en cache

La résolution DNS est un élément clé d'un environnement réseau/serveur. En tant qu'administrateur système Linux, nous devons être en mesure de fournir une réactivité DNS fiable. La résolution DNS est un élément clé de la communication du système, et un serveur **DNS en cache** peut contribuer à améliorer les performances.

- Installation de **BIND**

Sous Ubuntu

```
sudo apt update && sudo apt install bind9 bind9utils bind9-doc
```

Sous Rocky linux

```
sudo dnf install bind bind-utils
```

- Backup du fichier de configuration **/etc/bind/named.conf.options** sous Ubuntu et **/etc/named.conf** sous Rocky linux

Sous Ubuntu

```
sudo cp /etc/bind/named.conf.options ~/named.conf.options.backup
```

Sous Rocky linux

```
sudo cp /etc/named.conf ~/named.conf.backup
```

- Configuration du cache DNS

Sous Ubuntu

```
sudo vi /etc/bind/named.conf.options
```

Sous Rocky linux

```
sudo vi /etc/named.conf
```

```
...
acl allowclients {
    192.168.56.0/24;
    localhost;
    localnets;
};

options {
    ...
    recursion yes;
    allow-query { allowclients; };
    allow-query-cache { allowclients; };
    allow-recursion { allowclients; };
    ...
    forwarders {
        0.0.0.0;
        8.8.8.8;
        8.8.4.4;
    };
    ...
};
```

Vérifions si les configurations sont correctes

Sous Ubuntu ou Rocky linux

```
sudo named-checkconf
```

Redémarrons le service bind (sous Ubuntu ou Rocky linux)

```
sudo systemctl enable --now named
sudo systemctl status named
```

Sous Rocky linux, il faudrait autoriser le service dns au niveau du service **firewalld**

```
sudo firewall-cmd --add-service=dns
sudo firewall-cmd --runtime-to-permanent
```