import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/recipe/filters/filter_cubit.dart';
import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:abcuisto/recipe/recipe_details.dart';
import 'package:abcuisto/recipe/search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
    return Scaffold(appBar: SearchAppBar(), body: RecipesList());
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
                        ...state.filteredCategories.map(
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
                        ...state.filteredCreatorName != null && state.filteredCreatorName!.isNotEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: InputChip(
                                    label: Text('Créé par ${state.filteredCreatorName}'),
                                    onDeleted: () {
                                      context.read<FilterCubit>().updateFilteredCreatorName(null);
                                    },
                                  ),
                                ),
                              ]
                            : [],
                        ...state.filteredMaxTime != null && state.filteredMaxTime! < 24
                            ? [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: InputChip(
                                    label: Text('Moins de ${state.filteredMaxTime}h'),
                                    onDeleted: () {
                                      context.read<FilterCubit>().updateFilteredMaxTime(null);
                                    },
                                  ),
                                ),
                              ]
                            : [],
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: PagedListView<int, Recipe>(
                    state: state.pagingState,
                    fetchNextPage: context.read<FilterCubit>().fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, item, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width > 400
                                ? (MediaQuery.of(context).size.width - 400) / 2
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
    // Uri? image;
    // if (recipe.documents!.isNotEmpty) {
    //   image = context.read<AbcuistoRepository>().pb.files.getURL(
    //     RecordModel(recipe.toJson()),
    //     recipe.documents!.first,
    //   );
    // }
    // final note = NotationsRecord.fromRecordModel(recipe.expand!['noteId'][0]).note!;
    // final nbNotes = NotationsRecord.fromRecordModel(recipe.expand!['noteId'][0]).nbNotes!;
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer),
              child: recipe.images.isNotEmpty
                  ? Image.network(
                      recipe.images.first.toString(),
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, _) => NoImageBuilder(),
                    )
                  : NoImageBuilder(),
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
  const NoImageBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 400,
      child: Icon(
        Icons.no_photography_rounded,
        size: 70,
        color: Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(50),
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
