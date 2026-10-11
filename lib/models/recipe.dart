import 'package:abcuisto/app_config.dart' show AppConfig;

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

  final String label;
  final String displayName;

  const Category(this.label, this.displayName);

  static Category? fromApi(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase();
    for (final category in values) {
      if (category.label.toLowerCase() == normalized || category.displayName.toLowerCase() == normalized) {
        return category;
      }
    }
    return null;
  }
}

Duration? _durationFromMinutes(dynamic value) => value is num ? Duration(minutes: value.toInt()) : null;

int? _minutesFromDuration(Duration? value) => value?.inMinutes;

String _stringOrEmpty(dynamic value) => value is String ? value : '';

List<String> _stringList(dynamic value) => value is List ? value.whereType<String>().toList() : <String>[];

class Recipe {
  final String id;
  final List<Uri> images;
  final String name;
  final Duration? prepTime;
  final Duration? cookTime;
  final Duration? restTime;
  final Duration? apiTotalTime;
  final double? note;
  final String creatorId;
  final String creatorName;
  final DateTime createdDate;
  final Category? category;
  final List<String> cookware;
  final List<String> documents;
  final List<RecipeImage> apiImages;
  final int? forNumber;
  final String? typeNumber;
  final List<String> tags;
  final List<RecipeGroup> groups;
  final String? noteId;
  final int? nbNotes;
  final List<RecipeComment> comments;

  Recipe({
    required this.id,
    required this.images,
    required this.name,
    this.prepTime,
    this.cookTime,
    this.restTime,
    this.apiTotalTime,
    this.note,
    this.creatorId = '',
    required this.creatorName,
    required this.createdDate,
    required this.category,
    required this.cookware,
    this.documents = const [],
    this.apiImages = const [],
    this.forNumber,
    this.typeNumber,
    this.tags = const [],
    this.groups = const [],
    this.noteId,
    this.nbNotes,
    this.comments = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> recipe) {
    final documents = _stringList(recipe['documents']);
    final rawImages = recipe['images'];
    return Recipe(
      id: _stringOrEmpty(recipe['id']),
      images: documents.map((document) => Uri.parse('${AppConfig.instance.apiUrl}/images/$document')).toList(),
      name: _stringOrEmpty(recipe['name']),
      prepTime: _durationFromMinutes(recipe['preparationTime']),
      cookTime: _durationFromMinutes(recipe['cookingTime']),
      restTime: _durationFromMinutes(recipe['waitingTime']),
      apiTotalTime: _durationFromMinutes(recipe['totalTime']),
      note: (recipe['note'] as num?)?.toDouble(),
      creatorId: _stringOrEmpty(recipe['creator']),
      creatorName: _stringOrEmpty(recipe['creatorPseudo']),
      createdDate: DateTime.now(),
      category: Category.fromApi(recipe['category'] as String?),
      cookware: _stringList(recipe['ustensiles']),
      documents: documents,
      apiImages: rawImages is List ? rawImages.whereType<Map<String, dynamic>>().map(RecipeImage.fromJson).toList() : const [],
      forNumber: recipe['forNumber'] as int?,
      typeNumber: recipe['typeNumber'] as String?,
      tags: _stringList(recipe['tags']),
      groups: recipe['groups'] is List ? (recipe['groups'] as List).whereType<Map<String, dynamic>>().map(RecipeGroup.fromJson).toList() : const [],
      noteId: recipe['noteId'] as String?,
      nbNotes: recipe['nbNotes'] as int?,
      comments: recipe['comments'] is List
          ? (recipe['comments'] as List).whereType<Map<String, dynamic>>().map(RecipeComment.fromJson).toList()
          : const [],
    );
  }

  String? get prepTimeFormatted => _printDuration(prepTime);

  String? get cookTimeFormatted => _printDuration(cookTime);

  String? get restTimeFormatted => _printDuration(restTime);

  Duration get totalTime => apiTotalTime ?? (prepTime ?? Duration.zero) + (cookTime ?? Duration.zero) + (restTime ?? Duration.zero);

  String? get totalTimeFormatted => _printDuration(totalTime);

  String get createdTimeFormatted {
    final day = createdDate.day.toString().padLeft(2, '0');
    final month = createdDate.month.toString().padLeft(2, '0');
    final year = createdDate.year.toString();
    return '$day/$month/$year';
  }

  String? _printDuration(Duration? duration) {
    if (duration == null) return null;
    if (duration < const Duration(hours: 1)) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? "s" : ""}';
    }
    return '${duration.inHours} h ${duration.inMinutes.remainder(60)} min';
  }
}

class RecipeFull extends Recipe {
  final List<RecipeIngredientCategory> ingredientCategories;
  final List<String> instructions;

  Map<String, List<Ingredient>> get ingredients => {for (final category in ingredientCategories) category.name: category.ingredients};

  RecipeFull({
    required super.id,
    required super.images,
    required super.name,
    super.prepTime,
    super.cookTime,
    super.restTime,
    super.apiTotalTime,
    super.note,
    super.creatorId,
    required super.creatorName,
    required super.createdDate,
    required super.category,
    required super.cookware,
    super.documents,
    super.apiImages,
    super.forNumber,
    super.typeNumber,
    super.tags,
    super.groups,
    super.noteId,
    super.nbNotes,
    super.comments,
    required this.ingredientCategories,
    required this.instructions,
  });

  factory RecipeFull.fromJson(Map<String, dynamic> recipe) {
    final baseRecipe = Recipe.fromJson(recipe);
    final rawCategories = recipe['ingredientsCategories'];
    final categories = rawCategories is List
        ? rawCategories.whereType<Map<String, dynamic>>().map(RecipeIngredientCategory.fromJson).toList()
        : <RecipeIngredientCategory>[];

    return RecipeFull(
      id: baseRecipe.id,
      images: baseRecipe.images,
      name: baseRecipe.name,
      prepTime: baseRecipe.prepTime,
      cookTime: baseRecipe.cookTime,
      restTime: baseRecipe.restTime,
      apiTotalTime: baseRecipe.apiTotalTime,
      note: baseRecipe.note,
      creatorId: baseRecipe.creatorId,
      creatorName: baseRecipe.creatorName,
      createdDate: baseRecipe.createdDate,
      category: baseRecipe.category,
      cookware: baseRecipe.cookware,
      documents: baseRecipe.documents,
      apiImages: baseRecipe.apiImages,
      forNumber: baseRecipe.forNumber,
      typeNumber: baseRecipe.typeNumber,
      tags: baseRecipe.tags,
      groups: baseRecipe.groups,
      noteId: baseRecipe.noteId,
      nbNotes: baseRecipe.nbNotes,
      comments: baseRecipe.comments,
      ingredientCategories: categories,
      instructions: _stringList(recipe['steps']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'preparationTime': _minutesFromDuration(prepTime),
    'cookingTime': _minutesFromDuration(cookTime),
    'waitingTime': _minutesFromDuration(restTime),
    'totalTime': _minutesFromDuration(totalTime),
    'creator': creatorId.isEmpty ? null : creatorId,
    'creatorPseudo': creatorName,
    'category': category?.displayName,
    'documents': documents.isEmpty ? null : documents,
    'images': apiImages.map((image) => image.toJson()).toList(),
    'forNumber': forNumber,
    'typeNumber': typeNumber,
    'steps': instructions,
    'tags': tags,
    'groups': groups.map((group) => group.toJson()).toList(),
    'noteId': noteId,
    'note': note?.round(),
    'nbNotes': nbNotes,
    'comments': comments.map((comment) => comment.toJson()).toList(),
    'ustensiles': cookware,
    'ingredientsCategories': ingredientCategories.map((category) => category.toJson()).toList(),
  };
}

class RecipeIngredientCategory {
  final String id;
  final String name;
  final int index;
  final String? recipe;
  final List<Ingredient> ingredients;

  const RecipeIngredientCategory({required this.id, required this.name, required this.index, this.recipe, required this.ingredients});

  factory RecipeIngredientCategory.fromJson(Map<String, dynamic> json) => RecipeIngredientCategory(
    id: _stringOrEmpty(json['id']),
    name: _stringOrEmpty(json['name']),
    index: json['index'] as int? ?? 0,
    recipe: json['recipe'] as String?,
    ingredients: json['ingredients'] is List
        ? (json['ingredients'] as List).whereType<Map<String, dynamic>>().map(Ingredient.fromJson).toList()
        : const [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'index': index,
    'ingredients': ingredients.map((ingredient) => ingredient.toJson()).toList(),
    'recipe': recipe,
  };
}

class RecipeImage {
  final String? imageBase64;
  final String? extension;
  final String? fileType;

  const RecipeImage({this.imageBase64, this.extension, this.fileType});

  factory RecipeImage.fromJson(Map<String, dynamic> json) =>
      RecipeImage(imageBase64: json['imageBase64'] as String?, extension: json['extension'] as String?, fileType: json['fileType'] as String?);

  Map<String, dynamic> toJson() => {'imageBase64': imageBase64, 'extension': extension, 'fileType': fileType};
}

class RecipeGroup {
  final String? id;
  final String? name;
  final String? owner;
  final bool? canEdit;
  final String? link;
  final String? newOwner;
  final String? memberId;
  final String? memberUserName;

  const RecipeGroup({this.id, this.name, this.owner, this.canEdit, this.link, this.newOwner, this.memberId, this.memberUserName});

  factory RecipeGroup.fromJson(Map<String, dynamic> json) => RecipeGroup(
    id: json['id'] as String?,
    name: json['name'] as String?,
    owner: json['owner'] as String?,
    canEdit: json['canEdit'] as bool?,
    link: json['link'] as String?,
    newOwner: json['newOwner'] as String?,
    memberId: json['memberId'] as String?,
    memberUserName: json['memberUserName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (owner != null) 'owner': owner,
    if (canEdit != null) 'canEdit': canEdit,
    if (link != null) 'link': link,
    if (newOwner != null) 'newOwner': newOwner,
    if (memberId != null) 'memberId': memberId,
    if (memberUserName != null) 'memberUserName': memberUserName,
  };
}

class RecipeComment {
  final String? id;
  final String? recipe;
  final String? user;
  final String? comment;
  final String? username;
  final int? note;

  const RecipeComment({this.id, this.recipe, this.user, this.comment, this.username, this.note});

  factory RecipeComment.fromJson(Map<String, dynamic> json) => RecipeComment(
    id: json['id'] as String?,
    recipe: json['recipe'] as String?,
    user: json['user'] as String?,
    comment: json['comment'] as String?,
    username: json['username'] as String?,
    note: json['note'] as int?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (recipe != null) 'recipe': recipe,
    if (user != null) 'user': user,
    if (comment != null) 'comment': comment,
    if (username != null) 'username': username,
    if (note != null) 'note': note,
  };
}
