# Configuration d'un certificat et domaine [PART3]

**Let's Encrypt** est une autorité de certification (AC) qui fournit des certificats gratuits pour le chiffrement TLS (Transport Layer Security). Il simplifie le processus de création, de validation, de signature, d'installation et de renouvellement des certificats en fournissant un client logiciel : **Certbot**.

Nous supposerons notre domaine : **vault.willbrid.com**

### Création d'un certificat du domaine vault.willbrid.com avec Let's Encrypt

Nous configurerons un certificat TLS/SSL de **Let's Encrypt** sur un serveur Rocky Linux 8.

1. **Installation de certbot**

```
sudo dnf install epel-release
```

```
sudo dnf install certbot
```

2. **Création du certificat de notre domaine** 

```
sudo certbot certonly --standalone -d vault.willbrid.com
```

L'argument **certonly** permet d'obtenir ou renouveler un certificat, mais sans l'installer. Son option **--standalone** permet d'exécuter un serveur Web autonome pour l'authentification et sans une utilisation spécifique d'un serveur web tel que : **nginx** ou **apache**. Son option **-d** permet d'indiquer notre nom de domaine.

La sortie de la commande nous demande de préciser notre email, de lire et d'accepter les Conditions d'utilisation du service **Let's Encrypt** (nous acceptons) et de partager notre email (nous refusons).

Nous pouvons vérifier le contenu du repertoire généré contenant les informations sur notre certificat de notre domaine **vault.willbrid.com**:

```
sudo ls /etc/letsencrypt/live/vault.willbrid.com/
```

```
# Sortie de la commande
cert.pem  chain.pem  fullchain.pem  privkey.pem  README
```

**NB :** Cette procédure ci-dessus est à utiliser si nous souhaitons exposer le service **vault** sur Internet. Dans notre cas, nous allons utiliser la section suivante.

### Création d'un certificat auto-signé du domaine vault.willbrid.com

Pour créer un certificat auto-signé nous utiliserons un playbook ansible diponible via ce lien [https://github.com/willbrid/DevSecOps-SRE-infra/blob/main/tls/script-ansible/](https://github.com/willbrid/DevSecOps-SRE-infra/blob/main/tls/script-ansible/). Il suffira juste de définir la valeur des variables contenues dans le fichier **vars.yml** et d'exécuter la commande :

```
mkdir -p $HOME/own-ca-crt && cd $HOME/own-ca-crt
```

```
ansible-playbook playbook.yml --ask-become-pass
```

Ce playbook s'exécute sur une machine locale et est compatible avec les distributions **Redhat** et **Debian**. <br> Avec les valeurs par défaut des variables définies dans le fichier **vars.yml**, 4 fichiers sont créés :
- un fichier **ca.pem** correspondant au fichier clé privé de l'autorité de certification
- un fichier **ca.crt** correspondant au fichier certificat de l'autorité de certification
- un fichier **willbrid.com.key** correspondant au fichier clé privé du wildcard domaine **\*.willbrid.com**
- un fichier **willbrid.com.crt** correspondant au fichier certificat du wildcard domaine **\*.willbrid.com**.

Pour la suite, ces 4 fichiers doivent être importés sur le serveur **vault-server** à l'emplacement **/opt/vault/tls** (emplacement créé automatiquement lors de l'installation de **vault**) avec les droits suivants :

```
sudo chmod 600 /opt/vault/tls/*
sudo chown vault:vault /opt/vault/tls/*
```