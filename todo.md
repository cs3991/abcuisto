# Points à améliorer

- [x] Filtre « Créé par moi » : utiliser le pseudo du profil plutôt que l’e-mail dans l’état d’authentification et déduire la sélection « Moi » du filtre actif à la réouverture de l’écran.
- [ ] `lib/recipe/filters/filter_page.dart` : le champ « Ingrédients » n’a pas de `onChanged` et n’applique aucun filtre ; raccorder la saisie au `FilterCubit`.

- [x] `lib/recipe/recipe_cubit.dart` : gérer les erreurs de `focusRecipe` et `refreshRecipe` dans les états et proposer un retour utilisateur. Les échecs passent désormais par `RecipeError`, avec une action pour recharger la recette.
- [ ] `lib/recipe/recipe_details.dart` : retirer le code commenté de `_submitComment` et clarifier la gestion de la note sélectionnée, actuellement conservée dans le widget alors qu’elle participe à l’envoi d’un avis.
- [ ] `lib/models/abcuisto_repository.dart` : retirer le doublon d’affectation du header `Authorization` dans `_request`.
