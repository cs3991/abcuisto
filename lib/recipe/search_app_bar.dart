import 'package:abcuisto/login/authentication_cubit.dart';
import 'package:abcuisto/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../profile/profile_page.dart';
import 'filters/filter_cubit.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  SearchAppBar({super.key});

  final TextEditingController searchBarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchText = context.select((FilterCubit cubit) => cubit.state.filter.searchText ?? '');
    searchBarController.value = TextEditingValue(
      text: searchText,
      selection: TextSelection.collapsed(offset: searchText.length),
    );
    return AppBar(
      toolbarHeight: 65,

      title: TextField(
        controller: searchBarController,
        decoration: InputDecoration(
          hintText: 'Rechercher une recette',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          constraints: BoxConstraints(maxHeight: 50),
          isDense: false,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainer,
          suffixIcon: searchText.isEmpty
              ? Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.outline)
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: Theme.of(context).colorScheme.outline,
                  tooltip: 'Effacer la recherche',
                  onPressed: () {
                    searchBarController.clear();
                    context.read<FilterCubit>().updateSearchPattern('');
                  },
                ),
        ),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        onChanged: (t) => context.read<FilterCubit>().updateSearchPattern(t),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state is AuthenticationLoggedIn ? Icons.person_rounded : Icons.login_rounded),
                tooltip: state is AuthenticationLoggedIn ? "Connecté" : "Se connecter",
                onPressed: () {
                  if (state is AuthenticationLoggedOut || state is AuthenticationInitial) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  } else if (state is AuthenticationLoggedIn) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
