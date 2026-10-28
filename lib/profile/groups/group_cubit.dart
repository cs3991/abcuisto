import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';
import '../../models/group_member.dart';
import '../../models/recipe.dart';

enum GroupStatus { initial, loading, success, failure, deleting, deleted, leaving, left, transferring, transferred }

@immutable
class GroupState {
  final RecipeGroup group;
  final List<GroupMember> members;
  final GroupStatus status;
  final String? errorMessage;
  final bool canDelete;
  final bool canLeave;

  const GroupState({required this.group, this.members = const [], this.status = GroupStatus.initial, this.errorMessage, this.canDelete = false, this.canLeave = false});

  GroupState copyWith({required GroupStatus status, List<GroupMember>? members, String? errorMessage}) => GroupState(
    group: group,
    canDelete: canDelete,
    canLeave: canLeave,
    members: members ?? this.members,
    status: status,
    errorMessage: errorMessage,
  );
}

class GroupCubit extends Cubit<GroupState> {
  final AbcuistoRepository repository;

  GroupCubit(this.repository, RecipeGroup group) : super(GroupState(group: group, canDelete: !group.isPublic && repository.user != null && group.owner == repository.user!.id, canLeave: !group.isPublic && group.owner != null && repository.user != null && group.owner != repository.user!.id && repository.user!.groups.any((value) => value.id == group.id)));

  Future<void> transferOwnership(GroupMember member) async {
    if (!state.canDelete || state.status == GroupStatus.loading || state.status == GroupStatus.deleting || state.status == GroupStatus.deleted || state.status == GroupStatus.leaving || state.status == GroupStatus.left || state.status == GroupStatus.transferring || state.status == GroupStatus.transferred) return;
    if (member.id == state.group.owner || !state.members.any((value) => value.id == member.id)) {
      emit(state.copyWith(status: GroupStatus.failure, errorMessage: 'Choisissez un autre membre du groupe.'));
      return;
    }
    emit(state.copyWith(status: GroupStatus.transferring));
    try {
      final id = state.group.id;
      if (id == null) throw const FormatException('Identifiant du groupe manquant.');
      await repository.changeGroupOwner(groupId: id, newOwnerId: member.id);
      if (isClosed) return;
      emit(state.copyWith(status: GroupStatus.transferred));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: GroupStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> leaveGroup() async {
    if (!state.canLeave || state.status == GroupStatus.loading || state.status == GroupStatus.deleting || state.status == GroupStatus.deleted || state.status == GroupStatus.leaving || state.status == GroupStatus.left || state.status == GroupStatus.transferring || state.status == GroupStatus.transferred) return;
    emit(state.copyWith(status: GroupStatus.leaving));
    try {
      final id = state.group.id;
      final user = repository.user;
      if (id == null || user == null) throw const FormatException('Groupe ou utilisateur manquant.');
      await repository.quitGroup(groupId: id, memberId: user.id);
      if (isClosed) return;
      emit(state.copyWith(status: GroupStatus.left));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: GroupStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> deleteGroup() async {
    if (!state.canDelete || state.status == GroupStatus.loading || state.status == GroupStatus.deleting || state.status == GroupStatus.deleted || state.status == GroupStatus.leaving || state.status == GroupStatus.left || state.status == GroupStatus.transferring || state.status == GroupStatus.transferred) return;
    emit(state.copyWith(status: GroupStatus.deleting));
    try {
      final id = state.group.id;
      if (id == null) throw const FormatException('Identifiant du groupe manquant.');
      await repository.deleteGroup(id);
      if (isClosed) return;
      emit(state.copyWith(status: GroupStatus.deleted));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: GroupStatus.failure, errorMessage: error.toString()));
    }
  }

  Future<void> loadGroup() async {
    if (state.status == GroupStatus.loading || state.status == GroupStatus.deleting || state.status == GroupStatus.deleted || state.status == GroupStatus.leaving || state.status == GroupStatus.left || state.status == GroupStatus.transferring || state.status == GroupStatus.transferred) return;
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
