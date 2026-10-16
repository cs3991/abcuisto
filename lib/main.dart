import 'dart:ui';

import 'package:abcuisto/app_config.dart';
import 'package:abcuisto/entry_page.dart';
import 'package:abcuisto/login/authentication_cubit.dart';
import 'package:abcuisto/models/abcuisto_repository.dart';
import 'package:abcuisto/recipe/add_recipe/add_recipe_cubit.dart';
import 'package:abcuisto/recipe/comment_cubit.dart';
import 'package:abcuisto/recipe/filters/filter_cubit.dart';
import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() {
  final flavorName = const String.fromEnvironment('APP_FLAVOR', defaultValue: 'prod');
  final flavor = AppFlavor.values.firstWhere(
    (value) => value.name == flavorName,
    orElse: () => AppFlavor.dev,
  );

  AppConfig.initialize(flavor: flavor);
  runApp(const ProvidersWidget());
}

class ProvidersWidget extends StatelessWidget {
  const ProvidersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final repo = AbcuistoRepository(url: AppConfig.instance.apiUrl);
        return repo;
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthenticationCubit(context.read<AbcuistoRepository>())),
          BlocProvider(create: (context) => RecipeCubit(context.read<AbcuistoRepository>())),
          BlocProvider(create: (context) => CommentCubit(context.read<AbcuistoRepository>())),
          BlocProvider(create: (context) => FilterCubit(context.read<AbcuistoRepository>())),
          BlocProvider(create: (context) => AddRecipeCubit(context.read<AbcuistoRepository>())),
        ],
        child: App(),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyScrollBehavior(),
      title: 'ABCuisto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff006874), brightness: Brightness.light),
      ),
      home: EntryPage(),
    );
  }
}

class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
