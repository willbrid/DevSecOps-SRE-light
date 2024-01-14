# Naviguer dans l'interface

Consultons la barre latérale Zabbix telle que nous la voyons depuis notre page par défaut.

Nous avons ici quelques catégories parmi lesquelles choisir, et un niveau en dessous des catégories, nous avons nos différentes pages. Tout d'abord, commençons par détailler les catégories :

- **Monitoring** : La catégorie Surveillance est l'endroit où nous pouvons trouver toutes nos informations sur nos données collectées. C'est essentiellement la catégorie que nous souhaitons utiliser lorsque nous travaillons avec Zabbix pour lire toutes les informations collectées.

- **Services** : la catégorie Services est nouvelle dans Zabbix 6 et fait partie des fonctionnalités améliorées de surveillance des services métier. Nous pouvons trouver toutes les informations concernant le service et le suivi des SLA ici.

- **Inventory** : la catégorie Inventaire est une fonctionnalité supplémentaire intéressante dans Zabbix que nous pouvons utiliser pour consulter nos informations d'inventaire liées à l'hôte. Nous pouvons ajouter des éléments tels que des versions logicielles ou des numéros de série aux hôtes et les consulter ici.

- **Rapports** : la catégorie Rapports contient une variété de rapports prédéfinis et personnalisables par l'utilisateur axés sur l'affichage d'un aperçu des paramètres tels que les informations système, les déclencheurs et les données collectées.

- **Configuration** : la catégorie Configuration est l'endroit où nous créons tout ce que nous voulons voir dans la surveillance, l'inventaire et la création de rapports. Nous pouvons modifier nos paramètres pour répondre à tous nos besoins afin que Zabbix puisse nous montrer ces données de manière utile.

- **Administration** : la catégorie Administration est l'endroit où nous administrons le serveur Zabbix. Nous trouverons ici tous nos paramètres du serveur pour nous permettre, à nous et à nos collègues, d'avoir une bonne expérience de travail avec Zabbix.

<br>

L'onglet **Monitoring** contient les pages suivantes :

- **Dashboard** : C'est ici que nous trouverons le tableau de bord par défaut. C'est également là que nous pouvons ajouter de nombreux autres tableaux de bord pour tout ce à quoi nous pouvons penser.

- **Problems** : nous pouvons examiner en détail notre problème actuel ici. Nous disposons d'un tas d'options de filtrage pour affiner notre recherche de problèmes si nécessaire.

- **Hosts** : les hôtes fourniront un aperçu rapide de ce qui se passe avec les hôtes. Il fournit également des liens pour naviguer vers des pages affichant les données de nos hôtes.

- **Latest data** : cette page est l'endroit où nous pouvons trouver les valeurs collectées pour chaque hôte, sur lesquelles nous pouvons bien sûr filtrer.

- **Maps**: les cartes (Maps) sont un outil très utile dans Zabbix pour obtenir un aperçu de notre infrastructure. Nous pouvons les utiliser pour des aperçus du réseau et autres.

- **Discovery** : Cette page nous donne un aperçu des appareils découverts.

<br>

Cette partie **Services** de la barre latérale contient les pages suivantes :

- **Services** : C'est ici que nous configurons tous nos services que nous voulons surveiller.

- **Service actions** : La section où nous pouvons configurer toutes les actions pour nos services configurés. Nous trouverons des options telles que l'envoi de nos notifications pour les SLA et plus encore.

- **SLA** : Nous pouvons configurer ici tous les SLA que nous pouvons ensuite utiliser dans nos services.

- **SLA report** : Un aperçu détaillé des services configurés avec leurs SLA et s'ils sont respectés ou non.

<br>

L'onglet **Inventory** contient les pages suivantes :

- **Overview** : Une page d'aperçu rapide pour nos informations d'inventaire.

- **Hosts** : un aperçu plus détaillé des valeurs d'inventaire par hôte.

<br>

L'onglet **Rapports** contient les pages suivantes :

- **System information** : nous pouvons consulter les informations système ici ; il contient les mêmes informations que le widget Informations système.

- **Scheduled reports** : c'est ici que nous configurons les rapports PDF automatiques que nous pourrions envoyer.

- **Availability report** : sur cette page, nous pouvons voir le pourcentage de temps pendant lequel un déclencheur a été dans un état problématique par rapport à l'état ok. C'est un moyen utile de voir pendant combien de temps certains éléments sont réellement sains.

- **Triggers top 100** : les 100 principaux déclencheurs dont l'état a changé le plus souvent au cours d'une période donnée.

- **Audit** : nous pouvons voir ici qui a changé quoi sur notre serveur Zabbix. C'est un excellent moyen de voir quel collègue nous a mis en lock-out par accident ou si c'était exprès.

• **Action log** : nous pouvons voir une liste des actions qui ont été entreprises, par exemple, en raison de déclencheurs passant à un problème ou à un état ok.

• **Notifications** : Sur cette page, nous pouvons voir le nombre de notifications envoyées à nos utilisateurs.

<br>

L'onglet **Configuration** contient les pages suivantes :

- **Host groups** : nous configurons ici nos groupes d'hôtes ; par exemple, un groupe pour tous les serveurs Linux.

- **Templates**: c'est ici que nous configurons nos modèles que nous pouvons utiliser pour surveiller les hôtes à partir du serveur Zabbix.

- **Hosts** : Un autre onglet d'hôtes, mais cette fois ce n'est pas pour vérifier les données. C'est ici que nous ajoutons et configurons les paramètres de l'hôte.

- **Maintenance**: dans Zabbix, nous avons la possibilité de définir des périodes de maintenance ; de cette façon, les déclencheurs ou les notifications ne nous dérangeront pas pendant que nous mettons quelque chose hors ligne pour la maintenance, par exemple.

- **Actions**: c'est ici que nous configurons ces actions lorsqu'un déclencheur change d'état.

- **Event correlation** : nous pouvons corréler les problèmes ici pour réduire le bruit ou prévenir les tempêtes d'événements. Ceci est réalisé en fermant les problèmes nouveaux ou anciens lorsqu'ils sont en corrélation avec d'autres problèmes.

- **Discovery**: c'est ici que nous configurons la découverte Zabbix pour la création automatique d'hôtes.

<br>

L'onglet **Administration** contient les pages suivantes :

- **General** : la page générale contient la configuration de notre serveur Zabbix.

- **Proxies** : c'est ici que nous configurons les proxys qui doivent être connectés à ce serveur Zabbix.

- **Authentification** : Nous pouvons trouver nos paramètres d'authentification ici, tels que LDAP, SAML et HTTP.

- **User groups** : C'est ici que nous configurons les groupes d'utilisateurs et les autorisations pour ces groupes d'utilisateurs.

- **User roles** : Il est possible de configurer ici les rôles de différents utilisateurs, de limiter ou d'étendre certaines fonctionnalités du frontend à certains utilisateurs.

- **Users** : ajoutons des utilisateurs dans cette page.

- **Media types** : il existe plusieurs types de médias préconfigurés dans Zabbix, que nous trouverons déjà ici. Nous pouvons également ajouter des types de médias personnalisés.

- **Scripts** : c'est ici que nous pouvons ajouter des scripts personnalisés, pour étendre les fonctionnalités de Zabbix dans le frontend.

- **Queue** : nous affichons la file d'attente de notre serveur Zabbix ici. Les éléments peuvent être bloqués dans une file d'attente en raison de la collecte de données ou de problèmes de performances.