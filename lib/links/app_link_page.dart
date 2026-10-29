import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../login/authentication_cubit.dart';
import '../login/login_page.dart';
import '../models/abcuisto_repository.dart';
import '../profile/groups/join_group_cubit.dart';
import '../profile/profile_page.dart';
import '../recipe/filters/filter_cubit.dart';
import '../recipe/recipe_cubit.dart';
import '../recipe/recipe_details.dart';
import 'app_link.dart';
import 'linked_recipe_cubit.dart';

class AppLinkPage extends StatelessWidget {
  final AppLink link;

  const AppLinkPage({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    if (link.type == AppLinkType.recipe) {
      return BlocProvider(
        create: (context) {
          final cubit = LinkedRecipeCubit(context.read<AbcuistoRepository>(), link.id);
          final authentication = context.read<AuthenticationCubit>().state;
          if (authentication is AuthenticationLoggedIn || authentication is AuthenticationLoggedOut) cubit.loadRecipe();
          return cubit;
        },
        child: BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationLoggedIn || state is AuthenticationLoggedOut) {
              context.read<LinkedRecipeCubit>().loadRecipe();
            }
          },
          child: BlocBuilder<LinkedRecipeCubit, LinkedRecipeState>(
          builder: (context, state) {
            if (state.recipe != null) {
              return BlocProvider(
                key: ObjectKey(state.recipe),
                create: (context) => RecipeCubit(context.read<AbcuistoRepository>())..showRecipe(state.recipe!),
                child: const RecipeDetailsPage(),
              );
            }
            return Scaffold(
              appBar: AppBar(title: const Text('Recette')),
              body: Center(
                child: state.status == LinkedRecipeStatus.loading
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.errorMessage ?? 'Recette indisponible.'),
                            TextButton(onPressed: context.read<LinkedRecipeCubit>().loadRecipe, child: const Text('Réessayer')),
                          ],
                        ),
                      ),
              ),
            );
          },
          ),
        ),
      );
    }
    return BlocProvider(
      create: (context) => JoinGroupCubit(context.read<AbcuistoRepository>()),
      child: BlocConsumer<JoinGroupCubit, JoinGroupState>(
        listener: (context, state) {
          if (state.status == JoinGroupStatus.success) {
            context.read<FilterCubit>().update();
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
        },
        builder: (context, joinState) => Scaffold(
      appBar: AppBar(title: const Text('Invitation à un groupe')),
      body: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.group_rounded, size: 72),
              const SizedBox(height: 24),
              const Text('Vous avez reçu une invitation à rejoindre un groupe ABCuisto.'),
              const SizedBox(height: 16),
              Text('ID du groupe : ${link.id}'),
              const SizedBox(height: 24),
              if (state is AuthenticationLoggedIn)
                FilledButton(
                  onPressed: joinState.status == JoinGroupStatus.loading
                      ? null
                      : () => context.read<JoinGroupCubit>().joinGroup(link.uri.toString()),
                  child: Text(joinState.status == JoinGroupStatus.loading ? 'Adhésion…' : 'Rejoindre ce groupe'),
                )
              else if (state is AuthenticationLoggedOut)
                FilledButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage())),
                  child: const Text('Se connecter pour rejoindre le groupe'),
                )
              else
                const Center(child: CircularProgressIndicator()),
              if (joinState.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(joinState.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}
