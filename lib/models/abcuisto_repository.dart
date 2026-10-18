import 'dart:convert';
import 'dart:math';

import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/models/user.dart';
import 'package:abcuisto/recipe/add_recipe/enum_extensions.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

  Future<dynamic> deleteRecipe({required String id}) => _post('/api/Recipes/deleteRecipe', {'id': id});

  Future<dynamic> updateRecipe({
    required String id,
    String? name,
    int? preparationTime,
    int? cookingTime,
    int? waitingTime,
    int? totalTime,
    String? creator,
    String? creatorPseudo,
    String? category,
    List<String>? documents,
    List<ApiImageInput>? images,
    int? forNumber,
    String? typeNumber,
    List<String>? steps,
    List<String>? tags,
    List<ApiGroupInput>? groups,
    String? noteId,
    int? note,
    int? nbNotes,
    List<ApiRecipeCommentInput>? comments,
    List<String>? ustensiles,
    List<ApiRecipeCategoryInput>? ingredientsCategories,
    bool includePreparationTime = false,
    bool includeCookingTime = false,
    bool includeWaitingTime = false,
    bool includeTotalTime = false,
  }) {
    final recipe = <String, dynamic>{
      'id': id,
      if (name != null) 'name': name,
      if (name != null) 'nameWithoutDiacritics': removeDiacritics(name),
      if (preparationTime != null || includePreparationTime) 'preparationTime': preparationTime,
      if (cookingTime != null || includeCookingTime) 'cookingTime': cookingTime,
      if (waitingTime != null || includeWaitingTime) 'waitingTime': waitingTime,
      if (totalTime != null || includeTotalTime) 'totalTime': totalTime,
      if (creator != null) 'creator': creator,
      if (creatorPseudo != null) 'creatorPseudo': creatorPseudo,
      if (category != null) 'category': category,
      if (documents != null) 'documents': documents,
      if (images != null) 'images': images.map((image) => image.toJson()).toList(),
      if (forNumber != null) 'forNumber': forNumber,
      if (typeNumber != null) 'typeNumber': typeNumber,
      if (steps != null) 'steps': steps,
      if (tags != null) 'tags': tags,
      if (groups != null) ...{
        'groups': groups.map((group) => group.toJson()).toList(),
        'groupsIds': groups.map((group) => group.id).whereType<String>().toList(),
      },
      if (noteId != null) 'noteId': noteId,
      if (note != null) 'note': note,
      if (nbNotes != null) 'nbNotes': nbNotes,
      if (comments != null) 'comments': comments.map((comment) => comment.toJson()).toList(),
      if (ustensiles != null) 'ustensiles': ustensiles,
      if (ingredientsCategories != null) ...{
        'ingredientsCategories': ingredientsCategories.map((category) => category.toJson()).toList(),
        'categoriesIds': <String>[],
      },
    };
    return _post('/api/Recipes/updateRecipe', recipe);
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

  Future<dynamic> createNewGroup(String name) => _post('/api/Groups/createNewGroup', name);

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

  Future<void> createRecipe({
    required String name,
    required RecipeCategory category,
    required String tempsPreparation,
    required String tempsCuisson,
    required String tempsRepos,
    required List<String> steps,
    required List<String> ustensiles,
    required double forNumber,
    required RecipeServingType typeNumber,
    required List<RecipeTag> tags,
    required List<ApiGroupInput> groups,
    required List<ApiRecipeCategoryInput> ingredientsCategories,
    required List<ApiImageInput> images,
    String? createur,
    String? createurPseudo,
  }) async {
    final recipeTags = tags.map((tag) => tag.displayValue).toList();
    final prepTime = _durationInMinutes(tempsPreparation);
    final cookTime = _durationInMinutes(tempsCuisson);
    final waitingTime = _durationInMinutes(tempsRepos);
    final body = <String, dynamic>{
      'id': _newGuid(),
      'name': name,
      'nameWithoutDiacritics': removeDiacritics(name),
      'category': category.displayValue,
      'preparationTime': prepTime,
      'cookingTime': cookTime,
      'waitingTime': waitingTime,
      'steps': steps,
      'ustensiles': ustensiles,
      'forNumber': forNumber.round(),
      'typeNumber': typeNumber.displayValue,
      'creator': createur,
      'creatorPseudo': createurPseudo,
      'tags': recipeTags,
      'groups': groups.map((group) => group.toJson()).toList(),
      'groupsIds': groups.map((group) => group.id).whereType<String>().toList(),
      'categoriesIds': <String>[],
      'ingredientsCategories': ingredientsCategories.map((category) => category.toJson()).toList(),
      'images': images.map((image) => image.toJson()).toList(),
      'note': 0,
      'nbNotes': 0,
      'noteId': null,
    };
    body.removeWhere((key, value) => value == null && key != 'noteId');
    if (prepTime != null || cookTime != null || waitingTime != null) {
      body['totalTime'] = (prepTime ?? 0) + (cookTime ?? 0) + (waitingTime ?? 0);
    }
    await _post('/api/Recipes/createRecipe', body);
    notifyListeners();
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
  final String? imageBase64;
  final String? extension;
  final String? fileType;

  const ApiImageInput({this.imageBase64, this.extension, this.fileType});

  Map<String, dynamic> toJson() => {
    if (imageBase64 != null) 'imageBase64': imageBase64,
    if (extension != null) 'extension': extension,
    if (fileType != null) 'fileType': fileType,
  };
}

class ApiGroupInput {
  final String? id;
  final String? name;
  final String? owner;
  final bool? canEdit;
  final String? link;
  final String? newOwner;
  final String? memberId;
  final String? memberUserName;
  final List<Map<String, dynamic>> members;

  const ApiGroupInput({
    this.id,
    this.name,
    this.owner,
    this.canEdit,
    this.link,
    this.newOwner,
    this.memberId,
    this.memberUserName,
    this.members = const [],
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (owner != null) 'owner': owner,
    if (canEdit != null) 'canEdit': canEdit,
    if (link != null) 'link': link,
    if (newOwner != null) 'newOwner': newOwner,
    if (memberId != null) 'memberId': memberId,
    if (memberUserName != null) 'memberUserName': memberUserName,
    'members': members,
  };
}

class ApiRecipeCommentInput {
  final String? id;
  final String? recipe;
  final String? user;
  final String? comment;
  final String? username;
  final int? note;

  const ApiRecipeCommentInput({this.id, this.recipe, this.user, this.comment, this.username, this.note});

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (recipe != null) 'recipe': recipe,
    if (user != null) 'user': user,
    if (comment != null) 'comment': comment,
    if (username != null) 'username': username,
    if (note != null) 'note': note,
  };
}

class ApiRecipeIngredientInput {
  final String? id;
  final String? name;
  final String? type;
  final String number;
  final int index;
  final double? price;
  final String? category;

  const ApiRecipeIngredientInput({this.id, this.name, this.type, required this.number, required this.index, this.price, this.category});

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (name != null) 'nameWithoutDiacritics': removeDiacritics(name!),
    if (type != null) 'type': type,
    'number': number,
    'index': index,
    if (price != null) 'price': price,
    if (category != null) 'category': category,
  };
}

class ApiRecipeCategoryInput {
  final String? id;
  final String? name;
  final int? index;
  final List<ApiRecipeIngredientInput>? ingredients;
  final String? recipe;

  const ApiRecipeCategoryInput({this.id, this.name, this.index, this.ingredients, this.recipe});

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (index != null) 'index': index,
    if (ingredients != null) 'ingredients': ingredients!.map((ingredient) => ingredient.toJson()).toList(),
    'ingredientsIds': <String>[],
  };
}

class IngredientPriceInput {
  final String? id;
  final String? name;
  final String? unit;
  final double price;

  const IngredientPriceInput({this.id, this.name, this.unit, required this.price});

  Map<String, dynamic> toJson() => {if (id != null) 'id': id, if (name != null) 'name': name, if (unit != null) 'unit': unit, 'price': price};
}
