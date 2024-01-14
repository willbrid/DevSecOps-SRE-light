# Authentification login et Mot de passe

- Activons l'authentification par login et mot de passe

```
vault auth enable userpass
```

```
# Résultat
Success! Enabled userpass auth method at: userpass/
```

- Créons un utilisateur **willbrid** avec son mot de passe

```
vault write auth/userpass/users/willbrid password=123Test
```

```
# Résultat
Success! Data written to: auth/userpass/users/willbrid
```

- Authentifions nous avec notre nouvel utilisateur (**willbrid**) créé

```
vault login -method=userpass username=willbrid password=123Test
```

```
# Résultat
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                    Value
---                    -----
token                  hvs.CAESILeoIovNqVIVc942m_577WhdnbAdc3SRDxUH-tlALO-nGh4KHGh2cy4yUWVoZW9BTE9kb0hJWnEzNTRjZTdXUm8
token_accessor         yh1GX7KrMG3ICkPm5TaEqUfT
token_duration         768h
token_renewable        true
token_policies         ["default"]
identity_policies      []
policies               ["default"]
token_meta_username    willbrid
```