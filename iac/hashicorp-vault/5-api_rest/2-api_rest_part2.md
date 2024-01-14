# Api Rest [Part2]

- Définissons un payload post pour la création d'un token root

```
vi payload.json
```

```
{
    "policies": ["root"],
    "meta": {
        "user": "test-user"
    },
    "ttl": "1h",
    "renewable": true
}
```

- Consommons l'api **/v1/auth/token/create** en POST pour créer notre token

```
curl -H "Authorization: Bearer hvs.oYcFoZDwF595Zi5hUHGdemO9" --request POST --data @payload.json https://notredomaine:8443/v1/auth/token/create | jq '.'
```

```
# Résultat
{
  "request_id": "b440e8f2-d598-bc16-e68f-7b28aebf3755",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": null,
  "wrap_info": null,
  "warnings": [
    "Endpoint ignored these unrecognized parameters: [meta]"
  ],
  "auth": {
    "client_token": "hvs.7rcWtQ7pYFetIc43AAUinGVI",
    "accessor": "0MC354AT2cMEBnjpANUZzYQt",
    "policies": [
      "root"
    ],
    "token_policies": [
      "root"
    ],
    "metadata": {
      "user": "test-user"
    },
    "lease_duration": 3600,
    "renewable": true,
    "entity_id": "",
    "token_type": "service",
    "orphan": false,
    "mfa_requirement": null,
    "num_uses": 0
  }
}
```

- Consommons l'api **/v1/auth/token/lookup-self** en GET pour afficher les informations en détail de notre token (champ **client_token** dans les résultats) nouvellement créé

```
curl -X GET -H "Authorization: Bearer hvs.7rcWtQ7pYFetIc43AAUinGVI" https://notredomaine:8443/v1/auth/token/lookup-self | jq '.'
```

```
# Résultat
{
  "request_id": "ad606f83-ffc2-3c31-e3f8-78fe9032e227",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": {
    "accessor": "0MC354AT2cMEBnjpANUZzYQt",
    "creation_time": 1680420940,
    "creation_ttl": 3600,
    "display_name": "token",
    "entity_id": "",
    "expire_time": "2023-04-02T08:35:40.185559241Z",
    "explicit_max_ttl": 0,
    "id": "hvs.7rcWtQ7pYFetIc43AAUinGVI",
    "issue_time": "2023-04-02T07:35:40.185569261Z",
    "meta": {
      "user": "test-user"
    },
    "num_uses": 0,
    "orphan": false,
    "path": "auth/token/create",
    "policies": [
      "root"
    ],
    "renewable": true,
    "ttl": 3046,
    "type": "service"
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
```

- Définissons un payload policy post pour la création de la règle **dev** d'écriture de secret sur le path **secret**

```
vi payloadpolicy.json
```

```
{
    "policy": "{\"name\": \"dev\", \"path\": {\"secret/*\": {\"policy\": \"write\"}}}"
}
```

- Consommons l'api **/v1/sys/policy/dev** en POST pour créer notre règle **dev**

```
curl -H "Authorization: Bearer hvs.7rcWtQ7pYFetIc43AAUinGVI" --request POST --data @payloadpolicy.json https://notredomaine:8443/v1/sys/policy/dev | jq '.'
```

- Consommons l'api **/v1/sys/policy/dev** en GET pour afficher les détails de notre règle **dev** créée

```
curl -X GET -H "Authorization: Bearer hvs.7rcWtQ7pYFetIc43AAUinGVI" https://notredomaine:8443/v1/sys/policy/dev | jq '.'
```

```
# Résultat
{
  "name": "dev",
  "rules": "{\"name\": \"dev\", \"path\": {\"secret/*\": {\"policy\": \"write\"}}}",
  "request_id": "53f45447-ebfe-b744-1ac3-57ea00bc6833",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": {
    "name": "dev",
    "rules": "{\"name\": \"dev\", \"path\": {\"secret/*\": {\"policy\": \"write\"}}}"
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
```