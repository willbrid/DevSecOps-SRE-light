# Configurer les serveurs et clients SSH

En tant qu'administrateur système Linux, nous utilisons probablement SSH quotidiennement pour nous connecter à nos systèmes. Nous devrons nous assurer que nos systèmes sont sûrs et correctement accessibles. **Secure Shell** est le protocole d'accès à distance standard utilisé par les administrateurs système Linux pour se connecter à des serveurs partout dans le monde.

- Fichiers de configuration SSH

--- fichier de configuration du serveur à l'échelle du système

```
/etc/ssh/sshd_config
```

--- fichier de configuration du client à l'échelle du système

```
/etc/ssh/ssh_config
```

--- fichier de configuration client spécifique à l'utilisateur

```
~/.ssh/config
```

- Génération et partage de clés SSH depuis notre serveur **rocky-server**

Utilisons la commande **ssh-keygen** pour créer une paire de clés sans mot de passe

```
ssh-keygen
```

Ici on accepte le nom par défaut du fichier de clé **/home/vagrant/.ssh/id_rsa** et on valide. Les 2 fichiers **id_rsa** (clé privée à ne pas partager) et **id_rsa.pub** (clé publique) seront créés.

Désactivons l'authentification ssh par mot de passe sur notre serveur **rocky-server**

```
sudo vi /etc/ssh/sshd_config
```

```
...
PasswordAuthentication no
...
```

```
sudo systemctl restart sshd
```

Copions la clé publique depuis notre serveur **rocky-server** vers notre serveur **ubuntu-server**

```
ssh-copy-id vagrant@192.168.56.111
```

Nous pouvons aussi utiliser la commande longue

```
cat ~/.ssh/id_rsa.pub | ssh vagrant@192.168.56.111 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Connectons nous en ssh au serveur **rocky-server** depuis notre serveur **ubuntu-server**

```
ssh vagrant@192.168.56.110
```

Nous constaterons qu'aucun mot de passe nous sera demandé.