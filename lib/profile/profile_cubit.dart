import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/abcuisto_repository.dart';
import '../models/user.dart';

enum ProfileStatus { initial, loading, success, failure }
enum ProfileSaveStatus { initial, saving, success, failure }

@immutable
class ProfileState {
  final ProfileStatus status;
  final User? user;
  final String? errorMessage;
  final ProfileSaveStatus saveStatus;
  final String? saveError;

  const ProfileState({this.status = ProfileStatus.initial, this.user, this.errorMessage,
    this.saveStatus = ProfileSaveStatus.initial, this.saveError});

  ProfileState copyWith({ProfileStatus? status, User? user, String? errorMessage,
    ProfileSaveStatus? saveStatus, String? saveError}) =>
      ProfileState(status: status ?? this.status, user: user ?? this.user, errorMessage: errorMessage,
        saveStatus: saveStatus ?? this.saveStatus, saveError: saveError);
}

class ProfileCubit extends Cubit<ProfileState> {
  final AbcuistoRepository repository;

  ProfileCubit(this.repository) : super(ProfileState(user: repository.user));

  void resetSave() {
    if (state.saveStatus == ProfileSaveStatus.saving) return;
    emit(state.copyWith(saveStatus: ProfileSaveStatus.initial, errorMessage: state.errorMessage));
  }

  Future<void> updateBio(String bio) => _save(() => repository.updateBio(bio: bio.trim()));

  Future<void> updateEmail(String email) async {
    final value = email.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      _saveFailure('Saisissez une adresse e-mail valide.');
      return;
    }
    await _save(() => repository.updateEmail(email: value));
  }

  Future<void> updatePassword(String current, String password, String confirmation) async {
    if (current.isEmpty || password.isEmpty || confirmation.isEmpty) {
      _saveFailure('Remplissez les trois champs de mot de passe.');
      return;
    }
    if (password != confirmation) {
      _saveFailure('La confirmation ne correspond pas au nouveau mot de passe.');
      return;
    }
    await _save(() => repository.updatePassword(
      lastPassword: current, newPassword: password, confirmNewPassword: confirmation));
  }

  void _saveFailure(String message) {
    if (state.saveStatus == ProfileSaveStatus.saving) return;
    emit(state.copyWith(saveStatus: ProfileSaveStatus.failure, saveError: message, errorMessage: state.errorMessage));
  }

  Future<void> _save(Future<dynamic> Function() action) async {
    if (state.saveStatus == ProfileSaveStatus.saving) return;
    emit(state.copyWith(saveStatus: ProfileSaveStatus.saving, errorMessage: state.errorMessage));
    try {
      await action();
      if (isClosed) return;
      emit(state.copyWith(saveStatus: ProfileSaveStatus.success, errorMessage: state.errorMessage));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(saveStatus: ProfileSaveStatus.failure, saveError: error.toString(), errorMessage: state.errorMessage));
    }
  }

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
