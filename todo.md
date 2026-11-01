# Points à améliorer

- [ ] Droits de modification des recettes (`lib/recipe/recipe_cubit.dart`, `User.groups`) : le calcul autorise déjà les membres d’un groupe partagé avec `canEdit == true`. Le backend de développement inclut bien ce champ dans `getUserInfos`, mais le client conservait les droits de la connexion jusqu’au prochain chargement du profil. Le chargement d’une recette (liste ou lien) recharge désormais le profil connecté avant de calculer les droits. Valider dans l’application l’activation et la révocation par un autre propriétaire ; le cas signalé reste à confirmer en conditions réelles.

- [ ] Autorisation serveur des modifications (`pi`, `backend-dev/src/ABCuisto/Services/RecipesService.cs`, `UpdateRecipe`) : la méthode contrôle la connexion puis charge la recette avec `GetRecipeById`, mais aucun contrôle explicite du créateur ou de l’appartenance à un groupe avec `canEdit` n’apparaît avant les suppressions de documents et les écritures. Le contrôle `recipeToUpdate == null` est placé à l’intérieur du bloc `recipeToUpdate != null`. Ajouter une vérification des droits sur les données persistées avant tout effet de bord ; le contrôle du bouton côté Flutter ne suffit pas.

- [ ] Build Google Play : `flutter build appbundle --release --target lib/main_prod.dart` produit un AAB mais Flutter échoue à la vérification/suppression des symboles natifs (« failed to strip debug symbols from native libraries »). Diagnostiquer les bibliothèques natives et l’outillage NDK ; `flutter doctor -v` signale aussi un statut inconnu des licences Android. Le SDK local nécessite `ANDROID_HOME` et `ANDROID_SDK_ROOT` à `/home/cedric/android_cmd_tools` dans cet environnement.

- [ ] Outils de compilation Android : le build App Bundle signale la fin prochaine du support Flutter pour Gradle 8.14.0, AGP 8.11.1 et Kotlin 2.2.20 (minimums annoncés : 9.1.0, 9.0.1 et 2.3.20). Préparer une migration coordonnée. Le plugin `jni` demande aussi le NDK 28.2.13676358 alors que `android/app/build.gradle.kts` fixe 27.0.12077973 ; les outils SDK signalent également un décalage des versions de schéma XML (3/4).

- [x] Identifiant Android : `applicationId`, namespace, activité Kotlin et modèles Android App Links alignés sur `fr.abcuisto.app`, identifiant communiqué depuis la Play Console.

- [ ] App Links de production (`docs/app-links/production/assetlinks.json`) : déployer le package `fr.abcuisto.app` et remplacer l’empreinte debug par celle du certificat Play App Signing pour les installations Google Play. Le serveur n’a pas été modifié dans ce jalon.

- [x] Filtres actifs (`lib/recipe/recipes_list.dart`) : afficher les groupes sélectionnés parmi les pastilles récapitulatives de la liste, avec leur nom et la possibilité de les retirer comme les tags et ingrédients.

- [ ] Sélection d’environnement (`lib/main.dart`) : une valeur `APP_FLAVOR` inconnue sélectionne silencieusement `AppFlavor.dev`, alors que l’absence de valeur sélectionne la production. Rejeter les valeurs invalides avec un message explicite pour éviter de lancer une build contre le mauvais serveur.

- [ ] Backend photo (`pi`, `backend-dev/src/ABCuisto/Services/UserService.cs`, `UpdateImage`) : `oldImage == null` passe le contrôle `oldImage != ""` et entraîne `DeleteImage(null)`. Le client envoie désormais une chaîne vide en l’absence de photo. Corriger aussi le serveur avec un contrôle de valeur vide, conserver l’exception d’origine dans le contrôleur et supprimer l’ancienne photo seulement après enregistrement réussi de la nouvelle (actuellement supprimée avant validation de l’envoi).

- [ ] Changement d’e-mail : le repository expose `confirmUpdateEmail`, mais aucun parcours de confirmation n’est raccordé dans le profil. Clarifier le retour de l’API et la réception du token ; après confirmation, synchroniser aussi `authEmail` et `api_auth_email` avec l’adresse effective (actuellement enregistrée seulement à la connexion).


- [ ] Adaptation des quantités (`lib/models/ingredient.dart`, `Ingredient.quantityFormatted`) : l’affichage impose une seule décimale ; une quantité positive inférieure à 0,05 apparaît comme « 0.0 » après réduction des portions. Prévoir une précision adaptée aux petites quantités et un affichage français cohérent lors de l’étape de calcul à partir d’un ingrédient.
  - L’affichage du détail utilise maintenant une précision adaptée et une virgule décimale ; le formateur partagé `Ingredient.quantityFormatted` conserve sa limite pour ses autres usages.
- [ ] Quantités dans les instructions (`lib/recipe/recipe_details.dart`, `InstructionsView`) : les étapes sont du texte libre et peuvent contenir des quantités fixes. L’adaptation recalcule la liste des ingrédients et les portions, mais les quantités écrites dans les étapes restent celles d’origine. Prévoir une indication visible ou une représentation structurée des quantités si ce cas doit être pris en charge.

- [ ] Contrat API des favoris (`swagger.json`, `/api/User/getFavs`) : la réponse 200 ne décrit aucun schéma. Le client accepte une liste d’identifiants ou d’objets avec `id` ; documenter le format effectif côté serveur pour fiabiliser cette conversion.
