# Création d'utilisateurs

Nous allons ici affecter certains utilisateurs aux groupes d'utilisateurs nouvellement (**Networking**, **Infrastructure**, **IT**) créés pour s'assurer qu'ils reçoivent nos nouvelles autorisations d'utilisateur du groupe.
<br>
Commençons à créer les utilisateurs. Nous allons commencer par notre département **Networking**.

- Accédons à la page **Administration > Users**

- Pour créer notre premier utilisateur du département **Networking** nommé **a_network** , cliquons sur le bouton **Create user** dans le coin supérieur droit.

- Remplissons le champ **username** pour nous fournir le nom d'utilisateur que cet utilisateur utilisera, qui sera **a_network** .

- Cliquons sur **Select** et choisissons notre groupe appelé **Networking** .

- Enfin et surtout, définissons un mot de passe sécurisé dans les champs Mot de passe : **passworda1**

- Après cela, passons à l'onglet **Permissions** 

- Sélectionnons l'option **Role** nommée **Super admin role** ici. Cela permettra à notre utilisateur d'accéder à tous les éléments de l'interface utilisateur et de voir et de modifier les informations sur tous les groupes d'hôtes du serveur Zabbix. 

- Enfin nous enregistrons avec le bouton **Add**

- Répétons les étapes précédentes pour l'utilisateur nommé **b_network** mais dans l'onglet **Permissions**, sélectionnons l'option **Admin role**. Mot de passe: **passwordb1**

- Après avoir créé ces deux utilisateurs, passons à la création de l'utilisateur du département **Infrastructure** : **a_infra** (mot de passe : **passworda2**). Répétons les étapes que nous avons suivies pour **s_network**, en changeant le nom d'utilisateur, bien sûr. Ensuite, ajoutons cet utilisateur au groupe et donnons à notre utilisateur les bonnes autorisations. Cliquons sur **Select** et choisissons notre groupe appelé **Infrastructure**. Enfin, faisons de cet utilisateur un autre super administrateur.

- Après avoir créé ces trois utilisateurs, passons à la création de l'utilisateur du département **IT** : **a_it** (mot de passe : **passworda3**). Répétons les étapes que nous avons suivies pour **s_network**, en changeant le nom d'utilisateur, bien sûr. Ensuite, ajoutons cet utilisateur au groupe et donnons à notre utilisateur les bonnes autorisations. Cliquons sur **Select** et choisissons notre groupe appelé **IT**. Enfin, ajoutons à cet utilisateur le rôle **user-plus-role**.

Pour tester nos configurations, nous pouvons nous connecter avec ces différents utilisateurs.