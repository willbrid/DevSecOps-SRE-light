# Concepts clés de Terraform

### Revoir notre code Terraform : terraform plan

- Lit le code puis crée et affiche un plan d'exécution/déploiement. cette commande ne déploie rien. Considérons ceci comme une commande en lecture seule.

- Permettre à l'utilisateur de revoir le plan d'action avant d'exécuter quoi que ce soit

- A ce stade, des identifiants d'authentification sont utilisés pour se connecter à notre infrastructure, si nécessaire

### Déployer notre code Terraform : terraform apply

- Déploie les instructions dans le code

- Mettre à jour le fichier du mécanisme de suivi de l'état du déploiement

### Nettoyer notre déploiement Terraform : terraform destroy

- Examine le fichier d'état enregistré et stocké créé lors du déploiement et détruit toutes les ressources créées par notre code

- Doit être utilisé avec prudence, car il s’agit d’une commande irréversible. Effectuons des sauvegardes et assurons-nous que nous souhaitons supprimer l'infrastructure