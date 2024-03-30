# ACLs

Une ACL HAProxy nous permet de définir des règles personnalisées pour bloquer les requêtes malveillantes, choisir des backends, rediriger vers HTTPS et utiliser des objets mis en cache.
<br>
Les listes de contrôle d'accès, ou ACL, dans HAProxy nous permettent de tester diverses conditions et d'effectuer une action donnée en fonction de ces tests. Ces conditions couvrent à peu près tous les aspects d'une requête ou d'une réponse, tels que la recherche de chaînes ou de motifs, la vérification des adresses IP d'où elles proviennent, les taux de requêtes récents (via stick tables), le statut TLS, etc. acheminer les décisions, rediriger les requêtes, renvoyer des réponses statiques et bien plus encore. Les ACL de HAProxy adoptent l'utilisation d'opérateurs logiques (AND, OR, NOT) pour former des conditions plus complexes.

### Formater une ACL

Il existe deux manières de spécifier une ACL : une ACL nommée et une ACL anonyme ou en ligne.

- La première forme est une ACL nommée

```
acl is_static path -i -m beg /static/
```

Nous commençons par le mot-clé **acl**, suivi d'un **nom**, suivi de la **condition**. Ici, nous avons une ACL nommée **is_static**. Ce nom ACL peut ensuite être utilisé avec des instructions **if** et **unless**. Cette forme est recommandée lorsque nous utilisons une condition donnée pour plusieurs actions.

```
acl is_static path -i -m beg /static/
use_backend be_static if is_static
```

La condition, **path -i -m beg /static/**, vérifie si l'URL commence par **/static/**.

- La deuxième forme est une liste de contrôle d'accès anonyme ou en ligne

```
use_backend be_static if { path -i -m beg /static/ }
```

Dans les deux formes, nous pouvons enchaîner plusieurs conditions. Les listes de contrôle d'accès répertoriées les unes après les autres sans rien entre elles, seront considérées comme jointes. La condition globale n'est vraie que si les deux ACL sont vraies.

```
http-request deny if { path -i -m beg /api/ } { src 192.168.56.0/24 }
```

Cela empêchera tout client du sous-réseau **192.168.56.0/24** d'accéder à tout ce qui commence par **/api/**, tout en pouvant accéder à d'autres chemins.
<br>
L'ajout d'un point d'exclamation inverse une condition.

```
http-request deny if { path -i -m beg /api/ } !{ src 192.168.56.0/24 }
```

Désormais, seuls les clients du sous-réseau **192.168.56.0/24** sont autorisés à accéder aux chemins commençant par **/api/** tandis que tous les autres seront interdits.
<br>
Les adresses IP peuvent également être importées depuis un fichier.

```
http-request deny if { path -i -m beg /api/ } { src -f /etc/haproxy/blacklist.acl }
```

Dans **blacklist.acl**, nous répertorions ensuite des adresses IP individuelles ou une plage d'adresses IP en utilisant la notation CIDR pour bloquer.

```
192.168.56.3
192.168.56.0/24
```

Nous pouvons également définir une ACL où l'une ou l'autre des conditions peut être vraie en utilisant **||** .

```
http-request deny if { path -i -m beg /evil/ } || { path -i -m end /evil }
```

Ainsi, chaque requête dont le chemin commence par **/evil/** (par exemple **/evil/foo**) ou se termine par **/evil** (par exemple **/foo/evil**) sera refusée.
<br>

Nous pouvons également faire de même pour combiner des ACL nommées.

```
acl starts_evil path -i -m beg /evil/
acl ends_evil path -i -m end /evil
http-request deny if starts_evil || ends_evil
```

Avec des ACL nommées, spécifier plusieurs fois le même nom d'ACL entraînera un **OU logique** des conditions, de sorte que le dernier bloc peut également être exprimé.

```
acl evil path_beg /evil/
acl evil path_end /evil
http-request deny if evil
```

Cela nous permet de combiner des **ET** et des **OU* (ainsi que des ACL nommées et en ligne) pour créer des conditions plus complexes.

```
acl evil path_beg /evil/
acl evil path_end /evil
http-request deny if evil !{ src 192.168.56.0/24 }
```

Cela bloquera la requête si le chemin commence ou se termine par **/evil**, mais uniquement pour les clients qui ne se trouvent pas dans le sous-réseau **192.168.56.0/24** .

### Extractions

Une source d'informations dans HAProxy est connue sous le nom de **extraction**. Celles-ci permettent aux ACL d'obtenir une information avec laquelle travailler.

Voici quelques-unes les plus couramment utilisées.

- **src** : Renvoie l'adresse IP du client qui a fait la requête

- **path** : Renvoie le chemin demandé par le client

- **url_param(foo)** : Renvoie la valeur d'un paramètre d'URL donné

- **req.hdr(foo)** : Renvoie la valeur d'une en-tête de requête HTTP donné (par exemple, User-Agent ou Host)

- **ssl_fc** : Un booléen qui renvoie vrai si la connexion a été établie via SSL et que HAProxy le déchiffre localement

### Convertisseurs

Les convertisseurs sont séparés par des virgules des extractions, ou d'autres convertisseurs, et peuvent être enchaînés plusieurs fois.

Certains convertisseurs (tels que **lower** et **upper**) sont spécifiés par eux-mêmes tandis que d'autres ont des arguments qui leur sont transmis. Si un argument est requis, il est spécifié entre parenthèses. Par exemple, pour obtenir la valeur du chemin avec **/static** supprimé au début de celui-ci, nous pouvons utiliser le convertisseur **regsub** avec une regex et un remplacement comme arguments :

```
path,regsub(^/static,/)
```

il existe une grande variété de convertisseurs dont les plus couramment utilisés.

- **lower** : change la casse d'un échantillon en minuscules

- **upper** : change la casse d'un échantillon en majuscules

- **base64** : Base64 encode la chaîne spécifiée

- **field** : Permet d'extraire un champ similaire à **awk**. Par exemple, si nous avons **"a|b|c"** comme exemple et que nous exécutons le **field(|,3)** dessus, il vous restera **"c"** .

- **bytes** : Extrait certains octets d'un échantillon binaire d'entrée avec un décalage et une longueur comme arguments

- **map** : Recherche l'échantillon dans le fichier spécifié et affiche la valeur résultante

### Indicateurs

Nous pouvons placer plusieurs indicateurs dans une seule ACL.

```
path -i -m beg -f /etc/hapee/paths_secret.acl
```

Cela effectuera une correspondance insensible à la casse basée sur le début du chemin et la correspondance avec les motifs stockés dans le fichier spécifié. Il n'y a pas autant de indicateurs qu'il y a de types de extraction/convertisseur. <br>

Voici quelques-uns des plus couramment utilisés :

- **-i** : effectue une correspondance insensible à la casse

- **-f** : au lieu de faire correspondre une chaîne, fait correspondre à partir d'un fichier ACL. Ce fichier ACL peut contenir des listes d'adresses IP, de chaînes, d'expressions régulières, etc.

- **-m** : spécifie le type de correspondance.

### Méthodes de correspondance

Nous avons maintenant un échantillon de convertisseurs et d'extractions, tels que le chemin d'URL demandé via **path**, et quelque chose à comparer via le chemin codé en dur **/evil**. Pour comparer le premier au second, nous pouvons utiliser l'une des nombreuses méthodes de correspondance. <br>
Voici quelques méthodes de correspondance couramment utilisées :

- **str** : effectue une correspondance de chaîne exacte

- **beg** : vérifie le début de la chaîne avec le motif, ainsi un échantillon de **"foobar"** correspondra à un motif de **"foo"** mais pas de **"bar"**.

- **end** : vérifie la fin d'une chaîne avec le motif, ainsi un échantillon de **foobar** correspondra à un motif de **bar** mais pas **foo**.

- **sub** : une correspondance de sous-chaîne, donc un échantillon de **foobar** correspondra aux motifs **foo**, **bar**, **oba**.

- **reg** : le motif est comparé en tant qu'expression régulière à l'échantillon. Avertissement : Cette méthode est gourmande en CPU par rapport aux autres méthodes de correspondance et doit être évitée à moins qu'il n'y ait pas d'autre choix.

- **found** : C'est une méthode de correspondance qui ne prend pas du tout de motif. La correspondance est vraie si l'échantillon est trouvé, fausse sinon.

- **len** : renvoie la longueur de l'échantillon (donc un échantillon de foo avec -m len 3 correspondra)