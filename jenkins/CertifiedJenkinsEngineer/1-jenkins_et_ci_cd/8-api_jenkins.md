# Api jenkins

Jenkins fournit une API de style REST consommable par la machine pour interagir par programmation avec le serveur jenkins.
<br>
Jenkins expose une interaction api rest en envoyant des méthodes rest à l'url jenkins.

**Exemple**

```
curl jenkins:8080/jobs/jobname/buildnumber. -user username:password
```

**Pourquoi utiliser l'api** 
- L'api permet de créer des jobs de manière programmatique. Une fois le job défini en tant que code, il peut être vérifié dans la source, versionné et géré. 

- Les job peuvent être copiés et ainsi, une fois qu'un pipeline a été standardisé, il peut être reproduit sans configuration manuelle.

- L'api peut être exploitée pour faciliter la création de rapports sur l'état de la file d'attente de construction et la charge sur les serveurs Jenkins, afin de déterminer s'il y a des problèmes.

- L'api fournit aux administrateurs une méthode pour redémarrer jenkins sans leur demander d'avoir un accès ssh à l'infrastructure sous-jacente sur laquelle jenkins s'exécute.