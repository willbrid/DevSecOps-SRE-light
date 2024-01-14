# Concept d'état terraform

### Pourquoi l'État terraform est important

**Surveillance des ressources** : un moyen pour Terraform de garder un œil sur ce qui a été déployé. Essentiel à la fonctionnalité de Terraform.

### Etat terraform

- Stocké dans des fichiers plats, nommés par défaut **"terraform .tfstate"**.

- Aide Terraform à calculer le delta de déploiement et à créer de nouveaux plans de déploiement.
<br>

**NB** : Ne perdons jamais notre fichier d'état Terraform.