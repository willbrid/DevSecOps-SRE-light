# Minimiser les rôles IAM
Rôles IAM : fournit des autorisations pour accéder aux ressources AWS.<br>
Les rôles IAM fournissent des autorisations et des informations d'identification que les utilisateurs et les applications peuvent utiliser pour accéder aux ressources au sein de la plate-forme cloud Amazon Web Services (AWS).<br>
Les applications exécutées sur la plate-forme AWS peuvent utiliser des rôles IAM pour obtenir des informations d'identification et accéder aux ressources dans AWS.<br>

Les conteneurs Kubernetes exécutés sur AWS peuvent accéder aux informations d'identification IAM.<br>
• Principe du moindre privilège - Assurons-nous que tous les rôles IAM attribués à nos EC2 ou à d'autres ressources pertinentes disposent uniquement des autorisations dont ils ont besoin, et pas plus.<br>
• Bloquer l'accès - Si nos applications Kubernetes n'ont pas besoin d'utiliser IAM, envisageons de bloquer l'accès aux informations d'identification IAM (pour EC2, adresse IP 169.254.169.254) via
firewall, NetworkPolicy.

