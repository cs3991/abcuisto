abstract class Filter {
  final String name;
  final String apiParameter;

  Filter({required this.name, required this.apiParameter});
}

class SelectFilter extends Filter {
  final List<String> options;
  final List<String>? selectedOptions;

  SelectFilter({
    required super.name,
    required super.apiParameter,
    required this.options,
    this.selectedOptions,
  });
}

class RangeFilter extends Filter {
  final double min;
  final double max;
  final double? minValue;
  final double? maxValue;

  RangeFilter({
    required super.name,
    required super.apiParameter,
    required this.min,
    required this.max,
    this.minValue,
    this.maxValue,
  });
}

class BooleanFilter extends Filter {
  final bool? value;

  BooleanFilter({required super.name, required super.apiParameter, this.value});
}

class TextFilter extends Filter {
  final String? value;

  TextFilter({required super.name, required super.apiParameter, this.value});
}

//
// [
// // Categories
// SelectFilter(
// name: "Catégorie",
// apiParameter: "categorie",
// options: ["Apéritif", "Entrée", "Plat", "Fromage", "Dessert", "Petit-déjeuner", "Boisson", "Sauce"],
// ),
//
// //   // Creator
// //   TextFilter(name: "Créateur", apiParameter: "createurPseudo"),
// //
// //   // Total time
// //   RangeFilter(name: "Temps total (minutes)", apiParameter: "tempsTotal", min: 0, max: 300),
// ];
