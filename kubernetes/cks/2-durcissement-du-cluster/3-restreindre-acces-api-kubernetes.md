# Restreindre l'accès à l'API Kubernetes
L'API Kubernetes est une interface HTTP vers le cluster. <br>

- Utilisons RBAC pour limiter les autorisations des utilisateurs à ce qui est nécessaire. Si un compte est compromis, cela limitera ce que l'attaquant peut faire.
- Limitons l'accès réseau à l'API Kubernetes à l'aide de la segmentation/des pare-feu du réseau. Cela empêche même les attaquants d'essayer d'atteindre l'API.
- Utilisons RBAC pour contrôler les autorisations des utilisateurs au sein de l'API Kubernetes. 
- Assurons-nous que les comptes ne disposent pas d'autorisations dont ils n'ont pas besoin.
- Limitons l'accès réseau à l'API Kubernetes pour empêcher les attaquants de pouvoir communiquer avec elle.