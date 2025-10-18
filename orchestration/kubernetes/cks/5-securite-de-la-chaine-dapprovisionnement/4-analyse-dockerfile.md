# Analyse d'un Dockerfile

L'analyse statique est le processus d'examen du code source ou de la configuration pour identifier les problèmes de sécurité potentiels.<br>
Une façon de renforcer la sécurité de nos images est d'analyser les Dockerfiles utilisés pour les créer.<br>

**Quelques éléments à rechercher** :

- **USER ROOT** : si la directive **USER** finale dans le Dockerfile est définie sur **root**, le processus de conteneur s'exécutera en tant que **root**. Donc pour éviter d'exécuter le conteneur en tant qu'utilisateur **root**, assurons-nous que la dernière directive **USER** dans le Dockerfile n'est pas définie sur **root** ou **0** . C'est généralement une bonne idée d'éviter cela.

- **tag *:latest*** : essayons d'éviter d'utiliser le tag *:latest* dans la directive **FROM** de notre Dockerfile. Au lieu de cela, faisons référence à une version de tag spécifique.

- **Logiciels inutiles** : assurons-nous que Dockerfile n'installe pas de logiciels ou d'outils inutiles dans l'image finale.

- **Données sensibles** : vérifions qu'aucune donnée sensible telle que des mots de passe ou des clés d'API n'est stockée dans l'image. Utilisons plutôt les secrets Kubernetes pour transmettre des données sensibles au conteneur lors de l'exécution.

Exemple d'un Dockerfile potentiellement vulnérable à corriger :

```
FROM nginx:1.19.10

USER root

RUN apt-get update && apt-get install -y wget
RUN useradd -ms /bin/bash nginxuser
ENV db_password=cool

USER root

ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Une correction de ce dockerfile consistera à :

- remplacer la deuxième occurrence de *USER root* par *USER nginx* .
- supprimer la ligne **RUN** qui installe le package *wget* inutile.
- supprimer la ligne **ENV** qui stocke un mot de passe à l'intérieur de l'image.

Au final, nous avons notre contenu Dockerfile :

```
FROM nginx:1.19.10

USER root

RUN useradd -ms /bin/bash nginxuser

USER nginx

ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```