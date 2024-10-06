# Blocs

Introduits dans Ansible 2.0.0, les blocs nous permettent de regrouper des tâches liées et d'appliquer des paramètres de tâche particuliers au niveau du bloc. Ils nous permettent également de gérer les erreurs à l'intérieur des blocs d'une manière similaire à la gestion des exceptions de la plupart des langages de programmation. Les blocs sont également utiles si nous souhaitons pouvoir gérer avec élégance les échecs dans certaines tâches.

```
---
- hosts: app
  become: yes

  tasks:
  - block:
    - name: Install Nginx
      yum:
        name: nginx
        state: present
        
    - name: Start Nginx
      service:
        name: nginx
        state: started
      
    rescue:
    - name: Show message if Nginx installation or startup fails
      debug:
        msg: "Nginx installation or startup failed."
        
    - name: Install Apache as an alternative if this fails
      yum:
        name: httpd
        state: present
          
    - name: Start Apache
      service:
        name: httpd
        state: started

    always:
    - name: Ensure the web server is running
      debug:
        msg: "Verification completed, web server is running."
```

- **block** : le bloc regroupe des tâches qui sont exécutées ensemble. Ici, nous avons deux tâches dans le block : l'installation et le démarrage de Nginx. Si une de ces tâches échoue, l'exécution passe au bloc rescue.

- **rescue** : ce bloc est exécuté si une ou plusieurs tâches dans le bloc principal échouent. Dans cet exemple, si l'installation ou le démarrage de Nginx échoue, un message de débogage est affiché, et Apache est installé à la place. Cela permet de récupérer une situation où Nginx échoue en installant une alternative (Apache).

- **always** : ce bloc est toujours exécuté, que le bloc principal ou rescue ait réussi ou échoué. Ici, on affiche un message indiquant que la vérification est terminée et que le serveur web (Nginx ou Apache) est en cours d'exécution.