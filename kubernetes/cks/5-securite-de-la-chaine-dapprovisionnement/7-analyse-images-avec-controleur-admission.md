# Analyse d'images avec un contrôleur d'admission

- **Contrôleurs d'admission** : ils interceptent les requêtes adressées à l'API Kubernetes. Ils peuvent approuver, refuser ou modifier les requêtes avant que les modifications ne soient réellement apportées.<br>

- Le contrôleur **ImagePolicyWebhook** envoie une requête à un **webhook externe** contenant des informations sur l'image utilisée. Il nous permet d'utiliser une logique personnalisable pour approuver ou refuser la création de charges de travail en fonction de l'image de conteneur utilisée.<br>
Le webhook peut approuver ou refuser la création de la charge de travail basée sur l'image.<br>
Cette fonctionnalité peut être utilisée pour analyser automatiquement les images et refuser les charges de travail en cas de vulnérabilités graves. Autrement dit nous pouvons utiliser le contrôleur d'admission **ImagePolicyWebhook** pour qu'une application externe analyse automatiquement les images à la recherche de vulnérabilités lors de la création des charges de travail.