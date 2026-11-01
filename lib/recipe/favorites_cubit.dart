import 'package:bloc/bloc.dart';

import '../models/abcuisto_repository.dart';

class FavoritesState {
  final Set<String> ids;
  final Set<String> pendingIds;
  final bool isLoading;
  final bool isLoaded;
  final String? error;

  FavoritesState({Set<String> ids = const {}, Set<String> pendingIds = const {}, this.isLoading = false, this.isLoaded = false, this.error})
    : ids = Set.unmodifiable(ids), pendingIds = Set.unmodifiable(pendingIds);

  FavoritesState copyWith({Set<String>? ids, Set<String>? pendingIds, bool? isLoading, bool? isLoaded, String? error}) => FavoritesState(
    ids: ids ?? this.ids,
    pendingIds: pendingIds ?? this.pendingIds,
    isLoading: isLoading ?? this.isLoading,
    isLoaded: isLoaded ?? this.isLoaded,
    error: error,
  );
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final AbcuistoRepository repository;

  FavoritesCubit(this.repository) : super(FavoritesState());

  Future<void> resetSession() async {
    emit(FavoritesState());
    if (repository.isAuthenticated) await _load();
  }

  Future<void> reload() async {
    if (!repository.isAuthenticated || state.isLoading || state.pendingIds.isNotEmpty) return;
    await _load();
  }

  Future<void> _load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final ids = await repository.getFavorites();
      if (isClosed) return;
      emit(FavoritesState(ids: ids.toSet(), isLoaded: true));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: 'Impossible de charger les favoris : $error'));
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    if (!repository.isAuthenticated || !state.isLoaded || state.isLoading || state.pendingIds.contains(recipeId)) return;
    final wasFavorite = state.ids.contains(recipeId);
    emit(state.copyWith(pendingIds: {...state.pendingIds, recipeId}));
    try {
      if (wasFavorite) {
        await repository.removeFavorite(recipeId);
      } else {
        await repository.addFavorite(recipeId);
      }
      if (isClosed) return;
      final ids = {...state.ids};
      wasFavorite ? ids.remove(recipeId) : ids.add(recipeId);
      emit(state.copyWith(ids: ids, pendingIds: {...state.pendingIds}..remove(recipeId)));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(
        pendingIds: {...state.pendingIds}..remove(recipeId),
        error: 'Impossible de modifier les favoris : $error',
      ));
    }
  }
}
