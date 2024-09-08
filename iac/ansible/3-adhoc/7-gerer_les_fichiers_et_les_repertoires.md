# Gérer les fichiers et les répertoires

Ansible facilite la copie de fichiers de notre hôte vers des serveurs distants, la création de répertoires, la gestion des autorisations et de la propriété des fichiers et des répertoires, et la suppression de fichiers ou de répertoires.

- Obtenir des informations sur un dossier

Si nous avons besoin de vérifier les autorisations d'un fichier, MD5 ou son propriétaire, utilisons le module **stat** d'Ansible.

```
ansible multi -m stat -a "path=/etc/environment"
```

Cela donne les mêmes informations que nous obtiendrions lors de l'exécution de la commande **stat**, mais renvoie les informations sous format JSON, qui peuvent être analysées un peu plus facilement.

- Copier un fichier sur les serveurs

La plupart des opérations de copie de fichiers peuvent être effectuées avec le module de **copy** d'Ansible.

```
ansible multi -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```

Le **src** peut être un fichier ou un répertoire. Si nous incluons une barre oblique finale, seul le contenu du répertoire sera copié dans le **dest** . Si nous omettons la barre oblique finale, le contenu et le répertoire lui-même seront copiés dans le **dest** .

Lorsque nous souhaitons copier des centaines de fichiers, en particulier dans des structures de répertoires très profondément imbriquées, nous devons envisager soit de copier puis de développer une archive des fichiers avec le module **unarchive** d'Ansible, soit d'utiliser les modules de synchronisation ou rsync d'Ansible.

- Récupérer un fichier sur les serveurs

Le module **fetch** fonctionne presque exactement de la même manière que le module **copy**, sauf en sens inverse. La principale différence est que les fichiers seront copiés vers la destination locale dans une structure de répertoires qui correspond à l'hôte à partir duquel nous les avons copiés. Par exemple, utilisez la commande suivante pour récupérer le fichier hosts sur les serveurs.

```
ansible multi -b -m fetch -a "src=/etc/hosts dest=/tmp"
```

**Fetch** placera, par défaut, le fichier **/etc/hosts** de chaque serveur dans un dossier de la destination avec le nom de l'hôte (dans notre cas, les trois adresses IP), puis à l'emplacement défini par **src** . Ainsi, le fichier hosts du serveur **db** se retrouvera dans **/tmp/192.168.56.7/etc/hosts** .
Nous pouvons ajouter le paramètre **flat=yes** et définir le dest sur **dest=/tmp/** (ajouter une barre oblique à la fin), pour qu'Ansible récupère les fichiers directement dans le répertoire **/tmp**. Cependant, les noms de fichiers doivent être uniques pour que cela fonctionne, ce n'est donc pas aussi utile lors de la copie de fichiers à partir de plusieurs hôtes. N'utilisons **flat=yes** que si nous copions des fichiers à partir d'un seul hôte.

- Créer des répertoires et des fichiers

Nous pouvons utiliser le module **file** pour créer des fichiers et des répertoires (comme **touch**), gérer les autorisations et la propriété sur les fichiers et les répertoires, modifier les propriétés SELinux et créer des liens symboliques.

créons un repertoire test avec les permissions **644**

```
ansible multi -m file -a "dest=/tmp/test mode=644 state=directory"
```

créons un fichier **test.txt**

```
ansible multi -m file -a "path=/tmp/test.txt state=touch"
```

créons un lien symbolique

```
ansible multi -m file -a "src=/tmp/test.txt dest=/tmp/symlink state=link"
```

Le **src** est le fichier cible du lien symbolique et le **dest** est le chemin où le lien symbolique lui-même devrait être.

- Supprimer des répertoires et des fichiers

Nous pouvons définir l'option **state** sur **absent** pour supprimer un fichier, un répertoire ou un lien symbolique.

Suppression du répertoire **/tmp/test**

```
ansible multi -m file -a "dest=/tmp/test state=absent"
```

Suppression du fichier **/tmp/test.txt**

```
ansible multi -m file -a "path=/tmp/test.txt state=absent"
```