# Paramètres

Les paramètres d'un job **A** peuvent recevoir leur valeur de plusieurs manières :

- soit lors du build du job **A** : dans ce cas c'est l'utilisateur qui renseignera manuellement les valeurs qui peuvent être un nombre, une chaine de caractères ou un fichier...

- soit à partir d'un job **B** si celui-ci a été configuré comme job **upstream** au job **A** par déclenchement du build du job **A** avec transfert des paramètres dans un fichier, après le build avec succès du job **B**

Exemple illustré à l'article précédent.