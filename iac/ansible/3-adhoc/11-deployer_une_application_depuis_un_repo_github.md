# Déployer une application depuis un repo github

Dans l'exemple ci-dessous, nous supposons que nous exécutons une application simple sur un ou deux serveurs, dans le répertoire **/opt/myapp** . Ce répertoire est un référentiel git cloné à partir d'un service GitHub, et les déploiements et mises à jour d'applications sont effectués en mettant à jour le clone, puis en exécutant un script shell sur **/opt/myapp/scripts/update.sh** .

- Tout d'abord, mettons à jour comme avec **git checkout** vers la nouvelle branche de version de l'application, **1.2.4**, sur tous les serveurs d'applications.

```
ansible app -b -m git -a "repo=git://example.com/path/to/repo.git dest=/opt/myapp update=yes version=1.2.4"
```

Le module **git** d'Ansible nous permet de spécifier une **branche**, un **tag** ou même un **commit spécifique** avec le paramètre **version** (dans ce cas, nous avons choisi de vérifier le tag **1.2.4** , mais si nous exécutons à nouveau la commande avec un nom de branche, comme **prod** , Ansible se fera un plaisir de le faire à la place).<br>
Pour forcer Ansible à mettre à jour la copie extraite, nous avons passé **update=yes** . Les options repo et dest permettent d'indiquer le référentiel git et la destination de sauvegarde des fichiers de l'application.

- Ensuite, exécutons le script shell **update.sh** de l'application
```
ansible app -b -a "/opt/myapp/update.sh"
```