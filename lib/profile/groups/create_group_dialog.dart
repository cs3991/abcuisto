import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';
import 'create_group_cubit.dart';

Future<bool?> showCreateGroupDialog(BuildContext context) {
  final repository = context.read<AbcuistoRepository>();
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => BlocProvider(
      create: (_) => CreateGroupCubit(repository),
      child: const _CreateGroupDialog(),
    ),
  );
}

class _CreateGroupDialog extends StatefulWidget {
  const _CreateGroupDialog();

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateGroupCubit, CreateGroupState>(
      listener: (context, state) {
        if (state.status == CreateGroupStatus.success) Navigator.of(context).pop(true);
      },
      builder: (context, state) {
        final loading = state.status == CreateGroupStatus.loading;
        return AlertDialog(
          title: const Text('Créer un groupe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                enabled: !loading,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Nom du groupe'),
                onSubmitted: (_) => context.read<CreateGroupCubit>().createGroup(_nameController.text),
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
              onPressed: loading ? null : () => context.read<CreateGroupCubit>().createGroup(_nameController.text),
              child: Text(loading ? 'Création…' : 'Créer'),
            ),
          ],
        );
      },
    );
  }
}
