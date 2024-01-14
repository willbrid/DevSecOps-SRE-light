# Configuration de la journalisation d'audit

Nous pouvons configurer la journalisation d'audit en transmettant des indicateurs à kube-apiserver. <br>
• **--audit-policy-file** : pointe vers le fichier de configuration de la stratégie d'audit.<br>
• **--audit-log-path** : L'emplacement des fichiers de sortie du journal.<br>
• **--audit-log-maxage** : Le nombre de jours de conservation des anciens fichiers journaux.<br>
• **--audit-log-maxbackup** : Le nombre d'anciens fichiers journaux à conserver.<br><br>

Le fichier de configuration de la stratégie d'audit définit les règles d'audit. L'emplacement du fichier est déterminé par l'indicateur *--audit-policy-file* transmis à kube-apiserver.<br><br>

créons un fichier de configuration de stratégie d'audit :

```
sudo vi /etc/kubernetes/audit-policy.yaml
```

Voici un exemple de configuration de stratégie tiré de la documentation Kubernetes :

```
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
# Log changes to Namespaces at the RequestResponse level.
- level: RequestResponse
  resources:
  - group: ""
    resources: ["namespaces"]
# Log pod changes in the audit-test Namespace at Request level
- level: Request
  resources:
  - group: ""
    resources: ["pods"]
  namespaces: ["audit-test"]
# Log all ConfigMap and Secret changes at the Metadata level.
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]
# Catch-all - Log all requests at the metadata level.
- level: Metadata
```

Configurons l'audit pour kube-apiserver :

```
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

Après la ligne **-kube-apiserver**, ajoutons des indicateurs de ligne de commande pour configurer la journalisation d'audit :

```
- command:
  - kube-apiserver
  - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
  - --audit-log-path=/var/log/k8s-audit/k8s-audit.log
  - --audit-log-maxage=30
  - --audit-log-maxbackup=10
```

Créons le répertoire **k8s-audit**

```
sudo mkdir /var/log/k8s-audit
```

Montons des volumes pour permettre à kube-apiserver d'accéder à la configuration d'audit et au répertoire de sortie du journal d'audit :

```
volumes:
- name: audit-config
  hostPath:
    path: /etc/kubernetes/audit-policy.yaml
    type: File
- name: audit-log
  hostPath:
    path: /var/log/k8s-audit
    type: DirectoryOrCreate
```

```
volumeMounts:
- name: audit-config
  mountPath: /etc/kubernetes/audit-policy.yaml
  readOnly: true
- name: audit-log
  mountPath: /var/log/k8s-audit
  readOnly: false
```

Affichons les journaux d'audit :

```
sudo tail -f /var/log/k8s-audit/k8s-audit.log
```