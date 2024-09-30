# Garder les secrets secrets

Il est préférable de traiter les mots de passe et les données sensibles de manière spéciale, et il existe deux manières principales de le faire :
- soit utiliser un service de gestion des secrets distinct, tel que **Vault de HashiCorp**
- soit utiliser **Ansible Vault**, qui est intégré à Ansible et stocke les mots de passe chiffrés et autres données sensibles

**Ansible Vault** fonctionne un peu comme un coffre-fort réel :
- nous prenons n’importe quel fichier YAML situé à l'emplacement de notre playbook (par exemple un fichier de variables, des variables d’hôte, des variables de groupe, des variables par défaut de rôle ou même des inclusions de tâches !) et nous le stockons dans le coffre-fort
- ansible chiffre le coffre-fort à l’aide d’une clé (un mot de passe que nous définissons)
- nous stockons la clé (le mot de passe de notre coffre-fort) séparément du playbook dans un emplacement que nous seul contrôlons ou auquel nous pouvons accéder
- nous utilisons la clé pour permettre à ansible de déchiffrer le coffre-fort chiffré chaque fois que nous exécutons notre playbook


```
mkdir $HOME/display-api-key && mkdir $HOME/display-api-key/vars && cd $HOME/display-api-key
```

```
vim display-api-key-playbook.yml
```

```
---
- hosts: multi

  vars_files:
  - vars/api_key.yml

  tasks:
  - name: Echo the api key which was injected into the env
    shell: echo $API_KEY
    environment:
      API_KEY: "{{ app_api_key }}"
    register: result

  - name: Show the echo result
    debug: var=result.stdout
```

```
vi vars/api_key.yml
```

```
---
app_api_key: "thaCei4aaehaeS3iWei7oe9J"
```

Pour une sécurité optimale, utilisons **Ansible Vault** pour chiffrer le fichier avec par exemple le mot de passe : **test@test2024**

```
ansible-vault encrypt $HOME/display-api-key/vars/api_key.yml
```

Si nous vérifions le contenu de ce fichier, nous constaterons qu'elle est chiffrée

```
cat $HOME/display-api-key/vars/api_key.yml
```

Si nous exécutons notre playbook (avec l'option **--ask-vault-pass**), nous devrons fournir le mot de passe que nous avons utilisé pour le coffre-fort afin qu'Ansible puisse déchiffrer le playbook en mémoire pendant la brève période pendant laquelle il sera utilisé. Si nous ne spécifions pas le mot de passe, nous recevrons une erreur.

```
ansible-playbook --ask-vault-pass $HOME/display-api-key/display-api-key-playbook.yml
```

Nous pouvons modifier le fichier chiffré avec **ansible-vault edit**. Par exemple nous modifirons la variable **app_api_key** avec la nouvelle valeur **aefiePh2Fai3OhX6ohH5Soh3** .

```
ansible-vault edit $HOME/display-api-key/vars/api_key.yml
```

Nous pouvons également modifier la clé d'un fichier (modifier son mot de passe). Nous saisissons d'abord l'ancien mot de passe **test@test2024**, puis nous saisissons le nouveau mot de passe **test@test2025**.

```
ansible-vault rekey $HOME/display-api-key/vars/api_key.yml
```

Nous pouvons aussi créer un nouveau fichier, afficher un fichier existant ou déchiffrer un fichier.

Toutes ces commandes fonctionnent avec un ou plusieurs fichiers. Pour plus de commodité ou pour des exécutions automatisées de playbook (par exemple sur un serveur d'intégration continue), nous pouvons fournir des mots de passe de coffre-fort via un fichier de mots de passe. Tout comme les clés sécurisées dans notre dossier **∼/.ssh**, nous devons traiter ces fichiers avec sécurité: 
- ne les enregistrer jamais dans un système contrôle de source
- définir des autorisations strictes (par exemple **600**) pour que nous seul puissions lire ou écrire dans ce fichier

Créons le fichier **∼/.ansible/vault_pass.txt** avec pour contenu notre mot de passe **test@test2025** et pour autorisation **600**

```
vim ~/.ansible/vault_pass.txt
```

```
test@test2025
```

```
chmod 600 ~/.ansible/vault_pass.txt
```

Puis exécutons la commande **ansible-playbook** en indiquant l'emplacement de notre mot de passe vault avec l'option **--vault-password-file**


```
ansible-playbook --vault-password-file ~/.ansible/vault_pass.txt $HOME/display-api-key/display-api-key-playbook.yml
```