# Répertorier et identifier les contextes de fichiers et de processus SELinux/AppArmor

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

### AppArmor

- Semblable à SELinux, il s'agit d'une amélioration du kernel utilisée pour limiter les applications à un ensemble sélectionné de ressources.
- **AppArmor** est différent de certains systèmes similaires car il est basé sur un chemin. Cela permet une combinaison de profils de mode **enforce** et de mode **complaint**.
- Il a tendance à être plus simple et plus facile à mettre en œuvre et à apprendre que les autres systèmes MAC populaires.
- Commun sur les systèmes **Debian/Ubuntu**. Les profils sont stockés dans le répertoire **/etc/apparmor.d/**.

--- Affichons diverses informations sur la stratégie **apparmor** actuelle.

```
sudo aa-status
```

Nous pouvons voir combien de profils sont chargés, quels profils sont configurés pour être en mode **enforce**, quels profils sont en mode **complain**, si des processus ont un profil défini, si des processus sont en mode **enforce** et quels processus sont en mode **complaint**.

Nous pouvons consulter les profils **apparmor** (par exemple pour le cas de **lsb_release**) dans le repertoire **/etc/apparmor.d/**

```
cat /etc/apparmor.d/lsb_release
```

--- Listons les profils **apparmor** pour les processus avec la commande **ps**

```
ps auxZ
```

--- Listons les profils **apparmor** avec la commande **ls** sur le repertoire **/var**

```
ls -Z /var
```

Si les commandes **aa-enforce**, **aa-disable**, **aa-complain** n'existe pas, nous pouvons les installer avec la commande 

```
sudo apt install apparmor-utils
```

Nous pouvons utiliser la commande **aa-enabled** pour vérifier que **apparmor** est activé.

```
aa-enabled
```

Nous pouvons utiliser la commande **aa-disable** pour désactiver un profil de sécurité **apparmor**.

```
sudo aa-disable /etc/apparmor.d/lsb_release
```

Nous pouvons utiliser la commande **aa-enforce** pour activer un profil de sécurité **apparmor** en mode **enforce**.

```
sudo aa-enforce /etc/apparmor.d/lsb_release
```

Nous pouvons utiliser la commande **aa-complain** pour activer un profil de sécurité **apparmor** en mode **complain**.

```
sudo aa-complain /etc/apparmor.d/lsb_release
```