import 'package:abcuisto/abcuisto_repository.dart';
import 'package:abcuisto/generated/pocketbase/recettes_record.dart';
import 'package:abcuisto/generated/pocketbase/users_record.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class RecipePage extends StatelessWidget {
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

class RecipesList extends StatelessWidget {
  const RecipesList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UsersRecord.fromRecordModel(context.read<AbcuistoRepository>().pb.authStore.record!);

    final futureRecipes = context.read<AbcuistoRepository>().getRecipes();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: futureRecipes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final recipes = snapshot.data!;

                    return ListView.builder(
                      itemBuilder: (context, index) => RecipeCard(recipe: recipes[index]),
                      itemCount: recipes.length,
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 400 ? (MediaQuery.of(context).size.width - 400) / 2: 0,
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
                    // Row(
                    //   children: List.generate(
                    //     5,
                    //     (index) =>
                    //         index < recipe.noteId ? Icon(Icons.star_rounded) : Icon(Icons.star_border_rounded),
                    //   ),
                    // ),
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
