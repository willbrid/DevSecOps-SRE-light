# Authentification SSH avec Vault [Part2]

## Configuration du firewall de notre serveur vault

Nous allons autoriser le port **tcp/8443** de notre serveur vault dans la zone publique de notre pare-feu firewalld.

```
sudo firewall-cmd --zone=public -add-port=8443/tcp --permanent
```

```
sudo firewall-cmd reload
```

## Configuration de notre serveur ssh ubuntu 

- Installons **vault-ssh-helper** version **0.2.1**

```
cd ~
wget https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip
```

- Ajoutons un utilisateur **ubuntu** avec son mot de passe **password**

```
sudo useradd ubuntu
```

```
sudo passwd ubuntu
```

- Dézippons le binaire **vault-ssh-helper** dans le répertoire **/usr/local/bin/**

```
sudo unzip -q vault-ssh-helper_0.2.1_linux_amd64.zip -d /usr/local/bin/
```

Pour vérifier la résultat, consultons le contenu du répertoire **/usr/local/bin/**

```
ls -l /usr/local/bin/
```

Supprimons notre fichier zip **vault-ssh-helper_0.2.1_linux_amd64.zip** qui n'est plus nécessaire
```
rm vault-ssh-helper_0.2.1_linux_amd64.zip
```

- Appliquons les autorisations **0755** sur le fichier binaire **vault-ssh-helper**

```
sudo chmod 0755 /usr/local/bin/vault-ssh-helper
```

- Si ce n'est pas le cas, changeons l'utilisateur et le groupe propriètaire du fichier binaire **vault-ssh-helper** en **root:root**

```
sudo chown root:root /usr/local/bin/vault-ssh-helper
```

- Créons le répertoire de configuration du binaire **vault-ssh-helper** et son fichier de configuration **config.hcl**

```
sudo mkdir /etc/vault-ssh-helper.d
```

```
sudo vim /etc/vault-ssh-helper.d/config.hcl
```

```
vault_addr = "https://notredomaine:8443"
ssh_mount_point = "ssh"
allowed_roles = "*"
```

Le champ **vault_addr** permet d'indiquer l'adresse du serveur vault.

- Configurons le fichier **/etc/pam.d/sshd** la prise en charge vault avec l'authentification pam ssh

```
sudo vim /etc/pam.d/sshd
```

```
# @include common-auth
auth requisite pam_exec.so quiet expose_authtok log=/var/log/vault-ssh.log /usr/local/bin/vault-ssh-helper -config=/etc/vault-ssh-helper.d/config.hcl
auth optional pam_unix.so not_set_pass use_first_pass nodelay
```

- Configurons le fichier **/etc/ssh/sshd_config** afin d'activer l'authentification via vault


```
sudo vim /etc/ssh/sshd_config
```

```
PasswordAuthentication no
ChallengeResponseAuthentication yes
UsePAM yes
```

Les lignes ci-dessus sont déjà présentes et elles doivent avoir cette configuration.

```
sudo systemctl restart ssh
```

- Vérifions nos configurations avec le binaire **vault-ssh-helper**

```
vault-ssh-helper -verify-only -config /etc/vault-ssh-helper.d/config.hcl
```

```
# Resultat
[INFO] using SSH mount point: ssh
[INFO] using namespace: 
[INFO] vault-ssh-helper verification successful!
```