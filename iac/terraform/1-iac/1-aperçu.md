# Aperçu de l'IAC et Terraform

IAC : Infrastructure As Code <br>

IaC est essentiellement un code qui déploie les ressources de notre infrastructure sur différentes plates-formes au lieu de les gérer manuellement via une interface utilisateur.

### Les avantages de l'IAC sont les suivants : 

- **plus de clic**

Ecrire ce que nous voulons déployer (VM, DISK, APPS) comme lisible par l'homme.

- **déclarer notre infrastructure**

L'infrastructure est la majorité des cas, écrite de manière déclarative via du code mais peut également être procédurale (impérative).

- **permettre le devops**

La codification du déploiement signifie qu'il peut être suivi dans le système de contrôle de version, ce qui améliore la visibilité et la collaboration entre les équipes.

- **rapidité, coût et risque réduit**

Moins d'intervention humaine pendant le déploiement signifie moins de risques de failles de sécurité, de ressources superflues et plus de temps gagné.

 ### IAC avec terraform

 Terraform ne se soucie pas de la méthode de déploiement cloud ou d'infrastructure que nous utilisons. Il fonctionne de manière transparente avec une longue (et croissante) liste de plates-formes cloud. <br>
 Terraform utilise son propre langage connu sous le nom de langage de configuration HashiCorp (**HCL : HashiCorp Configuration Language**).