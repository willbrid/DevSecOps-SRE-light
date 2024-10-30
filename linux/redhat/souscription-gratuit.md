# Obtenir un abonnement gratuit Red Hat Enterprise Linux Developer ou le renouveler

**Red Hat Enterprise Linux (RHEL)** est largement utilisé par les développeurs et entreprises pour sa stabilité et ses performances. **Red Hat** propose un abonnement gratuit via le **Red Hat Developer Program**, permettant aux développeurs d'accéder à une version complète de **RHEL** pour leurs projets et environnements de test. Nous suivrons les étapes pour obtenir un abonnement gratuit au programme **Red Hat Enterprise Linux Developer**, ou pour renouveler un abonnement existant. Ainsi, nous pourrons explorer, développer et tester nos applications sur RHEL tout en bénéficiant des fonctionnalités de la version commerciale, le tout sans frais.

### Etapes

Lorsque nous nous inscrivons sur le portail des développeurs **Red Hat** via le lien [https://developers.redhat.com/](https://developers.redhat.com/), nous avons droit à l'abonnement **Red Hat Developer** pour les particuliers. En étant déjà connecté sur le portail des développeurs **Red Hat**, nous avons cas 3 possibles :

- soit c'est de télécharger **RHEL** via le bouton **Download RHEL at no-cost** depuis la page [https://developers.redhat.com/products/rhel/hello-world/#fndtn-windows](https://developers.redhat.com/products/rhel/hello-world/#fndtn-windows)

- soit c'est d'utiliser une image box vagrant par exemple : **generic/rhel8**, puis d'aller sur la page [https://developers.redhat.com/products/rhel/download](https://developers.redhat.com/products/rhel/download) pour activer une souscription via le bouton **Activate your subscription**. Cette souscription permettra d'utiliser la commande ci-dessous qui est utilisée pour enregistrer un système **Red Hat** auprès du **Red Hat Subscription Management (RHSM)**, afin de lier ce système à un compte **Red Hat** et d'accéder aux souscriptions et aux dépôts de paquets associés. 

```
sudo subscription-manager register --username <login>
```

- soit c'est d'utiliser la sandbox **RHEL** directement sur le site de **Red Hat** via le lien [https://console.redhat.com/openshift/sandbox](https://console.redhat.com/openshift/sandbox)

**Référence :**
- [https://access.redhat.com/solutions/4078831](https://access.redhat.com/solutions/4078831)
- [https://developers.redhat.com/learning/learn:rhel:setting-red-hat-enterprise-linux-red-hat-developer-sandbox/resource/resources:prerequisites-step-step-guide](https://developers.redhat.com/learning/learn:rhel:setting-red-hat-enterprise-linux-red-hat-developer-sandbox/resource/resources:prerequisites-step-step-guide)