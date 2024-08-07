# PAAS

## Qu'est ce que PAAS (Platform as a service)

La plateforme fournit les services suivants :

- la gestion de l'infrastructure
- les outils de développement
- les outils de déploiement
- les technologies d'analyse commerciale
- les services de base de données
- les services middleware
- les environnements d'exécution

**Exemple de PASS** : Aws Elastic Beanstalk, Google App Engine, Microsoft Azure

## Comparaison entre l'IAAS, le PAAS et le modèle sur site

<table>
  <thead>
    <tr>
      <th>Sur site</th>
      <th>IAAS</th>
      <th>PAAS</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>$${\color{orange}Applications}$$</td>
      <td>$${\color{orange}Applications}$$</td>
       <td>$${\color{orange}Applications}$$</td>
    </tr>
    <tr>
      <td>$${\color{orange}Data}$$</td>
      <td>$${\color{orange}Data}$$</td>
      <td>$${\color{orange}Data}$$</td>
    </tr>
    <tr>
      <td>$${\color{orange}Runtime}$$</td>
      <td>$${\color{orange}Runtime}$$</td>
      <td>$${\color{green}Runtime}$$</td>
    </tr>
    <tr>
      <td>$${\color{orange}Middleware}$$</td>
      <td>$${\color{orange}Middleware}$$</td>
      <td>$${\color{green}Middleware}$$</td>
    </tr>
    <tr>
      <td>$${\color{orange}O/S}$$</td>
      <td>$${\color{orange}O/S}$$</td>
      <td>$${\color{green}O/S}$$</td>
    </tr>
    <tr>
      <td>$${\color{orange}Virtualisation}$$</td>
      <td>$${\color{green}Virtualisation}$$</td>
      <td>$${\color{green}Virtualisation}$$</td>
    </tr>
    <tr>
      <td>$${\color{orange}Serveurs}$$</td>
      <td>$${\color{green}Serveurs}$$</td>
      <td>$${\color{green}Serveurs}$$</td>
    </tr>
    <tr>
      <td>$${\color{orange}Stockage}$$</td>
      <td>$${\color{green}Stockage}$$</td>
      <td>$${\color{green}Stockage}$$</td>
    </tr>
    <tr>
      <td>$${\color{orange}Réseau}$$</td>
      <td>$${\color{green}Réseau}$$</td>
      <td>$${\color{green}Réseau}$$</td>
    </tr>
  </tbody>
</table>

Avec PAAS, seul les éléments : **runtime**, **middleware**, **O/S**, **virtualisation**, **serveurs**, **stockage** et **réseau** sont gérés par le fournisseur.

## Les avantages et fonctionnalités du PAAS

- met davantage l'accent sur le développement d'applications

- offre un accès global à l'environnement de développement

- réduit la complexité

- augmente la vitesse de livraison

- simplifie la gestion du cycle de vie des applications

- réduit le besoin d'administration du système