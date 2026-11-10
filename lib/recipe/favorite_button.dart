import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../login/authentication_cubit.dart';
import 'favorites_cubit.dart';

class FavoriteButton extends StatelessWidget {
  final String recipeId;
  final Color? foregroundColor;

  const FavoriteButton({
    super.key,
    required this.recipeId,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final loggedIn =
        context.watch<AuthenticationCubit>().state is AuthenticationLoggedIn;
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final selected = state.ids.contains(recipeId);
        final busy = state.isLoading || state.pendingIds.contains(recipeId);
        return IconButton(
          tooltip: !loggedIn
              ? 'Connectez-vous pour gérer vos favoris'
              : !state.isLoaded && !busy
              ? 'Réessayer de charger les favoris'
              : selected
              ? 'Retirer des favoris'
              : 'Ajouter aux favoris',
          icon: busy
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foregroundColor,
                  ),
                )
              : Icon(
                  selected
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
          color:
              foregroundColor ??
              (selected ? Theme.of(context).colorScheme.primary : null),
          disabledColor: foregroundColor?.withValues(alpha: 0.6),
          onPressed: !loggedIn || busy
              ? null
              : () {
                  final cubit = context.read<FavoritesCubit>();
                  state.isLoaded
                      ? cubit.toggleFavorite(recipeId)
                      : cubit.reload();
                },
        );
      },
    );
  }
}
