# Installation et configuration de vault [PART4]

Nous installerons et configurerons **vault 1.18.0** sur notre serveur **vault-server**.

1. **Installation**

```
sudo yum install -y yum-utils
```

```
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
```

```
sudo yum -y install vault-1.18.0
```

Pour vérifier si vault est bien installé, nous exécutons :

```
vault -h
```

2. **Elements préconfigurés lors de l'installation de vault**

L'installation de **vault** sur le serveur **vault-server** créera :
- son repertoire de configuration **/etc/vault.d**
- son fichier de configuration **/etc/vault.d/vault.hcl**
- son fichier service systemd  **/usr/lib/systemd/system/vault.service**
- son repertoire de certificat **/opt/vault/tls/** contenant les fichiers par défaut **tls.crt** et **tls.key**
- son repertoire de données **/opt/vault/data** mais qui ne sera pas utilisé puisque **consul** sera utilisé

2. **Configuration**

Effectuons le backup du fichier de configuration par défaut

```
sudo mv /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.backup
```

Editons le fichier de configuration **/etc/vault.d/vault.hcl**

```
sudo vi /etc/vault.d/vault.hcl
```

```
ui = true

storage "consul" {
  address = "192.168.56.70:8500"
  path    = "vault/"
}

api_addr = "https://vault.willbrid.com:8200"

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/willbrid.com.crt"
  tls_key_file  = "/opt/vault/tls/willbrid.com.key"
}
```

Démarrons et activons **vault**

```
sudo systemctl enable --now vault
```

Nous pouvons vérifier le statut de ce service :

```
sudo systemctl status vault
```

Nous pouvons aussi consulter les logs de **vault** via **journalctl**

```
sudo journalctl -f -u vault
```

Autorisation du port d'accès ui 8200 de **vault**

```
sudo firewall-cmd --permanent --add-port=8200/tcp
sudo firewall-cmd --reload
```

Configurons de manière permanente la variable d'environnement **VAULT_ADDR**

```
export VAULT_ADDR="https://vault.willbrid.com:8200"
echo "export VAULT_ADDR=https://vault.willbrid.com:8200" >> ~/.bashrc
```

Consultons le statut du cluster **vault**

```
vault status
```

### Initialisation du cluster vault

Initialisons un cluster vault

```
vault operator init
```

Si tout se passe bien, aucune erreur ne sera affichée.

Nous pouvons réinitialiser la configuration de notre cluster **vault** :

```
sudo systemctl stop vault
consul kv delete -recurse vault/
sudo systemctl start vault
vault operator init
```

L'argument **kv** de la commande **consul** permet d'nteragir avec son magasin **clé-valeur**. Avec son argument **delete** et son option **-recurse** (de l'argument **delete**), il permet de supprimer de manière récursive un magasin **clé-valeur** précisé en argument (**vault/**).

Nous aurons en sortie :

```
Unseal Key 1: BJeEhkVMjR39RGo4C2X6gQyMew5ufDcalp8F3UWLq9jA
Unseal Key 2: hkriOJpkbUHt2uhXWrvFjZ0kjCWS8WESCu4G353eIs+I
Unseal Key 3: Kz6UT4caGE5IexpwuZWuf9MSsQRdEuAEpIADEFlWMuZl
Unseal Key 4: DqPVn3J4Vmt2L73Sf274xfDG/yyT7A79/TfnTrfF0hkn
Unseal Key 5: 6c6cY920kRvpVlAJ9iQxoL7yAD8CmFyg+F/K5y8I8lBj

Initial Root Token: hvs.oYcFoZDwF595Zi5hUHGdemO9
```

Installons la saisie semi-automatique pour les commandes Vault.

```
vault -autocomplete-install
```

Activons après cette installation l'autocompletion.

```
complete -C /usr/bin/vault vault
```

### Descellement manuel des clés

Après avoir éxécuté la commande **vault operator init**, nous obtenons dans le résultat le message : 

```
Vault does not store the generated root key. Without at least 3 keys to
reconstruct the root key, Vault will remain permanently sealed!

# Vault ne stocke pas la clé racine générée. Sans au moins 3 clés pour
reconstruire la clé racine, Vault restera définitivement scellé !
```

Nous devons desceller au moins 3 clés (issus du résultat de la commande **vault operator init**) avec la commande :

```
vault operator unseal valeurCle
```

Pour tester nos configurations, nous pouvons nous connecter au service vault à l'aide du jeton **root** fourni à la sortie du résultat de la commande **vault operator init**:

```
vault login <JETON_RACINE>
```

Si tout se passe bien, nous verrons le message de succès.

<br>

**NB :** En perpectives, Descellement automatique des clés