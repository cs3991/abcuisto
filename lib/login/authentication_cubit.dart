import 'package:abcuisto/abcuisto_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';


@immutable
abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}
class AuthenticationLoggedIn extends AuthenticationState {}
class AuthenticationLoggedOut extends AuthenticationState {}
class AuthenticationLoading extends AuthenticationState {}

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AbcuistoRepository repository;
  AuthenticationCubit(this.repository) : super(AuthenticationInitial());

  Future<void> initialize() async {
    await repository.init();
    checkAuthentication();
  }

  Future<void> logIn(String username, String password) async {
    emit(AuthenticationLoading());
    await repository.login(username, password);
    emit(AuthenticationLoggedIn());
  }

  void logOut() {
    emit(AuthenticationLoading());
    repository.logout();
    emit(AuthenticationLoggedOut());
  }

  void checkAuthentication() {
    if (repository.pb.authStore.isValid) {
      emit(AuthenticationLoggedIn());
    } else {
      emit(AuthenticationLoggedOut());
    }
  }

}
