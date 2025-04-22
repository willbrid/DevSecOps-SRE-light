# Tests et développement automatisés avec Molecule [Part1]

**https://ansible.readthedocs.io/projects/molecule/**

Avant pour tester un playbook il fallait effectuer les opérations suivantes à chaque fois :
- Créer une nouvelle VM
- Configurer SSH pour pouvoir m'y connecter
- Configurer un inventaire pour que le playbook se connecte à la VM
- Exécuter mon playbook Ansible sur la VM
- Tester et valider son bon fonctionnement
- Supprimer la VM

De nos jours, nous avons **molecule**. En effet **molecule** est un outil léger, basé sur Ansible, qui facilite le développement et les tests de playbooks, rôles et collections Ansible. À sa base, **molecule** effectue les six étapes décrites ci-dessus et ajoute des fonctionnalités supplémentaires comme des scénarios multiples, des backends multiples et des méthodes de vérification configurables. Aussi tout dans **molecule** est contrôlé par des playbooks Ansible.

- Installer **molecule** via pipx sous Ubuntu 24.04

```
pipx install molecule
```

- Installer les drivers molecule via pipx sous Ubuntu 24.04

```
pipx inject molecule molecule-plugins
```

Pour vérifier si nos drivers sont présents, nous exécutons la commande :

```
molecule drivers
```

```
# Résultats
gce
containers
azure
default
vagrant
ec2
podman
openstack
docker
```

- Injecter le package **requests** nécessaire pour interroger la socket **docker**

```
pipx inject ansible-core requests
```

### Exécution de notre playbook en mode vérification

L'option **--check** d'Ansible permet d'exécuter un playbook sans appliquer de modifications, en indiquant les tâches qui entraîneraient un changement. Cela aide à détecter les dérives de configuration et à s'assurer que les modifications ne brisent pas l'idempotence. En complément, **--diff** affiche les différences ligne par ligne, bien qu'il puisse générer un grand volume de résultats si le mode **--check** effectue de nombreuses modifications.

### Spécification d’arguments de rôle

La spécification d'arguments permet de définir les variables attendues, d'ajouter des contraintes de validation et de fournir une documentation intégrée. <br>
La spécification d'arguments de rôle doit être définie dans un bloc **argument_specs** de niveau supérieur, dans le fichier **meta/argument_specs.yml** du rôle. Tous les champs sont en minuscules.

```
entry-point-name: #- Nom du point d'entrée du rôle.
                  #- Ce doit être « main » si le point d'entrée n'est pas spécifié.
                  #- Ce sera le nom de base du fichier de tâches à exécuter, sans extension .yml ou .yaml.
    short_description: #- Une description courte sur une seule ligne du point d'entrée.
                       #- Elle est affichée par la commande : ansible-doc -t role -l.
                       #- Elle fait également partie du titre de la page du rôle dans la documentation.
                       #- La description courte doit toujours être une chaîne, jamais une liste, et ne doit pas se terminer par un point.
    description: #- description plus longue pouvant contenir plusieurs lignes.
    version_added: #- Version du rôle lors de l'ajout du point d'entrée. Il s'agit d'une chaîne et non d'un nombre à virgule flottante.
                   #- Dans les collections, il s'agit de la version de la collection à laquelle le point d'entrée a été ajouté.
    author: #- Nom des auteurs du point d'entrée. Il peut s'agir d'une chaîne unique ou d'une liste de chaînes.
    options: #- Les options sont souvent appelées « paramètres » ou « arguments ». Cette section les définit.
             #- Pour chaque option de rôle (argument), nous pouvons inclure :
        option-name: #- Le nom de l'option/argument.
        description: #- Explication détaillée de la fonction de cette option.
        version_added: #- Nécessaire uniquement si cette option a été ajoutée après la publication initiale du rôle/point d'entrée. Autrement dit, elle est supérieure au champ version_added de niveau supérieur.
        type: #- le type de données de l'option : str, int, float, bool, list, dict. La valeur par défaut est str.
        required: #- Booléen permettant d'indiquer si l'option obligatoire ou non.
        default: #- Valeur par défaut de l'option. La valeur par défaut réelle de la variable de rôle proviendra toujours des valeurs par
                 #- défaut du rôle. Exemple de valeurs : true, false, "", [], {}, 77
        choices: #- Liste de valeurs d'options. Doit être absent si vide.
        elements: #- Spécifie le type de données pour les éléments de liste lorsque le type est une liste
        options : si cette option prend un dict ou une liste de dicts, nous pouvons définir la structure ici.
```

**Exemple :**

```
# meta/argument_specs.yml
---
argument_specs:
  # tasks/main.yml entry point
  main:
    short_description: Main entry point for the myapp role
    description:
      - This is the main entrypoint for the C(myapp) role.
      - Here we can describe what this entrypoint does in lengthy words.
      - Every new list item is a new paragraph. You can have multiple sentences
        per paragraph.
    author:
      - Daniel Ziegenberg
    options:
      myapp_int:
        type: "int"
        required: false
        default: 42
        description:
          - "The integer value, defaulting to 42."
          - "This is a second paragraph."

      myapp_str:
        type: "str"
        required: true
        description: "The string value"

      myapp_list:
        type: "list"
        elements: "str"
        required: true
        description: "A list of string values."
        version_added: 1.3.0

      myapp_list_with_dicts:
        type: "list"
        elements: "dict"
        required: false
        default:
          - myapp_food_kind: "meat"
            myapp_food_boiling_required: true
            myapp_food_preparation_time: 60
          - myapp_food_kind: "fruits"
            myapp_food_preparation_time: 5
        description: "A list of dicts with a defined structure and with default a value."
        options:
          myapp_food_kind:
            type: "str"
            choices:
              - "vegetables"
              - "fruits"
              - "grains"
              - "meat"
            required: false
            description: "A string value with a limited list of allowed choices."

          myapp_food_boiling_required:
            type: "bool"
            required: false
            default: false
            description: "Whether the kind of food requires boiling before consumption."

          myapp_food_preparation_time:
            type: int
            required: true
            description: "Time to prepare a dish in minutes."

      myapp_dict_with_suboptions:
        type: "dict"
        required: false
        default:
          myapp_host: "bar.foo"
          myapp_exclude_host: true
          myapp_path: "/etc/myapp"
        description: "A dict with a defined structure and default values."
        options:
          myapp_host:
            type: "str"
            choices:
              - "foo.bar"
              - "bar.foo"
              - "ansible.foo.bar"
            required: true
            description: "A string value with a limited list of allowed choices."

          myapp_exclude_host:
            type: "bool"
            required: true
            description: "A boolean value."

          myapp_path:
            type: "path"
            required: true
            description: "A path value."

          original_name:
            type: list
            elements: "str"
            required: false
            description: "An optional list of string values."

  # tasks/alternate.yml entry point
  alternate:
    short_description: Alternate entry point for the myapp role
    description:
      - This is the alternate entrypoint for the C(myapp) role.
    version_added: 1.2.0
    options:
      myapp_int:
        type: "int"
        required: false
        default: 1024
        description: "The integer value, defaulting to 1024."
```


**Référence** : [https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)