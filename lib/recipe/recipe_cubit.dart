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

  RecipeLoaded({required this.recipe, this.canEdit = false});
}

class RecipeCubit extends Cubit<RecipeState> {
  final AbcuistoRepository repository;

  RecipeCubit(this.repository) : super(RecipeInitial());

  bool _canEdit(RecipeFull recipe) {
    final user = repository.user;
    if (user == null) return false;
    return recipe.creatorId == user.id || user.groups.any((group) =>
      group.id != null && !group.isPublic && group.canEdit == true && recipe.groups.any((sharedGroup) => sharedGroup.id == group.id));
  }

  void refreshPermissions() {
    final current = state;
    if (current is! RecipeLoaded) return;
    final canEdit = _canEdit(current.recipe);
    if (canEdit != current.canEdit) emit(RecipeLoaded(recipe: current.recipe, canEdit: canEdit));
  }

  void showRecipe(RecipeFull recipe) => emit(RecipeLoaded(recipe: recipe, canEdit: _canEdit(recipe)));

  Future<void> focusRecipe(Recipe item) async {
    emit(RecipeLoading());
    final recipeFull = await repository.getRecipe(item.id);
    showRecipe(recipeFull);
  }

  Future<void> refreshRecipe({String? recipeId}) async {
    if (recipeId == null && state is! RecipeLoaded) return;
    recipeId ??= (state as RecipeLoaded).recipe.id;
    final recipeFull = await repository.getRecipe(recipeId);
    showRecipe(recipeFull);
  }
}
