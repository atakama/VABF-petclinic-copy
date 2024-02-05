# Application de démo VABF "Petclinic"

## Installation et paramétrage

### Vérification de l'accès au registre d'images

Assurez-vous d'avoir accès au registre privé Atakama en effectuant la commande suivante :
`curl -u 'atk:Atakam@2024' https://registry.atakama-technologies.com/v2/_catalog`
Le résultat attendu est la liste des images présentes sur le registre. Par exemple :
```
{
  "repositories": [
    "image1",
    "image2"
  ]
}
```
  
### Configuration de l'application

Les paramètres suivants sont modifiables :
- `ports : "8080:8080"` : Ports exposés par le conteneur. (Ne pas modifier la partie de droite)
- `volumes: "./agent/:/spring-petclinic/nudge-agent"` : Volume de la sonde PH Nudge. Permet aussi le stockage et le visionnage des logs. (Ne pas modifier la partie de droite)
- `vabf-nudge: ipam: config: subnet: "172.42.0.0/16"` : Sous-réseau du conteneur. Ne modifier qu'en cas de conflits.

### Configuration de la sonde PH Nudge Java

Modifiez le fichier de configuration de l'agent PH Nudge situé dans `agent/nudge.properties` pour renseigner correctement les paramètres obligatoires :
  - `server_url` : Adresse du collecteur PH Nudge (l'adresse doit commencer par http:// ou https://)
  - `app_id` : Token unique identifiant l'application instrumentée
 
Note : La sonde est interchangeable et les paramètres de la sonde sont modifiables depuis le dossier `agent/` sur le host.
Un simple `docker restart ph_vabf` suffit pour appliquer les changements.

## Lancement

Exécutez la commande suivante afin de télécharger et lancer l'image de VABF :
`docker-compose up -d`

## Tests

L'application est accessible depuis un navigateur sur le port 8080 par défaut.