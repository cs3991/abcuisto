# Liens vers l’application ABCuisto

La partie application Android/iOS accepte les liens HTTPS suivants sur
`abcuisto.fr` et `dev.abcuisto.fr` :

- `/group/ID` : invitation, connexion si nécessaire, puis confirmation d’adhésion.
- `/recette/ID` : chargement de la recette, avec affichage d’erreur si elle n’est pas accessible.

Un lien ne change pas le serveur API de l’application : la version dev utilise
sa configuration dev, la version prod utilise sa configuration prod.

## Association des domaines (nécessaire pour l’ouverture automatique)

Les fichiers à la racine de ce dossier sont des modèles à compléter.
Le sous-dossier `production/` contient la configuration déployée pour Android
sur `abcuisto.fr` ; iOS et le domaine dev restent en attente.
Les fichiers doivent être servis sur **chacun des deux domaines**, en HTTPS,
sans authentification ni redirection, avec un type `application/json`.

### Android

Compléter `assetlinks.json` avec l’empreinte SHA-256 du certificat qui signe
l’application installée. Le package actuel est `com.example.abcuisto` ; le mettre
à jour ici si l’identifiant de l’application change.

Publier à `https://DOMAINE/.well-known/assetlinks.json`.

La configuration actuelle signe aussi la release avec la clé debug. Pour une
publication Play Store, utiliser l’empreinte de la clé de signature de l’app
Play App Signing. Plusieurs empreintes peuvent être déclarées ; réserver les clés
de développement au domaine dev lorsque l’application sera publiée.

### iOS

Compléter `apple-app-site-association` avec le préfixe App ID Apple de l’application
(généralement le Team ID), suivi de `.com.example.abcuisto`. Activer la capacité
Associated Domains pour cet App ID dans le compte Apple et utiliser un profil de
signature qui l’inclut. Le projet référence déjà `Runner.entitlements`.

Publier à `https://DOMAINE/.well-known/apple-app-site-association`, sans extension.

## Hébergement de production

Sur `ssh pi`, le frontend se trouve dans `/home/cedric/dev/abcuisto/frontend`.
Son `docker-compose.yml` monte en lecture seule :

- `./nginx.conf` vers `/etc/nginx/conf.d/default.conf` ;
- `./app-links` vers `/usr/share/nginx/html/.well-known`.

Le fichier `production/nginx.conf` conserve le frontend et ajoute deux routes
exactes pour les fichiers d'association, servies en JSON. Un fichier absent
renvoie une 404 plutôt que la page HTML de l'application.

`production/assetlinks.json` utilise l'empreinte de la clé debug locale extraite
le 29 octobre 2026, également utilisée par la release dans la configuration
Android actuelle. Une application signée avec une autre clé nécessitera son
empreinte dans ce fichier. Pour une publication Play Store, remplacer cette
association par celle de Play App Signing.

Le fichier Android est copié dans `app-links/assetlinks.json` sur le serveur.
Les modifications de son contenu sont prises en compte sans reconstruire le
frontend. Le fichier iOS n'est pas publié tant que le préfixe App ID Apple
n'est pas disponible ; la route correspondante renvoie donc une 404.

Les configurations précédentes ont été sauvegardées sur le serveur dans
`app-links-backup-20261029-184015/`. Le conteneur frontend a été recréé pour
activer les montages. Le routage Traefik et les API n'ont pas été modifiés.

## Vérification manuelle

Aucune application ni aucun test n’a été lancé pour cette modification.
Après un redémarrage complet/rebuild et l’installation de l’app :

- Ouvrir un lien de groupe et de recette sur chaque domaine, app fermée puis ouverte.
- Vérifier une invitation en étant connecté puis déconnecté ; l’adhésion nécessite une confirmation.
- Vérifier une recette inaccessible et un identifiant invalide.
- Sur Android, les réglages « Ouvrir par défaut » permettent d’activer les domaines
  manuellement pendant le développement, avant leur association côté serveur.
- Les liens HTTPS natifs sont configurés ici pour Android et iOS. Linux n’a pas
  d’association HTTPS système configurée par ce projet ; les liens de groupe
  peuvent toujours être collés dans « Rejoindre un groupe ».

Références :
- https://pub.dev/packages/app_links/versions/6.4.1
- https://docs.flutter.dev/cookbook/navigation/set-up-app-links
- https://docs.flutter.dev/cookbook/navigation/set-up-universal-links
