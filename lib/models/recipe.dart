import 'package:abcuisto/app_config.dart' show AppConfig;
import 'package:abcuisto/generated/pocketbase/categories_record.dart';
import 'package:abcuisto/generated/pocketbase/ingredients_record.dart';
import 'package:abcuisto/generated/pocketbase/notations_record.dart';
import 'package:abcuisto/generated/pocketbase/recettes_record.dart';
import 'package:pocketbase/pocketbase.dart';

import 'ingredient.dart';

enum Category {
  appetizer('aperitif', 'Apéritif'),
  starter('entree', 'Entrée'),
  mainCourse('plat', 'Plat'),
  cheese('fromage', 'Fromage'),
  dessert('dessert', 'Dessert'),
  breakfast('petitxdejeuner', 'Petit-déjeuner'),
  drink('boisson', 'Boisson'),
  sauce('sauce', 'Sauce');

  final String displayName;
  final String label;

  const Category(this.label, this.displayName);
}

class Recipe {
  final List<Uri> images;
  final String name;
  final Duration? prepTime;
  final Duration? cookTime;
  final Duration? restTime;
  final double? note;
  final String creatorName;
  final DateTime createdDate;
  final Category? category;
  final List<String> cookware;

  Recipe({
    required this.images,
    required this.name,
    this.prepTime,
    this.cookTime,
    this.restTime,
    this.note,
    required this.creatorName,
    required this.createdDate,
    required this.category,
    required this.cookware,
  });

  factory Recipe.fromJson(Map<String, dynamic> recipe) {
    return Recipe(
      images: (recipe['documents'] ?? <dynamic>[]).map<Uri>((dynamic doc) => Uri.parse('${AppConfig.instance.apiUrl}/images/$doc')).toList(),
      name: recipe['name'],
      creatorName: '',
      createdDate: DateTime.now(),
      category: null,
      cookware: [],
    );
  }

  String? get prepTimeFormatted => _printDuration(prepTime);

  String? get cookTimeFormatted => _printDuration(cookTime);

  String? get restTimeFormatted => _printDuration(restTime);

  Duration get totalTime => (prepTime ?? Duration()) + (cookTime ?? Duration()) + (restTime ?? Duration());

  String? get totalTimeFormatted => _printDuration(totalTime);

  String get createdTimeFormatted {
    final day = createdDate.day.toString().padLeft(2, '0');
    final month = createdDate.month.toString().padLeft(2, '0');
    final year = createdDate.year.toString();
    return '$day/$month/$year';
  }

  String? _printDuration(Duration? duration) {
    if (duration == null) {
      return null;
    }
    if (duration < Duration(hours: 1)) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? "s" : ""}';
    }
    return '${duration.inHours} h ${duration.inMinutes.remainder(60)} min';
  }
}

class RecipeFull extends Recipe {
  final Map<String, List<Ingredient>> ingredients;
  final Iterable<String> instructions;

  // final List<Comment> comments;

  RecipeFull({
    required super.images,
    required super.name,
    // required this.comments,
    super.prepTime,
    super.cookTime,
    super.restTime,
    super.note,
    required this.ingredients,
    required this.instructions,
    required super.creatorName,
    required super.createdDate,
    required super.category,
    required super.cookware,
  });

  factory RecipeFull.fromJson(Map<String, dynamic> recipe) {
    final baseRecipe = Recipe.fromJson(recipe);
    /*
    final List<CategoriesRecord> categoriesRecord = recipe
        .expand!['categoriesIds']
        .map<CategoriesRecord>((e) => CategoriesRecord.fromRecordModel(e))
        .toList();
        */
    // Construction de la map { catégorie : [ingredients] }
    final ingredients = <String, List<Ingredient>>{};
    /*
    for (final category in categoriesRecord) {
      final ingrRecords = category.expand!['ingredientsIds'] ?? [];

      ingredients[category.name!] = ingrRecords
          .map<Ingredient>(
            (e) => Ingredient.fromRecordModel(
              IngredientsRecord.fromRecordModel(e),
            ),
          )
          .toList();
    }
    */
    return RecipeFull(
      images: baseRecipe.images,
      name: baseRecipe.name,
      ingredients: ingredients,
      instructions: [],
      prepTime: baseRecipe.prepTime,
      cookTime: baseRecipe.cookTime,
      restTime: baseRecipe.restTime,
      note: baseRecipe.note,
      creatorName: baseRecipe.creatorName,
      createdDate: baseRecipe.createdDate,
      category: baseRecipe.category,
      cookware: baseRecipe.cookware,
    );
  }
}
