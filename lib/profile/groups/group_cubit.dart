import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';
import '../../models/group_member.dart';
import '../../models/recipe.dart';

enum GroupStatus { initial, loading, success, failure }

@immutable
class GroupState {
  final RecipeGroup group;
  final List<GroupMember> members;
  final GroupStatus status;
  final String? errorMessage;

  const GroupState({required this.group, this.members = const [], this.status = GroupStatus.initial, this.errorMessage});

  GroupState copyWith({required GroupStatus status, List<GroupMember>? members, String? errorMessage}) => GroupState(
    group: group,
    members: members ?? this.members,
    status: status,
    errorMessage: errorMessage,
  );
}

class GroupCubit extends Cubit<GroupState> {
  final AbcuistoRepository repository;

  GroupCubit(this.repository, RecipeGroup group) : super(GroupState(group: group));

  Future<void> loadGroup() async {
    if (state.status == GroupStatus.loading) return;
    emit(state.copyWith(status: GroupStatus.loading));
    try {
      final id = state.group.id;
      if (id == null) throw const FormatException('Identifiant du groupe manquant.');
      final members = await repository.getGroupMembers(id);
      if (isClosed) return;
      emit(state.copyWith(status: GroupStatus.success, members: members));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: GroupStatus.failure, errorMessage: error.toString()));
    }
  }
}
