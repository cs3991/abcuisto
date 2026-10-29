import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

@immutable
class ThemeState {
  final ThemeMode mode;
  final String? errorMessage;

  const ThemeState({this.mode = ThemeMode.system, this.errorMessage});
}

class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  @override
  String get storagePrefix => 'ThemeCubit';

  void cycleTheme() => emit(ThemeState(mode: switch (state.mode) {
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
    ThemeMode.system => ThemeMode.light,
  }));

  @override
  ThemeState fromJson(Map<String, dynamic> json) => ThemeState(
    mode: ThemeMode.values.firstWhere(
      (mode) => mode.name == json['mode'],
      orElse: () => ThemeMode.system,
    ),
  );

  @override
  Map<String, dynamic>? toJson(ThemeState state) =>
      state.errorMessage == null ? {'mode': state.mode.name} : null;

  @override
  void onError(Object error, StackTrace stackTrace) {
    emit(ThemeState(mode: state.mode, errorMessage: 'Impossible de mémoriser le thème.'));
    super.onError(error, stackTrace);
  }
}
