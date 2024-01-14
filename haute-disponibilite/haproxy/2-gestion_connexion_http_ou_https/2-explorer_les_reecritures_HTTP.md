# Explorer les réécritures HTTP à l'aide de HAProxy

**Contexte** : Notre manager nous a dit que nous devions nettoyer tous les fichiers non essentiels à la racine de nos sites. Nous avons un fichier qui doit être déplacé, mais nous devons pouvoir continuer à prendre en charge les demandes le concernant à son emplacement actuel.

- Déplaçons notre fichier **/test.txt**

Nous allons créer un nouveau sous-répertoire sur le site, **/textfiles** , et y déplacer notre fichier **test.txt**. Nous traiterons les requêtes pour le fichier dans son emplacement d'origine, **/test.txt** , en utilisant une réécriture HTTP dans HAProxy. <br>

--- Commençons par créer le nouveau sous-répertoire **/textfiles** dans chaque conteneur sur notre serveur haproxy

```
vi ~/createNewDirectory.sh
```

```
#!/bin/bash

for site in `seq 1 2` 
do 
  for server in `seq 1 3`
  do 
    podman exec site$site\_server$server mkdir /usr/share/nginx/html/textfiles 
  done 
done
```

```
chmod +x createNewDirectory.sh
./createNewDirectory.sh
```

--- Ensuite, nous allons déplacer le fichier **test.txt** dans le sous-répertoire **/textfiles** se trouvant dans chaque conteneur sur notre serveur haproxy

```
vi ~/moveFileToDirectory.sh
```

```
#!/bin/bash

for site in `seq 1 2` 
do 
  for server in `seq 1 3`
  do 
    podman exec site$site\_server$server mv -v /usr/share/nginx/html/test.txt /usr/share/nginx/html/textfiles 
  done 
done
```

```
chmod +x moveFileToDirectory.sh
./moveFileToDirectory.sh
```

--- Vérifions si nous avons bien déplacer le fichier **test.txt** par exemple sur le conteneur site1_server1

```
podman exec -it site1_server1 /bin/bash
```

```
ls -la /usr/share/nginx/html
ls -la /usr/share/nginx/html/textfiles
exit
```

--- Vérifions à nouveau notre site ( **/test.txt** ), en utilisant curl sur la machine client

```
ssh vagrant@192.168.56.7
```

```
curl -s http://192.168.56.8:8000/test.txt
curl -s http://192.168.56.8:8100/test.txt
```

Nous constatons que le fichier **test.txt** n'est plus disponible à l'emplacement d'origine. <br>

--- Vérifions le nouvel emplacement ( /textfiles/test.txt ), en utilisant curl sur la machine client

```
curl -s http://192.168.56.8:8000/textfiles/test.txt
curl -s http://192.168.56.8:8100/textfiles/test.txt
```

Le fichier **test.txt** est disponible dans le nouvel emplacement (**/textfiles/test.txt**). Cependant nous aimerions également qu'il soit disponible via l'URL d'origine (**/test.txt**).

- Créeons une règle de réécriture HTTP

Nous pouvons gérer les modifications de notre backend HTTP en utilisant la capacité de HAProxy à réécrire le trafic HTTP qu'il utilise comme proxy. HAProxy fonctionne au niveau des couches d'application HTTP, 5 à 7, de sorte qu'il peut inspecter et manipuler les paquets dans ces couches. <br>

--- Nous allons apporter la modification suivante à notre fichier **/etc/haproxy/haproxy.cfg**

```
vi /etc/haproxy/haproxy.cfg
```

```
# Site Frontends
frontend site1
  bind *:8000
  default_backend site1
  acl p_ext_txt path_end -i .txt
  acl p_folder_textfiles path_beg -i /textfiles/
  http-request set-path /textfiles/%[path] if !p_folder_textfiles p_ext_txt

frontend site2
  bind *:8100
  default_backend site2
  acl p_ext_txt path_end -i .txt
  acl p_folder_textfiles path_beg -i /textfiles/
  http-request set-path /textfiles/%[path] if !p_folder_textfiles p_ext_txt
```

Redémarrons HAProxy pour récupérer notre changement de configuration

```
sudo systemctl restart haproxy
```

Nous avons ajouté la réécriture suivante à chacune de nos sections frontend :

```
acl p_ext_txt path_end -i .txt
acl p_folder_textfiles path_beg -i /textfiles/
http-request set-path /textfiles/%[path] if !p_folder_textfiles p_ext_txt
```

Cette réécriture modifie le chemin d'URL des fichiers texte ( ***.txt** ) vers le répertoire **/textfiles/** sur le serveur Web s'il n'est pas déjà défini sur **/textfiles/** .
<br>

--- Vérifions l'emplacement d'origine ( **/test.txt** ) et le nouvel emplacement ( **/textfiles/test.txt** ) en utilisant curl sur la machine client (192.168.56.7)

```
curl -s http://192.168.56.8:8000/test.txt
curl -s http://192.168.56.8:8100/test.txt
```

```
curl -s http://192.168.56.8:8000/textfiles/test.txt
curl -s http://192.168.56.8:8100/textfiles/test.txt
```

Nous constatons que le fichier **test.txt** est maintenant disponible à l'emplacement d'origine. Et le fichier **test.txt** est également disponible dans le nouvel emplacement, car la réécriture ignore la demande puisque l'URL est déjà définie sur **/textfiles/** .