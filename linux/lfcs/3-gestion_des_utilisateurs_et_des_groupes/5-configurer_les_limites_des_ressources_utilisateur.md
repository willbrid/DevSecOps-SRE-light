# Configurer les limites des ressources utilisateur

Les systèmes Linux ont souvent plusieurs utilisateurs activement connectés. En tant qu'administrateur système Linux, il est important qu'un ou plusieurs de ces utilisateurs ne monopolisent pas les ressources système.<br>
Pour garantir la disponibilité et la convivialité de nos serveurs, nous devrons peut-être appliquer des limites à certains utilisateurs ou groupes.

### Fichier /etc/security/limits.conf

À l'aide du fichier de configuration des limites, nous pouvons définir 2 types de limites pour les utilisateurs :

- Une limite stricte (**hard**) est définie par l'administrateur système et ne peut être dépassée ou modifiée par les utilisateurs.

- Pour une limite souple (**soft**), la valeur est également définie par l'administrateur système, mais l'utilisateur a la possibilité d'augmenter lui-même la limite jusqu'à la limite stricte (**hard**).

La page de manuel couvre beaucoup d'informations, y compris le **rôle du fichier**, le **format de fichier**, ainsi que la description du comportement du fichier, tout en fournissant quelques exemples. Les limites d'utilisateurs ont priorité sur les limites de groupe.

```
cat /etc/security/limits.conf
```

Format du fichier **/etc/security/limits.conf** :

- **Domaine** (**Domain**) : Utilisateur/groupe/wildcard
- **Type** (**Type**) : **Hard/Soft**
- **Elément** (**Item**) : Taille de la mémoire, taille du fichier, nombre de fichiers...
- **Valeur** (**Value**) : Limite, soit par valeur numérique, soit par taille en **Ko**

Les limites des fichiers sont définies dans 4 colonnes. Ces valeurs incluent le **domaine**, le **type**, l'**élément** et la **valeur**. Examinons chacun d’eux plus en détail.
- La **valeur** du domaine peut être un **nom d'utilisateur**, un **nom de groupe** ou une **valeur générique**. 
- Le **type** indique si la limite est souple (**soft**) ou stricte (**Hard**). 
- La valeur de l'élément peut contenir une grande variété d'informations <br> 
--- **core** définit une limite sur la taille du fichier principal <br>
--- **data** définit une taille maximale des données <br> 
--- **fsize** définit une limite maximale de taille de fichier <br>
--- **memlock** définit une limite sur l'espace d'adressage en mémoire verrouillé <br>
--- **nofile** définit le nombre maximum de fichiers que vous pouvez ouvrir à un moment donné <br> 
--- **rss** définira la taille maximale du rss (**resident set size**) <br>
--- **stack** définit une limite sur la taille de la pile <br>
--- **cpu** définit une limite sur le temps CPU <br>
--- **nproc** définit une limite maximale sur le nombre de processus que nous pouvons générer <br>
--- **as** définit une limite sur l'espace d'adressage <br>
--- **maxlogins** définit le nombre maximum de fois qu'un utilisateur peut se connecter simultanément à un système <br>
--- **maxsyslogins** définit un nombre maximum de connexions sur le système lui-même <br>
--- **priority** définit la priorité des processus utilisateur <br>
--- **locks** définit le nombre de verrous de fichiers qu'un utilisateur peut détenir <br>
--- **Sigending** définit un nombre maximum de signaux en attente <br> 
--- **msgqueue** définit une limite maximale sur la mémoire utilisée par les files d'attente de messages POSIX <br>
--- **nice** définit une priorité **nice** (priorité d'ordonnancement) maximale pouvant être utilisée sur les processus <br> 
--- **rtprio** définira la priorité maximale en temps réel <br> 
--- **chroot** qui est une valeur spécifique aux distributions Debian

Pour voir quelles limites sont définies pour nous sur un système, nous pouvons exécuter la commande 

```
ulimit -a
```

Si nous souhaitons consulter les limites d'un utilisateur spécifique (par exemple le cas de l'utilisateur **vagrant**), on exécute

```
sudo -u vagrant ulimit -a
```