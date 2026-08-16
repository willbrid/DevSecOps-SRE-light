# Primitives de sécurité Kubernetes

Ce contenu présente les **mesures de sécurité fondamentales** nécessaires pour exécuter des applications de niveau production sur Kubernetes.

### Sécuriser les hôtes sous-jacents

Avant les fonctionnalités propres à Kubernetes, il faut sécuriser les **hôtes physiques ou virtuels** du cluster :
- **Désactiver l'accès root** ;
- **Désactiver l'authentification par mot de passe** ;
- **Imposer l'authentification par clé SSH** ;
- Mettre en place d'autres mesures critiques.

> Une compromission à ce niveau peut **mettre en péril toute l'infrastructure**.

### Le kube-apiserver au cœur de la sécurité

Le composant central est le **kube-apiserver** : point de contact principal pour toutes les opérations (via `kubectl` ou directement via l'API). Sa sécurité est primordiale, autour de **deux questions clés** :
- **Qui** peut accéder au cluster ? → **Authentification**
- **Quelles actions** peuvent être effectuées une fois l'accès accordé ? → **Autorisation**

### L'Authentification (« Qui peut accéder ? »)

Méthodes de contrôle d'accès à l'API server :
- Fichiers statiques avec **identifiants et mots de passe** ;
- **Tokens** et **certificats** ;
- Fournisseurs d'authentification **externes** (ex. **LDAP**) ;
- **Service accounts** pour les interactions **machine-à-machine**.

### L'Autorisation (« Quelles actions ? »)

Une fois authentifié, le système détermine les actions autorisées :
- **RBAC (Role-Based Access Control)** : méthode **principale** ; permissions assignées selon des **rôles** ou l'appartenance à des **groupes** ;
- **ABAC (Attribute-Based Access Control)** ;
- **Webhooks** (flexibilité étendue).

### Le chiffrement TLS

Toutes les communications entre les composants essentiels du cluster sont **sécurisées par TLS** :
- **kube-apiserver**, **etcd**, **kube-controller-manager**, **scheduler**, et les **nœuds** (kubelet, kube-proxy).

→ Cela garantit que chaque interaction reste **confidentielle et infalsifiable**. Une section entière de la documentation Kubernetes est dédiée à la configuration des certificats TLS.

### Les Network Policies (politiques réseau)

- **Par défaut**, les pods d'un cluster peuvent communiquer **librement** entre eux.
- Pour renforcer la sécurité, on met en place des **network policies** qui **restreignent les communications** entre pods.

### À retenir

- La sécurité commence par les **hôtes** (root désactivé, clés SSH, pas de mot de passe).
- Le **kube-apiserver** est le point central → deux axes : **authentification** (qui ?) et **autorisation** (quelles actions ?).
- **Authentification** : mots de passe, tokens, certificats, LDAP, service accounts.
- **Autorisation** : **RBAC** (principal), ABAC, webhooks.
- **TLS** sécurise toutes les communications inter-composants.
- **Network policies** : restreignent la communication entre pods (libre par défaut).

### Liens utiles

- Documentation officielle Kubernetes : https://kubernetes.io/docs/
- Kubernetes Basics (Qu'est-ce que Kubernetes ?) : https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
- Docker Hub : https://hub.docker.com/
- Terraform Registry : https://registry.terraform.io/
