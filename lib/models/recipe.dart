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
  final RecettesRecord record;
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
    required this.record,
    required this.creatorName,
    required this.createdDate,
    required this.category,
    required this.cookware,
  });

  factory Recipe.fromRecord(RecettesRecord recipe, PocketBase pb) {
    final notationRecord = NotationsRecord.fromRecordModel(recipe.expand!['noteId'][0]);

    // Durées (peuvent être nulles)
    Duration? parseDuration(String? value) {
      if (value == null || !value.contains('h')) return null;
      final parts = value.split('h');
      return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]));
    }

    return Recipe(
      name: recipe.nom!,
      images: recipe.documents!.map((e) => pb.files.getUrl(RecordModel(recipe.toJson()), e)).toList(),
      // instructions: recipe.steps!.split('£').map((e) => e.replaceAll('¤', '\n')),
      prepTime: parseDuration(recipe.tempsPreparation),
      cookTime: parseDuration(recipe.tempsCuisson),
      // restTime: parseDuration(recipe.tempsRepos),
      restTime: null,
      note: notationRecord.nbNotes != 0 ? notationRecord.note : null,
      // ingredients: ingredients,
      record: recipe,
      creatorName: recipe.createurPseudo ?? 'Anonyme',
      createdDate: recipe.created!,
      category: Category.values.firstWhere((c) => c.label == recipe.categorie?.nameInSchema),
      cookware: recipe.ustensiles == "" || recipe.ustensiles == null
          ? List.empty()
          : recipe.ustensiles!.split(";").toList(),
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
    required super.record,
    required this.ingredients,
    required this.instructions,
    required super.creatorName,
    required super.createdDate,
    required super.category,
    required super.cookware,
  });

  factory RecipeFull.fromRecord(RecettesRecord recipe, PocketBase pb) {
    final baseRecipe = Recipe.fromRecord(recipe, pb);
    final List<CategoriesRecord> categoriesRecord = recipe.expand!['categoriesIds']
        .map<CategoriesRecord>((e) => CategoriesRecord.fromRecordModel(e))
        .toList();
    // Construction de la map { catégorie : [ingredients] }
    final ingredients = <String, List<Ingredient>>{};
    for (final category in categoriesRecord) {
      final ingrRecords = category.expand!['ingredientsIds'] ?? [];

      ingredients[category.name!] = ingrRecords
          .map<Ingredient>((e) => Ingredient.fromRecordModel(IngredientsRecord.fromRecordModel(e)))
          .toList();
    }
    return RecipeFull(
      images: baseRecipe.images,
      name: baseRecipe.name,
      ingredients: ingredients,
      instructions: recipe.steps!.split('£').map((e) => e.replaceAll('¤', '\n')),
      prepTime: baseRecipe.prepTime,
      cookTime: baseRecipe.cookTime,
      restTime: baseRecipe.restTime,
      note: baseRecipe.note,
      record: baseRecipe.record,
      creatorName: baseRecipe.creatorName,
      createdDate: baseRecipe.createdDate,
      category: baseRecipe.category,
      cookware: baseRecipe.cookware,
    );
  }
}
