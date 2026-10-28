import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';
import 'join_group_cubit.dart';

Future<bool?> showJoinGroupDialog(BuildContext context, {String initialInvitation = ''}) {
  final repository = context.read<AbcuistoRepository>();
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => BlocProvider(
      create: (_) => JoinGroupCubit(repository),
      child: _JoinGroupDialog(initialInvitation: initialInvitation),
    ),
  );
}

class _JoinGroupDialog extends StatefulWidget {
  final String initialInvitation;

  const _JoinGroupDialog({required this.initialInvitation});

  @override
  State<_JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<_JoinGroupDialog> {
  late final TextEditingController _invitationController;

  @override
  void initState() {
    super.initState();
    _invitationController = TextEditingController(text: widget.initialInvitation);
  }

  @override
  void dispose() {
    _invitationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JoinGroupCubit, JoinGroupState>(
      listener: (context, state) {
        if (state.status == JoinGroupStatus.success) Navigator.of(context).pop(true);
      },
      builder: (context, state) {
        final loading = state.status == JoinGroupStatus.loading;
        return PopScope(
          canPop: !loading,
          child: AlertDialog(
            title: const Text('Rejoindre un groupe'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _invitationController,
                  autofocus: true,
                  enabled: !loading,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Lien d’invitation ou ID du groupe'),
                  onSubmitted: (_) => context.read<JoinGroupCubit>().joinGroup(_invitationController.text),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: loading ? null : () => context.read<JoinGroupCubit>().joinGroup(_invitationController.text),
                child: Text(loading ? 'Adhésion…' : 'Rejoindre'),
              ),
            ],
          ),
        );
      },
    );
  }
}
