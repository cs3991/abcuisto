import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../models/abcuisto_repository.dart';
import '../models/recipe.dart';

enum LinkedRecipeStatus { loading, success, failure }

@immutable
class LinkedRecipeState {
  final LinkedRecipeStatus status;
  final RecipeFull? recipe;
  final String? errorMessage;

  const LinkedRecipeState({this.status = LinkedRecipeStatus.loading, this.recipe, this.errorMessage});
}

class LinkedRecipeCubit extends Cubit<LinkedRecipeState> {
  final AbcuistoRepository repository;
  final String recipeId;
  bool _loading = false;

  LinkedRecipeCubit(this.repository, this.recipeId) : super(const LinkedRecipeState());

  Future<void> loadRecipe() async {
    if (_loading) return;
    _loading = true;
    emit(const LinkedRecipeState());
    try {
      final recipe = await repository.getRecipe(recipeId);
      if (!isClosed) emit(LinkedRecipeState(status: LinkedRecipeStatus.success, recipe: recipe));
    } catch (error) {
      if (!isClosed) emit(LinkedRecipeState(status: LinkedRecipeStatus.failure, errorMessage: error.toString()));
    } finally {
      _loading = false;
    }
  }

}
