import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'links/app_link_cubit.dart';
import 'links/app_link_page.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
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
          BlocProvider(create: (_) => AppLinkCubit(AppLinks()), lazy: false),
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

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppLinkCubit>().start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      initialRoute: '/',
      builder: (context, child) => MultiBlocListener(
        listeners: [
          BlocListener<AuthenticationCubit, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationLoggedIn || state is AuthenticationLoggedOut) {
                context.read<RecipeCubit>().refreshPermissions();
              }
            },
          ),
          BlocListener<AppLinkCubit, AppLinkState>(
        listener: (context, state) {
          final link = state.link;
          if (link != null) {
            _navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => AppLinkPage(link: link)));
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
          ),
        ],
        child: child ?? const SizedBox.shrink(),
      ),
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
