# Authentification

Ce contenu couvre les **mécanismes d'authentification** dans Kubernetes pour sécuriser l'**accès de gestion** au cluster.

### Contexte : qui accède au cluster ?

Plusieurs types d'utilisateurs accèdent au cluster :
- **Administrateurs** (tâches système) ;
- **Développeurs** (déploiement, tests) ;
- **Utilisateurs finaux** (interaction avec les applications) ;
- **Processus tiers / bots** (intégrations).

### Point crucial : comment Kubernetes gère les comptes

- Toutes les requêtes (via `kubectl` ou appels API directs) passent par le **kube-apiserver**, qui les **authentifie** avant tout traitement.
- Kubernetes **ne gère PAS nativement les comptes d'utilisateurs humains** : il s'appuie sur des solutions **externes** (fichiers statiques, autorités de certification, LDAP…).
- En revanche, il **gère les service accounts** via son API (pour les processus automatisés).
- La sécurité des utilisateurs **au niveau applicatif** est gérée par l'application elle-même.

### Les méthodes d'authentification du kube-apiserver

- Fichiers **statiques de mots de passe** (usernames + passwords) ;
- Fichiers **statiques de tokens** (usernames + tokens) ;
- Authentification par **certificats** ;
- Intégration avec des protocoles tiers (**LDAP, Kerberos**).

### Authentification par fichier de mots de passe statique

Créer un fichier **CSV** avec 3 colonnes : **password, username, user ID**.

```csv
password123,user1,u0001
password123,user2,u0002
...
```

Référencer le fichier au démarrage du kube-apiserver avec l'option :

```
...
--basic-auth-file=user-details.csv
...
```

> Il faut **redémarrer le kube-apiserver** pour appliquer les changements (avec **kubeadm**, la modification du fichier de définition du pod déclenche un redémarrage automatique).

Accéder à l'API avec ces identifiants :

```bash
curl -v -k https://master-node-ip:6443/api/v1/pods -u "user1:password123"
```

**Option** : ajouter une **4ᵉ colonne** pour l'appartenance à un **groupe** :

```csv
password123,user1,u0001,group1
```

### Authentification par fichier de tokens statique

Similaire au fichier de mots de passe, mais le champ password est remplacé par un **token**.

```csv
token1,user1,u0001,group1
token2,user2,u0002,group2
...
```

Référencer avec l'option :

```
...
--token-auth-file=user-details.csv
...
```

Lors des requêtes, passer le token comme **bearer token** dans l'en-tête :

```bash
KpjCvBI7rCFAHYPKByTlzRb7gulcUc4B,user10,u0010,group1
rJjncHmvtXHc6M1WQddhtvNyhgTdxSC,user11,u0011,group1
mjpOFEiFokLgtoikaRNTt59ePtczZSq,user12,u0012,group2
PG411Xhs7qjwWkmBkvG7g9lOyUqZj,user13,u0013,group2
```

```bash
curl -v -k https://master-node-ip:6443/api/v1/pods --header "Authorization: Bearer KpjCvBI7rCFAHYPKByTlzRb7gulcUc4B"
```

### Avertissement de sécurité

> Stocker des identifiants, mots de passe et tokens **en clair** dans des fichiers statiques est **acceptable en apprentissage** mais **déconseillé en production** (risque de sécurité).
→ En production, privilégier l'**authentification par certificats** ou l'intégration avec des **fournisseurs d'identité externes**.

### Considération kubeadm

Avec **kubeadm**, il faut fournir correctement le fichier d'authentification au **kube-apiserver** via des **volume mounts** appropriés dans la configuration du pod — étape critique pour que le mécanisme fonctionne.

### À retenir

- Le **kube-apiserver** authentifie **toutes** les requêtes.
- Kubernetes ne gère **pas** les utilisateurs humains nativement (solutions externes) mais gère les **service accounts**.
- Méthodes : fichiers statiques (mots de passe/tokens), **certificats**, **LDAP/Kerberos**.
- Options CLI : **`--basic-auth-file`** (mots de passe), **`--token-auth-file`** (tokens).
- Une **4ᵉ colonne** optionnelle définit le **groupe**.
- Les fichiers statiques en clair sont **à proscrire en production** → certificats ou fournisseurs externes.

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
