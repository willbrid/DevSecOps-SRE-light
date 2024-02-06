# Installation [Part2]

Ici nous allons générer un certificat wildcard **\*.willbrid.com** depuis notre serveur **gitlab**.

### Création du certificat CA

Tout d’abord, nous devons créer une clé privée pour notre certificat **CA**. Nous allons l'appeler **ca.key**. Lorsque la clé est générée, nous devons saisir le mot de passe (dans notre cas : **test**) et le vérifier.

```
openssl genrsa -des3 -out ca.key 4096
```

L'étape suivante consiste à générer le certificat **CA** lui-même avec la clé privée déjà créée. Nous allons le nommer **ca.crt**.

```
openssl req -new -x509 -days 365 -key ca.key -out ca.crt
```

```
Country Name (2 letter code) [XX]:CM
State or Province Name (full name) []:LT
Locality Name (eg, city) [Default City]:DLA   
Organization Name (eg, company) [Default Company Ltd]:willbrid
Organizational Unit Name (eg, section) []:willbrid
Common Name (eg, your name or your server's hostname) []:willbrid.com
Email Address []:gitlab-dev@willbrid.com
```

### Création de notre certificat wildcard

Tout d’abord, nous devons créer une clé privée pour notre certificat du domaine wildcard **\*.willbrid.com**.

```
openssl genrsa -out willbrid.com.key 2048
```

Ensuite nous créons le fichier de configuration **openssl.cnf** que nous allons utiliser pour la demande de certificat **CSR** et la **signature**.

```
vi openssl.cnf
```

```
[req]
default_md = sha256
prompt = no
req_extensions = req_ext
distinguished_name = req_distinguished_name

[req_distinguished_name]
commonName = *.willbrid.com
countryName = CM
stateOrProvinceName = LT
localityName = DLA
organizationName = WILLBRID

[req_ext]
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=critical,serverAuth,clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=willbrid.com
DNS.2=*.willbrid.com
```

```
openssl req -new -nodes -key willbrid.com.key -config openssl.cnf -out willbrid.com.csr
```

Nous pouvons vérifier que la demande de certificat a été bien créée avec la commande

```
openssl req -noout -text -in willbrid.com.csr
```

Maintenant, nous pouvons le (**willbrid.com.csr**) signer avec notre autorité de certification créée au préalable. Nous nommerons le fichier CRT final **willbrid.com.crt**. Pour réussir la création, nous devons saisir le mot de passe du fichier de clé privée **CA**.

```
openssl x509 -req -in willbrid.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out willbrid.com.crt -days 365 -sha256 -extfile openssl.cnf -extensions req_ext
```

Nous pouvons vérifier que le certificat a été bien créé avec la commande

```
openssl x509 -noout -text -in willbrid.com.crt
```