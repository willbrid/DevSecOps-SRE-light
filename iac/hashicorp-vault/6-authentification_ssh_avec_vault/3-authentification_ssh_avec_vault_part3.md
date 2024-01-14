# Authentification SSH avec Vault [Part3]

- Depuis notre serveur vault, authentifions nous avec notre utilisateur **willbrid** et notre mot de passe **12345678**

```
vault login -method=userpass username=willbrid password=12345678
```

```
# Resultat
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                    Value
---                    -----
token                  hvs.CAESILFyrAAqphEp4CI_c3zhjOpGOFTeYH_bU_rXNXxJirxYGh4KHGh2cy43bnk5akhFeFcwOE53eUhEajEwSnN6cmQ
token_accessor         5373NIxuNSiAhPya8uZf4o6o
token_duration         768h
token_renewable        true
token_policies         ["default" "ssh_otp_role_policy"]
identity_policies      []
policies               ["default" "ssh_otp_role_policy"]
token_meta_username    willbrid
```

- Depuis le serveur ssh ubuntu, créons le repertoire **/home/ubuntu** de notre utilisateur **ubuntu**

```
sudo mkdir /home/ubuntu
```

```
sudo chown -R ubuntu:ubuntu /home/ubuntu
```

- Depuis notre serveur vault créons un mot de passe à usage unique pour notre utilisateur **ubuntu**

```
vault write ssh/creds/otp_role ip=<@IP_UBUNTU>
```

```
# Resultat
Key                Value
---                -----
lease_id           ssh/creds/otp_role/8ZuQaQIrZ5qQMBW3RuuRy1SZ
lease_duration     768h
lease_renewable    false
ip                 <IP_UBUNTU>
key                2449ef59-5e0f-4f77-4f19-22ffc1116211
key_type           otp
port               22
username           ubuntu
```

- Depuis notre serveur client ssh sous Rocky linux, connectons nous à notre serveur ubuntu via ssh en utilisant notre mot de passe généré (champ **key** dans le resultat ci-dessus)

```
ssh ubuntu@<IP_UBUNTU>
```

Si tout se passe, nous serons logué.