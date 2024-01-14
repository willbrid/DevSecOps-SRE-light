# Ecriture et test des règles ACL [Exemple1]

- Activons un secret kv sur le path **datacenter1**

```
vault secrets enable -path=datacenter1/ kv
```

- Ecrivons une règle d'ACL d'autorisation **create** et **read** sur les données de kubernetes sur le path **datacenter1/data/kubernetes**

```
vim kubernetespolicy.hcl
```

```
path "datacenter1/data/kubernetes"
{
    capabilities = ["create", "read"]
}
```

- Chargeons cette règle d'ACL nouvellement créée

```
vault policy write kubernetespolicy kubernetespolicy.hcl
```

L'argument **policy** de la commande **vault** avec son argument **write** permet de charger une règle d'ACL.
<br> 
**kubernetespolicy** : est le nom donnée à notre règle d'ACL.<br>
**kubernetespolicy.hcl** : le fichier contenant la règle à charger

- Créons un token associé à cette règle d'ACL **kubernetespolicy**

```
vault token create -policy="kubernetespolicy"
```

```
# Résultat
Key                  Value
---                  -----
token                hvs.CAESIPlUg6WCjCj3DYjRTXoAsfkx98gzQ6lrsnQI9WVp-IwNGh4KHGh2cy5hZ0VuYzd4Sm9KTjdtNG9VQWd0cVBvTWo
token_accessor       TjCs8hevzI8B5gEvjHN0ylhz
token_duration       768h
token_renewable      true
token_policies       ["default" "kubernetespolicy"]
identity_policies    []
policies             ["default" "kubernetespolicy"]
```

Nous constatons au niveau du champ **policies**, les règles **default** et **kubernetespolicy**.

- Loguons nous avec le token (champ token) associé à notre règle

```
vault login
```

- Essayons de créer un secret kv (key: user, value: willbrid) sur le path **datacenter1/server**

```
vault kv put datacenter1/server user=willbrid
```

Nous constatons que nous n'avons pas le droit d'écriture sur le path **datacenter1/server** puisque notre token est associé au path **datacenter1/data/kubernetes** de notre règle **kubernetespolicy**.

- Essayons de créer un secret kv (key: user, value: willbrid) sur le path **datacenter1/data/kubernetes**

```
vault kv put datacenter1/data/kubernetes user=willbrid
```

```
# Résultat
Success! Data written to: datacenter1/data/kubernetes
```

- Affichons notre secret kv nouvellement créé

```
vault kv get datacenter1/data/kubernetes
```

```
==== Data ====
Key     Value
---     -----
user    willbrid
```

- Nous pouvons afficher les autorisations de notre token sur le path **datacenter1/data/kubernetes**

```
vault token capabilities datacenter1/data/kubernetes
```

```
# Résultat
create, read
```