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

class Filters {
  final String searchText;
  final int totalTime;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> ingredientsToExclude;
  final String creator;
  final List<String> categories;
  final List<String> groups;
  final List<String> ids;
  final int page;

  Filters({
    required this.searchText,
    required this.totalTime,
    required this.tags,
    required this.ingredients,
    required this.ingredientsToExclude,
    required this.creator,
    required this.categories,
    required this.groups,
    required this.ids,
    required this.page,
  });

  Map<String, dynamic> toJson() {
    return {
      'searchText': searchText,
      'totalTime': totalTime,
      'tags': tags,
      'ingredients': ingredients,
      'ingredientsToExclude': ingredientsToExclude,
      'creator': creator,
      'categories': categories,
      'groups': groups,
      'ids': ids,
      'page': page,
    };
  }
}