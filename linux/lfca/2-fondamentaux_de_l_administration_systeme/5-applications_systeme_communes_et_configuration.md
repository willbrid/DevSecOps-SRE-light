# Applications système communes et configuration

- Service http Apache (httpd) : un serveur Web open source de la fondation logicielle apache qui fournit du contenu via le protocole http et sa variante sécurisée, https. La communication est initiée par un utilisateur généralement au moyen d'un navigateur Web. <br>

**Prototype : installation, configuration et utilisation (sous la famille redhat)**

```
yum install **httpd**
/etc/httpd/conf/httpd.conf
/etc/httpd/conf.d/
Repertoire de document web : "/var/www/html"
Page par défaut : index.html
Répertoire des logs : /var/log/httpd
Ports par défaut : 80 et 443
démarrer et activer le service httpd : systemctl enable httpd --now
```

- Service **postfix** : un serveur de messagerie open source, à l'origine d'IBM, qui utilise le protocole SMTP (Simple Mail Transfert Protocol) pour acheminer et livrer le courrier.

**Prototype : installation, configuration et utilisation (sous la famille redhat)**

```
yum install postfix
/etc/postfix/main.cf
/etc/postfix/master.cf
Répertoire des logs : /var/log/maillog (or mail.log)
Ports par défaut : 25, 465 et 587
démarrer et activer le service postfix : systemctl enable postfix --now
```

- Service **NTP** : le Network Time Protocol (NTP) : est utilisé pour synchroniser l'horloge système sur un système Linux avec un serveur NTP centralisé. Un serveur NTP local peut être utilisé avec une source de synchronisation externe pour synchroniser l'heure d'un groupe de serveurs sur un réseau.

**Prototype : installation, configuration et utilisation (sous la famille redhat)**

```
yum install ntp
/etc/ntp.conf
Fichier des logs :/var/log/ntp.log
Ports par défaut : 123/UDP
démarrer et activer le service postfix : systemctl enable ntpd --now
```

- Service **chrony** : il s'agit d'une implémentation plus polyvalente du protocole NTP qui est utilisée pour synchroniser l'horloge système sur un système Linux. Il peut également fonctionner comme un serveur et un homologue pour fournir une synchronisation de l'heure aux ordinateurs d'un réseau.

**Prototype : installation, configuration et utilisation (sous la famille redhat)**

```
yum install chrony
/etc/chrony.conf
Répertoire des logs : /var/log/chrony/
Ports par défaut : 123/UDP
démarrer et activer le service postfix : systemctl enable chronyd --now
```