# Mise en réseau kubernetes

Kubernetes utilise un réseau de cluster virtuel pour permettre aux conteneurs de communiquer de manière transparente, quel que soit le nœud sur lequel ils se trouvent.
<br><br>
La mise en réseau est un élément central de Kubernetes, mais il peut être difficile de comprendre exactement comment cela devrait fonctionner. Il existe 4 problèmes de réseau distincts à résoudre :

- Communications hautement couplées de conteneur à conteneur : ce problème est résolu par les pods et les communications localhost.
- Communications Pod-to-Pod
- Communications Pod-to-Service
- Communications externes au service

Kubernetes consiste à partager des machines entre applications. Généralement, le partage de machines nécessite de s'assurer que deux applications n'essaient pas d'utiliser les mêmes ports. La coordination des ports entre plusieurs développeurs est très difficile à faire à grande échelle et expose les utilisateurs à des problèmes au niveau du cluster hors de leur contrôle.
<br><br>
L'allocation de port dynamique apporte beaucoup de complications au système - chaque application doit prendre les ports comme flags, les serveurs d'API doivent savoir comment insérer des numéros de port dynamiques dans les blocs de configuration, les services doivent savoir comment se trouver, etc. que de gérer cela, Kubernetes adopte une approche différente.
<br>
Le modèle de réseau est implémenté par le runtime de conteneur sur chaque nœud. Les runtimes de conteneurs les plus courants utilisent des plugins **Container Network Interface** (CNI) pour gérer leurs capacités de réseau et de sécurité. Certains d'entre eux ne fournissent que des fonctionnalités de base d'ajout et de suppression d'interfaces réseau, tandis que d'autres fournissent des solutions plus sophistiquées, telles que l'intégration avec d'autres systèmes d'orchestration de conteneurs, l'exécution de plusieurs plug-ins CNI, des fonctionnalités IPAM avancées, etc.

[https://kubernetes.io/docs/concepts/cluster-administration/networking/](https://kubernetes.io/docs/concepts/cluster-administration/networking/)