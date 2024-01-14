# Certificats de signature

Demander et signer des certificats

- **CertificateSigningRequest** : le demandeur crée un objet **CertificateSigningRequest** pour demander un nouveau certificat.
- **Approve/Deny** : L'objet **CertificateSigningRequest** peut être approuvée ou refusée. Nous gérons, approuvons ou refusons les demandes via la ligne de commande : **kubectl certificate**. Une fois approuvé, le certificat signé peut être récupéré à partir du champ **status.certificate** de l'objet **CertificateSigningRequest**.
- **RBAC** : les autorisations liées à la signature de certificat peuvent être gérées via le contrôle d'accès basé sur les rôles (RBAC).

## Créer une demande de signature de certificat

Installons **cfssl**.

- Sous **Ubuntu 20.04**

```
sudo apt-get install -y golang-cfssl
```

- Sous **Rocky 8.x** (cfssl version 1.6.4)

```
sudo curl -s -L -o /bin/cfssl-bundle https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl-bundle_1.6.4_linux_amd64
sudo curl -s -L -o /bin/cfssl-certinfo https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl-certinfo_1.6.4_linux_amd64
sudo curl -s -L -o /bin/cfssl-newkey https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl-newkey_1.6.4_linux_amd64
sudo curl -s -L -o /bin/cfssl-scan https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl-scan_1.6.4_linux_amd64
sudo curl -s -L -o /bin/cfssljson https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssljson_1.6.4_linux_amd64
sudo curl -s -L -o /bin/cfssl https://github.com/cloudflare/cfssl/releases/download/v1.6.4/cfssl_1.6.4_linux_amd64
sudo curl -s -L -o /bin/cfssl-mkbundle https://github.com/cloudflare/cfssl/releases/download/v1.6.4/mkbundle_1.6.4_linux_amd64
```

```
sudo chmod +x /bin/cfssl*
```

Générons un fichier CSR.

```
cat <<EOF | cfssl genkey - | cfssljson -bare server
{
  "hosts": [
    "tls-svc.tls-test.svc.cluster.local",
    "tls-pod.tls-test.pod.cluster.local",
    "192.0.2.24",
    "10.0.34.2"
  ],
  "CN": "system:node:tls-pod.tls-test.pod.cluster.local",
  "key": {
    "algo": "ecdsa",
    "size": 256
  },
  "names": [
    {
      "O": "system:nodes"
    }
  ]
}
EOF
```

Obtenons le CSR codé en base64.

```
cat server.csr | base64
```

créons une demande de signature de certificat k8s.

```
vi tls-svc-csr.yml
```

```
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: tls-svc-csr
spec:
  request: <base64-encoded csr>
  signerName: kubernetes.io/kubelet-serving
  usages:
  - digital signature
  - key encipherment
  - server auth
```

```
kubectl create -f tls-svc-csr.yml
```

Affichons l'état de la demande

```
kubectl get csr
```

## Approuver la demande de signature de certificat

Approuvons la demande

```
kubectl certificate approve tls-svc-csr
```

Récupérons les données du certificat signé.

```
kubectl get csr tls-svc-csr -o yaml
kubectl get csr tls-svc-csr -o jsonpath='{.status.certificate}' | base64 --decode
```