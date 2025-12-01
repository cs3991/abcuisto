import 'package:abcuisto/models/recipe.dart';
import 'package:bloc/bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/abcuisto_repository.dart';

class FilterState {
  final PagingState<int, Recipe> pagingState;
  final String? searchPattern;
  final List<String> filteredCategories;
  final String? filteredCreatorName;

  FilterState(this.pagingState,
      {this.searchPattern, this.filteredCategories = const [], this.filteredCreatorName});

  FilterState copyWith({
    PagingState<int, Recipe>? pagingState,
    String? searchPattern,
    List<String>? filteredCategories,
    String? filteredCreatorName,
  }) {
    return FilterState(
      pagingState ?? this.pagingState,
      searchPattern: searchPattern ?? this.searchPattern,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      filteredCreatorName: filteredCreatorName ?? this.filteredCreatorName,
    );
  }
}

class FilterCubit extends Cubit<FilterState> {
  final AbcuistoRepository repository;
  static const int perPage = 10;

  FilterCubit(this.repository) : super(FilterState(PagingState<int, Recipe>()));

  Future<void> fetchNextPage() async {
    if (state.pagingState.isLoading) return;
    emit(state.copyWith(pagingState: state.pagingState.copyWith(isLoading: true, error: null)));

    try {
      final newKey = (state.pagingState.keys?.last ?? 0) + 1;
      final newItems = await repository.getRecipes(
        page: newKey,
        perPage: perPage,
        searchPattern: state.searchPattern,
        categories: state.filteredCategories,
        filterCreatorName: state.filteredCreatorName,
      );
      final isLastPage = newItems.isEmpty;

      emit(
        state.copyWith(
          pagingState: state.pagingState.copyWith(
            pages: [...?state.pagingState.pages, newItems],
            keys: [...?state.pagingState.keys, newKey],
            hasNextPage: !isLastPage,
            isLoading: false,
          ),
        ),
      );
    } catch (error) {
      print('Error fetching recipes: $error');
      emit(state.copyWith(pagingState: state.pagingState.copyWith(error: error, isLoading: false)));
    }

    emit(state.copyWith(pagingState: state.pagingState.copyWith(isLoading: false)));
  }

  void updateSearchPattern(String? pattern) {
    emit(state.copyWith(pagingState: PagingState<int, Recipe>(), searchPattern: pattern));
  }

  void updateFilteredCategories(String category, bool isSelected) {
    final updatedCategories = List<String>.from(state.filteredCategories);
    if (isSelected) {
      updatedCategories.add(category);
    } else {
      updatedCategories.remove(category);
    }
    emit(state.copyWith(pagingState: PagingState<int, Recipe>(), filteredCategories: updatedCategories));
  }

  void updateFilteredCreatorName(String? name) {
    name ??= '';
    emit(state.copyWith(pagingState: PagingState<int, Recipe>(), filteredCreatorName: name));
  }

}
