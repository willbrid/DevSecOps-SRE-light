# Comprendre le protocole mTLS de pod à pod

**Mutual Transport Layer Security** (mTLS) signifie que les deux parties communicantes s'authentifient pleinement et que toutes les communications sont chiffrées. <br>

Signature de certificat
- API Kubernetes : il nous permet d'obtenir des certificats que nous pouvons utiliser dans nos applications.
- Autorité de certification : les certificats fournis par l'API seront générés à partir d'une autorité de certification (CA) centrale, que nous pouvons utiliser à des fins de confiance.
- Certificats programmatiques : nous pouvons obtenir des certificats par programmation à l'aide de l'API.