import 'package:abcuisto/models/abcuisto_repository.dart';
import 'package:abcuisto/models/ingredient.dart';
import 'package:abcuisto/models/recipe.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

enum AddRecipeStatus { editing, loading, success, error }

@immutable
class AddRecipeState {
  final RecipeFull? modifiedRecipe;
  final AddRecipeStatus status;
  final String? message;

  const AddRecipeState({this.modifiedRecipe, this.status = AddRecipeStatus.editing, this.message});

  AddRecipeState copyWith({RecipeFull? modifiedRecipe, AddRecipeStatus? status, String? message}) => AddRecipeState(
    modifiedRecipe: modifiedRecipe ?? this.modifiedRecipe,
    status: status ?? this.status,
    message: message,
  );
}

class AddRecipeCubit extends Cubit<AddRecipeState> {
  final AbcuistoRepository repository;
  int _nextIndex = 0;

  AddRecipeCubit(this.repository) : super(const AddRecipeState());

  void initialize(RecipeFull? recipe) {
    _nextIndex = 0;
    final modifiedRecipe = recipe ?? RecipeFull(
      id: '', images: const [], name: '', creatorId: repository.user?.id ?? '',
      creatorName: repository.user?.userName ?? '', category: null, cookware: const [],
      typeNumber: RecipeServingType.personnes, ingredientCategories: const [], instructions: const [],
    );
    emit(AddRecipeState(modifiedRecipe: modifiedRecipe.copyWith(
      ingredientCategories: modifiedRecipe.ingredientCategories.map((category) => category.copyWith(
        index: _nextIndex++,
        ingredients: category.ingredients.map((ingredient) => ingredient.copyWith(index: _nextIndex++)).toList(),
      )).toList(),
      instructions: modifiedRecipe.instructions.isEmpty ? [''] : List.of(modifiedRecipe.instructions),
    )));
    if (state.modifiedRecipe!.ingredientCategories.isEmpty) addCategory();
  }

  void modify(RecipeFull modifiedRecipe) {
    if (state.status == AddRecipeStatus.loading) return;
    emit(state.copyWith(modifiedRecipe: modifiedRecipe, status: AddRecipeStatus.editing));
  }

  void addPhoto(Uri uri) {
    final recipe = state.modifiedRecipe!;
    modify(recipe.copyWith(documents: [...recipe.documents, uri]));
  }

  void setPublic(bool isPublic) {
    final recipe = state.modifiedRecipe!;
    modify(recipe.copyWith(groups: [
      ...recipe.groups.where((group) => !group.isPublic),
      if (isPublic) RecipeGroup.publicGroup,
    ]));
  }

  void selectGroup(RecipeGroup group, bool selected) {
    final recipe = state.modifiedRecipe!;
    modify(recipe.copyWith(groups: [
      ...recipe.groups.where((value) => value.id != group.id),
      if (selected) group,
    ]));
  }

  void replacePhoto(int index, Uri uri) {
    final recipe = state.modifiedRecipe!;
    modify(recipe.copyWith(documents: [...recipe.documents]..[index] = uri));
  }

  void removePhoto(int index) {
    final recipe = state.modifiedRecipe!;
    modify(recipe.copyWith(documents: [...recipe.documents]..removeAt(index)));
  }

  void addCategory() {
    final recipe = state.modifiedRecipe!;
    modify(recipe.copyWith(ingredientCategories: [
      ...recipe.ingredientCategories,
      RecipeIngredientCategory(id: '', name: '', index: _nextIndex++, ingredients: [_emptyIngredient()]),
    ]));
  }

  Ingredient _emptyIngredient() => Ingredient(
    id: '', name: '', nameWithoutDiacritics: '', quantity: 0, type: 'g', index: _nextIndex++,
  );

  void changeCategory(int index, RecipeIngredientCategory category) {
    final recipe = state.modifiedRecipe!;
    final categories = List<RecipeIngredientCategory>.of(recipe.ingredientCategories);
    categories[index] = category;
    modify(recipe.copyWith(ingredientCategories: categories));
  }

  void removeCategory(int index) {
    final recipe = state.modifiedRecipe!;
    if (recipe.ingredientCategories.length <= 1) return;
    modify(recipe.copyWith(ingredientCategories: [...recipe.ingredientCategories]..removeAt(index)));
  }

  void addIngredient(int categoryIndex) {
    final category = state.modifiedRecipe!.ingredientCategories[categoryIndex];
    changeCategory(categoryIndex, category.copyWith(ingredients: [...category.ingredients, _emptyIngredient()]));
  }

  void changeIngredient(int categoryIndex, int index, Ingredient ingredient) {
    final category = state.modifiedRecipe!.ingredientCategories[categoryIndex];
    final ingredients = List<Ingredient>.of(category.ingredients);
    ingredients[index] = ingredient;
    changeCategory(categoryIndex, category.copyWith(ingredients: ingredients));
  }

  void removeIngredient(int categoryIndex, int index) {
    final category = state.modifiedRecipe!.ingredientCategories[categoryIndex];
    if (category.ingredients.length <= 1) return;
    changeCategory(categoryIndex, category.copyWith(ingredients: [...category.ingredients]..removeAt(index)));
  }

  void changeQuantity(int categoryIndex, int index, String raw) {
    final value = raw.trim().replaceAll(',', '.');
    final fraction = RegExp(r'^(\d+)\s*/\s*(\d+)$').firstMatch(value);
    final quantity = value.isEmpty ? 0.0 : fraction == null ? double.tryParse(value)
        : double.parse(fraction.group(2)!) == 0 ? null
        : double.parse(fraction.group(1)!) / double.parse(fraction.group(2)!);
    final ingredient = state.modifiedRecipe!.ingredientCategories[categoryIndex].ingredients[index];
    changeIngredient(categoryIndex, index, ingredient.copyWith(quantity: quantity, clearQuantity: quantity == null));
  }

  void changeStep(int index, String value) {
    final recipe = state.modifiedRecipe!;
    modify(recipe.copyWith(instructions: [...recipe.instructions]..[index] = value));
  }

  void addStep() => modify(state.modifiedRecipe!.copyWith(instructions: [...state.modifiedRecipe!.instructions, '']));

  void removeStep(int index) {
    final recipe = state.modifiedRecipe!;
    if (recipe.instructions.length > 1) modify(recipe.copyWith(instructions: [...recipe.instructions]..removeAt(index)));
  }

  Future<void> save() async {
    if (state.status == AddRecipeStatus.loading) return;
    final recipe = state.modifiedRecipe!;
    String? error;
    if (recipe.name.trim().isEmpty) {
      error = 'Le nom de la recette est obligatoire.';
    } else if (recipe.category == null) {
      error = 'Choisissez une catégorie.';
    } else if (recipe.forNumber == null || recipe.forNumber! <= 0) {
      error = 'Indiquez un nombre de portions valide.';
    } else {
      for (final ingredient in recipe.ingredientCategories.expand((category) => category.ingredients)) {
        if (ingredient.name.trim().isNotEmpty && (ingredient.quantity == null || !ingredient.quantity!.isFinite)) {
          error = 'La quantité de « ${ingredient.name} » doit être un nombre valide.';
          break;
        }
      }
    }
    if (error != null) {
      emit(state.copyWith(status: AddRecipeStatus.error, message: error));
      return;
    }
    final categories = recipe.ingredientCategories.map((category) => category.copyWith(
      name: category.name.trim().isEmpty ? 'Ingrédients' : category.name.trim(),
      ingredients: category.ingredients.where((ingredient) => ingredient.name.trim().isNotEmpty)
          .map((ingredient) => ingredient.copyWith(name: ingredient.name.trim())).toList(),
    )).where((category) => category.ingredients.isNotEmpty).toList();
    final modifiedRecipe = recipe.copyWith(
      name: recipe.name.trim(),
      apiTotalTime: (recipe.prepTime ?? Duration.zero) + (recipe.cookTime ?? Duration.zero) + (recipe.restTime ?? Duration.zero),
      instructions: recipe.instructions.map((step) => step.trim()).where((step) => step.isNotEmpty).toList(),
      ingredientCategories: [
        for (var i = 0; i < categories.length; i++) categories[i].copyWith(index: i, ingredients: [
          for (var j = 0; j < categories[i].ingredients.length; j++) categories[i].ingredients[j].copyWith(index: j),
        ]),
      ],
    );
    emit(state.copyWith(status: AddRecipeStatus.loading));
    try {
      if (modifiedRecipe.id.isEmpty) {
        await repository.createRecipe(recipe: modifiedRecipe);
      } else {
        await repository.updateRecipe(recipe: modifiedRecipe);
      }
      emit(state.copyWith(status: AddRecipeStatus.success));
    } catch (error) {
      emit(state.copyWith(status: AddRecipeStatus.error, message: error.toString()));
      rethrow;
    }
  }

  void reset() => emit(const AddRecipeState());
}
