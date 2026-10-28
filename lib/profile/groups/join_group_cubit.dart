import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';
import '../../models/recipe.dart';

enum JoinGroupStatus { initial, loading, success, failure }

@immutable
class JoinGroupState {
  final JoinGroupStatus status;
  final String? errorMessage;

  const JoinGroupState({this.status = JoinGroupStatus.initial, this.errorMessage});
}

class JoinGroupCubit extends Cubit<JoinGroupState> {
  final AbcuistoRepository repository;

  JoinGroupCubit(this.repository) : super(const JoinGroupState());

  Future<void> joinGroup(String invitation) async {
    if (state.status == JoinGroupStatus.loading || state.status == JoinGroupStatus.success) return;
    emit(const JoinGroupState(status: JoinGroupStatus.loading));
    try {
      var id = invitation.trim();
      final uri = Uri.tryParse(id);
      if (uri != null && uri.hasScheme) {
        final segments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
        if (uri.scheme != 'https' || !const {'abcuisto.fr', 'dev.abcuisto.fr'}.contains(uri.host) || segments.length != 2 || segments.first != 'group') {
          throw const FormatException('Lien d’invitation invalide.');
        }
        id = segments.last;
      }
      if (!RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(id)) {
        throw const FormatException('Saisissez un lien d’invitation ou un ID de groupe valide.');
      }
      if (id.toLowerCase() == RecipeGroup.publicGroup.id) {
        throw const FormatException('Le groupe Public est accessible à tous.');
      }
      final user = repository.user;
      if (user == null) throw const FormatException('Connectez-vous pour rejoindre un groupe.');
      if (user.groups.any((group) => group.id?.toLowerCase() == id.toLowerCase())) {
        throw const FormatException('Vous faites déjà partie de ce groupe.');
      }
      await repository.joinGroup(groupId: id, memberId: user.id, memberUserName: user.userName);
      if (isClosed) return;
      emit(const JoinGroupState(status: JoinGroupStatus.success));
    } catch (error) {
      if (isClosed) return;
      emit(JoinGroupState(status: JoinGroupStatus.failure, errorMessage: error.toString()));
    }
  }
}
