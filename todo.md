# Points à améliorer

- [ ] Backend photo (`pi`, `backend-dev/src/ABCuisto/Services/UserService.cs`, `UpdateImage`) : `oldImage == null` passe le contrôle `oldImage != ""` et entraîne `DeleteImage(null)`. Le client envoie désormais une chaîne vide en l’absence de photo. Corriger aussi le serveur avec un contrôle de valeur vide, conserver l’exception d’origine dans le contrôleur et supprimer l’ancienne photo seulement après enregistrement réussi de la nouvelle (actuellement supprimée avant validation de l’envoi).

- [ ] Changement d’e-mail : le repository expose `confirmUpdateEmail`, mais aucun parcours de confirmation n’est raccordé dans le profil. Clarifier le retour de l’API et la réception du token ; après confirmation, synchroniser aussi `authEmail` et `api_auth_email` avec l’adresse effective (actuellement enregistrée seulement à la connexion).

- [x] Profil : sélection, envoi et affichage de photo branchés via `updateImage`. Le modèle `Entities/User.cs` et `GetUserInfos` sur `pi` confirment le champ `image` de type chaîne ; l’affichage reste à valider dans l’application.

- [x] Filtre « Créé par moi » : utiliser le pseudo du profil plutôt que l’e-mail dans l’état d’authentification et déduire la sélection « Moi » du filtre actif à la réouverture de l’écran.
- [ ] `lib/recipe/filters/filter_page.dart` : le champ « Ingrédients » n’a pas de `onChanged` et n’applique aucun filtre ; raccorder la saisie au `FilterCubit`.

- [x] `lib/recipe/recipe_cubit.dart` : gérer les erreurs de `focusRecipe` et `refreshRecipe` dans les états et proposer un retour utilisateur. Les échecs passent désormais par `RecipeError`, avec une action pour recharger la recette.
- [ ] `lib/recipe/recipe_details.dart` : retirer le code commenté de `_submitComment` et clarifier la gestion de la note sélectionnée, actuellement conservée dans le widget alors qu’elle participe à l’envoi d’un avis.
- [ ] `lib/models/abcuisto_repository.dart` : retirer le doublon d’affectation du header `Authorization` dans `_request`.
- [ ] `lib/models/abcuisto_repository.dart` : la persistance des identifiants utilise encore directement `SharedPreferences` ; envisager de l’extraire dans un stockage de session dédié pour recentrer le repository sur l’API. Le thème est désormais persisté par `HydratedCubit`.

- [ ] `lib/recipe/recipe_details.dart` : `_ImageCarouselState` possède un `PageController` sans le libérer dans `dispose` ; le libérer à la fermeture du détail de recette.
- [ ] Linux : ajouter un packaging avec un fichier `.desktop` et une icône installée, associés à l’`APPLICATION_ID` du lanceur. L’icône GTK embarquée couvre la fenêtre sous X11, mais certains bureaux, notamment sous Wayland, utilisent l’entrée `.desktop` pour l’icône du dock.

- [x] Invitation de groupe : le bouton « Rejoindre ce groupe » ouvrait un second formulaire de saisie alors que le lien était déjà connu. Déclencher directement l’adhésion avec le Cubit existant et afficher les erreurs sur la page d’invitation.


- [ ] dans les étapes de recette, lorsqu'on les modifie, il faudrait que le text field s'adapte en hauteur à la saisie actuelle. C'est pas pratique d'avoir à scroll à l'intérieur du text field
- [ ] possibilité de réorganiser les ingredients lors de la modif et creation de recette
