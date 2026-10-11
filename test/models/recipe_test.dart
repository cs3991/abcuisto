import 'package:abcuisto/app_config.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => AppConfig.initialize(flavor: AppFlavor.prod));

  test('parses and serializes the API recipe DTO', () {
    final json = <String, dynamic>{
      'id': 'recipe-id',
      'name': 'Pâte sucrée',
      'preparationTime': 15,
      'cookingTime': null,
      'waitingTime': 30,
      'totalTime': 45,
      'creator': 'user-id',
      'creatorPseudo': 'TrawFram',
      'category': 'Dessert',
      'documents': ['cover.jpg'],
      'images': [
        {'imageBase64': 'encoded-image', 'extension': 'jpg', 'fileType': 'image/jpeg'},
      ],
      'forNumber': 1,
      'typeNumber': 'Pièces',
      'steps': ['Mélanger.', 'Cuire.'],
      'tags': ['VEGETARIEN'],
      'groups': [
        {'id': 'group-id', 'name': 'Famille', 'canEdit': false},
      ],
      'noteId': 'note-id',
      'note': 4,
      'nbNotes': 2,
      'comments': [
        {'id': 'comment-id', 'comment': 'Très bon !', 'note': 5},
      ],
      'ustensiles': ['Fouet'],
      'ingredientsCategories': [
        {
          'id': 'category-id',
          'name': 'Pâte',
          'index': 0,
          'recipe': 'recipe-id',
          'ingredients': [
            {'id': 'ingredient-id', 'name': 'Farine', 'type': 'g', 'number': 190, 'index': 1, 'price': 0.2, 'category': 'category-id'},
            {'id': 'sugar-id', 'name': 'Sucre', 'type': 'g', 'number': 50, 'index': 0, 'price': 0.1, 'category': 'category-id'},
          ],
        },
      ],
    };

    final recipe = RecipeFull.fromJson(json);
    final serialized = recipe.toJson();

    expect(recipe.id, 'recipe-id');
    expect(recipe.prepTime, const Duration(minutes: 15));
    expect(recipe.restTime, const Duration(minutes: 30));
    expect(recipe.category, Category.dessert);
    expect(recipe.instructions, ['Mélanger.', 'Cuire.']);
    expect(recipe.ingredients['Pâte']!.first.name, 'Farine');
    expect(recipe.ingredients['Pâte']!.first.typeFormatted, 'g');
    expect(recipe.ingredientCategories.single.ingredients.map((ingredient) => ingredient.name), ['Farine', 'Sucre']);
    expect(serialized, json);
  });
}
