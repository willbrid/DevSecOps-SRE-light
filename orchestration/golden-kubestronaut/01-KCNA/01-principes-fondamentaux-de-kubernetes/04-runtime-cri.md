# Runtime CRI

L'**interface de runtime de conteneur (CRI, Container Runtime Interface)** est un composant fondamental qui permet à Kubernetes de prendre en charge **différents runtimes de conteneurs** sans modifier son code source principal.

### Contexte historique et évolution

- À l'origine, **Docker** était la solution la plus populaire grâce à sa simplicité, et Kubernetes était conçu pour orchestrer exclusivement des conteneurs Docker.
- Avec la montée en popularité de Kubernetes, de nouveaux runtimes (comme **Rocket/Rkt** et **containerd**) ont émergé et nécessitaient une intégration.
- Pour répondre à ce besoin, Kubernetes a introduit le **CRI**.

Docker Shim était maintenu uniquement pour assurer la rétrocompatibilité. À mesure que Kubernetes évoluait vers une approche plus agnostique vis-à-vis des environnements d'exécution de conteneurs, la dépendance à Docker Shim a été abandonnée. Dans la version 1.24 de Kubernetes, Docker Shim a été officiellement supprimé et la prise en charge native de Docker a été abandonnée. Toutefois, les images Docker restent compatibles car elles respectent la norme OCI, ce qui signifie qu'elles peuvent être utilisées avec d'autres environnements d'exécution de conteneurs, tels que **ContainerD**.

### Fonctionnement du CRI

Le **CRI** définit une **interface de plugin** que tout fournisseur peut implémenter, à condition de respecter les standards de l'**Open Container Initiative (OCI)**. Il repose sur une **API gRPC** utilisée par le **kubelet** de Kubernetes pour gérer les **images**, les **conteneurs** et le **réseau**.

Ainsi, les runtimes peuvent fonctionner indépendamment de Kubernetes, laissant aux architectes la liberté de choisir la solution la plus adaptée.

### Docker et le Docker Shim

- En raison de la large adoption de Docker, Kubernetes a maintenu sa compatibilité via une couche intermédiaire temporaire appelée **Docker Shim**.
- Cette couche permettait à Docker de communiquer avec Kubernetes sans utiliser directement le CRI, assurant la continuité des workflows existants.
- Le Docker Shim n'était maintenu que pour la **rétrocompatibilité**. Il a été officiellement **supprimé dans Kubernetes 1.24**, mettant fin au support natif de Docker.
- **Important** : les **images Docker restent compatibles**, car elles respectent le standard OCI et fonctionnent avec d'autres runtimes comme containerd.

### Vers un support natif du CRI

Les utilisateurs sont désormais encouragés à adopter des runtimes qui **supportent nativement le CRI**. Cette évolution :
- améliore la compatibilité et la standardisation ;
- réduit la dépendance à un fournisseur unique (**vendor lock-in**) ;
- offre le choix parmi plusieurs runtimes (containerd, CRI-O, gVisor, Kata Containers, etc.).

### Conclusion

Le CRI a ouvert la voie à une **compatibilité et une flexibilité accrues** dans l'écosystème des conteneurs. En permettant l'utilisation de runtimes variés, il évite les limitations propriétaires et favorise l'innovation dans la gestion des conteneurs.
