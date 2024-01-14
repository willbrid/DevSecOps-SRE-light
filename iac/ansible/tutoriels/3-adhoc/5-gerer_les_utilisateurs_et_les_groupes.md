# Gérer les utilisateurs et les groupes

Les modules user et group d'Ansible rendent la configuration des utilisateurs et des groupes assez simples et standard pour toutes les versions de Linux.

- commençons par ajouter un groupe d'administrateurs sur les serveurs d'applications pour les administrateurs de serveur

```
ansible app -b -m group -a "name=admin state=present"
```

Nous pouvons supprimer un groupe en définissant **state=absent** , définir un identifiant de groupe avec **gid=[gid]** et indiquer que le groupe est un groupe système avec **system=yes** .
<br>

- ajoutons maintenant l'utilisateur johndoe aux serveurs d'applications dans le groupe **admin** et donnons-lui un dossier personnel dans **/home/johndoe**

```
ansible app -b -m user -a "name=johndoe group=admin createhome=yes"
```

Si nous souhaitons créer automatiquement une clé SSH pour le nouvel utilisateur (si elle n'existe pas déjà), nous pouvons exécuter la même commande avec le paramètre supplémentaire **generate_ssh_key=yes** .

```
ansible app -b -m user -a "name=johndoe group=admin createhome=yes generate_ssh_key=yes"
```

Nous pouvons également définir : <br>
--- L'UID de l'utilisateur avec **uid=[uid]** <br>
--- Le shell de l'utilisateur avec **shell=[shell]** <br>
--- Le mot de passe des utilisateurs avec **password=[encrypted-password]**
<br>

- supprimons le compte johndoe
```
ansible app -b -m user -a "name=johndoe state=absent remove=yes"
```