import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'app_link.dart';

@immutable
class AppLinkState {
  final AppLink? link;
  final String? errorMessage;

  const AppLinkState({this.link, this.errorMessage});
}

class AppLinkCubit extends Cubit<AppLinkState> {
  final AppLinks appLinks;
  StreamSubscription<Uri>? _subscription;

  AppLinkCubit(this.appLinks) : super(const AppLinkState());

  void start() {
    if (_subscription != null) return;
    _subscription = appLinks.uriLinkStream.listen((uri) {
      final link = AppLink.fromUri(uri);
      emit(link == null
          ? const AppLinkState(errorMessage: 'Ce lien ABCuisto est invalide ou non pris en charge.')
          : AppLinkState(link: link));
    }, onError: (Object error) {
      emit(const AppLinkState(errorMessage: 'Impossible d’ouvrir le lien reçu.'));
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
