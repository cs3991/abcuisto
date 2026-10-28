enum AppLinkType { group, recipe }

class AppLink {
  final AppLinkType type;
  final String id;
  final Uri uri;

  const AppLink({required this.type, required this.id, required this.uri});

  static AppLink? fromUri(Uri uri) {
    if (uri.scheme != 'https' || !const {'abcuisto.fr', 'dev.abcuisto.fr'}.contains(uri.host)) return null;
    final segments = uri.pathSegments.where((part) => part.isNotEmpty).toList();
    if (segments.length != 2) return null;
    final type = switch (segments.first) {
      'group' => AppLinkType.group,
      'recette' => AppLinkType.recipe,
      _ => null,
    };
    if (type == null || !RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(segments.last)) return null;
    return AppLink(type: type, id: segments.last, uri: uri);
  }
}
