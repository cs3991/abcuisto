import 'package:abcuisto/login/authentication_cubit.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/recipe/add_recipe/add_recipe_page.dart';
import 'package:abcuisto/recipe/filters/filter_cubit.dart';
import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:abcuisto/recipe/recipe_details.dart';
import 'package:abcuisto/recipe/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' show ClientException;

import 'filters/filter_page.dart';

class RecipePage extends StatefulWidget {
  RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(),
      body: RecipesList(),
      floatingActionButton: BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationLoggedIn) {
            return FloatingActionButton(
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              foregroundColor: Theme
                  .of(context)
                  .colorScheme
                  .onPrimary,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddRecipePage()));
              },
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}


class RecipesList extends StatefulWidget {
  const RecipesList({super.key});

  @override
  State<RecipesList> createState() => _RecipesListState();
}

class _RecipesListState extends State<RecipesList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: Text('Filtres'),
                          onSelected: (_) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FilterPage()));
                          },
                        ),
                        const SizedBox(width: 8),
                        ...(state.filter.ingredients ?? []).map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              label: Text("Avec : $ingredient"),
                              deleteIcon: const Icon(Icons.close_rounded),
                              onDeleted: () {
                                context.read<FilterCubit>().removeFilteredIngredient(ingredient);
                              },
                            ),
                          ),
                        ),
                        ...(state.filter.categories ?? []).map(
                              (category) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              label: Text(category),
                              onDeleted: () {
                                context.read<FilterCubit>().updateFilteredCategories(category, false);
                              },
                            ),
                          ),
                        ),
                        ...state.filter.creator != null && state.filter.creator!.isNotEmpty
                            ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              label: Text('Créé par ${state.filter.creator}'),
                              onDeleted: () {
                                context.read<FilterCubit>().updateFilteredCreatorName(null);
                              },
                            ),
                          ),
                        ]
                            : [],
                        ...state.filter.totalTime != null && state.filter.totalTime! < 24
                            ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InputChip(
                              label: Text('Moins de ${state.filter.totalTime}h'),
                              onDeleted: () {
                                context.read<FilterCubit>().updateFilteredMaxTime(null);
                              },
                            ),
                          ),
                        ]
                            : [],
                        ...(state.filter.tags ?? []).map(
                              (tag) =>
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: InputChip(
                                  label: Text(tag.displayName),
                                  onDeleted: () {
                                    context.read<FilterCubit>().updateFilteredTags(tag, false);
                                  },
                                ),
                              ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: context.read<FilterCubit>().refresh,
                    child: PagedListView<int, Recipe>(
                      key: ObjectKey(state.filter),
                      physics: const AlwaysScrollableScrollPhysics(),
                      state: state.pagingState,
                      fetchNextPage: context.read<FilterCubit>().fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        noItemsFoundIndicatorBuilder: (context) => Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aucune recette trouvée',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Essayez un autre mot-clé ou retirez quelques filtres pour trouver votre prochaine recette.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        firstPageErrorIndicatorBuilder: (context) {
                          final state = context
                              .read<FilterCubit>()
                              .state;
                          final isConnectionError = state.pagingState.error is ClientException;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isConnectionError ? Icons.signal_wifi_connected_no_internet_4_rounded : Icons.error_outline_rounded,
                                  color: Theme
                                      .of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha(100),
                                  size: 60,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                  child: Text(
                                    isConnectionError
                                        ? "Connexion au serveur impossible.\nVérifiez la connexion internet."
                                        : "Impossible de charger les recettes.\nRéessayez dans quelques instants.",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () => context.read<FilterCubit>().fetchNextPage(),
                                  child: Text("Réessayer"),
                                ),
                              ],
                            );
                        },
                        itemBuilder: (context, item, index) =>
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: MediaQuery
                                      .of(context)
                                      .size
                                      .width > 400
                                      ? (MediaQuery
                                      .of(context)
                                      .size
                                      .width - 400) / 2
                                      : 0,
                                ),

                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          context.read<RecipeCubit>().focusRecipe(item);
                                          return RecipeDetailsPage();
                                        },
                                      ),
                                    );
                                  },
                                  child: RecipeCard(recipe: item),
                                ),
                              ),
                            ),
                      ),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              decoration: BoxDecoration(color: Theme
                  .of(context)
                  .colorScheme
                  .secondaryContainer),
              child: recipe.documents.isNotEmpty
                  ? Image.network(
                recipe.documents.first.toString(),
                height: 200,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                fit: BoxFit.cover,
                errorBuilder: (context, _, _) => NoImageBuilder(height: 200),
              )
                  : NoImageBuilder(height: 200),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(recipe.name, style: Theme.of(context).textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: Icon(Icons.favorite_border_rounded), onPressed: () {}),
                Text(recipe.totalTimeFormatted!, style: Theme.of(context).textTheme.labelLarge),
                RatingStars(note: recipe.note),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NoImageBuilder extends StatelessWidget {
  const NoImageBuilder({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: 400,
      child: Icon(
        Icons.no_photography_rounded,
        size: 70,
        color: Theme
            .of(context)
            .colorScheme
            .onSecondaryContainer
            .withAlpha(50),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final double? note;
  final double size;

  const RatingStars({super.key, required this.note, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return note != null
        ? Row(
      children: List.generate(
        5,
            (index) => index < note!
            ? Icon(Icons.star_rounded, color: Colors.orange.withValues(alpha: 0.5), size: size)
            : Icon(Icons.star_border_rounded, color: Colors.orange.withValues(alpha: 0.5), size: size),
      ),
    )
        : Text('Aucune note', style: Theme.of(context).textTheme.labelMedium);
  }
}
