import 'package:abcuisto/models/abcuisto_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';


@immutable
abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoggedIn extends AuthenticationState {
  final String username;

  AuthenticationLoggedIn({required this.username});
}

class AuthenticationLoggedOut extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationLoggedOut {
  final String message;

  AuthenticationFailure({required this.message});
}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final AbcuistoRepository repository;
  AuthenticationCubit(this.repository) : super(AuthenticationInitial());

  Future<void> initialize() async {
    await repository.init();
    checkAuthentication();
  }

  Future<bool> logIn(String email, String password) async {
    emit(AuthenticationLoading());
    try {
      await repository.login(email, password);
      emit(AuthenticationLoggedIn(username: repository.authEmail ?? email));
      return true;
    } on Exception catch (error) {
      emit(AuthenticationFailure(message: error.toString()));
      return false;
    }
  }

  Future<void> logOut() async {
    emit(AuthenticationLoading());
    await repository.logout();
    emit(AuthenticationLoggedOut());
  }

  void checkAuthentication() {
    if (repository.isAuthenticated) {
      emit(AuthenticationLoggedIn(username: repository.authEmail ?? ''));
    } else {
      emit(AuthenticationLoggedOut());
    }
  }

  Future<void> sendPasswordReset(String email) async {
    // todo: call pocketbase for password reset
  }

  void signUp(String email, String password, String username) {
    // todo: call pocketbase for signup
  }
}
