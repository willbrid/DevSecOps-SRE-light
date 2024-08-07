# Coût et budgétisation du cloud computing (AWS)

### Comprendre la tarification

- **Aperçu des coûts**

--- **coût par service** : chaque service fourni par AWS est tarifé indépendamment. <br>
--- **calcul** : il correspond aux ressources de calcul réelles utilisées. <br>
--- **stockage** : les données que nous stockons dans le cloud. <br>
--- **transfert de données sortant** : ce sont les données que nous envoyons entre les systèmes. Et d'une manière générale, il n'y aura pas de frais pour tout transfert de données entrant ou transfert entre services qui se trouvent dans la même région. <br>
--- **plans de support** : c'est le montant du support qui nous est offert sur les services que nous utilisons. Ceux-ci sont Basic, Developer, Business et Enterprise, chacun avec ses coûts associés. <br>
--- **offres gratuites** : ils nous permettront de tester différents services jusqu'à un certain point. Quelques exemples de cela sont une inscription initiale gratuite de 12 mois. Et avec cela, nous allons payer après avoir dépassé une certaine quantité d'utilisation des ressources.

- **Réduction le coût total de possession (reducing total cost of ownership : TCO)**

Cela va être une image complète de combien d'argent nous dépensons sur AWS, qui peut également inclure l'argent utilisé pour la transition vers AWS. Plusieurs stratégies peuvent être utilisées pour réduction ce coût : <br>

--- **Instances réservées** : AWS nous permet de réserver des instances à l'avance afin de nous aider à réaliser des économies. <br>
--- **Ressources adaptées** : Il s'agit du processus permettant de s'assurer que notre utilisation des ressources correspond à nos besoins. Il est très facile d'avoir plus de ressources que nécessaire, il est donc important de réduire cette graisse et de s'assurer que nous n'avons que les ressources dont nous avons besoin pour accomplir les différentes tâches que nous avons. <br>
--- **calculateur de tarification** : il n'est qu'un outil gratuit pour estimer le TCO global. Avec cela, nous pouvons explorer les services et trouver différents types d'instances. Et le processus d'utilisation du calculateur de prix consiste à créer une estimation. <br>
--- **API AWS Price List** : il s'agit d'une api que nous pouvons interroger à l'aide de HTML ou JSON. Et nous pouvons également le configurer pour recevoir des alertes de prix lorsque les prix changent. <br>
--- **Service Application Discovery** : il va nous permettre de planifier des projets de migration. Il sera utilisé pour recueillir des informations sur les centres de données sur site et nous aider à estimer le coût total de possession.

### Comprendre la facturation

- **Ressources de facturation**

--- **Budgets** : AWS nous permet de définir des budgets personnalisés qui nous alertent lorsque nous dépassons un montant budgétaire particulier, ce qui peut aider à améliorer la planification et le contrôle des coûts. <br>
--- **Rapports de coût et d'utilisation** : Ce sera l'ensemble le plus détaillé des coûts et de l'utilisation. Nous pouvons vraiment creuser et savoir exactement dans quoi nous dépensons notre argent. Ce rapport peut être téléchargé via S3, répertorie l'utilisation pour chaque catégorie de service et peut regrouper les données d'utilisation aux niveaux horaire, quotidien et mensuel. <br>
--- **Cost Explorer** : il est utilisé pour visualiser et prévoir les coûts et l'utilisation au fil du temps. Ainsi, nous pouvons afficher les 12 derniers mois, puis faire des prévisions jusqu'à 3 mois. <br>
--- **Etiquettes de répartition des coûts** : cela nous permet d'étiqueter les ressources à l'aide d'une paire clé/valeur, puis de suivre le coût via un rapport de répartition des coûts.

- **Types de budget**

--- **Coût** : il s'agit donc d'une planification fondée sur les dépenses réelles, le montant en dollars. <br>
--- **Utilisation** : il s'agit de la quantité de ressources que nous souhaitons utiliser. Nous pouvons donc établir un budget en fonction de cela. <br>
--- **Réservation** : il nous permet de définir des instances réservées, des plans d'économies et des objectifs d'utilisation ou de couverture.

### Comprendre la gourvernance

Ce sont les systèmes fournis par AWS qui sont utilisés pour nous aider à contrôler le coût global, la conformité et la sécurité de tous nos comptes AWS.

- **Ressources de la gourvernance**

--- **Organisations** : elles nous permettent de gérer de manière centralisée plusieurs comptes AWS en un seul endroit. Le compte racine s'appellera le compte principal du payeur et nous pourrons payer pour tous les comptes avec une facturation consolidée. Cela permet donc un paiement simple pour toutes les organisations. Nous pouvons également regrouper plusieurs comptes et automatiser la création de comptes, puis allouer des ressources et appliquer des politiques à tous les comptes. <br>
--- **Tour de contrôle** : elle siège au-dessus des organisations et s'assure que les comptes sont conformes aux politiques de l'entreprise. <br>
--- **Systems Manager** : il offre une visibilité et un contrôle sur les ressources AWS. Avec cela, nous pouvons automatiser les tâches opérationnelles. Nous pouvons également regrouper des ressources, puis effectuer des actions sur celles-ci. <br>
--- **Trusted Advisor** : il fournit des conseils en temps réel pour le provisionnement des ressources conformément aux meilleures pratiques AWS. Cela nous aidera donc à comprendre quelles sont ces pratiques, à vérifier notre compte et à faire des recommandations, et même à vérifier les limites de service. <br>
--- **License Manager** : il aide à gérer les licences logicielles. Cela peut être sur site ou AWS, et il va prendre en charge de nombreux types de services différents. <br>
--- **Certificate Manager** : il va provisionner et gérer les certificats SSL et TLS. Et un énorme avantage est qu'il fournit gratuitement des certificats publics et privés. Et il s'intègre également à Elastic Load Balancing, API Gateway et bien d'autres services.