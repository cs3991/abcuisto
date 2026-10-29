import 'package:abcuisto/models/recipe.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/abcuisto_repository.dart';

@immutable
abstract class RecipeState {}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final RecipeFull recipe;
  final bool canEdit;
  final bool canDelete;

  RecipeLoaded({required this.recipe, this.canEdit = false, this.canDelete = false});
}

class RecipeError extends RecipeState {
  final String message;
  final String recipeId;

  RecipeError({required this.message, required this.recipeId});
}

class RecipeDeleted extends RecipeState {}

class RecipeCubit extends Cubit<RecipeState> {
  final AbcuistoRepository repository;

  RecipeCubit(this.repository) : super(RecipeInitial());

  bool _canEdit(RecipeFull recipe) {
    final user = repository.user;
    if (user == null) return false;
    return recipe.creatorId == user.id ||
        user.groups.any(
          (group) => group.id != null && !group.isPublic && group.canEdit == true && recipe.groups.any((sharedGroup) => sharedGroup.id == group.id),
        );
  }

  void refreshPermissions() {
    final current = state;
    if (current is! RecipeLoaded) return;
    final canEdit = _canEdit(current.recipe);
    final canDelete = _canDelete(current.recipe);
    if (canEdit != current.canEdit || canDelete != current.canDelete) {
      emit(RecipeLoaded(recipe: current.recipe, canEdit: canEdit, canDelete: canDelete));
    }
  }

  bool _canDelete(RecipeFull recipe) => repository.user != null && recipe.creatorId == repository.user!.id;

  void showRecipe(RecipeFull recipe) => emit(RecipeLoaded(recipe: recipe, canEdit: _canEdit(recipe), canDelete: _canDelete(recipe)));

  Future<void> deleteRecipe() async {
    final current = state;
    if (current is! RecipeLoaded || !_canDelete(current.recipe)) return;
    emit(RecipeLoading());
    try {
      await repository.deleteRecipe(id: current.recipe.id);
      if (!isClosed) emit(RecipeDeleted());
    } catch (error) {
      if (!isClosed) emit(RecipeError(message: 'Impossible de supprimer la recette : $error', recipeId: current.recipe.id));
    }
  }

  Future<void> focusRecipe(Recipe item) => refreshRecipe(recipeId: item.id);

  Future<void> refreshRecipe({String? recipeId}) async {
    if (state is RecipeLoading) return;
    recipeId ??= switch (state) {
      RecipeLoaded current => current.recipe.id,
      RecipeError current => current.recipeId,
      _ => null,
    };
    if (recipeId == null) return;
    emit(RecipeLoading());
    try {
      // await Future.pause(Duration(seconds: 2));
      final recipeFull = await repository.getRecipe(recipeId);
      if (!isClosed) showRecipe(recipeFull);
    } catch (error) {
      if (!isClosed) emit(RecipeError(message: 'Impossible de charger la recette : $error', recipeId: recipeId));
    }
  }
}
