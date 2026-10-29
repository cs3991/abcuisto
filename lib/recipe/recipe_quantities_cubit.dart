import 'package:bloc/bloc.dart';

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

  void reset() => emit(const RecipeQuantitiesState());
}
