# Ecriture et test des règles Sentinel

- Définissons une règle sentinel sur les jours (de Lundi à Vendredi) et heures (de 8h00 à 16h00) de travail

```
vim our-policy.sentinel
```

```
import "time"

workdays = rule {
    time.now.weekday > 0 and time.now.weekday < 6
}

workhours = rule {
    time.now.hour > 8 and time.now.hour < 16
}

main = rule {
    workdays and workhours
}
```

- Téléchargeons et installons le binaire sentinel **0.21.0**

```
sudo yum install wget unzip
```

```
wget https://releases.hashicorp.com/sentinel/0.21.0/sentinel_0.21.0_linux_amd64.zip
```

```
sudo unzip sentinel_0.21.0_linux_amd64.zip -d /usr/local/bin
```

Pour vérifier l'installation du binaire sentinel, nous faisons

```
sentinel --version
```

- Créons le répertoire de test de notre règle et écrivons ses tests

```
mkdir -p test/our-policy
```

```
vim test/our-policy/fail.json
```

```
{
    "mock": {
        "time": {
            "now": {
                "weekday": 6,
                "hour": 20
            }       
        }
    },
    "test": {
        "main": false
    }       
} 
```

```
vim test/our-policy/success.json
```

```
{
    "mock": {
        "time": {
            "now": {
                "weekday": 3,
                "hour": 13
            }       
        }
    },
    "test": {
        "main": true
    }       
} 
```

- Exécutons notre test

```
sentinel test
```

```
# Résultat
PASS - our-policy.sentinel
  PASS - test/our-policy/fail.json
  PASS - test/our-policy/success.json
1 tests completed in 1.664455ms
```