# Configuration d'un simple registre privé docker avec l'image registry:2

NB: On supposera que la configuration sera faite sur un serveur de domaine **example.com** où docker est déjà installé.

## Création des crédentials du registre
**Création du répertoire registry et auth**

```
mkdir -p ~/registry/auth
```

**Génération des credentials**

```
docker run --entrypoint htpasswd registry:2.7.0 -Bbn login password > ~/registry/auth/htpasswd
```

## Génération d'un certificat auto-signé
Générez un certificat auto-signé. Lors de la génération du certificat, vous pouvez laisser les autres invites vides, à l'exception de l'invite du 
**Common Name**. Pour l'invite du **Common Name**, mettez le nom d'hôte public du serveur de registre : dans notre cas **example.com** .

```
mkdir ~/registry/certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ~/registry/certs/example.com.key -x509 -days 365 -out ~/registry/certs/example.com.crt
```

## Exécutez le registre avec l'authentification et TLS activés

```
docker run -d -p 443:443 --restart=always --name registry \
-v ~/registry/certs:/certs \
-v ~/registry/auth:/auth \
-e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
-e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
-e REGISTRY_AUTH=htpasswd \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
-e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
registry:2
```