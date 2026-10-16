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
  // final String? refreshErrorMessage;

  const CommentState({
    this.status = CommentStatus.initial,
    this.action,
    this.errorMessage,
    // this.refreshErrorMessage,
  });
}

class CommentCubit extends Cubit<CommentState> {
  final AbcuistoRepository repository;

  CommentCubit(this.repository) : super(const CommentState());

  void addComment({required String recipeId, required String comment, int? note}) async {
    if (state.status == CommentStatus.loading) return;
    emit(CommentState(status: CommentStatus.loading, action: CommentAction.add));

    try {
      await repository.commentRecipe(recipeId: recipeId, comment: comment, note: note);
      emit(CommentState(status: CommentStatus.success, action: CommentAction.add));
    } catch (error) {
      emit(CommentState(status: CommentStatus.failure, action: CommentAction.add, errorMessage: error.toString()));
    }
  }

  Future<void> deleteComment({required String recipeId, required String commentId}) async {
    if (state.status == CommentStatus.loading) return;

    emit(CommentState(status: CommentStatus.loading, action: CommentAction.delete));

    try {
      await repository.deleteComment(recipeId: recipeId, commentId: commentId);
      emit(CommentState(status: CommentStatus.success, action: CommentAction.delete));
    } catch (error) {
      emit(CommentState(status: CommentStatus.failure, action: CommentAction.delete, errorMessage: error.toString()));
    }
  }

  void reset() {
    emit(const CommentState());
  }
}
