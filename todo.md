# Points à améliorer

- [x] Filtres actifs (`lib/recipe/recipes_list.dart`) : afficher les groupes sélectionnés parmi les pastilles récapitulatives de la liste, avec leur nom et la possibilité de les retirer comme les tags et ingrédients.

- [ ] Sélection d’environnement (`lib/main.dart`) : une valeur `APP_FLAVOR` inconnue sélectionne silencieusement `AppFlavor.dev`, alors que l’absence de valeur sélectionne la production. Rejeter les valeurs invalides avec un message explicite pour éviter de lancer une build contre le mauvais serveur.

- [ ] Backend photo (`pi`, `backend-dev/src/ABCuisto/Services/UserService.cs`, `UpdateImage`) : `oldImage == null` passe le contrôle `oldImage != ""` et entraîne `DeleteImage(null)`. Le client envoie désormais une chaîne vide en l’absence de photo. Corriger aussi le serveur avec un contrôle de valeur vide, conserver l’exception d’origine dans le contrôleur et supprimer l’ancienne photo seulement après enregistrement réussi de la nouvelle (actuellement supprimée avant validation de l’envoi).

- [ ] Changement d’e-mail : le repository expose `confirmUpdateEmail`, mais aucun parcours de confirmation n’est raccordé dans le profil. Clarifier le retour de l’API et la réception du token ; après confirmation, synchroniser aussi `authEmail` et `api_auth_email` avec l’adresse effective (actuellement enregistrée seulement à la connexion).


- [ ] Adaptation des quantités (`lib/models/ingredient.dart`, `Ingredient.quantityFormatted`) : l’affichage impose une seule décimale ; une quantité positive inférieure à 0,05 apparaît comme « 0.0 » après réduction des portions. Prévoir une précision adaptée aux petites quantités et un affichage français cohérent lors de l’étape de calcul à partir d’un ingrédient.
  - L’affichage du détail utilise maintenant une précision adaptée et une virgule décimale ; le formateur partagé `Ingredient.quantityFormatted` conserve sa limite pour ses autres usages.
- [ ] Quantités dans les instructions (`lib/recipe/recipe_details.dart`, `InstructionsView`) : les étapes sont du texte libre et peuvent contenir des quantités fixes. L’adaptation recalcule la liste des ingrédients et les portions, mais les quantités écrites dans les étapes restent celles d’origine. Prévoir une indication visible ou une représentation structurée des quantités si ce cas doit être pris en charge.
