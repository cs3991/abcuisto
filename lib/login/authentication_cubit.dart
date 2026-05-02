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
    emit(AuthenticationLoggedIn(username: repository.pb.authStore.record!.get('name')));
  }

  void logOut() {
    emit(AuthenticationLoading());
    repository.logout();
    emit(AuthenticationLoggedOut());
  }

  void checkAuthentication() {
    if (repository.pb.authStore.isValid) {
      emit(AuthenticationLoggedIn(username: repository.pb.authStore.record!.get('name')));
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
