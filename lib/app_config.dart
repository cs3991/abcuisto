enum AppFlavor { dev, prod }

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiUrl,
  });

  final AppFlavor flavor;
  final String apiUrl;

  static AppConfig? _instance;

  static AppConfig get instance {
    final current = _instance;
    if (current == null) {
      throw StateError('AppConfig has not been initialized. Call AppConfig.initialize() before use.');
    }
    return current;
  }

  static void initialize({required AppFlavor flavor}) {
    _instance = AppConfig(
      flavor: flavor,
      apiUrl: switch (flavor) {
        AppFlavor.dev => 'http://localhost:7066',
        AppFlavor.prod => 'https://back.abcuisto.fr',
      },
    );
  }
}
