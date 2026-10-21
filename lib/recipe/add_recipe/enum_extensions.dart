// enum RecipeCategory {
//   aperitif,
//   entree,
//   plat,
//   fromage,
//   dessert,
//   petitxdejeuner,
//   boisson,
//   sauce,
// }

enum RecipeServingType { personnes, pieces }

enum RecipeTag { thermomix, vegan, vegetarien, alcool, sansgluten }

// extension RecipeCategoryDisplayValue on RecipeCategory {
//   String get displayValue {
//     switch (this) {
//       case RecipeCategory.aperitif:
//         return 'Aperitif';
//       case RecipeCategory.entree:
//         return 'Entree';
//       case RecipeCategory.plat:
//         return 'Plat';
//       case RecipeCategory.fromage:
//         return 'Fromage';
//       case RecipeCategory.dessert:
//         return 'Dessert';
//       case RecipeCategory.petitxdejeuner:
//         return 'Petit-dejeuner';
//       case RecipeCategory.boisson:
//         return 'Boisson';
//       case RecipeCategory.sauce:
//         return 'Sauce';
//     }
//   }
// }

extension RecipeTypeNumberDisplayValue on RecipeServingType {
  String get displayValue {
    switch (this) {
      case RecipeServingType.personnes:
        return 'Personnes';
      case RecipeServingType.pieces:
        return 'Pièces';
    }
  }
}

extension RecipeTagDisplayValue on RecipeTag {
  String get displayValue {
    switch (this) {
      case RecipeTag.thermomix:
        return 'THERMOMIX';
      case RecipeTag.vegan:
        return 'VEGAN';
      case RecipeTag.vegetarien:
        return 'VEGETARIEN';
      case RecipeTag.alcool:
        return 'ALCOOL';
      case RecipeTag.sansgluten:
        return 'SANSGLUTEN';
    }
  }
}
