import 'package:bloc/bloc.dart';

import '../models/ingredient.dart';

class RecipeQuantitiesState {
  final double factor;

  const RecipeQuantitiesState({this.factor = 1});

  RecipeQuantitiesState copyWith({double? factor}) => RecipeQuantitiesState(factor: factor ?? this.factor);
}

class RecipeQuantitiesCubit extends Cubit<RecipeQuantitiesState> {
  RecipeQuantitiesCubit() : super(const RecipeQuantitiesState());

  void changeServings(double servings, int originalServings) {
    if (!servings.isFinite || servings <= 0 || originalServings <= 0) return;
    final factor = servings / originalServings;
    if (!factor.isFinite || factor <= 0) return;
    emit(state.copyWith(factor: factor));
  }

  bool changeFromIngredient(Ingredient ingredient, double quantity) {
    final original = ingredient.quantity;
    if (original == null || !original.isFinite || original <= 0 || !quantity.isFinite || quantity <= 0) return false;
    final factor = quantity / original;
    if (!factor.isFinite || factor <= 0) return false;
    emit(state.copyWith(factor: factor));
    return true;
  }

  void reset() => emit(const RecipeQuantitiesState());
}
