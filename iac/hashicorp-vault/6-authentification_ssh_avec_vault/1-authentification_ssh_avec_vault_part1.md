# Authentification SSH avec Vault [Part1]

Nous commencerons la série sur l'authentification auprès d'un serveur SSH à partir d'un client en utilisant les informations d'identification fournies par HashiCorp Vault.
<br>
Nous aurons besoin 3 instances de machine virtuelle, donc l'une sera le serveur HashiCorp Vault (ce que nous utilisons déjà et qui est sous un système Rocky Linux 8), l'autre sera le client (sous un système Rocky Linux 8) et la troisième (sous un système ubuntu 20.04) sera celle sur laquelle le serveur SSH est opérationnel.
<br>
Dans cette partie nous allons configurer les préréquis sur notre serveur vault.

- Activons notre moteur de secret SSH

```
vault secrets enable ssh
```

- Créeons un rôle **otp_role** de type **otp** avec pour utilisateur par défaut **ubuntu** et pour plage d'adresse source **0.0.0.0/0**

```
vault write ssh/roles/otp_role key_type=otp default_user=ubuntu cidr_list=0.0.0.0/0
```

- Créons et appliquons une règle pour notre role **otp_role** sur le path **ssh/creds/otp_role**

```
vim ssh_otp_role_policy.hcl
```

```
path "ssh/creds/otp_role" {
    capabilities = ["create", "read", "update"]
}
```

```
vault policy write ssh_otp_role_policy ssh_otp_role_policy.hcl
```

- Activons l'authentification **userpass**

```
vault auth enable userpass
```

- Créons un utilisateur **willbrid** avec pour mot de passe **12345678** avec les droits de la règle **ssh_otp_role_policy**

```
vault write auth/userpass/users/willbrid password="12345678" policies="ssh_otp_role_policy"
```