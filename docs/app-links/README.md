# Liens vers l’application ABCuisto

La partie application Android/iOS accepte les liens HTTPS suivants sur
`abcuisto.fr` et `dev.abcuisto.fr` :

- `/group/ID` : invitation, connexion si nécessaire, puis confirmation d’adhésion.
- `/recette/ID` : chargement de la recette, avec affichage d’erreur si elle n’est pas accessible.

Un lien ne change pas le serveur API de l’application : la version dev utilise
sa configuration dev, la version prod utilise sa configuration prod.

## Association des domaines (nécessaire pour l’ouverture automatique)

Les fichiers de ce dossier sont des modèles à compléter, pas des fichiers déjà
publiés. Ils doivent être servis sur **chacun des deux domaines**, en HTTPS,
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
