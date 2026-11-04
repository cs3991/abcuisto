import 'package:bloc/bloc.dart';
import 'package:diacritic/diacritic.dart';

import '../models/abcuisto_repository.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';

enum RecipePriceStatus { initial, loading, success, failure }

class RecipeQuantitiesState {
  final double factor;
  final RecipePriceStatus priceStatus;
  final double baseCost;
  final int pricedIngredients;
  final List<String> unpricedIngredients;
  final String? priceError;

  const RecipeQuantitiesState({
    this.factor = 1,
    this.priceStatus = RecipePriceStatus.initial,
    this.baseCost = 0,
    this.pricedIngredients = 0,
    this.unpricedIngredients = const [],
    this.priceError,
  });

  double? get totalCost {
    final total = baseCost * factor;
    return total.isFinite ? total : null;
  }

  RecipeQuantitiesState copyWith({double? factor, RecipePriceStatus? priceStatus,
    double? baseCost, int? pricedIngredients, List<String>? unpricedIngredients,
    String? priceError}) => RecipeQuantitiesState(
      factor: factor ?? this.factor,
      priceStatus: priceStatus ?? this.priceStatus,
      baseCost: baseCost ?? this.baseCost,
      pricedIngredients: pricedIngredients ?? this.pricedIngredients,
      unpricedIngredients: unpricedIngredients ?? this.unpricedIngredients,
      priceError: priceError,
    );
}

class RecipeQuantitiesCubit extends Cubit<RecipeQuantitiesState> {
  final AbcuistoRepository repository;
  RecipeFull? _recipe;
  int _priceRequest = 0;

  RecipeQuantitiesCubit(this.repository) : super(const RecipeQuantitiesState());

  void setRecipe(RecipeFull? recipe) {
    if (identical(_recipe, recipe)) return;
    _recipe = recipe;
    clearPrices();
    emit(const RecipeQuantitiesState());
    if (recipe != null) loadPrices();
  }

  void clearPrices() {
    _priceRequest++;
    emit(RecipeQuantitiesState(factor: state.factor));
  }

  Future<void> loadPrices() async {
    final recipe = _recipe;
    clearPrices();
    if (recipe == null || !repository.isAuthenticated) return;
    final request = _priceRequest;
    final token = repository.authToken;
    emit(state.copyWith(priceStatus: RecipePriceStatus.loading));
    try {
      final prices = await repository.getIngredientsPrices();
      if (isClosed || request != _priceRequest || token != repository.authToken) return;
      double total = 0;
      var count = 0;
      final missing = <String>[];
      for (final ingredient in recipe.ingredientCategories.expand((category) => category.ingredients)) {
        final quantity = ingredient.quantity;
        final name = ingredient.name;
        final unit = ingredient.type.trim();
        final measure = _measure(ingredient.type);
        final details = <String>[
          if (quantity == null)
            'quantité manquante'
          else if (!quantity.isFinite || quantity < 0)
            'quantité à corriger',
          if (unit.isEmpty || unit.toLowerCase() == 'null')
            'unité manquante'
          else if (measure == null)
            'calcul impossible avec l’unité « $unit »',
        ];
        if (details.isNotEmpty) {
          missing.add('$name : ${details.join(', ')}');
          continue;
        }
        // The checks above guarantee a quantity and a supported unit.
        if (quantity == null || measure == null) continue;
        final namedPrices = prices.where((price) => _normalize(price.name ?? '') == _normalize(name)).toList();
        final compatible = namedPrices.where((price) => _measure(price.unit ?? '')?.$1 == measure.$1).toList();
        if (compatible.length != 1) {
          final priceUnit = switch (measure.$1) {
            'mass' => 'au kilo',
            'volume' => 'au litre',
            _ => 'à la pièce',
          };
          missing.add('$name : ${namedPrices.isEmpty ? 'prix non renseigné' : compatible.isEmpty ? 'prix à renseigner $priceUnit' : 'plusieurs prix pour cet ingrédient'}');
          continue;
        }
        final price = compatible.single;
        final priceMeasure = _measure(price.unit!)!;
        final cost = quantity * (measure.$2 / priceMeasure.$2) * price.price;
        if (!cost.isFinite) {
          missing.add('$name : quantité trop grande pour calculer le coût');
          continue;
        }
        total += cost;
        count++;
      }
      if (!total.isFinite) throw const FormatException('Le coût dépasse les limites de calcul.');
      emit(state.copyWith(priceStatus: RecipePriceStatus.success, baseCost: total,
        pricedIngredients: count, unpricedIngredients: List.unmodifiable(missing)));
    } catch (error) {
      if (isClosed || request != _priceRequest || token != repository.authToken) return;
      emit(state.copyWith(priceStatus: RecipePriceStatus.failure,
        priceError: 'Impossible de calculer le coût : $error'));
    }
  }

  static String _normalize(String name) => removeDiacritics(name).trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  // Quantities expressed in kg, L or pieces. No mass/volume conversion.
  static (String, double)? _measure(String unit) => switch (unit.trim().toLowerCase()) {
    'kg' => ('mass', 1),
    'g' => ('mass', 0.001),
    'mg' => ('mass', 0.000001),
    'l' => ('volume', 1),
    'cl' => ('volume', 0.01),
    'ml' => ('volume', 0.001),
    'pièce(s)' || 'pièce' || 'pièces' => ('piece', 1),
    _ => null,
  };

  void changeServings(double servings, int originalServings) {
    if (!servings.isFinite || servings <= 0 || originalServings <= 0) return;
    final factor = servings / originalServings;
    if (!factor.isFinite || factor <= 0) return;
    emit(state.copyWith(factor: factor, priceError: state.priceError));
  }

  bool changeFromIngredient(Ingredient ingredient, double quantity) {
    final original = ingredient.quantity;
    if (original == null || !original.isFinite || original <= 0 || !quantity.isFinite || quantity <= 0) return false;
    final factor = quantity / original;
    if (!factor.isFinite || factor <= 0) return false;
    emit(state.copyWith(factor: factor, priceError: state.priceError));
    return true;
  }

  void reset() => emit(state.copyWith(factor: 1, priceError: state.priceError));
}
