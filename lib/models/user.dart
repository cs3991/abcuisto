import 'recipe.dart';

class User {
  final String id;
  final String? userName;
  final String? email;
  final String? bio;
  final String? image;
  final List<RecipeGroup> groups;

  const User({required this.id, this.userName, this.email, this.bio, this.image, this.groups = const []});

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Réponse invalide : identifiant utilisateur manquant.');
    }

    final rawGroups = json['groups'] as List<dynamic>?;
    final groupValues = rawGroups ?? const <dynamic>[];
    final groups = List<RecipeGroup>.unmodifiable(
      groupValues.whereType<Map<String, dynamic>>().map(RecipeGroup.fromJson),
    );
    return User(
      id: id,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      image: json['image'] as String?,
      groups: groups,
    );
  }
}
