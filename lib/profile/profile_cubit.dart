import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/abcuisto_repository.dart';
import '../models/user.dart';

enum ProfileStatus { initial, loading, success, failure }

@immutable
class ProfileState {
  final ProfileStatus status;
  final User? user;
  final String? errorMessage;

  const ProfileState({this.status = ProfileStatus.initial, this.user, this.errorMessage});

  ProfileState copyWith({required ProfileStatus status, User? user, String? errorMessage}) =>
      ProfileState(status: status, user: user ?? this.user, errorMessage: errorMessage);
}

class ProfileCubit extends Cubit<ProfileState> {
  final AbcuistoRepository repository;

  ProfileCubit(this.repository) : super(ProfileState(user: repository.user));

  Future<void> loadProfile() async {
    if (state.status == ProfileStatus.loading) return;
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await repository.getUserInfos();
      if (isClosed) return;
      emit(state.copyWith(status: ProfileStatus.success, user: user));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: ProfileStatus.failure, errorMessage: error.toString()));
    }
  }
}
