import 'package:diacritic/diacritic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';

enum IngredientPricesStatus { initial, loading, success, failure }

@immutable
class IngredientPricesState {
  final IngredientPricesStatus status;
  final List<IngredientPriceInput> ingredients;
  final bool saving;
  final String? errorMessage;
  final String? saveError;
  final String unit;

  const IngredientPricesState({
    this.status = IngredientPricesStatus.initial,
    this.ingredients = const [],
    this.saving = false,
    this.errorMessage,
    this.saveError,
    this.unit = 'kg',
  });

  IngredientPricesState copyWith({
    IngredientPricesStatus? status,
    List<IngredientPriceInput>? ingredients,
    bool? saving,
    String? errorMessage,
    String? saveError,
    String? unit,
  }) => IngredientPricesState(
    status: status ?? this.status,
    ingredients: ingredients ?? this.ingredients,
    saving: saving ?? this.saving,
    errorMessage: errorMessage,
    saveError: saveError,
    unit: unit ?? this.unit,
  );
}

class IngredientPricesCubit extends Cubit<IngredientPricesState> {
  final AbcuistoRepository repository;
  static const units = ['kg', 'L', 'pièce(s)'];

  IngredientPricesCubit(this.repository) : super(const IngredientPricesState());

  Future<void> load() async {
    if (state.status == IngredientPricesStatus.loading || state.saving) return;
    emit(state.copyWith(status: IngredientPricesStatus.loading));
    try {
      final ingredients = await repository.getIngredientsPrices();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: IngredientPricesStatus.success,
          ingredients: ingredients,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: IngredientPricesStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void startEditing(IngredientPriceInput? ingredient) => emit(
    state.copyWith(
      unit: ingredient?.unit ?? 'kg',
      errorMessage: state.errorMessage,
    ),
  );

  void changeUnit(String unit) {
    if (!state.saving && units.contains(unit)) emit(state.copyWith(unit: unit));
  }

  Future<bool> save({
    int? index,
    required String name,
    required String price,
  }) async {
    if (state.saving || state.status != IngredientPricesStatus.success)
      return false;
    final unit = state.unit;
    final trimmedName = name.trim();
    final amount = double.tryParse(price.trim().replaceAll(',', '.'));
    String? error;
    if (trimmedName.isEmpty) {
      error = 'Saisissez un nom d’ingrédient.';
    } else if (amount == null || !amount.isFinite || amount < 0) {
      error = 'Saisissez un prix positif ou nul, par exemple 2,50.';
    } else if (!units.contains(unit)) {
      error = 'Choisissez une unité : kilo, litre ou pièce.';
    } else {
      final normalizedName = removeDiacritics(trimmedName).toLowerCase();
      for (var i = 0; i < state.ingredients.length; i++) {
        final ingredient = state.ingredients[i];
        if (i != index &&
            ingredient.unit == unit &&
            removeDiacritics(ingredient.name?.trim() ?? '').toLowerCase() ==
                normalizedName) {
          error = 'Cet ingrédient possède déjà un prix pour cette unité.';
          break;
        }
      }
    }
    if (error != null) {
      emit(state.copyWith(saveError: error));
      return false;
    }
    final ingredients = [...state.ingredients];
    final value = IngredientPriceInput(
      id: index == null ? null : ingredients[index].id,
      name: trimmedName,
      unit: unit,
      price: amount!,
    );
    if (index == null) {
      ingredients.add(value);
    } else {
      ingredients[index] = value;
    }
    emit(state.copyWith(saving: true));
    try {
      await repository.editIngredientsPrices(ingredients: ingredients);
    } catch (error) {
      if (!isClosed)
        emit(state.copyWith(saving: false, saveError: error.toString()));
      return false;
    }
    if (isClosed) return true;
    emit(state.copyWith(saving: false));
    // Reload server identifiers before allowing another edit.
    await load();
    return true;
  }
}
