# Sécurité kubernetes (Part2)

#### Utilisateurs dans Kubernetes

Tous les clusters Kubernetes ont deux catégories d'utilisateurs : les comptes de service gérés par Kubernetes et les utilisateurs normaux.

On suppose qu'un service indépendant du cluster gère les utilisateurs normaux de la manière suivante :

- un administrateur distribuant des clés privées
- un magasin d'utilisateurs comme Keystone ou Google Accounts
- un fichier avec une liste de noms d'utilisateur et de mots de passe

À cet égard, Kubernetes n'a pas d'objets qui représentent des comptes d'utilisateurs normaux. Les utilisateurs normaux ne peuvent pas être ajoutés à un cluster via un appel d'API.
<br><br>
Même si un utilisateur normal ne peut pas être ajouté via un appel d'API, tout utilisateur qui présente un certificat valide signé par l'autorité de certification (CA) du cluster est considéré comme authentifié. Dans cette configuration, Kubernetes détermine le nom d'utilisateur à partir du champ de nom commun dans le "sujet" du certificat (par exemple, "/CN=bob"). À partir de là, le sous-système de contrôle d'accès basé sur les rôles (RBAC) déterminerait si l'utilisateur est autorisé à effectuer une opération spécifique sur une ressource.
<br><br>
En revanche, les comptes de service sont des utilisateurs gérés par l'API Kubernetes. Ils sont liés à des espaces de noms spécifiques et créés automatiquement par le serveur d'API ou manuellement via des appels d'API. Les comptes de service sont liés à un ensemble d'informations d'identification stockées en tant que secrets, qui sont montés dans des pods permettant aux processus du cluster de communiquer avec l'API Kubernetes.
<br><br>
Les demandes d'API sont liées à un utilisateur normal ou à un compte de service, ou sont traitées comme des demandes anonymes. Cela signifie que chaque processus à l'intérieur ou à l'extérieur du cluster, qu'il s'agisse d'un utilisateur humain tapant kubectl sur un poste de travail, de kubelets sur des nœuds ou de membres du plan de contrôle, doit s'authentifier lorsqu'il adresse des requêtes au serveur d'API ou être traité comme un utilisateur anonyme.

#### Stratégies d'authentification

Kubernetes utilise des certificats client, des jetons porteurs ou un proxy d'authentification pour authentifier les demandes d'API via des plug-ins d'authentification. Au fur et à mesure que les requêtes HTTP sont adressées au serveur API, les plugins tentent d'associer les attributs suivants à la requête :

- **Username** : une chaîne qui identifie l'utilisateur final. Les valeurs courantes peuvent être kube-admin ou jane@example.com.
- **UID** : une chaîne qui identifie l'utilisateur final et tente d'être plus cohérente et unique que le nom d'utilisateur.
- **Groups**: ensemble de chaînes, chacune indiquant l'appartenance de l'utilisateur à une collection logique nommée d'utilisateurs. Les valeurs courantes peuvent être system:masters ou devops-team.
- **Extra fields** : une map de chaînes à une liste de chaînes contenant des informations supplémentaires que les autorités peuvent trouver utiles.

Toutes les valeurs sont opaques pour le système d'authentification et n'ont de signification que lorsqu'elles sont interprétées par un autorisateur.

Nous pouvons activer plusieurs méthodes d'authentification à la fois. Nous devons généralement utiliser au moins deux méthodes :

- jetons de compte de service pour les comptes de service
- au moins une autre méthode d'authentification de l'utilisateur.

Le groupe **system:authenticated** est inclus dans la liste des groupes pour tous les utilisateurs authentifiés.
<br><br>
Les intégrations avec d'autres protocoles d'authentification (LDAP, SAML, Kerberos, autres schémas x509, etc.) peuvent être réalisées à l'aide d'un proxy d'authentification ou du webhook d'authentification.

#### Certificats client X509

L'authentification par certificat client est activée en transmettant l'option **--client-ca-file=SOMEFILE** au serveur API. Le fichier référencé doit contenir une ou plusieurs autorités de certification à utiliser pour valider les certificats client présentés au serveur d'API. Si un certificat client est présenté et vérifié, le nom commun du sujet est utilisé comme nom d'utilisateur pour la demande. Depuis Kubernetes 1.4, les certificats clients peuvent également indiquer les appartenances à un groupe d'utilisateurs à l'aide des champs d'organisation du certificat. Pour inclure plusieurs appartenances à des groupes pour un utilisateur, il faudrait inclure plusieurs champs d'organisation dans le certificat.
<br><br>
Par exemple, en utilisant l'outil de ligne de commande openssl pour générer une demande de signature de certificat :

```
openssl req -new -key jbeda.pem -out jbeda-csr.pem -subj "/CN=jbeda/O=app1/O=app2"
```

Cela créerait un CSR pour le nom d'utilisateur "jbeda", appartenant à deux groupes, "app1" et "app2".

#### Fichier de jeton statique

Le serveur API lit les jetons de support à partir d'un fichier lorsqu'il reçoit l'option **--token-auth-file=SOMEFILE** sur la ligne de commande. Actuellement, les jetons durent indéfiniment et la liste des jetons ne peut pas être modifiée sans redémarrer le serveur d'API.

Le fichier de jeton est un fichier csv avec un minimum de 3 colonnes : jeton (**token**), nom d'utilisateur, uid d'utilisateur, suivis de noms de groupe facultatifs.

```
token,user,uid,"group1,group2,group3"
```

Mettre un jeton porteur dans une requête

```
Authorization: Bearer 31ada4fd-adec-460c-809a-9e56ceb75269
```

[https://kubernetes.io/docs/reference/access-authn-authz/authentication/](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)