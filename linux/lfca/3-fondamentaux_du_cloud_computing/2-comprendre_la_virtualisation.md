# Comprendre la virtualisation

- **Qu'est ce que la virtualisation**

En informatique, la virtualisation fait référence à l'abstraction du matériel physique sous-jacent des applications, des services ou des systèmes qui s'exécutent sur ce matériel.
<br>
--- elle peut inclure des machines virtuelles <br>
--- elle peut inclure d'autres objets virtuels logiciels

- **Machine virtuelle**

Un système virtuel (ou ordinateur) qui se comporte comme s'il s'exécutait sur son propre matériel dédié mais qui s'exécute dans un environnement logiciel.

- **Hyperviseur**

Un logiciel qui s'exécute sur un système physique et crée plusieurs systèmes d'exploitation virtuels isolés. 
<br>
--- il permet la virtualisation des ressources matérielles <br>
--- il prend en charge plusieurs machines virtuelles exécutant différents systèmes d'exploitation. <br>
--- il se décline en deux implémentations (il existe des exceptions comme KVM : kernel virtual machine) : <br>
----- type1 : l'hyperviseur est installé directement sur la machine physique ou bare métal (exemple : zen, vmware,...)<br>
----- type2 : l'hyperviseur est installé sur un système d'exploitation (exemple : virtualbox, vmware)

- **Vagrant** 

Un outil de hashicorp pour créer et gérer des environnements de machines virtuelles dans un seul workflow. <br>
--- vagrant : l'outil en ligne de commande <br>
--- vagrantfile : le fichier de configuration de la machine virtuelle <br>
<br>
Les avantages : <br>

--- automatise la configuration d'une ou plusieurs VM <br>
--- prend en charge plusieurs environnements VM <br>
--- prend en charge plusieurs hyperviseurs <br>
--- prend en charge l'utilisation sur plusieurs systèmes d'exploitation <br>
--- prend en charge l'utilisation des plugins