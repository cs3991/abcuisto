import 'package:abcuisto/abcuisto_repository.dart';
import 'package:abcuisto/generated/pocketbase/notations_record.dart';
import 'package:abcuisto/generated/pocketbase/recettes_record.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.filter_list_rounded)),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher une recette',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            constraints: BoxConstraints(maxHeight: 50),
            isDense: false,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainer,
            suffixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.outline),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: IconButton(icon: Icon(Icons.person_rounded), onPressed: () {}),
          ),
        ],
      ),
      body: RecipesList(),
    );
  }
}

class RecipesList extends StatefulWidget {
  const RecipesList({super.key});

  @override
  State<RecipesList> createState() => _RecipesListState();
}

class _RecipesListState extends State<RecipesList> {
  static const _pageSize = 25;
  late final _pagingController = PagingController<int, RecettesRecord>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => context.read<AbcuistoRepository>().getRecipes(page: pageKey, perPage: _pageSize),
  );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: PagedListView<int, RecettesRecord>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, item, index) => RecipeCard(recipe: item),
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
  final RecettesRecord recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    Uri? image;
    if (recipe.documents!.isNotEmpty) {
      image = context.read<AbcuistoRepository>().pb.files.getURL(
        RecordModel(recipe.toJson()),
        recipe.documents!.first,
      );
    }
    final note = NotationsRecord.fromRecordModel(recipe.expand!['noteId'][0]).note!;
    final nbNotes = NotationsRecord.fromRecordModel(recipe.expand!['noteId'][0]).nbNotes!;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 400
              ? (MediaQuery.of(context).size.width - 400) / 2
              : 0,
        ),

        child: Card(
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
                  child: Image.network(
                    image.toString(),
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, _) => SizedBox(
                      height: 300,
                      child: Icon(
                        Icons.no_photography_rounded,
                        size: 70,
                        color: Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(50),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(recipe.nom ?? '', style: Theme.of(context).textTheme.headlineMedium),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: Icon(Icons.favorite_border_rounded), onPressed: () {}),
                    Text(recipe.tempsPreparation!, style: Theme.of(context).textTheme.labelLarge),
                    nbNotes > 0
                        ? Row(
                            children: List.generate(
                              5,
                              (index) => index < note
                                  ? Icon(Icons.star_rounded, color: Colors.orange.withValues(alpha: 0.5))
                                  : Icon(
                                      Icons.star_border_rounded,
                                      color: Colors.orange.withValues(alpha: 0.5),
                                    ),
                            ),
                          )
                        : Text('Aucune note', style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
