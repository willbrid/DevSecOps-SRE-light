# Aperçu des formats de règle

Il existe 2 types de règle : des règles **ACL** et des règles **sentinel**.
Ils ont des caractéristiques distinctives entre elles, mais le principal élément qui les différencie est que l'un est réservé aux **entreprises**, tandis que l'autre, **n'importe qui peut l'utiliser**. Une autre chose qui les distingue est la **granularité du contrôle** qu'elles permettent.

<br>

Les fichiers de configuration des règles sont définis avec l'extension **.hcl** : **HashiCorp Configuration Langage**. Il est entièrement compatible avec **JSON**; d'où **JSON** est également une entrée valide.
<br>

- Règles **ACL**

**Exemple de contenu d'un fichier de règles ACL**

```
path "sys/auth/*"
{
    capabilities = ["create", "update", "delete", "sudo"]
}

path "sys/auth/"
{
    capabilities = ["read"]
}
```

L'ACL est basée sur le **path**. Nous ne pouvons donc accorder des autorisations que sur un **path** particulier. <br>
Dans l'exemple, l'autorisation **sudo** nous permet vraiment d'avoir accès si quelque chose est sous **root**. Nous aurons besoin d'autorisations basées sur **sudo** pour y mener des actions.
<br>
N'oublions pas que si une règle n'est pas définie ou si une autorisation n'est pas définie dans une règle, la valeur par défaut est de refuser.
<br>
L'astérisque dans le premier **path** représente ici un joker, ce qui signifie que tout ce qui vient après ce **path** est sensible à ces autorisations énumérées. 
<br>
Via l'autre chemin où il est écrit **sys/auth**, nous constatons que nous pouvons également avoir une autorisation unique (**read** ici).

- Règles **Sentinel**

Nous ne pouvons les utiliser que dans l'édition **Vault Enterprise** : nous pouvons soit utiliser un essai de 30 jours, soit nous pouvons utiliser un émulateur, ou soit nous pouvons réellement payer pour l'édition Enterprise.
<br>
Les règles **Sentinel** nous permettront d'avoir un contrôle précis. Ce qui signifie que nous aurons des règles, qui ne sont pas simplement basées sur les **path**, mais qui nous permettent également de prendre des décisions logiques sur les **path**. Donc avec **Sentinel**, nous pouvons disposer de contrôles beaucoup plus précis en termes d'interprétation des demandes, puis de prise de décisions, en fonction des propriétés de ces demandes.
<br>

**Exemple concrèt d'utilisation** 

Imaginons que nous avons 2 entreprises qui ont 2 fuseaux horaires complètement différents. Nous avons un groupe de personnes qui travaille aux États-Unis, un autre groupe de personnes qui travaille en Europe. Nous pourrions avoir une règle **Sentinel** indiquant que les personnes aux États-Unis ne peuvent accéder qu'à certaines choses à partir de Vault pendant leurs heures de travail, et en dehors de ces heures de travail, ils ne peuvent pas faire cela. Et les Européens peuvent avoir accès à ces mêmes choses pendant des heures de travail différentes. Ces règles peuvent être définies en utilisant les adresses IP.

```
# Exemple avec un pseudo code
import "<lib>"

<var> = <val>

main = rule {
    <conditions_to_value>
}
```