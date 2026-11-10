import 'package:abcuisto/recipe/filters/filter_cubit.dart';
import 'package:abcuisto/recipe/favorites_cubit.dart';
import 'package:abcuisto/login/authentication_cubit.dart';
import 'package:abcuisto/recipe/recipes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationLoggedIn ||
                state is AuthenticationLoggedOut) {
              if (state is AuthenticationLoggedOut) {
                context.read<FilterCubit>().updateFavoritesOnly(false);
              }
              context.read<FavoritesCubit>().resetSession();
            }
          },
        ),
        BlocListener<FavoritesCubit, FavoritesState>(
          listenWhen: (previous, current) =>
              previous.ids.length != current.ids.length ||
              !previous.ids.containsAll(current.ids) ||
              current.error != null,
          listener: (context, state) {
            context.read<FilterCubit>().updateFavoriteIds(state.ids);
            if (state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
        ),
      ],
      child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationInitial) {
            context.read<AuthenticationCubit>().initialize();
            return Scaffold(body: Center(child: CircularProgressIndicator()));
            // } else if (state is AuthenticationLoggedOut) {
            //   return LoginPage();
          } else if (state is AuthenticationLoggedIn ||
              state is AuthenticationLoggedOut) {
            return RecipePage();
          } else {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}
