# Initialisation du répertoire de travail

La commande **terraform init** permet d'initialiser le répertoire de travail qui contient notre code Terraform. <br>
Ce processus d'initialisation :
- télécharge les composants auxiliaires (modules et plugins)
- configure le backend pour stocker le fichier d'état Terraform, un mécanisme par lequel terraform suit les ressources.