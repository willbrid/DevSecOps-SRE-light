# Tests et développement automatisés avec Molecule

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

### Tester un rôle avec molecule

