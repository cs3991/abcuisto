import 'recipe.dart';

class User {
  final String id;
  final String? userName;
  final String? email;
  final String? bio;
  final List<RecipeGroup> groups;

  const User({required this.id, this.userName, this.email, this.bio, this.groups = const []});

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Réponse invalide : identifiant utilisateur manquant.');
    }

    final groups = json['groups'] is List
        ? (json['groups'] as List).whereType<Map<String, dynamic>>().map(RecipeGroup.fromJson).toList()
        : const <RecipeGroup>[];
    return User(
      id: id,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      groups: groups,
    );
  }
}
