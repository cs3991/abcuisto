class User {
  final String id;
  final String? userName;
  final String? email;
  final String? bio;

  const User({required this.id, this.userName, this.email, this.bio});

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Réponse invalide : identifiant utilisateur manquant.');
    }

    return User(id: id, userName: json['userName'] as String?, email: json['email'] as String?, bio: json['bio'] as String?);
  }
}
