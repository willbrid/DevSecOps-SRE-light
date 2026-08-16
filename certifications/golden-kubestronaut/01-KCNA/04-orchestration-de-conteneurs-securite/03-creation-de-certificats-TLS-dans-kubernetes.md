# Création de certificats TLS dans Kubernetes

Ce guide montre comment **générer les certificats TLS** d'un cluster Kubernetes avec **OpenSSL** (choisi pour sa simplicité ; d'autres outils existent : **EasyRSA**, **CFSSL**).

### Le processus général (3 étapes récurrentes)

Pour **chaque** certificat, on suit toujours 3 étapes :
1. **Générer une clé privée** (`genrsa`) ;
2. **Créer une demande de signature (CSR)** (`req -new`) ;
3. **Signer** le CSR avec la CA (`x509 -req`).

### 1. Créer le certificat de l'autorité de certification (CA)

La **CA** signe tous les autres certificats. Elle est **auto-signée** (signée par sa propre clé) :

```bash
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt
```

→ Résultat : la clé `ca.key` et le certificat racine `ca.crt`.

### 2. Générer les certificats clients

#### Certificat de l'utilisateur admin

```bash
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=kube-admin" -out admin.csr
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt
```

> **Point important** : pour attribuer des **privilèges de groupe**, on précise l'**Organizational Unit (O)**. Ex. pour les droits admin :

```bash
openssl req -new -key admin.key -subj "/CN=kube-admin/O=system:masters" -out admin.csr
```

- Le **CN** (Common Name) = identité de l'utilisateur ;
- Le **O** (Organization) = **groupe** (ici `system:masters`, groupe admin).

#### Autres composants système

Même procédure pour Kube Scheduler, Controller Manager, Kube Proxy — leurs noms sont préfixés par **`system:`**.

Exemple:

```
kube-scheduler -> CN=system:kube-scheduler
kube-controller-manager -> CN=system:kube-controller-manager
```

### Utiliser les certificats pour communiquer

Appel REST direct à l'API server :

```bash
curl https://kube-apiserver:6443/api/v1/pods \
  --key admin.key --cert admin.crt --cacert ca.crt
```

Ou consolider dans un fichier **kubeconfig** :

```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: ca.crt
    server: https://kube-apiserver:6443
  name: kubernetes
users:
- name: kubernetes-admin
  user:
    client-certificate: admin.crt
    client-key: admin.key
```

### 3. Générer les certificats côté serveur

> Pour le **TLS mutuel (mTLS)**, client **et** serveur ont besoin d'une copie du **certificat public de la CA** pour vérifier l'authenticité des certificats présentés.

#### Certificat du serveur etcd

Générer un certificat `etcd-server` (+ certificats **peer** si cluster), référencés dans les options de démarrage d'etcd (`--cert-file`, `--key-file`, `--peer-cert-file`, `--trusted-ca-file`…).

#### Certificat du Kube API Server (point essentiel)

L'API server est connu sous **plusieurs noms** ; son certificat doit inclure tous ces **noms alternatifs (SAN)** :
- `kubernetes`
- `kubernetes.default`
- `kubernetes.default.svc`
- `kubernetes.default.svc.cluster.local`
- son adresse **IP**

Étapes :

```bash
openssl genrsa -out apiserver.key 2048
openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr
```

Créer un fichier de config `openssl.cnf` avec les `subjectAltName` :

```plaintext
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 172.17.0.87
```

Signer en incluant ces extensions :

```bash
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -out apiserver.crt -extensions v3_req -extfile openssl.cnf
```

#### Certificats du Kubelet

- Le **kubelet** (composant au niveau du nœud) a besoin de sa propre paire clé/certificat.
- Pour communiquer avec l'API server, les certificats suivent une **convention de nommage** : **`system:node:<nodeName>`**.
- Cette identité permet à l'API server d'attribuer les **permissions spécifiques au nœud**.

### À retenir

- **3 étapes** par certificat : clé (`genrsa`) → CSR (`req -new`) → signature (`x509 -req`).
- La **CA** est auto-signée et signe tout le reste.
- **CN** = identité, **O** = groupe (ex. `system:masters` pour l'admin).
- Le certificat de l'**API server** doit lister tous ses **noms alternatifs (SAN)** DNS et IP.
- Le **kubelet** utilise la convention **`system:node:<nodeName>`** pour ses permissions.
- Le **mTLS** exige que chaque composant possède le **certificat public de la CA**.
