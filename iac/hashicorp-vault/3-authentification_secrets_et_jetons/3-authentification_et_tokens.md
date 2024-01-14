# Authentification et tokens

- Créeons un token vault

```
vault token create
```

```
# Résultat
Key                  Value
---                  -----
token                hvs.YDQrLUABO76xFrwNC1PQC8EL
token_accessor       whPGyglcBIWdewqpjfKf2lxA
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

Le résultat nous affiche les éléments suivants : <br>
--- **token** : ce champ donne la valeur du token <br>
--- **token_accessor** : ce champ indique l'accesseur au token qui est une valeur qui agit comme une référence à un token et ne peut être utilisé que pour effectuer des actions limitées (Rechercher les propriétés d'un token, rechercher les capacités d'un token sur un path, renouveler le token, révoquer le token,...) <br>
--- **token_duration** : ce champ indique le temps d'expiration <br>
--- **token_renewable** : ce champ indique si le token est renouvelable <br>
--- **token_policies** : ce champ indique les règles du token qui sont définies en fonction de la méthode de connexion ou, dans le cas de créations de jetons explicites via l'API et sont une entrée pour la création de jetons <br>
--- **identity_policies** : ce champ indique les règles d'identité qui sont calculées en fonction de l'entité et de ses groupes

- Authentifions nous avec le nouveau token généré

```
vault login
```

Puis nous insérons le token : **hvs.YDQrLUABO76xFrwNC1PQC8EL**

- Révoquons le nouveau token créé

```
vault token revoke hvs.YDQrLUABO76xFrwNC1PQC8EL
```

Si nous essayons à nouveau de nous authentifier avec ce token révoqué, nous recevons le message :

```
# Résultat
Error authenticating: error looking up token: Error making API request.

URL: GET https://domain:8443/v1/auth/token/lookup-self
Code: 403. Errors:

* permission denied
```