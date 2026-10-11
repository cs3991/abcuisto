import 'package:abcuisto/app_config.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/recipe/recipe_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => AppConfig.initialize(flavor: AppFlavor.prod));

  testWidgets('shows recipe comments and author', (tester) async {
    final recipe = RecipeFull.fromJson({
      'id': 'recipe-id',
      'name': 'Tarte',
      'creatorPseudo': 'Recipe author',
      'comments': [
        {'comment': 'Très bon !', 'username': 'Camille', 'note': 5},
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RecipeDetails(recipe: recipe)),
      ),
    );

    expect(find.text('Commentaires'), findsOneWidget);
    expect(find.text('Camille'), findsOneWidget);
    expect(find.text('Très bon !'), findsOneWidget);
  });
}
