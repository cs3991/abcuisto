import 'package:abcuisto/recipe/add_recipe/add_recipe_page.dart';
import 'package:abcuisto/recipe/comment_cubit.dart';
import 'package:abcuisto/recipe/recipe_cubit.dart';
import 'package:abcuisto/recipe/recipes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_pointer/transparent_pointer.dart';

import '../login/authentication_cubit.dart';
import '../login/login_page.dart';
import '../profile/profile_page.dart';
import '../models/abcuisto_repository.dart';
import '../models/recipe.dart';
import '../app_config.dart';
import '../pulsing_placeholder.dart';
import 'filters/filter_cubit.dart';

enum _RecipeAction { edit, share, link, delete }

class RecipeDetailsPage extends StatelessWidget {
  // final Recipe recipe;

  const RecipeDetailsPage({super.key});

  Future<void> _handleAction(BuildContext context, RecipeLoaded state, _RecipeAction action) async {
    final colors = Theme.of(context).colorScheme;
    final recipe = state.recipe;
    final link = Uri.https(AppConfig.instance.flavor == AppFlavor.prod ? 'abcuisto.fr' : 'dev.abcuisto.fr', '/recette/${recipe.id}').toString();
    switch (action) {
      case _RecipeAction.edit:
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecipePage(initialRecipe: recipe)));
        return;
      case _RecipeAction.share:
        try {
          final box = context.findRenderObject() as RenderBox?;
          await SharePlus.instance.share(
            ShareParams(
              text: '${recipe.name} sur ABCuisto : $link',
              subject: recipe.name,
              sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
            ),
          );
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Impossible de partager la recette. Vous pouvez copier son lien.')));
        }
        return;
      case _RecipeAction.link:
        try {
          await Clipboard.setData(ClipboardData(text: link));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lien de la recette copié.')));
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de copier le lien.')));
        }
        return;
      case _RecipeAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Supprimer la recette ?'),
            content: Text('« ${recipe.name} » sera supprimée définitivement. Cette action est irréversible.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuler')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: colors.error, foregroundColor: colors.onError),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
        if (!context.mounted || confirmed != true) return;
        await context.read<RecipeCubit>().deleteRecipe();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationLoggedIn || state is AuthenticationLoggedOut) {
          context.read<RecipeCubit>().refreshPermissions();
        }
      },
      child: BlocConsumer<RecipeCubit, RecipeState>(
        listener: (context, state) {
          if (state is RecipeDeleted) {
            context.read<FilterCubit>().update();
            final messenger = ScaffoldMessenger.of(context);
            Navigator.of(context).pop();
            messenger.showSnackBar(const SnackBar(content: Text('Recette supprimée.')));
          }
        },
        builder: (context, state) {
          if (state is RecipeInitial || state is RecipeLoading || state is RecipeLoaded) {
            final recipeState = state is RecipeLoaded ? state : null;
            final recipe = recipeState?.recipe;
            return PopScope(
              canPop: recipeState != null,
              child: Scaffold(
                appBar: AppBar(
                  toolbarHeight: 65,
                  title: recipe == null
                      ? const PulsingPlaceholder(width: 180, height: 24)
                      : Text(recipe.name),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
                          builder: (context, state) {
                            return Row(
                              children: [
                                PopupMenuButton<_RecipeAction>(
                                  icon: const Icon(Icons.more_vert_rounded),
                                  tooltip: 'Options de la recette',
                                  position: PopupMenuPosition.under,
                                  constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(8))),
                                  color: Theme.of(context).colorScheme.surface,
                                  surfaceTintColor: Colors.transparent,
                                  enabled: recipeState != null,
                                  onSelected: (action) => _handleAction(context, recipeState!, action),
                                  itemBuilder: (context) => [
                                    if (recipeState?.canEdit == true)
                                      const PopupMenuItem(
                                        value: _RecipeAction.edit,
                                        child: _RecipeActionTile(
                                          title: 'Éditer',
                                          description: 'Modifier les ingrédients et les étapes.',
                                          icon: Icons.edit_rounded,
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: _RecipeAction.share,
                                      child: _RecipeActionTile(
                                        title: 'Partager',
                                        description: 'Envoyer cette recette à vos proches.',
                                        icon: Icons.share_rounded,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: _RecipeAction.link,
                                      child: _RecipeActionTile(
                                        title: 'Lien vers la recette',
                                        description: 'Copier le lien dans le presse-papiers.',
                                        icon: Icons.link_rounded,
                                      ),
                                    ),
                                    if (recipeState?.canDelete == true)
                                      PopupMenuItem(
                                        value: _RecipeAction.delete,
                                        child: _RecipeActionTile(
                                          title: 'Supprimer',
                                          description: 'Supprimer définitivement cette recette.',
                                          icon: Icons.delete_rounded,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(state is AuthenticationLoggedIn ? Icons.person_rounded : Icons.login_rounded),
                                  tooltip: state is AuthenticationLoggedIn ? "Connecté" : "Se connecter",
                                  onPressed: () async {
                                          if (state is AuthenticationLoggedOut || state is AuthenticationInitial) {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                          } else if (state is AuthenticationLoggedIn) {
                                            await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                                            if (!context.mounted) return;
                                            context.read<RecipeCubit>().refreshPermissions();
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
                body: RecipeDetails(recipe: recipe),
              ),
            );
          }
          if (state is RecipeError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Recette')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message),
                      TextButton(
                        onPressed: () => context.read<RecipeCubit>().refreshRecipe(),
                        child: const Text('Recharger la recette'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          if (state is RecipeDeleted) return const Scaffold();
          return Text("Unexpected Error");
        },
      ),
    );
  }
}

class _RecipeActionTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;

  const _RecipeActionTile({required this.title, required this.description, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(description),
      trailing: Icon(icon, color: color),
    );
  }
}

class RecipeDetails extends StatelessWidget {
  final RecipeFull? recipe;

  RecipeDetails({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final recipe = this.recipe;
    final servingType = recipe?.typeNumber?.displayName ?? 'personnes';
    final servingLabel = servingType == 'personnes' && recipe?.forNumber == 1 ? 'personne' : servingType;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: _ImageCarousel(images: recipe?.documents)),
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
                        recipe == null
                            ? const PulsingPlaceholder(width: 140, height: 16)
                            : recipe.prepTime != null
                            ? Text(
                                'Préparation : ${recipe.prepTimeFormatted!}',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                              )
                            : Container(),
                        recipe == null
                            ? const PulsingPlaceholder(width: 140, height: 16)
                            : recipe.cookTime != null
                            ? Text(
                                'Cuisson : ${recipe.cookTimeFormatted!}',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                              )
                            : Container(),
                        recipe == null
                            ? const PulsingPlaceholder(width: 140, height: 16)
                            : recipe.restTime != null
                            ? Text(
                                'Repos : ${recipe.restTimeFormatted!}',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                              )
                            : Container(),
                        SizedBox(height: 4),
                        recipe == null
                            ? const PulsingPlaceholder(width: 240, height: 34)
                            : Text(recipe.name, style: Theme.of(context).textTheme.headlineMedium),
                        SizedBox(height: 4),
                        recipe == null
                            ? const PulsingPlaceholder(width: 100, height: 16)
                            : Text(recipe.category?.displayName ?? '', style: Theme.of(context).textTheme.bodySmall),
                        SizedBox(height: 12),
                        recipe == null
                            ? const PulsingPlaceholder(width: 200, height: 24)
                            : Text(
                                recipe.forNumber == null ? "Ingrédients" : "Ingrédients pour ${recipe.forNumber} $servingLabel",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                        IngredientView(recipe: recipe),
                        SizedBox(height: 12),
                        Text("Instructions", style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 8),
                        InstructionsView(recipe: recipe),
                        SizedBox(height: 12),
                        recipe == null
                            ? const PulsingPlaceholder(width: 180, height: 16)
                            : Text("Recette créée par ${recipe.creatorName}", style: Theme.of(context).textTheme.labelMedium),
                        SizedBox(height: 12),
                        Text("Ustensiles", style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recipe == null ? 3 : recipe.cookware.length,
                            itemBuilder: (context, index) {
                              final cookware = recipe?.cookware[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(label: cookware == null
                                    ? const PulsingPlaceholder(width: 64, height: 16)
                                    : Text(cookware)),
                              );
                            },
                          ),
                        ),
                        if (recipe == null || recipe.tags.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 0,
                            children: List.generate(
                              recipe == null ? 3 : recipe.tags.length,
                              (index) => Chip(
                                label: recipe == null
                                    ? const PulsingPlaceholder(width: 56, height: 14)
                                    : Text(recipe.tags[index].displayName),
                                labelStyle: Theme.of(context).textTheme.bodySmall,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 12),
                        Text("Commentaires", style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            recipe == null
                                ? const PulsingPlaceholder(width: 160, height: 32)
                                : RatingStars(note: recipe.note, size: 32),
                            SizedBox(width: 12),
                            recipe == null
                                ? const PulsingPlaceholder(width: 40, height: 34)
                                : Text(recipe.note?.toStringAsPrecision(2) ?? '', style: Theme.of(context).textTheme.headlineMedium),
                            if (recipe == null || recipe.nbNotes != null) ...[
                              SizedBox(width: 8),
                              recipe == null
                                  ? const PulsingPlaceholder(width: 48, height: 16)
                                  : Text('${recipe.nbNotes} avis', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ],
                        ),
                        SizedBox(height: 12),
                        if (recipe != null && recipe.comments.isEmpty)
                          Text("Aucun commentaire pour le moment.", style: Theme.of(context).textTheme.bodyMedium)
                        else
                          ...List.generate(recipe == null ? 2 : recipe.comments.length, (index) =>
                            _RecipeCommentCard(comment: recipe?.comments[index], recipeId: recipe?.id)),
                        SizedBox(height: 4),
                        if (recipe == null)
                          const PulsingPlaceholder(width: 140, height: 40)
                        else if (recipe.creatorId != context.read<AbcuistoRepository>().user?.id)
                          _CommentComposer(recipe: recipe),
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    context.read<CommentCubit>().addComment(recipeId: widget.recipe.id, comment: _commentController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentCubit, CommentState>(
      listener: (context, state) {
        if (state.status == CommentStatus.success && state.action == CommentAction.add) {
          setState(() {
            _isExpanded = false;
            _commentController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Commentaire ajouté.')));
          context.read<RecipeCubit>().refreshRecipe();
          context.read<CommentCubit>().reset(clearRating: true);
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
                    context.read<CommentCubit>().reset(clearRating: true);
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
                      onPressed: state.status == CommentStatus.loading ? null : () => context.read<CommentCubit>().toggleRating(rating),
                      icon: Icon(rating <= (state.selectedRating ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded),
                      color: Colors.orange.withValues(alpha: 0.5),
                    ),
                ],
              ),

              TextField(
                controller: _commentController,
                enabled: state.status != CommentStatus.loading,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Commentaire', border: OutlineInputBorder()),
                onChanged: (_) {
                  context.read<CommentCubit>().reset();
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
                            });
                            context.read<CommentCubit>().reset(clearRating: true);
                          },
                    child: const Text('Annuler'),
                  ),
                  FilledButton.icon(
                    onPressed: state.status == CommentStatus.loading || state.selectedRating == null ? null : _submitComment,
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
  final RecipeComment? comment;
  final String? recipeId;

  const _RecipeCommentCard({required this.comment, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final comment = this.comment;
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        final userId = context.read<AbcuistoRepository>().user?.id;
        final canDelete = authState is AuthenticationLoggedIn && userId != null && comment != null && comment.user == userId && comment.id != null;
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
                      child: comment == null
                          ? const Align(alignment: Alignment.centerLeft, child: PulsingPlaceholder(width: 120, height: 20))
                          : Text(
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
                    if (comment == null)
                      const PulsingPlaceholder(width: 80, height: 16),
                    if (comment?.note != null) RatingStars(note: comment!.note!.toDouble(), size: 16),
                  ],
                ),
                if (comment == null || comment.comment?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  comment == null
                      ? const PulsingPlaceholder(width: double.infinity, height: 16)
                      : Text(comment.comment!, style: Theme.of(context).textTheme.bodyMedium),
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
    await commentCubit.deleteComment(recipeId: recipeId!, commentId: comment!.id!);
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
  final RecipeFull? recipe;

  const IngredientView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final categories = recipe?.ingredientCategories;
    var children = <Widget>[];
    for (var categoryIndex = 0; categoryIndex < (categories?.length ?? 1); categoryIndex++) {
      final ingredientCategory = categories?[categoryIndex];
      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 12, bottom: 4),
          child: ingredientCategory == null
              ? const PulsingPlaceholder(width: 120, height: 16)
              : Text(ingredientCategory.name, style: Theme.of(context).textTheme.labelMedium),
        ),
      );
      var ingredientChildren = <TableRow>[];
      for (var index = 0; index < (ingredientCategory?.ingredients.length ?? 4); index++) {
        final ingredient = ingredientCategory?.ingredients[index];
        ingredientChildren.add(
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: ingredient == null
                      ? const PulsingPlaceholder(width: 48, height: 20)
                      : Text('${ingredient.quantityFormatted} ${ingredient.typeFormatted}', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
              TableCell(child: ingredient == null
                  ? const Align(alignment: Alignment.centerLeft, child: PulsingPlaceholder(width: 160, height: 20))
                  : Text(ingredient.name, style: Theme.of(context).textTheme.bodyMedium)),
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
  final RecipeFull? recipe;
  final double iconSize = 22;
  final double borderWidth = 2;

  const InstructionsView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final instructions = recipe?.instructions;
    var children = <Widget>[];
    for (var i = 0; i < (instructions?.length ?? 3); i++) {
      final instruction = instructions?[i];
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
                child: Padding(padding: const EdgeInsets.only(left: 8), child: instruction == null
                    ? const PulsingPlaceholder(width: double.infinity, height: 48)
                    : Text(instruction)),
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
  final List<dynamic>? images;

  const _ImageCarousel({required this.images});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
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
            child: images == null
                ? const PulsingPlaceholder(width: double.infinity, height: 400)
                : images.isNotEmpty
                ? PageView.builder(
                    controller: _controller,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, i) {
                      return Image.network(images[i].toString(), fit: BoxFit.cover, errorBuilder: (_, __, ___) => NoImageBuilder(height: 400));
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
            children: List.generate(images?.length ?? 0, (i) {
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
