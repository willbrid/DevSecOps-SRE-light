# Explorer la sécurité au niveau du réseau
Kubernetes utilise un réseau de cluster virtuel pour permettre aux pods de communiquer librement et de manière transparente avec d'autres pods et services, quel que soit le nœud sur lequel ils se trouvent.<br>

Limitons l'accès au réseau du cluster depuis l'extérieur du cluster. Toute personne pouvant accéder au réseau du cluster peut accéder à n'importe quel pod du cluster !