import 'dart:math';

import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:abcuisto/recipe/recipes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../login/authentication_cubit.dart';
import '../login/login_page.dart';
import '../login/profile_modal.dart';
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      builder: (context, state) {
                        return IconButton(
                          icon: Icon(
                            state is AuthenticationLoggedIn ? Icons.person_rounded : Icons.login_rounded,
                          ),
                          tooltip: state is AuthenticationLoggedIn ? "Connecté" : "Se connecter",
                          onPressed: () {
                            if (state is AuthenticationLoggedOut || state is AuthenticationInitial) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                            } else if (state is AuthenticationLoggedIn) {
                              showProfilePopup(context);
                            }
                          },
                        );
                      },
                    ),
                  ),
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

class RecipeDetails extends StatefulWidget {
  final RecipeFull recipe;

  RecipeDetails({super.key, required this.recipe});

  @override
  State<RecipeDetails> createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  var imageSelected = 0;

  final ScrollController imageScrollController = ScrollController(initialScrollOffset: 0);

  @override
  Widget build(BuildContext context) {
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
            child: widget.recipe.images.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.recipe.images.length,
                    controller: imageScrollController,
                    itemBuilder: (context, i) {
                      return Image.network(
                        widget.recipe.images[i].toString(),
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
            GestureDetector(
              child: Container(
                height: 350,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.recipe.images.length, (i) {
                      return Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: imageSelected == i
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              onHorizontalDragUpdate: widget.recipe.images.isNotEmpty
                  ? (dragUpdateDetails) {
                      var newScrollOffset = imageScrollController.offset - dragUpdateDetails.delta.dx;
                      if (newScrollOffset < 0) {
                        newScrollOffset = 0;
                      } else if (newScrollOffset > imageScrollController.position.maxScrollExtent) {
                        newScrollOffset = imageScrollController.position.maxScrollExtent;
                      }
                      imageScrollController.jumpTo(newScrollOffset);
                    }
                  : null,
              onHorizontalDragEnd: widget.recipe.images.isNotEmpty
                  ? (dragEndDetails) {
                      var previousImageSelected = imageSelected;
                      var velocity = dragEndDetails.primaryVelocity ?? 0;
                      var newImageSelected = ((imageScrollController.offset - velocity * 0.2) / width)
                          .round();
                      // Only one image can be changed on drag end, even if the user dragged very fast
                      if (newImageSelected - previousImageSelected > 1) {
                        newImageSelected = previousImageSelected + 1;
                      } else if (newImageSelected - previousImageSelected < -1) {
                        newImageSelected = previousImageSelected - 1;
                      }
                      // saturate to avoid selecting an image that doesn't exist
                      newImageSelected = max(0, min(widget.recipe.images.length - 1, newImageSelected));
                      var newOffset = newImageSelected * width;
                      // var offset = imageScrollController.offset;
                      // var offsetWithVelocity = offset + max(-velocity * 0.2, width / 2.1) ;
                      // var newOffset = offsetWithVelocity - (offsetWithVelocity + width / 2).remainder(width) + width / 2;

                      setState(() {
                        imageSelected = (newOffset / width).round();
                      });
                      imageScrollController.animateTo(
                        newOffset,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.linearToEaseOut,
                      );
                    }
                  : null,
            ),
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
                      widget.recipe.prepTime != null
                          ? Text(
                              'Préparation : ${widget.recipe.prepTimeFormatted!}',
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                            )
                          : Container(),
                      widget.recipe.cookTime != null
                          ? Text(
                              'Cuisson : ${widget.recipe.cookTimeFormatted!}',
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                            )
                          : Container(),
                      widget.recipe.restTime != null
                          ? Text(
                              'Repos : ${widget.recipe.restTimeFormatted!}',
                              style: Theme.of(
                                context,
                              ).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                            )
                          : Container(),
                      SizedBox(height: 4),
                      Text(widget.recipe.name, style: Theme.of(context).textTheme.headlineMedium),
                      SizedBox(height: 4),
                      Text(
                        widget.recipe.category?.displayName ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: 12),
                      Text("Ingrédients", style: Theme.of(context).textTheme.titleMedium),
                      IngredientView(recipe: widget.recipe),
                      SizedBox(height: 12),
                      Text("Instructions", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8),
                      InstructionsView(recipe: widget.recipe),
                      SizedBox(height: 12),
                      Text(
                        "Recette créée par ${widget.recipe.creatorName} le ${widget.recipe.createdTimeFormatted}",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      SizedBox(height: 12),
                      Text("Ustensiles", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.recipe.cookware.length,
                          itemBuilder: (context, index) {
                            final cookware = widget.recipe.cookware[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(label: Text(cookware)),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      Text("Commentaires", style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          RatingStars(note: widget.recipe.note, size: 32),
                          SizedBox(width: 12),
                          Text(
                            widget.recipe.note?.toStringAsPrecision(2) ?? '',
                            style: Theme.of(context).textTheme.headlineMedium,
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
