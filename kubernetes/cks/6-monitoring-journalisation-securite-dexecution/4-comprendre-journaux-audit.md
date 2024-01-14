# Présentation des journaux d'audit

Que sont les journaux d'audit ?
Les journaux d'audit sont un enregistrement chronologique des actions effectuées via l'API Kubernetes. Ils sont utiles pour voir ce qui se passe dans notre cluster en temps réel (c'est-à-dire la détection des menaces) ou pour examiner ce qui s'est passé dans le cluster après coup (c'est-à-dire l'analyse post-mortem).<br>

Exemple d'objet *Policy* :
```
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: RequestResponse
  resources:
  - group: ""
    resources: ["pods", "services"]
  namespaces: ["test"]
```

La stratégie d'audit comprend un ensemble de règles qui déterminent les événements consignés et le niveau de détail des journaux.<br>

- *level* - le niveaux de détail des journaux de la règle : <br>
--- None : ne rien enregistrer.<br>
--- Metadata : enregistrer uniquement les données de haut niveau.<br>
--- Request : enregistrer les métadonnées et le corps de la requête.<br>
--- RequestResponse : métadonnées du journal, corps de la requête et corps de la réponse. <br>

- *resources* - fait correspondre les types d'objets Kubernetes avec la règle applicable. <br>

- *namespaces* - (facultatif) limite la règle à un ou plusieurs espaces de noms.