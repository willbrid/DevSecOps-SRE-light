# Gestion d'un job et cronjob
Un Job est conçu pour exécuter une tâche conteneurisée avec succès jusqu'à son achèvement.<br>
Les CronJobs exécutent des Jobs périodiquement selon un calendrier.<br>
Le *restartPolicy* d'un Pod Job ou CronJob doit être *OnFailure* ou *Never* .<br>
Utilisez *activeDeadlineSeconds* dans la spécification du job pour mettre fin au job s'il s'exécute trop longtemps.

## Création d'un job
Nous créons un simple Job qui exécute la commande *echo bienvenue sur mon blog !*

```
vi mon-job.yml
```

```
apiVersion: batch/v1
kind: Job
metadata:
  name: mon-job
spec:
  template:
    spec:
      containers:
      - name: print
        image: busybox:stable
        command: ["echo", "bienvenue sur mon blog !"]
      restartPolicy: Never
  backoffLimit: 4
  activeDeadlineSeconds: 10
```

```
kubectl apply -f mon-job.yml
```

Nous pouvons checker le statut du job :
```
kubectl get jobs
```

Nous pouvons voir les logs du job :
```
kubectl get pods
```

```
kubectl logs $JOB_POD_NAME
```

## Création d'un cronjob
Nous créons un simple cronjob qui exécute le job ci-dessus toutes les minutes.

```
vi mon-cronjob.yml
```

```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mon-cronjob
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: print
            image: busybox:stable
            command: ["echo", "This is a test!"]
          restartPolicy: Never
      backoffLimit: 4
      activeDeadlineSeconds: 10
```

```
kubectl apply -f mon-cronjob.yml
```

Nous pouvons checker le statut du cronjob :
```
kubectl get cronjob
```