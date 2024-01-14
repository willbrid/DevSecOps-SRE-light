# Ressource personnalisée
Les ressources personnalisées sont des extensions de l'API Kubernetes.<br>
Un *CustomResourceDefinition* définit une ressource personnalisée.<br>

- créons un objet *CustomResourceDefinition*
```
vi beehives.yml
```

```
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  # Le nom doit correspondre aux champs de spécification ci-dessous et se présenter sous la forme : <plural>.<group>
  name: beehives.acloud.guru
spec:
  # Nom de groupe à utiliser pour l'API REST : /apis/<group>/<version>
  group: acloud.guru
  names:
    # Nom pluriel à utiliser dans l'URL : /apis/<group>/<version>/<plural>
    plural: beehives
    # Nom singulier à utiliser dans l'URL : /apis/<group>/<version>/<singular>
    singular: beehive
    # kind est normalement le type singulier CamelCased. Nos manifestes de ressources utilisent ceci.
    kind: BeeHive
    # shortNames permet à une chaîne plus courte de correspondre à votre ressource sur la CLI
    shortNames:
    - hive
  # Deux valeurs possibles : soit Namespaced ou Cluster  
  scope: Namespaced
  # Liste des versions prises en charge par cette CustomResourceDefinition
  versions:
  - name: v1
    # Chaque version peut être activée/désactivée par l'option served.
    served: true
    # Une et une seule version doit être marquée comme version de stockage.
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              supers:
                type: integer
              bees:
                type: integer
```

```
kubectl apply -f beehives.yml
```

Nous pouvons lister les ressources crd :
```
kubectl get crd
```

- créons un objet en utilisant notre nouveau CRD <br>
```
vi test-beehive.yml
```

```
apiVersion: acloud.guru/v1
kind: BeeHive
metadata:
  name: test-beehive
spec:
  supers: 3
  bees: 60000
```

```
kubectl apply -f test-beehive.yml
```

Nous pouvons interagir avec notre objet personnalisé à l'aide des commandes kubectl.
```
kubectl get beehives
kubectl get hive
kubectl describe beehive test-beehive
```