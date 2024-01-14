# Création de groupes d'utilisateurs

Il est important de choisir comment nous souhaitons gérer les utilisateurs dans Zabbix avant de configurer les comptes d'utilisateurs. Si nous souhaitons utiliser quelque chose comme LDAP ou SAML, c'est une bonne idée de choisir d'utiliser immédiatement l'une de ces méthodes d'authentification, de sorte que nous n'aurons aucun problème de migration.
<br>
Ainsi, la direction des opérations a certains départements qui ont besoin d'accéder à l'interface Zabbix et d'autres qui n'en ont pas du tout besoin. Disons que nous voulons donner aux départements suivants l'accès à l'interface Zabbix :
- **Networking** : pour configurer et surveiller leurs périphériques réseau
- **Infrastructure** : pour configurer et surveiller leurs serveurs Linux
- **IT** : pour configurer et surveiller leurs applications, base de données, système de fil d'attente

Commençons par créer ces trois groupes dans notre interface utilisateur Zabbix.

- Pour ce faire, accédez à **Administration > Groupes d'utilisateurs**

- Commençons par créer le groupe de **Networking** en cliquant sur **Create user group** dans le coin supérieur droit. <br>
Nous devrons remplir les informations, en commençant par le nom du groupe, qui sera bien sûr **Networking** . Il n'y a pas encore d'utilisateurs pour ce groupe, nous allons donc ignorer celui-ci. L'accès frontal est la possibilité de nous fournir une authentification ; si nous sélectionnons LDAP ici, l'authentification LDAP sera utilisée pour l'authentification. Nous le conserverons comme **System default**, qui est l'authentification interne de Zabbix.

- Passons maintenant à l'onglet suivant de cette page, qui est **Template Permissions**: Ici, nous pouvons spécifier à quels groupes de modèles notre groupe aura accès. Il existe déjà un groupe de modèles par défaut pour **Networking**, que nous utiliserons.

- Cliquons sur **Select** pour accéder à une fenêtre contextuelle avec les groupes de modèles disponibles. Sélectionnons **Templates/Network devices** ici et cela nous ramènera à la fenêtre précédente, avec le groupe rempli.

- Sélectionnons **Read-write** et cliquons sur le bouton **Add** en plus petit texte pour ajouter ces autorisations.

- Nous n'ajouterons rien d'autre, alors cliquons sur le plus gros bouton bleu **Add** pour terminer la création de ce groupe d'hôtes.

- Répétons ce processus pour le groupe d'hôtes **Infrastructure**, en ajoutant le groupe de modèles **Templates/Operating systems** depuis l'onglet **Template Permissions** et nous ajouterons aussi le groupe d'hôtes **Linux servers** depuis l'onglet **Host Permissions**.

- Répétons ce processus pour le groupe d'hôtes **IT** en ajoutant les groupes de modèles **Templates/Applications** et **Templates/Databases** depuis l'onglet **Template Permissions** et nous ajouterons aussi les groupes d'hôtes **Applications** et **Databases** depuis l'onglet **Host Permissions**.