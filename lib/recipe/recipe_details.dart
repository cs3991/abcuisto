import 'package:abcuisto/recipe/add_recipe/add_recipe_page.dart';
import 'package:abcuisto/recipe/comment_cubit.dart';
import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:abcuisto/recipe/recipes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transparent_pointer/transparent_pointer.dart';

import '../login/authentication_cubit.dart';
import '../login/login_page.dart';
import '../login/profile_modal.dart';
import '../models/abcuisto_repository.dart';
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
              title: Text(recipe.name),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      builder: (context, state) {
                        final isOwner = state is AuthenticationLoggedIn && context.read<AbcuistoRepository>().user?.id == recipe.creatorId;
                        return Row(
                          children: [
                            if (isOwner)
                              IconButton(
                                icon: const Icon(Icons.edit_rounded),
                                tooltip: "Modifier la recette",
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddRecipePage(initialRecipe: recipe)));
                                },
                              ),
                            IconButton(
                              icon: Icon(state is AuthenticationLoggedIn ? Icons.person_rounded : Icons.login_rounded),
                              tooltip: state is AuthenticationLoggedIn ? "Connecté" : "Se connecter",
                              onPressed: () {
                                if (state is AuthenticationLoggedOut || state is AuthenticationInitial) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                } else if (state is AuthenticationLoggedIn) {
                                  showProfilePopup(context);
                                }
                              },
                            ),
                          ],
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

class RecipeDetails extends StatelessWidget {
  final RecipeFull recipe;

  RecipeDetails({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final servingType = recipe.typeNumber?.toLowerCase() ?? 'personnes';
    final servingLabel = servingType == 'personnes' && recipe.forNumber == 1 ? 'personne' : servingType;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: _ImageCarousel(images: recipe.images)),
        TransparentPointer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 350),

              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3), width: 1),
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
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                              )
                            : Container(),
                        recipe.cookTime != null
                            ? Text(
                                'Cuisson : ${recipe.cookTimeFormatted!}',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                              )
                            : Container(),
                        recipe.restTime != null
                            ? Text(
                                'Repos : ${recipe.restTimeFormatted!}',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                              )
                            : Container(),
                        SizedBox(height: 4),
                        Text(recipe.name, style: Theme.of(context).textTheme.headlineMedium),
                        SizedBox(height: 4),
                        Text(recipe.category?.displayName ?? '', style: Theme.of(context).textTheme.bodySmall),
                        SizedBox(height: 12),
                        Text(
                          recipe.forNumber == null ? "Ingrédients" : "Ingrédients pour ${recipe.forNumber} $servingLabel",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IngredientView(recipe: recipe),
                        SizedBox(height: 12),
                        Text("Instructions", style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 8),
                        InstructionsView(recipe: recipe),
                        SizedBox(height: 12),
                        Text("Recette créée par ${recipe.creatorName}", style: Theme.of(context).textTheme.labelMedium),
                        SizedBox(height: 12),
                        Text("Ustensiles", style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recipe.cookware.length,
                            itemBuilder: (context, index) {
                              final cookware = recipe.cookware[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(label: Text(cookware)),
                              );
                            },
                          ),
                        ),
                        if (recipe.tags.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 0,
                            children: recipe.tags
                                .map(
                                  (tag) => Chip(
                                    label: Text(tag),
                                    labelStyle: Theme.of(context).textTheme.bodySmall,
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        SizedBox(height: 12),
                        Text("Commentaires", style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            RatingStars(note: recipe.note, size: 32),
                            SizedBox(width: 12),
                            Text(recipe.note?.toStringAsPrecision(2) ?? '', style: Theme.of(context).textTheme.headlineMedium),
                            if (recipe.nbNotes != null) ...[
                              SizedBox(width: 8),
                              Text('${recipe.nbNotes} avis', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ],
                        ),
                        SizedBox(height: 12),
                        if (recipe.comments.isEmpty)
                          Text("Aucun commentaire pour le moment.", style: Theme.of(context).textTheme.bodyMedium)
                        else
                          ...recipe.comments.map((comment) => _RecipeCommentCard(comment: comment, recipeId: recipe.id)),
                        SizedBox(height: 4),
                        recipe.creatorId != context.read<AbcuistoRepository>().user?.id ? _CommentComposer(recipe: recipe) : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentComposer extends StatefulWidget {
  final RecipeFull recipe;

  const _CommentComposer({required this.recipe});

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _commentController = TextEditingController();
  bool _isExpanded = false;
  int? _selectedRating;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleRating(int rating) {
    setState(() {
      _selectedRating = _selectedRating == rating ? null : rating;
    });
  }

  void _submitComment() {
    final comment = _commentController.text.trim();
    if (_selectedRating == null) return;

    // setState(() {
    //   _isSubmitting = true;
    //   _errorMessage = null;
    // });

    // final messenger = ScaffoldMessenger.of(context);
    context.read<CommentCubit>().addComment(recipeId: widget.recipe.id, comment: comment, note: _selectedRating);

    // if (!mounted) return;
    // if (result.status == CommentStatus.failure) {
    //   setState(() {
    //     _isSubmitting = false;
    //     _errorMessage = 'Impossible d’ajouter le commentaire : ${result.errorMessage}';
    //   });
    //   return;
    // }

    // setState(() {
    //   _isSubmitting = false;
    //   _isExpanded = false;
    //   _commentController.clear();
    //   _selectedRating = null;
    // });
    // messenger.showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       result.refreshErrorMessage == null
    //           ? 'Commentaire ajouté.'
    //           : 'Commentaire ajouté, mais impossible d’actualiser la recette : ${result.refreshErrorMessage}',
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentCubit, CommentState>(
      listener: (context, state) {
        if (state.status == CommentStatus.success && state.action == CommentAction.add) {
          setState(() {
            _isExpanded = false;
            _commentController.clear();
            _selectedRating = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Commentaire ajouté.')));
          context.read<RecipeCubit>().refreshRecipe();
          context.read<CommentCubit>().reset();
        }
      },

      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isExpanded) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    if (context.read<AuthenticationCubit>().state is! AuthenticationLoggedIn) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      return;
                    }
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                  icon: const Icon(Icons.add_comment_rounded),
                  label: const Text('Ajouter un avis'),
                ),
              ),
            ],
            if (_isExpanded) ...[
              Text('Note', style: Theme.of(context).textTheme.labelLarge),
              Row(
                children: [
                  for (var rating = 1; rating <= 5; rating++)
                    IconButton(
                      tooltip: '$rating étoile${rating > 1 ? 's' : ''}',
                      iconSize: 32,
                      padding: EdgeInsets.zero,
                      onPressed: state.status == CommentStatus.loading ? null : () => _toggleRating(rating),
                      icon: Icon(_selectedRating != null && rating <= _selectedRating! ? Icons.star_rounded : Icons.star_outline_rounded),
                      color: Colors.orange.withValues(alpha: 0.5),
                    ),
                ],
              ),

              TextField(
                controller: _commentController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Commentaire', border: OutlineInputBorder()),
                onChanged: (_) {
                  setState(() {
                    context.read<CommentCubit>().reset();
                  });
                },
              ),
              const SizedBox(height: 8),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: state.status == CommentStatus.loading
                        ? null
                        : () {
                            setState(() {
                              _isExpanded = false;
                              _commentController.clear();
                              _selectedRating = null;
                            });
                            context.read<CommentCubit>().reset();
                          },
                    child: const Text('Annuler'),
                  ),
                  FilledButton.icon(
                    onPressed: state.status == CommentStatus.loading || _selectedRating == null ? null : _submitComment,
                    icon: state.status == CommentStatus.loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                    label: const Text('Publier'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _RecipeCommentCard extends StatelessWidget {
  final RecipeComment comment;
  final String recipeId;

  const _RecipeCommentCard({required this.comment, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        final userId = context.read<AbcuistoRepository>().user?.id;
        final canDelete = authState is AuthenticationLoggedIn && userId != null && comment.user == userId && comment.id != null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.username?.isNotEmpty == true ? comment.username! : 'Utilisateur',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (canDelete)
                      BlocBuilder<CommentCubit, CommentState>(
                        builder: (context, commentState) => IconButton(
                          tooltip: 'Supprimer mon commentaire',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: commentState.status == CommentStatus.loading ? null : () => _confirmDelete(context),
                        ),
                      ),
                    if (comment.note != null) RatingStars(note: comment.note!.toDouble(), size: 16),
                  ],
                ),
                if (comment.comment?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(comment.comment!, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le commentaire ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;

    final commentCubit = context.read<CommentCubit>();
    await commentCubit.deleteComment(recipeId: recipeId, commentId: comment.id!);
    if (!context.mounted) return;

    final state = commentCubit.state;
    if (state.status == CommentStatus.success && state.action == CommentAction.delete) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commentaire supprimé.')));
      context.read<RecipeCubit>().refreshRecipe();
      commentCubit.reset();
    } else if (state.status == CommentStatus.failure && state.action == CommentAction.delete) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de supprimer le commentaire : ${state.errorMessage}')));
      commentCubit.reset();
    }
  }
}

class IngredientView extends StatelessWidget {
  final RecipeFull recipe;

  const IngredientView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for (final ingredientCategory in recipe.ingredientCategories) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 12, bottom: 4),
          child: Text(ingredientCategory.name, style: Theme.of(context).textTheme.labelMedium),
        ),
      );
      var ingredientChildren = <TableRow>[];
      for (final ingredient in ingredientCategory.ingredients) {
        ingredientChildren.add(
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Text('${ingredient.quantityFormatted} ${ingredient.typeFormatted}', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
              TableCell(child: Text(ingredient.name, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        );
      }
      children.add(Table(columnWidths: {0: IntrinsicColumnWidth(), 1: FlexColumnWidth(6)}, children: ingredientChildren));
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
                    child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimary)),
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

class _ImageCarousel extends StatefulWidget {
  final List<dynamic> images;

  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(
          height: 400,
          width: width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            boxShadow: [BoxShadow(offset: const Offset(1, 1), blurRadius: 5, color: Colors.black.withValues(alpha: 0.25))],
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: widget.images.isNotEmpty
                ? PageView.builder(
                    controller: _controller,
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, i) {
                      return Image.network(widget.images[i].toString(), fit: BoxFit.cover, errorBuilder: (_, __, ___) => NoImageBuilder(height: 400));
                    },
                  )
                : NoImageBuilder(height: 400),
          ),
        ),

        // Indicators
        Positioned(
          top: 335,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              return Container(
                width: _currentIndex == i ? 16 : 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _currentIndex == i ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
