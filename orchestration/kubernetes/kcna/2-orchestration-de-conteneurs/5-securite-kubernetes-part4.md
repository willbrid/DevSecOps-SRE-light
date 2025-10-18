# Sécurité kubernetes (Part4)

- OPA Gatekeeper - Nous pouvons créer des politiques pour limiter ce qui peut être fait dans notre cluster. Gatekeeper valide les requêtes entrantes vers l'API conformément à nos politiques.
- L'outil OPA Gatekeeper existe en dehors de Kubernetes et peut être
utilisé dans d'autres contextes.
<br><br>
Si une organisation exploite Kubernetes, alors elle a probablement cherché des moyens de contrôler ce que les utilisateurs finaux peuvent faire sur le cluster et des moyens de s'assurer que les clusters sont conformes aux politiques de l'entreprise. Ces politiques peuvent être là pour répondre aux exigences de gouvernance et légales ou pour appliquer les meilleures pratiques et conventions organisationnelles. Avec Kubernetes, comment assurer la conformité sans sacrifier l'agilité de développement et l'indépendance opérationnelle ?

<br>

Par exemple, nous pouvons appliquer des règles telles que :

- toutes les images doivent provenir de référentiels approuvés
- tous les noms d'hôte d'Ingress doivent être uniques
- tous les pods doivent avoir la définition de limites de ressources
- tous les espaces de noms doivent avoir une étiquette qui répertorie un point de contact

Kubernetes permet de découpler les décisions de politique du serveur d'API au moyen de webhooks de contrôleur d'admission pour intercepter les demandes d'admission avant qu'elles ne soient conservées en tant qu'objets dans Kubernetes. Gatekeeper a été créé pour permettre aux utilisateurs de personnaliser le contrôle d'admission via la configuration, et non le code, et pour faire prendre conscience de l'état du cluster, et pas seulement de l'objet unique en cours d'évaluation au moment de l'admission. Gatekeeper est un webhook d'admission personnalisable pour Kubernetes qui applique les politiques exécutées par l'Open Policy Agent (OPA), un moteur de politique pour les environnements Cloud Native hébergés par la CNCF.

[https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/](https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/)