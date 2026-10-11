import 'dart:convert';

import 'package:abcuisto/generated/pocketbase/recettes_record.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/recipe/add_recipe/enum_extensions.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../recipe/filters/filters.dart';

class AbcuistoRepository extends ChangeNotifier {
  final String url;
  late final PocketBase pb;
  SharedPreferences? prefs;
  String? fileToken;
  bool initialized = false;

  AbcuistoRepository({required this.url});

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    final store = AsyncAuthStore(
      save: (String data) async => prefs!.setString('pb_auth', data),
      initial: prefs!.getString('pb_auth'),
    );

    pb = PocketBase(url, authStore: store);
    initialized = true;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    await pb.collection('users').authWithPassword(username, password);
    fileToken = await pb.files.getToken();
    notifyListeners();
  }

  void logout() {
    pb.authStore.clear();
    notifyListeners();
  }

  Future<List<Recipe>> getRecipesFiltered(Filters filters) async {
    final res = await http.post(
        Uri.parse(url + '/api/recipes/filters'),
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(filters.toJson())
    );
    return jsonDecode(res.body)['recipes'].map<Recipe>((e) => Recipe.fromJson(e)).toList();
  }

  Future<RecipeFull> getRecipe(String id) async {
    final record = await http.get(
      Uri.parse(url + '/api/recipes/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return RecipeFull.fromJson(jsonDecode(record.body));
  }

  Future<void> createRecipe({
    required String name,
    required RecettesRecordCategorieEnum category,
    required String tempsPreparation,
    required String tempsCuisson,
    required String steps,
    required String ustensiles,
    required bool vege,
    required double forNumber,
    required RecettesRecordTypeNumberEnum typeNumber,
    required RecettesRecordPrixEnum prix,
    required List<RecettesRecordTagsEnum> tags,
    String? createur,
    String? createurPseudo,
    required List<Map<String, String>> ingredients,
  }) async {
    List<String> ingredientIds = [];
    String? ingredientsCategoryId;

    if (ingredients.isNotEmpty) {
      final categoryResult = await pb.collection('categories').create(body: {
        'name': '$name-ingredients',
        'visible': true,
      });
      ingredientsCategoryId = categoryResult.id;

      for (final ingredient in ingredients) {
        final quantity = double.tryParse(ingredient['quantity'] ?? '') ?? 0;
        final type = ingredient['unit'] ?? '';
        final ingredientName = ingredient['name'] ?? '';

        if (ingredientName.isNotEmpty) {
          final ingredientResult = await pb.collection('ingredients').create(body: {
            'name': ingredientName,
            'number': quantity,
            'type': type,
            'nameWithoutDiacritics': ingredientName.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ''),
          });
          ingredientIds.add(ingredientResult.id);
        }
      }

      if (ingredientIds.isNotEmpty) {
        await pb.collection('categories').update(categoryResult.id, body: {
          'ingredientsIds': ingredientIds,
        });
      }
    }

    final notationResult = await pb.collection('notations').create(body: {
      'note': 0,
      'nbNotes': 0,
    });

    final body = <String, dynamic>{
      'nom': name,
      'categorie': category.displayValue,
      'tempsPreparation': tempsPreparation,
      'tempsCuisson': tempsCuisson,
      'steps': steps,
      'ustensiles': ustensiles,
      'vege': vege,
      'forNumber': forNumber,
      'typeNumber': typeNumber.displayValue,
      'prix': prix.displayValue,
      'tags': tags.map((t) => t.displayValue).toList(),
      'visible': true,
      'nameWithoutDiacritics': name.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ''),
      'noteId': notationResult.id,
    };

    if (createur != null) body['createur'] = createur;
    if (createurPseudo != null) body['createur_pseudo'] = createurPseudo;
    if (ingredientsCategoryId != null) body['categoriesIds'] = [ingredientsCategoryId];

    await pb.collection('recettes').create(body: body);
    notifyListeners();
  }
}
