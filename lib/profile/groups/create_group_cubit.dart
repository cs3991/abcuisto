import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';

enum CreateGroupStatus { initial, loading, success, failure }

@immutable
class CreateGroupState {
  final CreateGroupStatus status;
  final String? errorMessage;

  const CreateGroupState({this.status = CreateGroupStatus.initial, this.errorMessage});
}

class CreateGroupCubit extends Cubit<CreateGroupState> {
  final AbcuistoRepository repository;

  CreateGroupCubit(this.repository) : super(const CreateGroupState());

  Future<void> createGroup(String name) async {
    if (state.status == CreateGroupStatus.loading || state.status == CreateGroupStatus.success) return;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      emit(const CreateGroupState(status: CreateGroupStatus.failure, errorMessage: 'Saisissez un nom de groupe.'));
      return;
    }
    emit(const CreateGroupState(status: CreateGroupStatus.loading));
    try {
      await repository.createNewGroup(trimmedName);
      if (isClosed) return;
      emit(const CreateGroupState(status: CreateGroupStatus.success));
    } catch (error) {
      if (isClosed) return;
      emit(CreateGroupState(status: CreateGroupStatus.failure, errorMessage: error.toString()));
    }
  }
}
