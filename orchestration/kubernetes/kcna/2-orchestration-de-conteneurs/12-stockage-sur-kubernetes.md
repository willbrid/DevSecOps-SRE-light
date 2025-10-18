# Stockage sur kubernetes

#### Volume

Les fichiers sur disque dans un conteneur sont éphémères, ce qui présente certains problèmes pour les applications non triviales lorsqu'elles s'exécutent dans des conteneurs. Un problème survient lorsqu'un conteneur tombe en panne ou est arrêté. L'état du conteneur n'est pas enregistré, de sorte que tous les fichiers qui ont été créés ou modifiés pendant la durée de vie du conteneur sont perdus. Lors d'un crash, kubelet redémarre le conteneur avec un état propre. Un autre problème survient lorsque plusieurs conteneurs s'exécutent dans un pod et doivent partager des fichiers. Il peut être difficile de configurer et d'accéder à un système de fichiers partagé sur tous les conteneurs. L'abstraction de volume Kubernetes résout ces deux problèmes.
<br>

**Volume** : Fournit un stockage externe à nos conteneurs Kubernetes pour stocker les données d'application.

<br>

Kubernetes prend en charge de nombreux types de volumes. Un pod peut utiliser n'importe quel nombre de types de volumes simultanément. Les types de volumes éphémères ont une durée de vie d'un pod, mais les volumes persistants existent au-delà de la durée de vie d'un pod. Lorsqu'un pod cesse d'exister, Kubernetes détruit les volumes éphémères ; cependant, Kubernetes ne détruit pas les volumes persistants. Pour tout type de volume dans un pod donné, les données sont conservées lors des redémarrages du conteneur.
<br>
À la base, un volume est un répertoire, contenant éventuellement des données, accessible aux conteneurs d'un pod. La façon dont ce répertoire est créé, le support qui le soutient et son contenu sont déterminés par le type de volume particulier utilisé.
<br>
Pour utiliser un volume, spécifions les volumes à fournir pour le pod dans **.spec.volumes** et déclarons où monter ces volumes dans des conteneurs dans **.spec.containers[*].volumeMounts**. Un processus dans un conteneur voit une vue du système de fichiers composée du contenu initial de l'image du conteneur, plus les volumes (si définis) montés à l'intérieur du conteneur. Le processus voit un système de fichiers racine qui correspond initialement au contenu de l'image du conteneur. Toute écriture dans cette hiérarchie de système de fichiers, si elle est autorisée, affecte ce que ce processus voit lorsqu'il effectue un accès ultérieur au système de fichiers. Les volumes sont montés sur les chemins spécifiés dans l'image. Pour chaque conteneur défini dans un pod, nous devons spécifier indépendamment où monter chaque volume utilisé par le conteneur.
<br>
Les volumes ne peuvent pas être montés dans d'autres volumes (mais voir Utilisation de subPath pour un mécanisme connexe). De plus, un volume ne peut pas contenir de lien physique vers quoi que ce soit dans un volume différent.

#### Volume persistant et demande de volume persistant

- Un volume persistant (PV) est un élément de stockage dans le cluster qui a été provisionné par un administrateur ou provisionné dynamiquement à l'aide de classes de stockage. C'est une ressource dans le cluster, tout comme un nœud est une ressource de cluster. Les PV sont des plugins de volume comme Volumes, mais ont un cycle de vie indépendant de tout pod individuel qui utilise le PV. Cet objet API capture les détails de l'implémentation du stockage, qu'il s'agisse de NFS, d'iSCSI ou d'un système de stockage spécifique au fournisseur de cloud.

- Une demande de volume persistant (PVC) est une demande de stockage par un utilisateur. Il est similaire à un Pod. Les pods consomment des ressources de nœud et les PVC consomment des ressources PV. Les pods peuvent demander des niveaux de ressources spécifiques (processeur et mémoire). Les revendications peuvent demander une taille et des modes d'accès spécifiques (par exemple, elles peuvent être montées ReadWriteOnce, ReadOnlyMany ou ReadWriteMany via l'option AccessModes).

Bien que PersistentVolumeClaims permette à un utilisateur de consommer des ressources de stockage abstraites, il est courant que les utilisateurs aient besoin de PersistentVolumes avec des propriétés variables, telles que les performances, pour différents problèmes. Les administrateurs de cluster doivent être en mesure d'offrir une variété de volumes persistants qui diffèrent plus que la taille et les modes d'accès, sans exposer les utilisateurs aux détails de la façon dont ces volumes sont implémentés. Pour ces besoins, il existe la ressource **StorageClass**.
<br><br>
Politiques de récupération volume persistant :
- Retain - Récupérer manuellement.
- Recycle - Récupération automatique via un simple nettoyage des données.
- Delete - La ressource de stockage sous-jacente est supprimée.

- Cycle de vie d'un volume et d'une demande de volume

Les PV sont des ressources dans le cluster. Les PVC sont des demandes pour ces ressources et agissent également comme des vérifications de réclamation pour la ressource. L'interaction entre les PV et les PVC suit ce cycle de vie :
- **approvisionnement** : il existe deux manières de provisionner les PV : de manière statique ou dynamique.
- **Liaison** : un utilisateur crée, ou dans le cas d'un provisionnement dynamique, a déjà créé, un PersistentVolumeClaim avec une quantité spécifique de stockage demandée et avec certains modes d'accès.
- **Utilisation** : les pods utilisent les revendications comme volumes. Le cluster inspecte la réclamation pour trouver le volume lié et monte ce volume pour un pod.

#### Configmap et secret

Les configMaps et secrets peuvent être montés en tant que volumes de données.

- Pour consommer une ConfigMap dans un volume d'un pod :

--- créons une ConfigMap ou utilisons-en une existante. Plusieurs pods peuvent référencer le même ConfigMap. <br>
--- Modifions la définition de notre pod pour ajouter un volume sous **.spec.volumes[]**. Nommons le volume de notre choix et ayons un champ **.spec.volumes[].configMap.name** défini pour référencer notre objet ConfigMap. <br>
--- Ajoutons un **.spec.containers[].volumeMounts[]** à chaque conteneur qui a besoin de ConfigMap. <br>
--- Spécifions **.spec.containers[].volumeMounts[].readOnly = true** et **.spec.containers[].volumeMounts[].mountPath** vers un nom de répertoire inutilisé où nous souhaitons que le ConfigMap apparaisse. <br>
--- Modifions notre image ou notre ligne de commande afin que le programme recherche des fichiers dans ce répertoire. Chaque clé du mappage de données ConfigMap devient le nom de fichier sous **mountPath**.

- Utiliser des secrets en tant que fichiers à partir d'un pod

Si nous souhaitons accéder aux données d'un secret dans un pod, une façon de le faire est de faire en sorte que Kubernetes rende la valeur de ce secret disponible sous forme de fichier dans le système de fichiers d'un ou plusieurs conteneurs du pod. Lorsqu'un volume contient des données d'un secret et que ce secret est mis à jour, Kubernetes suit cela et met à jour les données dans le volume, en utilisant une approche cohérente à terme.
<br>
- Utilisons **immutable : true** avec ConfigMaps et Secrets pour marquer les données comme non modifiables.
- Par défaut, les données stockées dans Secrets ne sont pas cryptées, il faudrait juste encoder en base64.

#### Rook

Rook : automatise la gestion du stockage avec autogestion, auto-
mise à l'échelle, services de stockage d'auto-réparation.
<br>
En tant qu'opérateurs de stockage pour Kubernetes, Rook transforme les systèmes de stockage distribués en services de stockage autogérés, autoévolutifs et autoréparateurs. Il automatise les tâches d'un administrateur de stockage : déploiement, démarrage, configuration, provisionnement, mise à l'échelle, mise à niveau, migration, reprise après sinistre, surveillance et gestion des ressources.
<br>
Rook utilise la puissance de la plate-forme Kubernetes pour fournir ses services via un opérateur Kubernetes pour Ceph.
<br>
Rook orchestre la solution de stockage Ceph, avec un opérateur Kubernetes spécialisé pour automatiser la gestion. Rook garantit que Ceph fonctionnera bien sur Kubernetes et simplifiera l'expérience de déploiement et de gestion.

[https://kubernetes.io/docs/concepts/storage/volumes/](https://kubernetes.io/docs/concepts/storage/volumes/)

[https://kubernetes.io/docs/concepts/storage/persistent-volumes/](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

[https://kubernetes.io/docs/concepts/configuration/configmap/](https://kubernetes.io/docs/concepts/configuration/configmap/)

[https://kubernetes.io/docs/concepts/configuration/secret/](https://kubernetes.io/docs/concepts/configuration/secret/)

[https://rook.io/](https://rook.io/)