import 'package:abcuisto/generated/pocketbase/categories_record.dart';
import 'package:abcuisto/generated/pocketbase/ingredients_record.dart';
import 'package:abcuisto/generated/pocketbase/notations_record.dart';
import 'package:abcuisto/generated/pocketbase/recettes_record.dart';
import 'package:pocketbase/pocketbase.dart';

import 'ingredient.dart';

class Recipe {
  final List<Uri> images;
  final String name;
  final Map<String, List<Ingredient>> ingredients;
  final Duration? prepTime;
  final Duration? cookTime;
  final Duration? restTime;
  final Iterable<String> instructions;
  final double? note;

  // final List<Comment> comments;

  Recipe({
    required this.images,
    required this.name,
    required this.ingredients,
    required this.instructions,
    // required this.comments,
    this.prepTime,
    this.cookTime,
    this.restTime,
    this.note,
  });

  factory Recipe.fromRecord(RecettesRecord recipe, PocketBase pb) {
    final notationRecord = NotationsRecord.fromRecordModel(recipe.expand!['noteId'][0]);

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

    // Durées (peuvent être nulles)
    Duration? parseDuration(String? value) {
      if (value == null || !value.contains('h')) return null;
      final parts = value.split('h');
      return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]));
    }

    return Recipe(
      name: recipe.nom!,
      images: recipe.documents!.map((e) => pb.files.getUrl(RecordModel(recipe.toJson()), e)).toList(),
      instructions: recipe.steps!.split('£').map((e) => e.replaceAll('¤', '\n')),
      prepTime: parseDuration(recipe.tempsPreparation),
      cookTime: parseDuration(recipe.tempsCuisson),
      // restTime: parseDuration(recipe.tempsRepos),
      restTime: null,
      note: notationRecord.nbNotes != 0 ? notationRecord.note : null,
      ingredients: ingredients,
    );
  }

  String? get prepTimeFormatted => _printDuration(prepTime);

  String? get cookTimeFormatted => _printDuration(cookTime);

  String? get restTimeFormatted => _printDuration(restTime);

  Duration get totalTime => (prepTime ?? Duration()) + (cookTime ?? Duration()) + (restTime ?? Duration());

  String? get totalTimeFormatted => _printDuration(totalTime);

  // String? _printDuration(Duration? duration) {
  //   if (duration == null) {
  //     return null;
  //   }
  //   String negativeSign = duration.isNegative ? '-' : '';
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  //   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  //   return "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes";
  // }
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
