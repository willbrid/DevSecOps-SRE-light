# Ecriture et test des règles ACL [Exemple2]

- Ecrivons une règle d'ACL d'autorisation **update** sur les données de kubernetes sur le path **datacenter1/data/kubernetes**

```
vim kubernetespolicy_update.hcl
```

```
path "datacenter1/data/kubernetes"
{
    capabilities = ["update"]
}
```

- Loguons nous avec le token root

```
vault login
```

- Chargeons cette règle d'ACL nouvellement créée

```
vault policy write kubernetespolicy_update kubernetespolicy_update.hcl
```

- Créons un token associé à cette règle d'ACL **kubernetespolicy_update**

```
vault token create -policy="kubernetespolicy_update"
```

```
# Résultat
Key                  Value
---                  -----
token                hvs.CAESICGikFXGRHZcccP--a7blMb8f5zBegfaZ7kacdoeRD_LGh4KHGh2cy5jNlVhNjBGRGJKa1VQVXEwQmo5ZXltY3c
token_accessor       EcarEUCOcVcRNyKQPmTndEGd
token_duration       768h
token_renewable      true
token_policies       ["default" "kubernetespolicy_update"]
identity_policies    []
policies             ["default" "kubernetespolicy_update"]
```

- Loguons nous avec le token (champ token) associé à notre règle

```
vault login
```

- Afficher les autorisations de notre token sur le path **datacenter1/data/kubernetes**

```
vault token capabilities datacenter1/data/kubernetes
```

```
# Résultat
update
```

- Essayons d'afficher le secret kv (key: user, value: willbrid) sur le path **datacenter1/data/kubernetes**

```
vault kv get datacenter1/data/kubernetes
```

Nous constatons que nous n'avons pas le droit de lecture sur le path **datacenter1/data/kubernetes** puisque notre token est associé à notre règle **kubernetespolicy_update** qui autorise uniquement les mises à jour sur notre path **datacenter1/data/kubernetes**.

- Mettons à jour notre secret kv (donnée initiale {key: user, value: willbrid}, nouvelle donnée {key: user, value: willbrid1}) sur le path **datacenter1/data/kubernetes**

```
vault kv put datacenter1/data/kubernetes user=willbrid1
```

- Loguons nous avec le token root et affichons les données du path **datacenter1/data/kubernetes**

```
vault login
```

```
vault kv get datacenter1/data/kubernetes
```

```
# Résultat
==== Data ====
Key     Value
---     -----
user    willbrid1
```

Nous constatons que la clé **user** a été mise à jour.