
import 'package:abcuisto/models/recipe.dart';
import 'package:bloc/bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/abcuisto_repository.dart';
import 'filters.dart';

class FilterState {
  final PagingState<int, Recipe> pagingState;
  final Filters filter;

  FilterState(this.pagingState, {required this.filter});

  FilterState copyWith({PagingState<int, Recipe>? pagingState, Filters? filter}) {
    return FilterState(pagingState ?? this.pagingState, filter: filter ?? this.filter);
  }
}

class FilterCubit extends Cubit<FilterState> {
  final AbcuistoRepository repository;
  static const int perPage = 10;

  FilterCubit(this.repository)
    : super(
        FilterState(
          PagingState<int, Recipe>(),
          filter: Filters(searchText: '', tags: [], ingredients: [], ingredientsToExclude: [], creator: '', categories: [], groups: [], ids: []),
        ),
      );

  Future<void> fetchNextPage() async {
    if (state.pagingState.isLoading) return;
    emit(state.copyWith(pagingState: state.pagingState.copyWith(isLoading: true, error: null)));

    final loadingState = state.pagingState;
    try {
      final newKey = (state.pagingState.keys?.last ?? 0) + 1;
      final newItems = await repository.getRecipesFiltered(state.filter.copyWith(page: newKey));
      if (isClosed || !identical(state.pagingState, loadingState)) return;
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
    } catch (error, stackTrace) {
      if (isClosed || !identical(state.pagingState, loadingState)) return;
      print('Error fetching recipes: $error');
      // print stack trace for debugging
      print(stackTrace);
      emit(state.copyWith(pagingState: state.pagingState.copyWith(error: error, isLoading: false)));
    }
  }

  void updateSearchPattern(String? pattern) {
    emit(
      state.copyWith(
        pagingState: PagingState<int, Recipe>(),
        filter: state.filter.copyWith(searchText: pattern ?? ''),
      ),
    );
  }

  void updateFilteredCategories(String category, bool isSelected) {
    final updatedCategories = List<String>.from(state.filter.categories ?? []);
    if (isSelected && !updatedCategories.contains(category)) {
      updatedCategories.add(category);
    } else if (!isSelected && updatedCategories.contains(category)) {
      updatedCategories.remove(category);
    }
    emit(
      state.copyWith(
        pagingState: PagingState<int, Recipe>(),
        filter: state.filter.copyWith(categories: updatedCategories),
      ),
    );
  }

  void updateFilteredCreatorName(String? name) {
    name ??= '';
    emit(
      state.copyWith(
        pagingState: PagingState<int, Recipe>(),
        filter: state.filter.copyWith(creator: name),
      ),
    );
  }

  void updateFilteredMaxTime(int? maxHours) {
    emit(
      state.copyWith(
        pagingState: PagingState<int, Recipe>(),
        filter: state.filter.copyWith(totalTime: maxHours == 24 ? null : maxHours, clearTotalTime: maxHours == null || maxHours == 24),
      ),
    );
  }

  void updateFilteredTags(String tag, bool isSelected) {
    final updatedTags = List<String>.from(state.filter.tags ?? []);
    if (isSelected && !updatedTags.contains(tag)) {
      updatedTags.add(tag);
    } else if (!isSelected && updatedTags.contains(tag)) {
      updatedTags.remove(tag);
    }
    emit(
      state.copyWith(
        pagingState: PagingState<int, Recipe>(),
        filter: state.filter.copyWith(tags: updatedTags),
      ),
    );
  }

  Future<void> refresh() async {
    update();
    await fetchNextPage();
  }

  void update() {
    emit(state.copyWith(pagingState: PagingState<int, Recipe>()));
  }
}
