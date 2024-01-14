# Configuration d'un certificat et domaine [PART3]

**Let's Encrypt** est une autorité de certification (AC) qui fournit des certificats gratuits pour le chiffrement TLS (Transport Layer Security). Il simplifie le processus de création, de validation, de signature, d'installation et de renouvellement des certificats en fournissant un client logiciel : **Certbot**.

Nous configurerons un certificat TLS/SSL de **Let's Encrypt** sur un serveur Rocky Linux 8.

1. **Installation de certbot**

```
sudo dnf install epel-release
```

```
sudo dnf install certbot
```

2. Création du certificat de notre domaine 

```
sudo certbot certonly --standalone -d notredomaine
```

L'argument **certonly** permet d'obtenir ou renouveler un certificat, mais sans l'installer. Son option **--standalone** permet d'exécuter un serveur Web autonome pour l'authentification et sans une utilisation spécifique d'un serveur web tel que : nginx ou apache. Son option **-d** permet d'indiquer notre nom de domaine.

<br>

La sortie de la commande nous demande de préciser notre email, de lire et d'accepter les Conditions d'utilisation du service **Let's Encrypt** (nous acceptons) et de partager notre email (nous refusons).

<br>

Nous pouvons vérifier le contenu du repertoire généré contenant les informations sur notre certificat de notre domaine **notredomaine**:

```
sudo ls /etc/letsencrypt/live/notredomaine/
```

```
# Sortie de la commande
cert.pem  chain.pem  fullchain.pem  privkey.pem  README
```