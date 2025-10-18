# Fondamentaux de l'orchestration de conteneurs

- L'orchestration consiste à utiliser l'automatisation pour prendre en charge l'exécution et la gestion des charges de travail conteneurisées.
- L'orchestration inclut des éléments tels que l'attribution de conteneurs à un serveur et leur lancement sur ce serveur, ou le redémarrage d'un conteneur défectueux.

<br>

**Certains des avantages de l'orchestration de conteneurs incluent** :
- gestion efficace des ressources.
- mise à l'échelle transparente des services.
- la haute disponibilité.
- faible surcharge opérationnelle à grande échelle.
- un modèle déclaratif pour la plupart des outils d'orchestration, réduisant les frictions pour une gestion plus autonome.
- infrastructure en tant que service (IaaS) de style opérationnel, mais gérable comme une plate-forme en tant que service (PaaS).
- expérience d'exploitation cohérente entre les fournisseurs de cloud sur site et publics.

<br>

**Runtime de conteneur**
- Le runtime de conteneur est le logiciel responsable de l'exécution des conteneurs.
- Kubernetes prend en charge les runtimes de conteneurs tels que **containerd**, **CRI-O** et toute autre implémentation de Kubernetes **CRI** (Container Runtime Interface).

<br>

**Container Runtime Interface (CRI)** 
- Protocole standard de communication entre kubelet et le runtime de conteneur.
- **CRI-O** et **containerd** - deux exemples de runtime de conteneur qui prennent en charge la norme CRI et fonctionnent donc avec Kubernetes.

<br>

[https://thenewstack.io/what-is-container-orchestration/](https://thenewstack.io/what-is-container-orchestration/)

[container-runtime](https://kubernetes.io/docs/concepts/overview/components/#container-runtime)