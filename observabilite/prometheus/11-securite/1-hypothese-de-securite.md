# Hypothèse de sécurité prometheus

Quelques considérations sur la sécurité du serveur prometheus :

- Le serveur prometheus ne fournit pas d'authentification prête à l'emploi. Toute personne pouvant accéder aux endpoints http du serveur a accès à toutes nos données de séries chronologiques.

- Le serveur prometheus ne fournit pas le chiffrement tls. Les communications non chiffrées entre les clients et prometheus sont vulnérables à la lecture de données non chiffrées et aux attaques de l'homme du milieu.

- si nos endpoints prometheus sont ouverts sur un réseau avec des clients potentiellement non fiables, nous pouvons ajouter notre propre couche de sécurité au-dessus du serveur prometheus à l'aide d'un reverse-proxy avec par exemple **nginx**.

<br>

Quelques considérations sur la sécurité d'Alertmanager :

- comme le serveur prometheus alertmanager ne fournit pas d'authentification ou de chiffrement tls.
- utilisons un reverse-proxy pour ajouter notre propre couche de sécurité, si nécessaire.

<br>

Quelques considérations sur la sécurité de Pushgateway :
- pushgateway ne fournit pas non plus d'authentification ni de chiffrement tls.
- de même nous pouvons utiliser un reverse-proxy pour ajouter notre propre couche de sécurité, si nécessaire

<br>

Quelques considérations sur la sécurité des exportateurs :

- de nombreux exportateurs fournissent une authentification et/ou un chiffrement tls
- consultons la documentation de nos exportateurs pour en savoir plus sur les fonctions de sécurité de base
- sans sécurité, les données fournies par les exportateurs peuvent être lues par toute personne ayant accès au endpoint des métriques.