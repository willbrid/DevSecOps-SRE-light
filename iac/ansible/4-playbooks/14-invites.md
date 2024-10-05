# Invite (Prompt)

Dans de rares circonstances, nous pouvons demander à l'utilisateur de saisir la valeur d'une variable qui sera utilisée dans le playbook. Pour nous utilisons la directive **vars_prompt**.

```
---
- hosts: multi
  
  vars_prompt:
  - name: share_user
    prompt: "What is your network username?"

  - name: share_pass
    prompt: "What is your network password?"
    private: yes

  tasks:
  - name: display credentials
    debug:
      msg: "Username : {{share_user}} - Password : {{share_pass}}"  
```

Avant d'exécuter la lecture, Ansible demande à l'utilisateur un nom d'utilisateur et un mot de passe, la saisie de ce dernier étant masquée sur la ligne de commande pour des raisons de sécurité. 

Nous pouvons ajouter quelques options spéciales aux invites :
- **private** : si cette option est définie sur **yes**, la saisie de l'utilisateur sera masquée sur la ligne de commande.
- **default** : nous pouvons définir une valeur par défaut pour l'invite, afin de gagner du temps pour l'utilisateur final.
- **encrypt / confirm / salt_size** : ces valeurs peuvent être définies pour les mots de passe afin que nous puissions vérifier l'entrée (l'utilisateur devra saisir le mot de passe deux fois si **confirm** est défini sur yes), et le chiffrer à l'aide d'un sel (**salt**=) (avec la taille et le schéma de chiffrement spécifiés).

Les invites constituent un moyen simple de recueillir des informations spécifiques à l'utilisateur, mais dans la plupart des cas, nous devons les éviter, sauf si cela est absolument nécessaire. Il est préférable d'utiliser des variables de rôle ou de manuel, des variables d'inventaire ou même des variables d'environnement locales, pour maintenir une automatisation complète de l'exécution du manuel.