abstract class Filter {
  final String name;
  final String apiParameter;

  Filter({required this.name, required this.apiParameter});
}

class SelectFilter extends Filter {
  final List<String> options;
  final List<String>? selectedOptions;

  SelectFilter({required super.name, required super.apiParameter, required this.options, this.selectedOptions});
}

class RangeFilter extends Filter {
  final double min;
  final double max;
  final double? minValue;
  final double? maxValue;

  RangeFilter({required super.name, required super.apiParameter, required this.min, required this.max, this.minValue, this.maxValue});
}

class BooleanFilter extends Filter {
  final bool? value;

  BooleanFilter({required super.name, required super.apiParameter, this.value});
}

class TextFilter extends Filter {
  final String? value;

  TextFilter({required super.name, required super.apiParameter, this.value});
}

class Filters {
  final String? searchText;
  final int? totalTime;
  final List<String>? tags;
  final List<String>? ingredients;
  final List<String>? ingredientsToExclude;
  final String? creator;
  final List<String>? categories;
  final List<String>? groups;
  final List<String>? ids;
  final int? page;

  Filters({
    this.searchText,
    this.totalTime,
    this.tags,
    this.ingredients,
    this.ingredientsToExclude,
    this.creator,
    this.categories,
    this.groups,
    this.ids,
    this.page,
  });

  Map<String, dynamic> toJson() {
    return {
      if (searchText != null) 'searchText': searchText,
      if (totalTime != null) 'totalTime': totalTime,
      if (tags != null) 'tags': tags,
      if (ingredients != null) 'ingredients': ingredients,
      if (ingredientsToExclude != null) 'ingredientsToExclude': ingredientsToExclude,
      if (creator != null) 'creator': creator,
      if (categories != null) 'categories': categories,
      if (groups != null) 'groups': groups,
      if (ids != null) 'ids': ids,
      if (page != null) 'page': page,
    };
  }
}
