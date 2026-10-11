import 'dart:convert';

import 'package:abcuisto/generated/pocketbase/recettes_record.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/recipe/add_recipe/enum_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../recipe/filters/filters.dart';

class AbcuistoRepository extends ChangeNotifier {
  final String url;
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

    initialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await _request('POST', '/api/Auth/login', body: {'email': email, 'password': password}, authenticated: false);
    if (response is! Map<String, dynamic> || response['token'] is! String || (response['token'] as String).isEmpty) {
      throw const AuthenticationException('Réponse invalide du serveur : token manquant.');
    }

    await _saveAuthentication(response['token'] as String, email);
  }

  Future<void> signUp(String email, String password, String username) async {
    await _request(
      'POST',
      '/api/Auth/signup',
      body: {'email': email, 'userName': username, 'password': password, 'confirmPassword': password},
      authenticated: false,
    );
  }

  Future<void> _saveAuthentication(String token, String email) async {
    final preferences = prefs;
    if (preferences == null) {
      throw StateError('Repository must be initialized before authentication.');
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
    final preferences = prefs;
    if (preferences != null) {
      await preferences.remove('api_auth_token');
      await preferences.remove('api_auth_email');
    }
    authToken = null;
    authEmail = null;
    notifyListeners();
  }

  Uri _uri(String path) => Uri.parse(url).resolve(path);

  Future<dynamic> _request(String method, String path, {Object? body, bool authenticated = true}) async {
    final headers = <String, String>{};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated && authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    final request = http.Request(method, _uri(path))..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    dynamic responseBody;
    if (response.body.isNotEmpty) {
      try {
        responseBody = jsonDecode(response.body);
      } on FormatException {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response.body;
        }
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = responseBody is Map<String, dynamic> ? responseBody['message'] ?? responseBody['error'] : null;
      throw ApiException(response.statusCode, message is String && message.isNotEmpty ? message : 'La requête a échoué (${response.statusCode}).');
    }
    return responseBody;
  }

  Future<dynamic> _get(String path) => _request('GET', path);

  Future<dynamic> _post(String path, [Object? body]) => _request('POST', path, body: body);

  Future<dynamic> _delete(String path) => _request('DELETE', path);

  Future<List<Recipe>> getRecipesFiltered(Filters filters) async {
    final response = await _post('/api/Recipes/filters', filters.toJson());
    final List<dynamic> recipes;
    if (response is List<dynamic>) {
      recipes = response;
    } else if (response is Map<String, dynamic> && response['recipes'] is List<dynamic>) {
      recipes = response['recipes'] as List<dynamic>;
    } else {
      throw const FormatException('Réponse invalide : liste de recettes manquante.');
    }
    return recipes.map((recipe) {
      if (recipe is! Map<String, dynamic>) {
        throw const FormatException('Réponse invalide : recette mal formée.');
      }
      return Recipe.fromJson(recipe);
    }).toList();
  }

  Future<RecipeFull> getRecipe(String id) async {
    final response = await _get('/api/Recipes/${Uri.encodeComponent(id)}');
    return RecipeFull.fromJson(response as Map<String, dynamic>);
  }

  Future<dynamic> getAllRecipes() => _get('/api/Recipes/all');

  Future<dynamic> deleteRecipe(Map<String, dynamic> recipe) => _post('/api/Recipes/deleteRecipe', recipe);

  Future<dynamic> updateRecipe(Map<String, dynamic> recipe) => _post('/api/Recipes/updateRecipe', recipe);

  Future<dynamic> getRecipesForAuthorization(Filters filters) => _post('/api/Recipes/filters/authorization', filters.toJson());

  Future<dynamic> commentRecipe(Map<String, dynamic> comment) => _post('/api/Recipes/commentRecipe', comment);

  Future<dynamic> deleteComment(String recipeId, String commentId) =>
      _delete('/api/Recipes/deleteComment/${Uri.encodeComponent(recipeId)}/${Uri.encodeComponent(commentId)}');

  Future<dynamic> getGroupById(String id) => _get('/api/Groups/getGroupById/${Uri.encodeComponent(id)}');

  Future<dynamic> createNewGroup(String name) => _post('/api/Groups/createNewGroup', name);

  Future<dynamic> joinGroup(Map<String, dynamic> group) => _post('/api/Groups/joinGroup', group);

  Future<dynamic> deleteGroup(String id) => _post('/api/Groups/deleteGroup', id);

  Future<dynamic> changeCanEdit(Map<String, dynamic> group) => _post('/api/Groups/changeCanEdit', group);

  Future<dynamic> changeGroupOwner(Map<String, dynamic> group) => _post('/api/Groups/changeGroupOwner', group);

  Future<dynamic> getGroupUsers(String id) => _get('/api/Groups/getGroupUsers/${Uri.encodeComponent(id)}');

  Future<dynamic> quitGroup(Map<String, dynamic> group) => _post('/api/Groups/quitGroup', group);

  Future<dynamic> getIngredientsPrices() => _get('/api/Prices/getIngredients');

  Future<dynamic> editIngredientsPrices(Map<String, dynamic> ingredients) => _post('/api/Prices/editIngredients', ingredients);

  Future<dynamic> deleteIngredient(String id) => _post('/api/Prices/deleteIngredient', id);

  Future<dynamic> updateDisplayPriceRecipe(bool showPrice) => _post('/api/Prices/updateDisplayPriceRecipe', showPrice);

  Future<dynamic> deleteAccount() async {
    final response = await _post('/api/User/deleteAccount');
    await logout();
    return response;
  }

  Future<dynamic> getUserInfos() => _get('/api/User/getUserInfos');

  Future<dynamic> verifyEmail(String token) => _post('/api/User/verifyEmail', token);

  Future<dynamic> updateBio(Map<String, dynamic> user) => _post('/api/User/updateBio', user);

  Future<dynamic> updateEmail(Map<String, dynamic> user) => _post('/api/User/updateEmail', user);

  Future<dynamic> confirmUpdateEmail(String token) => _post('/api/User/confirmUpdateEmail', token);

  Future<dynamic> resetPassword(Map<String, dynamic> request) => _post('/api/User/resetPassword', request);

  Future<dynamic> confirmResetPassword(Map<String, dynamic> request) => _post('/api/User/confirmResetPassword', request);

  Future<dynamic> updatePassword(Map<String, dynamic> user) => _post('/api/User/updatePassword', user);

  Future<dynamic> updateImage(Map<String, dynamic> user) => _post('/api/User/updateImage', user);

  Future<dynamic> getFavorites() => _get('/api/User/getFavs');

  Future<dynamic> contactSupport(Map<String, dynamic> request) => _post('/api/User/contact', request);

  Future<dynamic> addFavorite(String recipeId) => _post('/api/User/addFav/${Uri.encodeComponent(recipeId)}');

  Future<dynamic> removeFavorite(String recipeId) => _post('/api/User/removeFav/${Uri.encodeComponent(recipeId)}');

  Future<dynamic> getWeatherForecast() => _get('/WeatherForecast');

  int? _durationInMinutes(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final hours = RegExp(r'(\d+)\s*(?:h|heure)').firstMatch(normalized);
    final minutes = RegExp(r'(\d+)\s*(?:min|m)').firstMatch(normalized);
    if (hours != null || minutes != null) {
      return (int.tryParse(hours?.group(1) ?? '') ?? 0) * 60 + (int.tryParse(minutes?.group(1) ?? '') ?? 0);
    }
    return int.tryParse(normalized);
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
    final recipeTags = tags.map((tag) => tag.displayValue).toList();
    if (vege && !recipeTags.contains('VEGETARIEN')) {
      recipeTags.add('VEGETARIEN');
    }
    final body = <String, dynamic>{
      'id': '00000000-0000-0000-0000-000000000000',
      'name': name,
      'category': category.displayValue,
      'preparationTime': _durationInMinutes(tempsPreparation),
      'cookingTime': _durationInMinutes(tempsCuisson),
      'steps': steps.split(RegExp(r'\r?\n')).where((step) => step.trim().isNotEmpty).toList(),
      'ustensiles': ustensiles.split(',').map((value) => value.trim()).where((value) => value.isNotEmpty).toList(),
      'forNumber': forNumber.round(),
      'typeNumber': typeNumber.displayValue,
      'creator': createur,
      'creatorPseudo': createurPseudo,
      'tags': recipeTags,
      'ingredientsCategories': [
        {
          'name': '$name-ingredients',
          'id': '00000000-0000-0000-0000-000000000000',
          'index': 0,
          'ingredients': [
            for (var index = 0; index < ingredients.length; index++)
              if ((ingredients[index]['name'] ?? '').isNotEmpty)
                {
                  'id': '00000000-0000-0000-0000-000000000000',
                  'name': ingredients[index]['name'],
                  'type': ingredients[index]['unit'],
                  'number': double.tryParse(ingredients[index]['quantity'] ?? '') ?? 0,
                  'index': index,
                },
          ],
        },
      ],
    };
    body.removeWhere((key, value) => value == null);
    if (ingredients.isEmpty) body.remove('ingredientsCategories');
    final prepTime = body['preparationTime'] as int?;
    final cookTime = body['cookingTime'] as int?;
    if (prepTime != null || cookTime != null) {
      body['totalTime'] = (prepTime ?? 0) + (cookTime ?? 0);
    }
    body['images'] = <dynamic>[];
    body['documents'] = <dynamic>[];
    body['comments'] = <dynamic>[];
    body['groups'] = <dynamic>[];
    body['note'] = 0;
    body['nbNotes'] = 0;
    await _post('/api/Recipes/createRecipe', body);
    notifyListeners();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException(this.message);

  @override
  String toString() => message;
}
