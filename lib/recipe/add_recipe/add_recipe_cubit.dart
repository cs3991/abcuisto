import 'dart:convert';

import 'package:abcuisto/models/abcuisto_repository.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:abcuisto/recipe/add_recipe/enum_extensions.dart';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AddRecipeState {}

class AddRecipeInitial extends AddRecipeState {}

class AddRecipeLoading extends AddRecipeState {}

class AddRecipeSuccess extends AddRecipeState {
  final bool updated;

  AddRecipeSuccess({required this.updated});
}

class AddRecipeError extends AddRecipeState {
  final String message;

  AddRecipeError({required this.message});
}

class AddRecipeCubit extends Cubit<AddRecipeState> {
  final AbcuistoRepository repository;

  AddRecipeCubit(this.repository) : super(AddRecipeInitial());

  Future<void> createRecipe({
    required String name,
    required RecipeCategory category,
    required String preparationTime,
    required String cookingTime,
    required String waitingTime,
    required List<String> steps,
    required List<String> utensils,
    required int servings,
    required RecipeServingType servingType,
    required List<RecipeTag> tags,
    required List<ApiGroupInput> groups,
    required List<ApiRecipeCategoryInput> ingredientsCategories,
    required List<XFile> images,
  }) async {
    await _save(
      updated: false,
      save: () async {
        await repository.createRecipe(
          name: name,
          category: category,
          tempsPreparation: preparationTime,
          tempsCuisson: cookingTime,
          tempsRepos: waitingTime,
          steps: steps,
          ustensiles: utensils,
          forNumber: servings.toDouble(),
          typeNumber: servingType,
          tags: tags,
          groups: groups,
          ingredientsCategories: ingredientsCategories,
          images: await _apiImages(images),
          createur: repository.user?.id,
          createurPseudo: repository.user?.userName,
        );
      },
    );
  }

  Future<void> updateRecipe({
    required RecipeFull recipe,
    required String name,
    required RecipeCategory category,
    required String preparationTime,
    required String cookingTime,
    required String waitingTime,
    required List<String> steps,
    required List<String> utensils,
    required int servings,
    required RecipeServingType servingType,
    required List<RecipeTag> tags,
    required List<ApiGroupInput> groups,
    required List<ApiRecipeCategoryInput> ingredientsCategories,
    required List<String> documents,
    required List<XFile> images,
  }) async {
    final prepMinutes = repository.parseRecipeDuration(preparationTime);
    final cookMinutes = repository.parseRecipeDuration(cookingTime);
    final waitingMinutes = repository.parseRecipeDuration(waitingTime);

    await _save(
      updated: true,
      save: () async {
        await repository.updateRecipe(
          id: recipe.id,
          name: name,
          preparationTime: prepMinutes,
          cookingTime: cookMinutes,
          waitingTime: waitingMinutes,
          totalTime: prepMinutes == null && cookMinutes == null && waitingMinutes == null
              ? null
              : (prepMinutes ?? 0) + (cookMinutes ?? 0) + (waitingMinutes ?? 0),
          includePreparationTime: true,
          includeCookingTime: true,
          includeWaitingTime: true,
          includeTotalTime: true,
          creator: recipe.creatorId.isEmpty ? null : recipe.creatorId,
          creatorPseudo: recipe.creatorName,
          category: category.label,
          documents: documents,
          images: await _apiImages(images),
          forNumber: servings,
          typeNumber: servingType.displayValue,
          steps: steps,
          tags: tags.map((tag) => tag.displayValue).toList(),
          groups: groups,
          ustensiles: utensils,
          ingredientsCategories: ingredientsCategories,
        );
      },
    );
  }

  Future<void> _save({required bool updated, required Future<void> Function() save}) async {
    emit(AddRecipeLoading());
    try {
      await save();
      emit(AddRecipeSuccess(updated: updated));
    } catch (error) {
      emit(AddRecipeError(message: error.toString()));
    }
  }

  Future<List<ApiImageInput>> _apiImages(List<XFile> files) async {
    final inputs = <ApiImageInput>[];
    for (final file in files) {
      final extension = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';
      final fileType = file.mimeType ??
          switch (extension) {
            'jpg' || 'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'webp' => 'image/webp',
            'gif' => 'image/gif',
            _ => 'image/$extension',
          };
      inputs.add(ApiImageInput(
        imageBase64: base64Encode(await file.readAsBytes()),
        extension: extension,
        fileType: fileType,
      ));
    }
    return inputs;
  }

  void reset() {
    emit(AddRecipeInitial());
  }
}
