import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../models/abcuisto_repository.dart';

enum CommentAction { add, delete }

enum CommentStatus { initial, loading, success, failure }

@immutable
class CommentState {
  final CommentStatus status;
  final CommentAction? action;
  final String? errorMessage;
  final int? selectedRating;

  const CommentState({
    this.status = CommentStatus.initial,
    this.action,
    this.errorMessage,
    this.selectedRating,
  });

  CommentState copyWith({CommentStatus? status, CommentAction? action, String? errorMessage}) {
    return CommentState(
      status: status ?? this.status,
      action: action ?? this.action,
      errorMessage: errorMessage,
      selectedRating: selectedRating,
    );
  }
}

class CommentCubit extends Cubit<CommentState> {
  final AbcuistoRepository repository;

  CommentCubit(this.repository) : super(const CommentState());

  void toggleRating(int rating) {
    if (state.status == CommentStatus.loading || rating < 1 || rating > 5) return;
    emit(CommentState(selectedRating: state.selectedRating == rating ? null : rating));
  }

  void addComment({required String recipeId, required String comment}) async {
    if (state.status == CommentStatus.loading || state.selectedRating == null) return;
    final note = state.selectedRating;
    emit(state.copyWith(status: CommentStatus.loading, action: CommentAction.add));

    try {
      await repository.commentRecipe(recipeId: recipeId, comment: comment, note: note);
      emit(state.copyWith(status: CommentStatus.success, action: CommentAction.add));
    } catch (error) {
      emit(state.copyWith(status: CommentStatus.failure, action: CommentAction.add, errorMessage: error.toString()));
    }
  }

  Future<void> deleteComment({required String recipeId, required String commentId}) async {
    if (state.status == CommentStatus.loading) return;

    emit(state.copyWith(status: CommentStatus.loading, action: CommentAction.delete));

    try {
      await repository.deleteComment(recipeId: recipeId, commentId: commentId);
      emit(state.copyWith(status: CommentStatus.success, action: CommentAction.delete));
    } catch (error) {
      emit(state.copyWith(status: CommentStatus.failure, action: CommentAction.delete, errorMessage: error.toString()));
    }
  }

  void reset({bool clearRating = false}) {
    if (state.status == CommentStatus.loading) return;
    emit(CommentState(selectedRating: clearRating ? null : state.selectedRating));
  }
}
