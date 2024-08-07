# Configurer les alias d'Email

En tant qu'administrateur système Linux, nous pouvons simplifier la gestion des **e-mails** du système d'un serveur Linux en configurant des alias pour le système de messagerie de notre choix. Ainsi les **alias** nous éviteront de gérer plusieurs boîtes aux lettres dans les scénario où nous souhaiterons envoyer une copie de tous les **e-mails** reçus d'une adresse à une autre, ou envoyer des **e-mails** de compte de service à un utilisateur spécifique.

Ici nous prendrons un exemple en créeant un alias depuis un serveur smtp **postfix**.

**Postfix** est un logiciel de serveur de messagerie open source largement utilisé sous Linux et d'autres systèmes Unix. Il est principalement utilisé pour gérer l'acheminement, la livraison et le transfert des **e-mails** sur un système informatique.

- Installation de **postfix**

Sous Ubuntu

```
sudo apt install -y postfix sasl2-bin
```

Ici nous sélectionnerons le menu **No Configuration**.

Sous Rocky Linux

```
sudo dnf install -y postfix
```

- Configuration des alias

```
sudo vi /etc/postfix/aliases
```

```
# Alias interne associé à un compte unique
willbrid: rodrigue

# Alias interne associé à une liste de comptes
webmaster: webmaster,vagrant
urgent: daniel,rodrigue,maginot

# Alias externe associé à une adresse email
user: ngaswilly77@gmail
```

Activons ces alias au près de postfix

```
sudo postalias /etc/postfix/aliases
```