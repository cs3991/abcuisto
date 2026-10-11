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
  String? authToken;
  String? authEmail;
  bool initialized = false;

  AbcuistoRepository({required this.url});

  bool get isAuthenticated => authToken?.isNotEmpty ?? false;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    authToken = prefs!.getString('api_auth_token');
    authEmail = prefs!.getString('api_auth_email');

    final store = AsyncAuthStore(save: (String data) async => prefs!.setString('pb_auth', data), initial: prefs!.getString('pb_auth'));

    pb = PocketBase(url, authStore: store);
    initialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$url/api/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    dynamic responseBody;
    try {
      responseBody = jsonDecode(response.body);
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw const AuthenticationException('Réponse invalide du serveur.');
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = responseBody is Map<String, dynamic> ? responseBody['message'] ?? responseBody['error'] : null;
      throw AuthenticationException(message is String && message.isNotEmpty ? message : 'Échec de la connexion (${response.statusCode}).');
    }

    if (responseBody is! Map<String, dynamic> || responseBody['token'] is! String || (responseBody['token'] as String).isEmpty) {
      throw const AuthenticationException('Réponse invalide du serveur : token manquant.');
    }

    final token = responseBody['token'] as String;
    final preferences = prefs;
    if (preferences == null) {
      throw StateError('Repository must be initialized before login.');
    }
    if (!await preferences.setString('api_auth_token', token) || !await preferences.setString('api_auth_email', email)) {
      await preferences.remove('api_auth_token');
      await preferences.remove('api_auth_email');
      throw const AuthenticationException('Impossible de sauvegarder la session.');
    }

    authToken = token;
    authEmail = email;
    notifyListeners();
  }

  Future<void> logout() async {
    pb.authStore.clear();
    final preferences = prefs;
    if (preferences != null) {
      await preferences.remove('api_auth_token');
      await preferences.remove('api_auth_email');
    }
    authToken = null;
    authEmail = null;
    notifyListeners();
  }

  Future<List<Recipe>> getRecipesFiltered(Filters filters) async {
    final res = await http.post(
      Uri.parse(url + '/api/recipes/filters'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(filters.toJson()),
    );
    return jsonDecode(res.body)['recipes'].map<Recipe>((e) => Recipe.fromJson(e)).toList();
  }

  Future<RecipeFull> getRecipe(String id) async {
    final record = await http.get(Uri.parse(url + '/api/recipes/$id'), headers: {'Content-Type': 'application/json'});
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
      final categoryResult = await pb.collection('categories').create(body: {'name': '$name-ingredients', 'visible': true});
      ingredientsCategoryId = categoryResult.id;

      for (final ingredient in ingredients) {
        final quantity = double.tryParse(ingredient['quantity'] ?? '') ?? 0;
        final type = ingredient['unit'] ?? '';
        final ingredientName = ingredient['name'] ?? '';

        if (ingredientName.isNotEmpty) {
          final ingredientResult = await pb
              .collection('ingredients')
              .create(
                body: {
                  'name': ingredientName,
                  'number': quantity,
                  'type': type,
                  'nameWithoutDiacritics': ingredientName.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ''),
                },
              );
          ingredientIds.add(ingredientResult.id);
        }
      }

      if (ingredientIds.isNotEmpty) {
        await pb.collection('categories').update(categoryResult.id, body: {'ingredientsIds': ingredientIds});
      }
    }

    final notationResult = await pb.collection('notations').create(body: {'note': 0, 'nbNotes': 0});

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

class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException(this.message);

  @override
  String toString() => message;
}
