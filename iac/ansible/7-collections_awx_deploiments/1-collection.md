# Collections

Les collections, tout comme les rôles, peuvent être partagées avec la communauté via **Ansible Galaxy** ou Automation Hub (plateforme Red Hat). Si nous trouvons une collection utile, nous pouvons l’installer en ligne de commande avec **ansible-galaxy**, comme pour un rôle.

```
ansible-galaxy collection install geerlingguy.k8s
```

si nous voulions installer la même collection, mais en utilisant un fichier **requirements.yml**, nous pourrions faire :

```
vim requirements.yml
```

```
collections:
  - name: geerlingguy.k8s
```

```
ansible-galaxy install -r requirements.yml
```

Pour assurer la stabilité des playbooks, il est recommandé d’installer une version spécifique d’une **collection**. Contrairement aux rôles, les collections suivent le **versionnement sémantique**, ce qui permet de définir des contraintes de version lors de l’installation, que ce soit via la ligne de commande ou un fichier **requirements.yml**.

```
vim requirements.yml
```

```
collections:
  - name: geerlingguy.k8s
    version: >=0.10.0,<0.11.0
```

Définir une contrainte de version (ex. 0.10.x) permet d’éviter les mises à jour majeures non prévues. Cela garantit la stabilité des playbooks, car les mises à jour respectant le versionnement sémantique ne cassent pas le fonctionnement existant. Nous pouvons ensuite tester les nouvelles versions majeures à notre rythme, sans les subir automatiquement.

Lorsque nous installons une collection à partir d'Ansible Galaxy ou d'Automation Hub, Ansible utilise la directive de configuration **collections_path** pour déterminer où les collections doivent être installées.

Par défaut, les collections sont installées à l'un des emplacements suivants :
- **∼/.ansible/collections**
- **/usr/share/ansible/collections**

Nous pouvons toutefois modifier ce paramètre dans nos propres projets en définissant la variable d'environnement **ANSIBLE_COLLECTIONS_PATH** ou en définissant **collections_path** dans un fichier **ansible.cfg** associé à notre playbook.