# Configurer un service IMAP et IMAPS

En tant qu'administrateur système Linux, nous pouvons être chargé d'installer et de gérer la messagerie électronique de nos utilisateurs. Comprendre les bases de POP3 et IMAP peut donc s'avérer précieux. Les administrateurs système Linux gèrent les serveurs de messagerie depuis longtemps, avec une variété d'options disponibles.

### Protocoles de messagerie

- **IMAP : Internet Message Access Protocol**

--- Lors de la lecture d'un message via IMAP, le message (et les pièces jointes) ne sont pas automatiquement téléchargés. <br>
--- Les messages ne sont téléchargés que lorsque nous cliquons dessus et tous les messages restent sur le serveur.

- **POP3 : Post Office Protocol**

--- POP contacte le fournisseur de messagerie et télécharge d'abord tous les nouveaux messages, puis les rend disponibles pour lecture. <br>
--- Une fois que POP télécharge un message, il est supprimé du serveur et n'est disponible que sur le périphérique local.

- Affichons les groupes auxquel appartiennent le service mail et postfix

```
cat /etc/group | grep -e mail -e postfix
```

```
ls -alh /var/mail
```

### Installation et configuration de Dovecot

**Dovecot** est un logiciel serveur de messagerie open source conçu pour gérer l'accès aux boîtes aux lettres des utilisateurs sur un serveur. Il est couramment utilisé en conjonction avec d'autres logiciels de messagerie tels que **Postfix** pour offrir une solution de messagerie complète sur les systèmes Linux et Unix-like. Il prend en charge les protocoles **IMAP** (**Internet Message Access Protocol**) et **POP3** (**Post Office Protocol version 3**), permettant aux utilisateurs d'accéder à leurs **e-mails** à partir de clients de messagerie tels que **Thunderbird**, **Outlook**, ou **Mail**.

- Installation

Sous Ubuntu

```
sudo apt install -y dovecot-core dovecot-pop3d dovecot-imapd
```

Sous Rocky linux

```
sudo dnf install -y dovecot
```

--- **/etc/dovecot/dovecot.conf** : fichier de configuration principal <br>
--- **/etc/dovecot/conf.d/** - contient les fichiers de configuration Dovecot <br>
------- **10-mail.conf** : **mail_location** pour l'emplacement physique où les boîtes aux lettres sont stockées et **mail_privileged_group** pour le groupe utilisateur privilégié pour accéder aux boîtes aux lettres <br>
------- **10-ssl.conf** : fichier de configuration SSL <br>
------- **20-imap.conf**/**20-pop3.conf** : fichiers de configuration des protocoles IMAP et POP3 <br>
--- **/etc/dovecot/private** : contient les clés SSL