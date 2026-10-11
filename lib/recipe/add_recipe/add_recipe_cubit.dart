import 'package:abcuisto/generated/pocketbase/recettes_record.dart';
import 'package:abcuisto/models/abcuisto_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AddRecipeState {}

class AddRecipeInitial extends AddRecipeState {}

class AddRecipeLoading extends AddRecipeState {}

class AddRecipeSuccess extends AddRecipeState {}

class AddRecipeError extends AddRecipeState {
  final String message;

  AddRecipeError({required this.message});
}

class AddRecipeCubit extends Cubit<AddRecipeState> {
  final AbcuistoRepository repository;

  AddRecipeCubit(this.repository) : super(AddRecipeInitial());

  Future<void> createRecipe({
    required String name,
    required RecettesRecordCategorieEnum category,
    required String tempsPreparation,
    required String tempsCuisson,
    required String steps,
    required String ustensiles,
    required bool vege,
    required int forNumber,
    required RecettesRecordTypeNumberEnum typeNumber,
    required RecettesRecordPrixEnum prix,
    required List<RecettesRecordTagsEnum> tags,
    required List<Map<String, String>> ingredients,
  }) async {
    emit(AddRecipeLoading());
    try {
      await repository.createRecipe(
        name: name,
        category: category,
        tempsPreparation: tempsPreparation,
        tempsCuisson: tempsCuisson,
        steps: steps,
        ustensiles: ustensiles,
        vege: vege,
        forNumber: forNumber.toDouble(),
        typeNumber: typeNumber,
        prix: prix,
        tags: tags,
        ingredients: ingredients,
      );
      emit(AddRecipeSuccess());
    } catch (e) {
      emit(AddRecipeError(message: e.toString()));
    }
  }

  void reset() {
    emit(AddRecipeInitial());
  }
}
