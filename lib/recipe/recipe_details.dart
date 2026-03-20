import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:abcuisto/recipe/recipes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/recipe.dart';

class RecipeDetailsPage extends StatelessWidget {
  // final Recipe recipe;

  const RecipeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeCubit, RecipeState>(
      builder: (context, state) {
        if (state is RecipeInitial || state is RecipeLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is RecipeLoaded) {
          final recipe = state.recipe;
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 65,
              title: Text(recipe.name ?? ''),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: IconButton(icon: Icon(Icons.person_rounded), onPressed: () {}),
                ),
              ],
            ),
            body: RecipeDetails(recipe: state.recipe),
          );
        }
        return Text("Unexpected Error");
      },
    );
  }
}

class RecipeDetails extends StatelessWidget {
  final RecipeFull recipe;

  const RecipeDetails({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // List<Uri>? images = recipe.documents!
    //     .map((e) => context.read<AbcuistoRepository>().pb.files.getURL(RecordModel(recipe.toJson()), e))
    //     .toList();
    final width = MediaQuery.of(context).size.width;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 400,
          width: width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                offset: const Offset(1, 1),
                blurRadius: 5,
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ],
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: recipe.images.isNotEmpty
                ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recipe.images.length,
              itemBuilder: (context, i) {
                return Image.network(
                  recipe.images[i].toString(),
                  height: 400,
                  width: width,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, _) => NoImageBuilder(height: 400),
                  // loadingBuilder: (context, _, _) => NoImageBuilder(),
                );
              },
            )
                : NoImageBuilder(height: 400),
          ),
        ),
        ListView(
          children: [
            Container(height: 350, width: MediaQuery.of(context).size.width, color: Colors.transparent),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      recipe.prepTime != null
                          ? Text(
                        'Préparation : ${recipe.prepTimeFormatted!}',
                        style: Theme
                            .of(
                          context,
                        )
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Theme
                            .of(context)
                            .colorScheme
                            .primary),
                      )
                          : Container(),
                      recipe.cookTime != null
                          ? Text(
                        'Cuisson : ${recipe.cookTimeFormatted!}',
                        style: Theme
                            .of(
                          context,
                        )
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Theme
                            .of(context)
                            .colorScheme
                            .primary),
                      )
                          : Container(),
                      recipe.restTime != null
                          ? Text(
                        'Repos : ${recipe.restTimeFormatted!}',
                        style: Theme
                            .of(
                          context,
                        )
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Theme
                            .of(context)
                            .colorScheme
                            .primary),
                      )
                          : Container(),
                      SizedBox(height: 4),
                      Text(recipe.name, style: Theme
                          .of(context)
                          .textTheme
                          .headlineMedium),
                      SizedBox(height: 4),
                      Text(recipe.category?.displayName ?? '', style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall),
                      SizedBox(height: 12),
                      Text("Ingrédients", style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium),
                      IngredientView(recipe: recipe),
                      SizedBox(height: 12),
                      Text("Instructions", style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium),
                      SizedBox(height: 8),
                      InstructionsView(recipe: recipe),
                      SizedBox(height: 12),
                      Text(
                        "Recette créée par ${recipe.creatorName} le ${recipe.createdTimeFormatted}",
                        style: Theme
                            .of(context)
                            .textTheme
                            .labelMedium,
                      ),
                      SizedBox(height: 12),
                      Text("Ustensiles", style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recipe.cookware.length,
                          itemBuilder: (context, index) {
                            final cookware = recipe.cookware[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(
                                label: Text(cookware),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Text("Commentaires", style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          RatingStars(note: recipe.note, size: 32),
                          SizedBox(width: 12),
                          Text(
                            recipe.note?.toStringAsPrecision(2) ?? '',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headlineMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class IngredientView extends StatelessWidget {
  final RecipeFull recipe;

  const IngredientView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for (final ingredientCategory in recipe.ingredients.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 12, bottom: 4),
          child: Text(ingredientCategory.key, style: Theme.of(context).textTheme.labelMedium),
        ),
      );
      var ingredientChildren = <TableRow>[];
      for (final ingredient in ingredientCategory.value) {
        ingredientChildren.add(
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Text(
                    '${ingredient.quantityFormatted} ${ingredient.typeFormatted}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              TableCell(child: Text(ingredient.name, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        );
      }
      children.add(
        Table(columnWidths: {0: IntrinsicColumnWidth(), 1: FlexColumnWidth(6)}, children: ingredientChildren),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

class InstructionsView extends StatelessWidget {
  final RecipeFull recipe;
  final double iconSize = 22;
  final double borderWidth = 2;

  const InstructionsView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for (var i = 0; i < recipe.instructions.length; i++) {
      final instruction = recipe.instructions.toList()[i];
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary, // border color
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text('Étape ${i + 1}', style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: (iconSize - borderWidth) / 2, top: 6, bottom: 6),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Theme.of(context).colorScheme.primary, width: borderWidth),
                  ),
                ),
                child: Padding(padding: const EdgeInsets.only(left: 8), child: Text(instruction)),
              ),
            ),
          ],
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}
