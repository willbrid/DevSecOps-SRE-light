# Api Rest [Part3]

Dans cette dernière partie, nous présentons un exemple complet d'utilisation des api rest de vault.

## Activons 3 instances du moteur de secret kv sur les paths **secrets-kv-X**, **secrets-kv-Y** et **secrets-kv-Z**

```
vault secrets enable -path=secrets-kv-X kv

vault secrets enable -path=secrets-kv-Y kv

vault secrets enable -path=secrets-kv-Z kv
```

## Créons une règle pour tous les chemins précédemment créés : CREATE, READ, DELETE

- Créons notre fichier de règle

```
vim XYZ.hcl
```

```
path "secrets-kv-X/*"{
    capabilities = ["create", "read", "delete"]
}
path "secrets-kv-Y/*"{
    capabilities = ["create", "read", "delete"]
}
path "secrets-kv-Z/*"{
    capabilities = ["create", "read", "delete"]
}
```

- Activons notre règle via le fichier **XYZ.hcl**

```
vault policy write XYZ XYZ.hcl
```

**XYZ** représente le nom de notre règle.

## Créons un token avec la règle créée précédemment et testons les appels d'API avec curl

- Créons un token et attribuons la règle nouvellement créée

```
vault token create -policy=XYZ -format=json | jq
```

```
# Résultat
{
  "request_id": "4a3dee0c-4065-5df2-9587-c16975ecc2a1",
  "lease_id": "",
  "lease_duration": 0,
  "renewable": false,
  "data": null,
  "warnings": null,
  "auth": {
    "client_token": "hvs.CAESIGtfCMGNcX23oGr7zNL-NNyEsMmKTmS3nB2Rthp83U7pGh4KHGh2cy5TVVA1cW81YU11TnZ1QWh2THE3SDRIVGo",
    "accessor": "pGqCZUtyO9I5YqJqGh5JV6aG",
    "policies": [
      "default",
      "xyz"
    ],
    "token_policies": [
      "default",
      "xyz"
    ],
    "identity_policies": null,
    "metadata": null,
    "orphan": false,
    "entity_id": "",
    "lease_duration": 2764800,
    "renewable": true,
    "mfa_requirement": null
  }
}
```

- Faisons les appels d'api pour créer les secrets kv **X**, **Y** et **Z** respectivement sur les paths **secrets-kv-X/X**, **secrets-kv-Y/Y**, **secrets-kv-Z/Z**

```
curl \
-H "Authorization: Bearer <TOKEN>" \
-H "Content-Type: application/json" \
-X POST \
-d '{"user1":"password1"}' \
https://notredomaine:8443/v1/secrets-kv-X/X | jq
```

```
curl \
-H "Authorization: Bearer <TOKEN>" \
-H "Content-Type: application/json" \
-X POST \
-d '{"user2":"password2"}' \
https://notredomaine:8443/v1/secrets-kv-Y/Y | jq
```

```
curl \
-H "Authorization: Bearer <TOKEN>" \
-H "Content-Type: application/json" \
-X POST \
-d '{"user3":"password3"}' \
https://notredomaine:8443/v1/secrets-kv-Z/Z | jq
```

Ici **TOKEN** représente le champ **auth.client_token** dans le résultat de la commande de création de token.

- Faisons les appels d'api pour afficher les secrets nouvellement créés

```
curl -H "Authorization: Bearer <TOKEN>" \
https://notredomaine:8443/v1/secrets-kv-X/X | jq
```

```
curl -H "Authorization: Bearer <TOKEN>" \
https://notredomaine:8443/v1/secrets-kv-Y/Y | jq
```

```
curl -H "Authorization: Bearer <TOKEN>" \
https://notredomaine:8443/v1/secrets-kv-Z/Z | jq
```

- Faisons un appel d'api pour supprimer le secret **Z** sur le path **secrets-kv-Z/Z**

```
curl -H "Authorization: Bearer <TOKEN>" --request DELETE https://notredomaine:8443/v1/secrets-kv-Z/Z | jq
```

- Faisons un appel d'api pour essayer à nouveau d'afficher le secret nouvellement supprimé

```
curl -H "Authorization: Bearer <TOKEN>" \
https://notredomaine:8443/v1/secrets-kv-Z/Z | jq
```

Nous constatons que rien ne s'affiche car le secret **Z** a été supprimé.