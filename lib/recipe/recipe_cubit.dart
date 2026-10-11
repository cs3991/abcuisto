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

  RecipeLoaded({required this.recipe});
}

class RecipeCubit extends Cubit<RecipeState> {
  final AbcuistoRepository repository;

  RecipeCubit(this.repository) : super(RecipeInitial());

  Future<void> focusRecipe(Recipe item) async {
    emit(RecipeLoading());
    final recipeFull = await repository.getRecipe(item.id);
    emit(RecipeLoaded(recipe: recipeFull));
  }
}
