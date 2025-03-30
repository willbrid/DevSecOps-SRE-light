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

- Install **molecule** via pipx sous Ubuntu 24.04

```
pipx install molecule
```

### Exécution de notre playbook en mode vérification

L'option **--check** d'Ansible permet d'exécuter un playbook sans appliquer de modifications, en indiquant les tâches qui entraîneraient un changement. Cela aide à détecter les dérives de configuration et à s'assurer que les modifications ne brisent pas l'idempotence. En complément, **--diff** affiche les différences ligne par ligne, bien qu'il puisse générer un grand volume de résultats si le mode **--check** effectue de nombreuses modifications.