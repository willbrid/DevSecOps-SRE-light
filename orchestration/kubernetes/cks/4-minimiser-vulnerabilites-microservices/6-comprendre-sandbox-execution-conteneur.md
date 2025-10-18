# Comprendre les sandboxs d'exécution de conteneur

Une sandbox d'exécution de conteneur est un environnement d'exécution de conteneur spécialisé offrant des couches supplémentaires d'isolation des processus et une plus grande sécurité. <br>

Utilisons des sandboxs d'exécution de conteneur dans les situations où nous avons besoin d'une sécurité supplémentaire autour des conteneurs :

- **CHARGES DE TRAVAIL NON FIABLES** : si nous avons absolument besoin d'exécuter des applications auxquelles nous ne faisons pas nécessairement confiance ou dont nous ne pouvons pas vérifier l'origine.
- **MULTI-LOCATION** : si nous avons des utilisateurs ou des clients externes qui ont la possibilité d'exécuter des charges de travail dans notre cluster.
- **PETIT ET SIMPLE** : les charges de travail qui n'ont pas besoin d'un accès direct à l'hôte et qui ne se soucient pas des compromis en matière de performances.

La sécurité supplémentaire d'une sandbox d'exécution de conteneur se fait généralement au détriment des performances.

- **gVisor/runsc** : **gVisor** est un noyau d'application Linux qui s'exécute dans le système d'exploitation hôte, offrant une couche supplémentaire d'isolation entre le système d'exploitation hôte et les conteneurs. Autrement dit il crée une sandbox d'exécution en exécutant un noyau d'application Linux dans le système d'exploitation hôte.<br>
**runsc** est un environnement d'exécution de conteneur conforme à **OCI** qui intègre **gVisor** à des applications telles que Kubernetes. Autrement dit il permet à Kubernetes de s'interfacer avec **gVisor**.

- **Kata Containers** : il fournit une couche supplémentaire d'isolation en exécutant de manière transparente des conteneurs à l'intérieur de machines virtuelles légères.