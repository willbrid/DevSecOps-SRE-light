# Répertorier et identifier les contextes de fichiers et de processus SELinux/AppArmor [PART1]

Pour éviter les problèmes potentiels causés par les faiblesses et les exploits d'une application, les administrateurs système s'appuient sur des outils tels que **SELinux** et **AppArmor** pour renforcer la sécurité du système.

### SELinux

- **SELinux** signifie **Security Enhanced Linux**.
- **SELinux** est un module du kernel permettant de prendre en charge les politiques de sécurité du contrôle d'accès, y compris les contrôles d'accès obligatoires.
- Il fait partie de l'écosystème **RedHat/CentOS** depuis 2005.
- **semanage** : Outil de gestion des politiques **SELinux**

- **fcontext** : type d'objet **SELinux** permettant de gérer les définitions de mappage de contexte de fichier.

--- Listons les enregistrements du type d’objet **fcontext**

```
sudo semanage fcontext -l
```

La sortie est une liste énorme qui contient les informations contextuelles pour chaque fichier, répertoire et processus du système. La sortie est générée sur 3 colonnes : 
- La première colonne est la valeur du **contexte fichier SELinux**. 
- La deuxième colonne est le type de contexte (**directory, all files, regular file**).
- la troisième colonne est le contexte lui-même. 

Lorsqu'une **étiquette de contexte** correspond à un **fichier**, un **processus** ou un **port**, l'accès est autorisé. Si les étiquettes ne correspondent pas, le résultat dépend alors du mode dans lequel SELinux est exécuté : 
- si **SELinux** s'exécute en mode **enforcing**, l'accès n'est pas autorisé. 
- si **SELinux** est en mode **permissive**, il enregistrera l'infraction.
- si **SELinux** est désactivé, rien ne se passera du tout.

Il est fortement recommander de ne pas désactiver **SELinux** ou **AppArmor** sur un système de production. Comme ces outils sont conçus pour nous aider, en tant qu'administrateur système, à garantir que nos systèmes sont protégés contre les pirates et les exploits.

--- Listons les enregistrements du type d’objet **fcontext** pour le processus **cron**

```
sudo semanage fcontext -l | grep cron
```

--- Listons les enregistrements du type d’objet **fcontext** avec la commande **ls** sur le repertoire **/var**

```
ls -Z /var
```

--- Listons les enregistrements du type d’objet **fcontext** pour les processus avec la commande **ps**

```
ps auxZ
```

--- Listons les enregistrements du type d’objet **fcontext** pour le processus **cron** avec la commande **ps**

```
ps auxZ | grep cron
```

Nous utilisons le paramètre **-v** pour exclure **grep**, puis nous renverrons ces résultats vers **grep**, puis nous rechercherons **VSZ**, l'une des valeurs d'en-tête, et nous rechercherons également **cron**. Et maintenant, nous avons filtré notre sortie **ps** pour inclure uniquement l'en-tête et le processus cron lui-même. L'option **-Z** a ajouté une nouvelle colonne à gauche de la sortie **ps**. Cette colonne est l'étiquette de contexte. Et en regardant la tâche **cron**, nous pouvons voir qu'un contexte système lui est appliqué.

```
ps auxZ | grep -v grep | grep -e VSZ -e cron
```

Nous pouvons utiliser la commande **getenforce** pour vérifier le mode actuel de **SELinux**.

```
getenforce
```

Nous pouvons utiliser la commande **setenforce** pour mettre à jour le mode de SELinux en mode **permissive**.

```
sudo setenforce permissive
```

Nous pouvons revenir au mode **enforcing**

```
sudo setenforce enforcing
```

### Concept selinux

Un **contexte selinux** est composé de : **user:role:type:level**. On parle généralement de **type** ou **domain**. <br>
Exemple de contexte

```
unconfined_u:object_r:user_home_t:s0
```

Chaque utilisateur qui se connecte à un système Linux est associé à un **utilisateur SELinux** dans le cadre de la configuration de la politique SELinux. <br>
Exemple d'utilisateurs selinux avec leur rôle

```
SELinux User               Roles
developer_u                developer_r, docker_r
guest_u                    guest_r
root                       staff_r, sysadm_r, system_r, unconfined_r
```

- seuls certains utilisateurs peuvent entrer dans certains rôles et certains types : cela empêche les utilisateurs et processus non autorisés d'accéder à des types ou des domaines qui ne leur sont pas destinés
- cela permet aux utilisateurs et processus autorisés de faire leur travail en leur accordant les permissions dont ils ont besoin
- cependant en même temps, même les utilisateurs et processus autorisés ne peuvent effectuer qu'un ensemble limité d'actions, 
- tout le reste est refusé

Dans la politique Selinux par défaut à l'échelle du système, seuls les fichiers ayant le type SELinux x_t par exemple dans leur étiquette peuvent entrer dans ce domaine x_t. Donc seul un fichier marqué avec un certain type peut entrer dans un processus qui peut passer dans un certain domaine. Le type établit les actions autorisées pour un fichier et le domaine établit les actions autorisées pour un processus.

Tout ce qui est étiquette **unconfined_t** fonctionne sans restrictions. SELinux permet à ces processus de faire presque tout ce qu'ils veulent.

- Vérifier si selinux est activé

```
sudo sestatus
```

- Afficher le contexte de sécurité attribué à notre utilisateur courant

```
id -Z
```

- Afficher la liste des mappages utilisateur système et utilisateur selinux

```
sudo semanage login -l
```

Donc un utilisateur qui se connecte qui n'est pas défini dans cette liste, il sera mappé à ce que nous voyons sur la ligne **__default__**.

- Afficher la liste des rôles qu'un utilisateur peut avoir

```
sudo semanage user -l
```

selinux confine les processus dans les bulles de sécurité appelées domaines et un domaine est étiqueté avec un certain type et le type appliqué à un processus détermine quelles règles appliquées.

- Voir ce que selinux a enregistré dans le journal d'audit

```
sudo audit2why --all | grep less
```

- Afficher les processus ayant pour contexte selinux de type **sshd_t**

```
ps -eZ | grep sshd_t
```

- Afficher le contexte selinux du fichier **/usr/sbin/sshd**

```
ls -Z /usr/sbin/sshd
```

- Générer une politique SELinux personnalisée basée sur les événements de refus enregistrés dans les logs d'audit

```
sudo audit2allow --all -M mymodule
```

**audit2allow** est un utilitaire qui analyse les logs d'audit SELinux et génère les règles **allow** nécessaires pour autoriser les actions bloquées par SELinux.

- Activer (ou charger) le module **mymodule.pp**

```
sudo semodule -i mymodule.pp
```

La politque par défaut vient avec un utilisateur prédéfini. **extension pp = policy package**. Un 2ème fichier est généré (**mymodule.te**) avec l'extension **te = type enforcement**.

- Changer l'utilisateur selinux du contexte selinux du fichier **/var/log/secure**

```
sudo chcon -u unconfined_u /var/log/secure
```

- Changer le rôle selinux du contexte selinux du fichier **/var/log/secure**

```
sudo chcon -r object_r /var/log/secure
```

- Changer le type selinux du contexte selinux du fichier **/var/log/secure**

```
sudo chcon -t user_home_t /var/log/secure
```

- Changer le contexte selinux du fichier **/var/log/secure** par rapport à la référence de celui du fichier **/var/log/messages**

```
sudo chcon --reference=/var/log/messages /var/log/secure
```

- Installation du package **setools-console** pour avoir la commande **seinfo**

```
sudo dnf install setools-console
```

- Afficher les étiquettes d'utilisateur selinux existant

```
seinfo -u
```

- Afficher les étiquettes de rôle selinux existant

```
seinfo -r
```

- Afficher les étiquettes de type existant

```
seinfo -t
```

- Afficher les utilisateurs selinux avec leur rôle

```
sudo semanage user -l
```

selinux a une sorte de base de données qui lui indique comment étiqueter les fichiers dans certains repertoires. Dans le cas où les étiquettes sont incorrectes nous pouvons les corriger avec  la commande **restorecon**.

```
sudo restorecon -R /var/www/
```

L'option R correspond au mode recursive. Par défaut cette option restaure uniquement le type et non l'utilisateur ou le rôle.

```
sudo restorecon -F -R /var/www/
```

Avec l'option -F le contexte selinux est restauré pour toutes les étiquettes : user, role et type.

- Modifier temporairement le type du contexte selinux du fichier ***/var/www/app.log**

```
sudo mkdir /var/www && sudo touch /var/www/app.log
```

```
sudo semanage fcontext --add --type var_log_t /var/www/app.log
```

Valider le changement

```
sudo restorecon /var/www/app.log
```

- Modifier temporairement le type du contexte selinux du repertoire **/nfs/shares** et son contenu

```
sudo mkdir -p /nfs/shares
```

```
sudo semanage fcontext --add --type nfs_t "/nfs/shares(/.*)?"
```

Valider le changement

```
sudo restorecon -R /nfs/shares
```

- Lister les booléens selinux

```
sudo semanage boolean --list
```

Les **booléens selinux** sont utilisés pour dire à selinux de permettre ou d'interdire une action.

- Activer le booléen selinux **virt_use_nfs**

```
sudo setsebool virt_use_nfs 1
```

- afficher la valeur du booléen selinux **virt_use_nfs**

```
sudo getsebool virt_use_nfs
```

Pour un booléen selinux donné, on a un couple (x, y) où x représente sa valeur courante (off, 0, false) et y sa valeur par défaut.

- Lister les types ports selinux

```
sudo semanage port --list
```

- Afficher le type port selinux pour ssh

```
sudo semanage port --list | grep ssh
```

- Autoriser le port 2222 au près de selinux

```
sudo semanage port --add --type ssh_port_t --proto tcp 2222
```

- Supprimer l'autorisation selinux sur le port 222

```
sudo semanage port --delete --type ssh_port_t --proto tcp 2222
```