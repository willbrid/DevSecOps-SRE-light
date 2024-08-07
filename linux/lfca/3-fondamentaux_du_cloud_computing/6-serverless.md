# Comprendre l'informatique sans serveur ou serverless

## Qu'est ce que l'informatique sans serveur ou serverless

- Le code est écrit pour se concentrer sur une tâche spécifique.

- Le code prend généralement la forme d'une fonction.

- Les applications/fonctions sont déclenchées par différents événements.

- Un fournisseur de cloud exécute le morceau de code en allouant dynamiquement des ressources.

- Le code s'exécute généralement dans un conteneur sans état.

- Les serveurs (ressources de calcul) sont abstraits.

- L'utilisateur n'est facturé que pour le nombre de ressources utilisées pour exécuter le code.

**Exemple d'architecture d'application web serverless sur AWS**

![lfca_4_7.png](../../images/lfca_4_7.png)

## comprendre les technologies et les outils du modèle serverless

- AWS Lambda

--- fournit un calcul piloté par les événements <br>
--- lambda peut être déclenché à partir de plus de 200 services AWS et applications SAAS <br>
--- prend en charge Node.js, Java, C #, Go, Powershell, Python, Ruby et l'API d'exécution pour une prise en charge supplémentaire des langages de programmation <br>
--- s'intègre et étend d'autres services AWS <br>
--- permet des services backend personnalisés, déclenchés à l'aide de l'API lambda <br> 
--- fournit une connexion aux bases de données relationnelles et aux systèmes de fichiers partagés <br>

- Google cloud functions

--- fournit des fonctions serverless basées sur les événements <br>
--- s'intègre à d'autres services Google <br>
--- s'intègre à Amazon Simple Notification Service (SNS) <br>
--- prend en charge les langages de programmation Node.js, Python, Go, Java, .NET, Go, Ruby et PHP <br>
--- autres plateformes serverless fournies par Google : App Engine et Cloud Run <br>

- Azure functions

--- fournit un environnement événementiel <br>
--- s'intègre à d'autres services Azure <br>
--- fournit un environnement d'exécution open source <br>
--- prend en charge les langages de programmation C#, Javascript, F#, Java, Python, Typescript et Powershell <br>
--- les autres offres serverless incluent kubernetes serverless et les environnements d'application serverless <br>

- Knative

--- plateforme open source basée sur kubernetes <br>
--- utilisé pour déployer et gérer des applications serverless <br>
--- capable de fonctionner sur n'importe quelle distribution kubernetes - empêche le verrouillage du fournisseur <br>
--- les principales caractéristiques sont le service et l'événementiel <br>

- OpenFaaS

--- vise à simplifier le déploiement du code et des fonctions sur kubernetes <br>
--- utilise docker comme runtime de conteneur <br>
--- fonctionne sur bare-métal, VM ou cloud <br>
--- les microservices et les fonctions peuvent être créés dans n'importe quel langage <br>

- Projets utilisant des conteneurs pour le serverless

--- Azure Container instances (ACI) <br>
--- AWS Fargate <br>
--- Kubeless <br>
--- Fission <br>
--- Fn Project <br>
--- Virtual Kubelet