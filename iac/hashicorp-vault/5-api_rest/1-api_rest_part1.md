# Api Rest [Part1]

L'API HTTP Vault nous donne un accès complet à Vault en utilisant REST comme des verbes HTTP. Chaque aspect de Vault peut être contrôlé à l'aide des API. L'interface de ligne de commande Vault utilise l'API HTTP pour accéder à Vault comme tous les autres consommateurs.

- Installons **jq** l'utilitaire de traitement des sorties en json

```
sudo yum install epel-release -y
sudo yum install jq
```

Nous vérifions si **jq** est bien installé.

```
jq --version
```

- Consommons l'api **/v1/sys/init**

```
curl -H "Authorization: Bearer hvs.oYcFoZDwF595Zi5hUHGdemO9" https://notredomaine:8443/v1/sys/init | jq '.'
```

```
# Résultat
{
  "initialized": true
}
```