# Priorité des variables

La documentation d'Ansible fournit le classement suivant concernant l'ordre de priorité des variables :

1. **--extra-vars** transmis via la ligne de commande <br>
2. Variables au niveau de la tâche (dans un bloc de tâches) <br>
3. Variables au niveau du bloc (pour toutes les tâches d'un bloc) <br>
4. Variables de rôle (par exemple [role]/vars/main.yml) et variables du module **include_vars** <br>
5. Variables définies via les modules **set_facts** <br>
6. Variables définies via un registre dans une tâche <br> 
7. Variables individuelles au niveau du playbook : **1. vars_files 2. vars_prompt 3. vars** <br>
8. Faits de l'hôte <br>
9. Playbook **host_vars.** <br>
10. Playbook **group_vars** <br>
11. Inventaire : **1. host_vars 2. group_vars 3. vars** <br>
12. Variables par défaut du rôle (par exemple, [role]/defaults/main.yml)

Quelques récommandations :

- Les rôles doivent fournir des valeurs par défaut saines via les variables « par défaut » du rôle. Ces variables serviront de solution de secours au cas où la variable ne serait définie nulle part ailleurs dans la chaîne.
- Les playbooks doivent rarement définir des variables, mais plutôt les variables doivent être définies soit dans les fichiers **vars_files** inclus, soit moins souvent via l’inventaire.
- Seules les variables véritablement spécifiques à l’hôte ou au groupe doivent être définies dans les inventaires d’hôtes ou de groupes.
- Les sources d’inventaire dynamiques et statiques doivent contenir un minimum de variables, d’autant plus que ces variables sont souvent moins visibles pour ceux qui gèrent un playbook particulier.
- Les variables de ligne de commande (-e) doivent être évitées autant que possible. L’un des principaux cas d’utilisation est lors de tests locaux ou d’exécution de playbooks ponctuels.