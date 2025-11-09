import 'package:abcuisto/abcuisto_repository.dart';
import 'package:abcuisto/entry_page.dart';
import 'package:abcuisto/login/authentication_cubit.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProvidersWidget());
}

class ProvidersWidget extends StatelessWidget {
  const ProvidersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final repo = AbcuistoRepository(url: "https://back.abcuisto.fr");
        // repo.init();
        return repo;
      },
      child: BlocProvider(
        create: (context) => AuthenticationCubit(context.read<AbcuistoRepository>()),
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
      title: 'ABCuisto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff006874))),
      home: EntryPage(),
    );
  }
}
