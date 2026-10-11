import 'package:abcuisto/app_config.dart';
import 'package:abcuisto/main.dart' as app;
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(flavor: AppFlavor.prod);
  runApp(const app.ProvidersWidget());
}
