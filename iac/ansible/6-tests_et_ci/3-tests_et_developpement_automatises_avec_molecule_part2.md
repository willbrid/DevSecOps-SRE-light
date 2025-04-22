# Tests et développement automatisés avec Molecule [Part2]

Cette section est dédiée à l’utilisation de Molecule pour tester un rôle Ansible simple, chargé de créer un ou plusieurs utilisateurs sur les distributions **Debian** ou **RedHat**.

### Création du rôle ansible-role-user

```
ansible-galaxy role init ansible-role-user
```

Nous supposerons que le contenu du rôle est déjà fourni ([ansible-role-user](./examples/ansible-role-user/)).

### Utilisation de molecule pour tester notre rôle ansible-role-user

Molecule fonctionne avec des scénarios, qui sont des configurations définies par l’utilisateur pour tester un rôle Ansible. Chaque scénario décrit comment créer l’environnement de test, exécuter les tâches, et valider le comportement du rôle. Cela permet de tester un même rôle dans plusieurs contextes ou configurations. Un scénario par défaut nommé **default** est automatiquement proposé, et peut être généré à l’aide de la commande suivante au niveau du repertoire de notre rôle **ansible-role-user** :

```
molecule init scenario --driver-name docker
```

Ici nous utilisons le pilote (**driver**) **docker** qui permettra d'exécuter nos tests via un conteneur **docker**.

Dans le dossier **molecule/default**, nous trouvons 2 fichiers :
- **molecule.yml** est le point d'entrée central de la configuration de **Molecule** par scénario. Ce fichier nous permet de configurer chaque outil utilisé par Molecule pour tester notre rôle.
- **converge.yml** est le fichier playbook contenant l'appel de notre rôle. **Molecule** invoquera ce playbook avec **ansible-playbook** et l'exécutera sur une instance créée par le pilote.

Dans un fichier **molecule.yml**, nous pouvons avoir :
- **dependency** : **molecule** utilise le guide de développement Galaxy par défaut pour résoudre les dépendances de nos rôles.
- **driver** : **molecule** utilise le pilote **Delegated** par défaut. Molecule l'utilise pour déléguer la création des instances.
- **platforms** : **molecule** s'appuie sur ces informations pour savoir quelles instances créer, nommer et à quel groupe elles appartiennent. Si nous devons tester votre rôle sur plusieurs distributions populaires (CentOS, Fedora, Debian), nous pouvons le spécifier dans cette section.
- **provisioner** : **molecule** fournit uniquement un provisionneur **Ansible**. **Ansible** gère le cycle de vie de l'instance en fonction de cette configuration.
- **scenario** : **molecule** s'appuie sur cette configuration pour contrôler l'ordre de séquence des scénarios.
- **verifier** : **molecule** utilise **Ansible** par défaut pour fournir un moyen d'écrire des tests de vérification d'état spécifiques (tels que des tests de fumée de déploiement) sur l'instance cible.

Une fois les fichiers **molecule.yml** et **converge.yml** correctement configurés, nous pouvons exécuter la commande suivante afin de vérifier que Molecule crée correctement l’environnement de test et exécute le playbook intégrant notre rôle.

```
molecule converge
```

Nous configurons ensuite notre fichier **verify.yml** qui permettra de valider le résultat d'exécution de notre rôle via notre playbook défini dans le fichier **converge.yml**.

```
molecule verify
```

Si les deux commandes ci-dessous se sont exécutées avec succès, nous pouvons alors lancer la commande complète permettant d’exécuter l’ensemble des scénarios.

```
molecule test
```