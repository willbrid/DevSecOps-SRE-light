# Introduction sur la mise en place d'un repo local Redhat 8.9

Dans un contexte professionnel, il est courant que certains serveurs d’entreprise soient isolés de l’internet pour des raisons de sécurité. Ce type de configuration pose toutefois des défis lorsqu’il s’agit de gérer les packages et les mises à jour, essentiels pour le bon fonctionnement des applications et la sécurité du système. **Red Hat Enterprise Linux** offre des solutions pour répondre à ce besoin, notamment à travers la configuration d’un dépôt local (repository).

Dans cet article qui sera composé de plusieurs parties, nous explorerons comment mettre en place un dépôt de packages local sur une machine **Red Hat 8.9**, afin de centraliser et simplifier l’accès aux packages nécessaires sans dépendre d’une connexion externe. Ce dépôt local permet ainsi d’éviter les connexions internet répétées, tout en assurant que les serveurs disposent des versions les plus récentes et sécurisées des logiciels. Nous verrons comment cette approche peut non seulement optimiser la gestion des ressources, mais aussi s’intégrer efficacement dans des environnements d’entreprise à accès restreint.

**Références :**
- [https://access.redhat.com/solutions/7019225](https://access.redhat.com/solutions/7019225)
- [https://access.redhat.com/solutions/2785791](https://access.redhat.com/solutions/2785791)