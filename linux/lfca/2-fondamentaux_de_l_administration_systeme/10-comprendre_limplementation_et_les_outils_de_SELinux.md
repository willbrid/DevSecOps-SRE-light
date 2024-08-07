# Comprendre l'implémentation et les outils de SELinux

## Définition

- Security-Enhanced Linux (SELinux) : une implémentation d'une architecture flexible de contrôle d'accès obligatoire (MAC : mandatory access control) dans le système d'exploitation linux qui intègre un ensemble de modifications du noyau et d'outils d'espace utilisateur.
<br>

NB : Architecture de sécurité par défaut pour les systèmes RHEL.
<br>

C'est donc quelque chose qui est implémenté à un niveau profond du système celui du **noyau**, mais il fournit également des outils d'administration qui permettent de modifier le comportement de son application. <br>
Donc, l'une des meilleures façons d'y penser est un ensemble de règles qui définissent quel processus peut avoir accès à quel fichier sur l'hôte. Et il le fait en **étiquetant** chaque fichier, port et socket, etc.
<br>

Les différents modes opératoires : <br>

--- **Enforcing** : cela signifie donc qu'il va appliquer la politique de sécurité chargée.<br>
--- **Permissive** : ce qui signifie que la politique de sécurité est chargée, mais qu'elle n'est pas appliquée. Donc, ce mode va garder une trace de toutes les violations de sécurité mais il ne va pas restreindre l'accès. <br>
--- **Disabled** : la politique de sécurité est désactivée et ne sera pas appliquée. <br>

- contexte de sécurité : qui va prendre le format d'utilisateur (**user**), de rôle (**role**), de type (**type**), puis de niveau de sécurité (**range or security level**). Donc, en mentionnant l'étiquetage, SELinux va exiger que le contexte de sécurité soit associé à pratiquement tout. Et cela va décider si l'accès est autorisé ou non tel que défini par la politique SELinux. <br>
--- Donc, pour l'utilisateur (**user**), il s'agit de l'identité de l'utilisateur SELinux et peut être associée à un ou plusieurs rôles que l'utilisateur SELinux est alors autorisé à utiliser. <br> 
--- Ensuite, nous avons le rôle (**roles**), qui est le rôle SELinux. Cela peut être associé à un ou plusieurs types auxquels l'utilisateur SELinux est autorisé à accéder. <br>
--- Ensuite, nous avons le type (**type**) qui définit les processus auxquels l'utilisateur SELinux peut accéder. <br>
--- Ensuite, nous avons le niveau de sécurité (**range or security level**). Donc, cela va venir sous l'une des 2 formes : <br>
----- il peut contenir un seul niveau de sécurité qui contient un niveau de sensibilité et 0 ou plusieurs catégories, <br>
----- ou une plage qui se compose de 2 niveaux de sécurité, un bas et un haut. <br>

- obtenir des informations sur SELinux

--- **semanage** : utiliser l'option -l pour lister les OBJETS spécifiés <br>
--- **getenforce** : récupérer le mode actuel de selinux <br>
--- **getsebool** : récupérer les valeurs booléennes selinux <br>
--- **sestatus** : récupérer le statut de selinux <br>
--- **ls -Z** : afficher le contexte de sécurité dans la liste de contenu <br>
--- **ps -Z** : afficher le contexte de sécurité dans la liste des processus

- modifier selinux

--- **semanage** : outil de gestion des politiques selinux <br>
--- **setenforce** : modifier le mode de selinux <br>
--- **setsebool** : définir les valeurs booléennes selinux <br>
--- **chcon** : modifier le contexte de sécurité des fichiers <br>
--- **restorecon** : restaurer le contexte de sécurité par défaut du ou des fichier(s)

## Pratiques

- affichons le mode actuel de selinux

```
getenforce
```

- configurons selinux en mode **permissive**

```
sudo setenforce 0
```

affichons à nouveau le mode actuel pour confirmer le résultat

```
getenforce
```

- désactivons selinux

```
sudo vim /etc/selinux/config
```

```
SELINUX=disabled
```

- affichons le status de selinux

```
sestatus
```

- affichons les informations du contexte de fichier SELinux (**fcontext : file context**)

```
sudo semanage fcontext -l | less
```

Cela va donc nous donner 3 colonnes : <br>
--- colonne **SELinux fcontext** : cela va donc montrer le fichier ou le répertoire sur lequel cette politique est appliquée. <br>
--- colonne **type** : nous allons donc voir tous les **fichiers**, **fichier normal**, **répertoire**, **lien symbolique**. <br>
--- colonne **contexte réel** (context) : nous allons voir l'utilisateur (user), le rôle (role), le type (type), puis le niveau de sécurité (**range or security level**). <br>

Avec l'affichage (vi ou vim) issu de la commande ci-dessus, nous pouvons rechercher le mot clé **httpd**.

- affichons les processus avec leur contexte de sécurité

```
ps -efZ
```

- affichons les processus associés à httpd avec leur contexte de sécurité

```
ps -efZ | grep httpd
```

- affichons toutes les valeurs booléennes selinux

```
getsebool -a
```

- affichons toutes les valeurs booléennes selinux associées à httpd

```
getsebool -a | grep httpd
```

Nous constatons que la valeur booleenne selinux **httpd_enable_cgi** pour httpd est activée et la valeur booléenne selinux **httpd_enable_ftp_server** pour httpd est désactivée. <br>

- activons la valeur booléenne **httpd_enable_ftp_server** et désactivons la valeur booléenne **httpd_enable_cgi**

```
sudo setsebool httpd_enable_cgi off
sudo setsebool httpd_enable_ftp_server on
```

Pour confirmer ce changement, nous exécutons à nouveau :

```
getsebool -a | grep httpd
```

- affichons le répertoire **/var/www/html/** avec son contexte de sécurité selinux 

```
ll -dZ /var/www/html/
```

```
# Sortie de la commande
drwxr-xr-x. 2 root root system_u:object_r:httpd_sys_content_t:s0 6  8 nov.  11:31 /var/www/html/
```

- créons un repertoire **webContent** à la racine **/** et 5 fichiers nommés **file0...file5**

```
sudo mkdir /webContent
sudo touch /webContent/file{0..5}
```

- affichons le répertoire **/webContent** avec son contexte de sécurité selinux 

```
ll -dZ /webContent/
```

```
# Sortie de la commande
drwxr-xr-x. 2 root root unconfined_u:object_r:default_t:s0 84 17 févr. 03:18 /webContent/
```

```
ll -Z /webContent
```

```
# Sortie de la commande
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file0
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file1
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file2
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file3
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file4
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file5
```

Nous constatons que le type par défaut du contexte de sécurité du repertoire **/webContent** et son contenu est **default_t**.

- changeons le type du contexte de sécurité repertoire **/webContent** et son contenu pour la valeur **httpd_sys_content_t**

```
sudo chcon -R -t httpd_sys_content_t /webContent/
```

L'option **-R** permet de préciser le mode récursive (le repertoire et son contenu) et l'option **-t** permet de préciser le type de contexte de sécurité. <br>

Pour vérifier le résultat nous pouvons lister à nouveau le contexte de sécurité du repertoire **/webContent** et son contenu

```
ll -dZ /webContent/
```

```
# Sortie de la commande
drwxr-xr-x. 2 root root unconfined_u:object_r:httpd_sys_content_t:s0 84 17 févr. 03:18 /webContent/
```

```
ll -Z /webContent
```

```
# Sortie de la commande
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0 17 févr. 03:18 file0
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0 17 févr. 03:18 file1
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0 17 févr. 03:18 file2
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0 17 févr. 03:18 file3
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0 17 févr. 03:18 file4
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0 17 févr. 03:18 file5
```

- restaurons le contexte de securité du repertoire **/webContent/** et de son contenu

```
sudo restorecon -R -v /webContent/
```

L'option **-R** permet de préciser le mode récursive (le repertoire et son contenu) et l'option **-v** permet de préciser le mode verbose. <br>

Pour vérifier le résultat nous pouvons lister à nouveau le contexte de sécurité du repertoire **/webContent** et son contenu

```
ll -dZ /webContent/
```

```
# Sortie de la commande
drwxr-xr-x. 2 root root unconfined_u:object_r:default_t:s0 84 17 févr. 03:18 /webContent/
```

```
ll -Z /webContent
```

```
# Sortie de la commande
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file0
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file1
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file2
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file3
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file4
-rw-r--r--. 1 root root unconfined_u:object_r:default_t:s0 0 17 févr. 03:18 file5
```

- ajoutons un enregistrement du type d'objet **fcontext**, de contexte de sécurité de type **httpd_sys_content_t** pour le repertoire **/webContent** et son contenu

```
sudo semanage fcontext -a -t httpd_sys_content_t "/webContent(/.*)?"
```

Pour vérifier le résultat nous pouvons exécuter la commande 

```
sudo semanage fcontext -l | grep httpd_sys_content_t
```

Si nous affichons à nouveau le contexte de sécurité du repertoire **/webContent** et son contenu, nous constaterons aucun changement. <br>
Pour appliquer les changements, nous exécutons la commande **restorecon** afin qu'il puisse s'appliquer à la politique enregistrée au type d'objet **fcontext** pour le repertoire **/webContent/**

```
sudo restorecon -R -v /webContent/
```