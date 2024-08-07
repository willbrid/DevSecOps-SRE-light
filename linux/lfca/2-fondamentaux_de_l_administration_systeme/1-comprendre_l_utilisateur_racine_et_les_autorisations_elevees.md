# Comprendre l'utilisateur racine et les autorisations élevées

## Définition

- **utilisateur root** : le compte root est un compte d'utilisateur spécial utilisé pour l'administration sur l'hôte Linux. Contrairement aux autres utilisateurs, l'utilisateur root a accès à tous les fichiers et programmes et a la possibilité de changer la propriété, les autorisations et de modifier les comptes d'utilisateurs (entre autres). Le compte root est également appelé **superutilisateur**, **administrateur** et parfois **admin** en abrégé.

- **/etc/sudoers** : il est utilisé pour déterminer les privilèges **sudo** d'un utilisateur ou d'un groupe. Les fichiers du répertoire, **/etc/sudoers.d**, sont lus avec le fichier **sudoers** pour déterminer les privilèges. Ce répertoire, comme d'autres, est utilisé pour faciliter l'organisation et l'ordre des configurations.

- **/etc/ssh/sshd_config** : c'est le fichier de configuration du démon ssh openssh. Afin de désactiver les connexions root à distance, il faudrait définir l'option **PermitRootLogin** sur **no** (l'option doit être décommentée). Pour appliquer les modifications, il faudrait redémarrer le service **sshd**.

- **visudo** : il est utilisé pour éditer le fichier sudoers. Il fournit un verrou sur le fichier sudoers contre plusieurs modifications simultanées, fournit des vérifications de base et vérifie les erreurs d'analyse. Différents éditeurs peuvent être utilisés avec visudo, mais il utilise **vi** par défaut.

- **su** (**switch user** ou **substitute user**) : il permet à l'utilisateur d'exécuter un interpréteur de commandes en changeant d'**identifiant de groupe** (**GID**) et d'**identifiant d'utilisateur** (**UID**). Lorsqu'il est exécuté sans arguments, il exécute par défaut un shell interactif en tant qu'utilisateur **root** (c'est à dire la commande utilise les UID **0** et le GID **0** qui sont ceux du compte utilisateur root). Les options **-**, **-l** et **--login** lanceront le shell comme un shell de connexion avec un environnement similaire à une connexion réelle. La commande **su** démarre un interpréteur de commandes à l'intérieur de la nouvelle session utilisateur.

- **sudo** : il permet à l'utilisateur d'exécuter une commande en tant que superutilisateur (**root**) ou un autre utilisateur (à l'aide de l'option **-u**). L'option -i (ou --login) exécutera le shell interactif si aucune commande n'est spécifiée. Les privilèges **sudo** sont définis dans le fichier sudoers.

## Pratiques

- Désactivons les connexions root à distance par ssh

```
sudo vim /etc/ssh/sshd_config
```

```
---
PermitRootLogin no
---
```

```
sudo systemctl restart sshd
```

Si nous essayons de nous connecter par ssh avec l'utilisateur **root**, ça ne marchera pas.

- ouvrir un interpréteur de commandes en tant que root

```
sudo su -
```

ou

```
sudo -i
```

- étudions le fichier **/etc/sudoers** avec ces 3 lignes ci-dessous

```
Syntax : User <space> OnHost = (Runas-User:Group) <space> Commands
```


```
rodrigue    ALL=(ALL)       ALL
%wheel  ALL=(ALL)       ALL
includedir /etc/sudoers.d
```

Maintenant, nous pouvons voir quelques distinctions : <br>
--- lorsque nous utilisons un nom d'utilisateur, nous tapons simplement ce nom d'utilisateur <br>
--- si nous souhaiterons associer à un groupe, nous devons ajouter ce signe **%** devant le nom du groupe. Et cela permet au système de savoir qu'il s'agira d'un groupe. <br>
--- Nous avons plusieurs fois le mot clé **ALL** : <br>
------- Le premier **ALL**, permet de définir l'hôte sur lequel ils peuvent exécuter les commandes. Nous pouvons définir un nom d'hôte ou une adresse IP. Et **ALL** signifie sur n'importe quel hôte. Ici **OnHost** ne pourrait pas représenter un hôte distant : il s'agit du local **hostname/ip-address**.<br>
------- Et puis le suivant **ALL**, qui est entre parenthèses, va être l'utilisateur ou le groupe pour exécuter les commandes. Ici **ALL** signifie tous les utilisateurs et tous les groupes.<br>
------- Et puis le dernier **ALL** permet de définir les commandes. Ici **ALL** signifie l'utilisateur pourra exécuter toutes les commandes. <br>

- Créons un fichier **local-perms** personnalisé pour définir les permissions sudoers

```
sudo visudo -f /etc/sudoers.d/local-perms 
```

```
# User rules
lois ALL=(ALL)  ALL

# Group rules
%ops  ALL=/bin/systemctl
```

- créons un utilisateur **lois**, connectons-nous avec cet utilisateur, puis exécutons la commande pour afficher le contenu du fichier **/etc/passwd**

```
useradd lois
passwd lois
```

```
su - lois
```

```
sudo cat /etc/passwd
```

Nous constatons que l'utilisateur **lois** peut très bien afficher le contenu du fichier **/etc/passwd**.

- créons un utilisateur **super**, connectons-nous avec cet utilisateur **super** et exécutons la commande **systemctl**

```
useradd super
passwd super
```

```
su - super
```

```
sudo systemctl restart sshd
```

Cette commande nous demande de saisir le mot de passe de l'utilisateur **super**. Une fois saisie, un message s'affiche indiquant l'utilisateur **super** ne se trouve pas dans le fichier **sudoers**.

- ajoutons notre utilisateur **super** dans le groupe **ops** (groupe défini dans le fichier **local-perms**), puis exécutons à nouveau la commande

```
exit
sudo usermod -G ops
```

```
su - super
```

```
sudo systemctl restart sshd
```

Nous constatons qu'il n'y a plus de message d'erreurs.