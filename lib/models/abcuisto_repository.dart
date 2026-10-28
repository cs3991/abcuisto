import 'dart:convert';
import 'dart:math';

import 'group_member.dart';

import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/models/user.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../recipe/filters/filters.dart';

class AbcuistoRepository extends ChangeNotifier {
  final String url;
  SharedPreferences? prefs;
  String? authToken;
  String? authEmail;
  User? user;
  bool initialized = false;

  AbcuistoRepository({required this.url});

  bool get isAuthenticated => authToken?.isNotEmpty ?? false;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    authToken = prefs!.getString('api_auth_token');
    authEmail = prefs!.getString('api_auth_email');

    try {
      if (isAuthenticated) await getUserInfos();
    } catch (error) {
      await logout();
    }

    initialized = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await _request('POST', '/api/Auth/login', body: {'email': email, 'password': password}, authenticated: false);
    if (response is! Map<String, dynamic> || response['token'] is! String || (response['token'] as String).isEmpty) {
      throw const AuthenticationException('Réponse invalide du serveur : token manquant.');
    }

    await _saveAuthentication(response['token'] as String, email);
    await getUserInfos();
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
    user = null;
    notifyListeners();
  }

  Uri _uri(String path) => Uri.parse(url).resolve(path);

  Future<dynamic> _request(String method, String path, {Object? body, bool authenticated = true}) async {
    final headers = <String, String>{};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated && authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

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
        if (!response.body.trimLeft().startsWith('<')) responseBody = response.body;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String? message;
      if (responseBody is Map<String, dynamic>) {
        final details = <String>[];
        final summary = responseBody['message'] ?? responseBody['error'] ?? responseBody['detail'] ?? responseBody['title'];
        if (summary is String && summary.isNotEmpty) details.add(summary);
        final errors = responseBody['errors'];
        if (errors is Map<String, dynamic>) {
          for (final entry in errors.entries) {
            final value = entry.value;
            final text = value is List ? value.join(' ') : value.toString();
            details.add('${entry.key}: $text');
          }
        }
        if (details.isNotEmpty) message = details.join('\n');
      } else if (responseBody is String && responseBody.isNotEmpty) {
        message = responseBody;
      }
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

  Future<dynamic> deleteRecipe({required String id}) => _post('/api/Recipes/deleteRecipe', {'id': id});

  Future<void> updateRecipe({
    required RecipeFull recipe,
  }) async {
    await _post('/api/Recipes/updateRecipe', await _recipeBody(recipe));
  }



  Future<dynamic> getRecipesForAuthorization(Filters filters) => _post('/api/Recipes/filters/authorization', filters.toJson());

  Future<dynamic> commentRecipe({required String recipeId, required String comment, String? userId, String? username, int? note}) =>
      _post('/api/Recipes/commentRecipe', {
        'recipe': recipeId,
        'comment': comment,
        if (userId != null) 'user': userId,
        if (username != null) 'username': username,
        if (note != null) 'note': note,
      });

  Future<dynamic> deleteComment({required String recipeId, required String commentId}) =>
      _delete('/api/Recipes/deleteComment/${Uri.encodeComponent(recipeId)}/${Uri.encodeComponent(commentId)}');

  Future<dynamic> getGroupById(String id) => _get('/api/Groups/getGroupById/${Uri.encodeComponent(id)}');

  Future<List<GroupMember>> getGroupMembers(String id) async {
    final response = await getGroupUsers(id);
    if (response is! Map<String, dynamic> || response['members'] is! List) {
      throw const FormatException('Réponse invalide : membres du groupe manquants.');
    }
    return List<GroupMember>.unmodifiable((response['members'] as List).map((member) {
      if (member is! Map<String, dynamic>) {
        throw const FormatException('Réponse invalide : membre mal formé.');
      }
      return GroupMember.fromJson(member);
    }));
  }

  Future<dynamic> createNewGroup(String name) => _post('/api/Groups/createNewGroup', {'name': name});

  Future<dynamic> joinGroup({required String groupId, required String memberId, String? memberUserName}) =>
      _post('/api/Groups/joinGroup', {'id': groupId, 'memberId': memberId, if (memberUserName != null) 'memberUserName': memberUserName});

  Future<dynamic> deleteGroup(String groupId) => _post('/api/Groups/deleteGroup', groupId);

  Future<dynamic> changeCanEdit({required String groupId, required bool canEdit}) =>
      _post('/api/Groups/changeCanEdit', {'id': groupId, 'canEdit': canEdit});

  Future<dynamic> changeGroupOwner({required String groupId, required String newOwnerId}) =>
      _post('/api/Groups/changeGroupOwner', {'id': groupId, 'newOwner': newOwnerId});

  Future<dynamic> getGroupUsers(String id) => _get('/api/Groups/getGroupUsers/${Uri.encodeComponent(id)}');

  Future<dynamic> quitGroup({required String groupId, required String memberId}) =>
      _post('/api/Groups/quitGroup', {'id': groupId, 'memberId': memberId});

  Future<dynamic> getIngredientsPrices() => _get('/api/Prices/getIngredients');

  Future<dynamic> editIngredientsPrices({required List<IngredientPriceInput> ingredients}) =>
      _post('/api/Prices/editIngredients', {'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList()});

  Future<dynamic> deleteIngredient(String id) => _post('/api/Prices/deleteIngredient', id);

  Future<dynamic> updateDisplayPriceRecipe(bool showPrice) => _post('/api/Prices/updateDisplayPriceRecipe', showPrice);

  Future<dynamic> deleteAccount() async {
    final response = await _post('/api/User/deleteAccount');
    await logout();
    return response;
  }

  Future<User> getUserInfos() async {
    final response = await _get('/api/User/getUserInfos');
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Réponse invalide : informations utilisateur manquantes.');
    }

    final fetchedUser = User.fromJson(response);
    user = fetchedUser;
    notifyListeners();
    return fetchedUser;
  }

  Future<dynamic> verifyEmail(String token) => _post('/api/User/verifyEmail', token);

  Future<dynamic> updateBio({required String bio, String? userName}) =>
      _post('/api/User/updateBio', {'bio': bio, if (userName != null) 'userName': userName});

  Future<dynamic> updateEmail({required String email, required String lastPassword}) =>
      _post('/api/User/updateEmail', {'email': email, 'lastPassword': lastPassword});

  Future<dynamic> confirmUpdateEmail(String token) => _post('/api/User/confirmUpdateEmail', token);

  Future<dynamic> resetPassword({required String email, String? newPassword, String? confirmNewPassword}) => _post('/api/User/resetPassword', {
    'email': email,
    if (newPassword != null) 'newPassword': newPassword,
    if (confirmNewPassword != null) 'confirmNewPassword': confirmNewPassword,
  });

  Future<dynamic> confirmResetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmNewPassword,
  }) =>
      _post('/api/User/confirmResetPassword', {'email': email, 'token': token, 'newPassword': newPassword, 'confirmNewPassword': confirmNewPassword});

  Future<dynamic> updatePassword({required String lastPassword, required String newPassword, required String confirmNewPassword}) =>
      _post('/api/User/updatePassword', {'lastPassword': lastPassword, 'newPassword': newPassword, 'confirmNewPassword': confirmNewPassword});

  Future<dynamic> updateImage({required String imageBase64, required String extension, required String fileType, String? oldImage}) =>
      _post('/api/User/updateImage', {
        'image': {'imageBase64': imageBase64, 'extension': extension, 'fileType': fileType},
        if (oldImage != null) 'oldImage': oldImage,
      });

  Future<dynamic> getFavorites() => _get('/api/User/getFavs');

  Future<dynamic> contactSupport({required String userEmail, required String userObject, required String userMessage}) =>
      _post('/api/User/contact', {'userEmail': userEmail, 'userObject': userObject, 'userMessage': userMessage});

  Future<dynamic> addFavorite(String recipeId) => _post('/api/User/addFav/${Uri.encodeComponent(recipeId)}');

  Future<dynamic> removeFavorite(String recipeId) => _post('/api/User/removeFav/${Uri.encodeComponent(recipeId)}');

  Future<dynamic> getWeatherForecast() => _get('/WeatherForecast');

  int? _durationInMinutes(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final plainMinutes = int.tryParse(normalized);
    if (plainMinutes != null) return plainMinutes;
    final duration = RegExp(r'^(?:(\d+)\s*(?:h|heure(?:s)?)\s*)?(?:(\d+)\s*(?:min|m))?$').firstMatch(normalized);
    if (duration == null || (duration.group(1) == null && duration.group(2) == null)) return null;
    return (int.tryParse(duration.group(1) ?? '') ?? 0) * 60 + (int.tryParse(duration.group(2) ?? '') ?? 0);
  }

  int? parseRecipeDuration(String value) => _durationInMinutes(value);

  Future<void> createRecipe({required RecipeFull recipe}) async {
    final body = await _recipeBody(recipe);
    body.addAll({
      'id': _newGuid(),
      'nameWithoutDiacritics': removeDiacritics(recipe.name),
      'groupsIds': recipe.groups.map((group) => group.id).whereType<String>().toList(),
      'categoriesIds': <String>[],
      'note': 0,
      'nbNotes': 0,
      'noteId': null,
    });
    await _post('/api/Recipes/createRecipe', body);
    notifyListeners();
  }

  Future<Map<String, dynamic>> _recipeBody(RecipeFull recipe) async {
    final body = recipe.toJson();
    final localImages = await Future.wait(
      recipe.documents.where((uri) => uri.scheme == 'file').map((uri) => ApiImageInput.fromXFile(XFile(uri.toFilePath()))),
    );
    body['documents'] = recipe.documents.where((uri) => uri.scheme != 'file').map((uri) => uri.pathSegments.last).toList();
    body['images'] = [...recipe.images, ...localImages].map((image) => image.toJson()).toList();
    body['ingredientsCategories'] = recipe.ingredientCategories.map((category) {
      final json = category.toJson();
      if (category.id.isEmpty) json.remove('id');
      json['ingredientsIds'] = <String>[];
      json['ingredients'] = category.ingredients.map((ingredient) {
        final json = ingredient.toJson();
        if (ingredient.id.isEmpty) json.remove('id');
        json['nameWithoutDiacritics'] = ingredient.nameWithoutDiacritics;
        return json;
      }).toList();
      return json;
    }).toList();
    return body;
  }

  static String _newGuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
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

class ApiImageInput {
  final String imageBase64;
  final String extension;
  final String fileType;

  const ApiImageInput({required this.imageBase64, required this.extension, required this.fileType});

  Map<String, dynamic> toJson() => {
    'imageBase64': imageBase64,
    'extension': extension,
    'fileType': fileType,
  };

  static Future<ApiImageInput> fromXFile(XFile file) async {
    final extension = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';
    final fileType = file.mimeType ??
        switch (extension) {
          'jpg' || 'jpeg' => 'image/jpeg',
          'png' => 'image/png',
          'gif' => 'image/gif',
          _ => 'application/octet-stream',
        };
    return ApiImageInput(imageBase64: base64Encode(await file.readAsBytes()), extension: extension, fileType: fileType);
  }
}

class IngredientPriceInput {
  final String? id;
  final String? name;
  final String? unit;
  final double price;

  const IngredientPriceInput({this.id, this.name, this.unit, required this.price});

  Map<String, dynamic> toJson() => {if (id != null) 'id': id, if (name != null) 'name': name, if (unit != null) 'unit': unit, 'price': price};
}
