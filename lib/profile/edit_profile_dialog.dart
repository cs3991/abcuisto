import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets.dart';
import 'profile_cubit.dart';

enum ProfileEdit { bio, email, password }

Future<void> showEditProfileDialog(BuildContext context, ProfileEdit edit) async {
  final cubit = context.read<ProfileCubit>();
  cubit.resetSave();
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => BlocProvider.value(value: cubit, child: _EditProfileDialog(edit: edit)),
  );
  if (!context.mounted || saved != true) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(switch (edit) {
    ProfileEdit.bio => 'Bio enregistrée.',
    ProfileEdit.email => 'Demande de changement envoyée. Vérifiez vos e-mails pour une éventuelle confirmation.',
    ProfileEdit.password => 'Mot de passe modifié.',
  })));
  await cubit.loadProfile();
}

class _EditProfileDialog extends StatefulWidget {
  final ProfileEdit edit;

  const _EditProfileDialog({required this.edit});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _value = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileCubit>().state.user;
    _value.text = switch (widget.edit) {
      ProfileEdit.bio => user?.bio ?? '',
      ProfileEdit.email => user?.email ?? '',
      ProfileEdit.password => '',
    };
  }

  @override
  void dispose() {
    _value.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    final cubit = context.read<ProfileCubit>();
    switch (widget.edit) {
      case ProfileEdit.bio:
        cubit.updateBio(_value.text);
      case ProfileEdit.email:
        cubit.updateEmail(_value.text);
      case ProfileEdit.password:
        cubit.updatePassword(_password.text, _value.text, _confirmation.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) => previous.saveStatus != current.saveStatus,
      listener: (context, state) {
        if (state.saveStatus == ProfileSaveStatus.success) Navigator.of(context).pop(true);
      },
      builder: (context, state) {
        final saving = state.saveStatus == ProfileSaveStatus.saving;
        final edit = widget.edit;
        return PopScope(
          canPop: !saving,
          child: AlertDialog(
            title: Text(switch (edit) {
              ProfileEdit.bio => 'Modifier la bio',
              ProfileEdit.email => 'Changer l’adresse e-mail',
              ProfileEdit.password => 'Changer le mot de passe',
            }),
            content: SingleChildScrollView(
              child: SizedBox(
                width: edit == ProfileEdit.bio ? 480 : null,
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (edit == ProfileEdit.password) ...[
                    RoundedTextField(
                      controller: _password,
                      enabled: !saving,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      hintText: 'Mot de passe actuel',
                    ),
                    const SizedBox(height: 12),
                  ],
                  RoundedTextField(
                    controller: _value,
                    enabled: !saving,
                    autofocus: true,
                    obscureText: edit == ProfileEdit.password,
                    autocorrect: edit == ProfileEdit.bio,
                    enableSuggestions: edit == ProfileEdit.bio,
                    minLines: edit == ProfileEdit.bio ? 6 : 1,
                    maxLines: edit == ProfileEdit.bio ? 10 : 1,
                    keyboardType: switch (edit) {
                      ProfileEdit.bio => TextInputType.multiline,
                      ProfileEdit.email => TextInputType.emailAddress,
                      ProfileEdit.password => TextInputType.visiblePassword,
                    },
                    hintText: switch (edit) {
                      ProfileEdit.bio => 'Bio',
                      ProfileEdit.email => 'Nouvelle adresse e-mail',
                      ProfileEdit.password => 'Nouveau mot de passe',
                    },
                  ),
                  if (edit == ProfileEdit.password) ...[
                    const SizedBox(height: 12),
                    RoundedTextField(
                      controller: _confirmation,
                      enabled: !saving,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      hintText: 'Confirmer le nouveau mot de passe',
                    ),
                  ],
                  if (edit == ProfileEdit.email) ...[
                    const SizedBox(height: 12),
                    const Text('Une confirmation par e-mail peut être nécessaire pour finaliser le changement.'),
                  ],
                  if (state.saveError != null) ...[
                    const SizedBox(height: 12),
                    Text(state.saveError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: saving ? null : () => Navigator.of(context).pop(false), child: const Text('Annuler')),
              FilledButton(onPressed: saving ? null : _submit, child: Text(saving ? 'Enregistrement…' : 'Enregistrer')),
            ],
          ),
        );
      },
    );
  }
}
