import 'package:abcuisto/models/recipe.dart';
import 'package:bloc/bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/abcuisto_repository.dart';

class FilterState {
  final PagingState<int, Recipe> pagingState;
  final String? searchPattern;

  FilterState(this.pagingState, {this.searchPattern});

  FilterState copyWith({PagingState<int, Recipe>? pagingState, String? searchPattern}) {
    return FilterState(pagingState ?? this.pagingState, searchPattern: searchPattern ?? this.searchPattern);
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
      emit(state.copyWith(pagingState: state.pagingState.copyWith(error: error, isLoading: false)));
    }

    emit(state.copyWith(pagingState: state.pagingState.copyWith(isLoading: false)));
  }

  void updateSearchPattern(String? pattern) {
    emit(state.copyWith(pagingState: PagingState<int, Recipe>(), searchPattern: pattern));
  }
}
