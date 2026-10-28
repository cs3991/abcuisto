import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';
import '../../models/recipe.dart';
import '../../pulsing_placeholder.dart';
import 'group_cubit.dart';

enum GroupDetailsResult { deleted, left }

class GroupDetailsPage extends StatelessWidget {
  final RecipeGroup group;

  const GroupDetailsPage({super.key, required this.group});

  Future<void> _copyInvitation(BuildContext context, String link) async {
    try {
      await Clipboard.setData(ClipboardData(text: link));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lien d’invitation copié.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de copier le lien d’invitation.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupCubit(context.read<AbcuistoRepository>(), group)..loadGroup(),
      child: Scaffold(
        appBar: AppBar(title: Text(group.name ?? 'Groupe')),
        body: BlocConsumer<GroupCubit, GroupState>(
          listener: (context, state) {
            if (state.status == GroupStatus.deleted) Navigator.of(context).pop(GroupDetailsResult.deleted);
            if (state.status == GroupStatus.left) Navigator.of(context).pop(GroupDetailsResult.left);
          },
          builder: (context, state) {
            final loading = state.status == GroupStatus.loading;
            final deleting = state.status == GroupStatus.deleting || state.status == GroupStatus.leaving;
            return PopScope(
              canPop: !deleting,
              child: RefreshIndicator(
                onRefresh: context.read<GroupCubit>().loadGroup,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Icon(Icons.group_rounded, size: 72),
                    const SizedBox(height: 24),
                    Text('Membres', style: Theme.of(context).textTheme.titleLarge),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      TextButton(onPressed: deleting ? null : context.read<GroupCubit>().loadGroup, child: const Text('Réessayer')),
                    ],
                    if (state.status == GroupStatus.success && state.members.isEmpty)
                      const Padding(padding: EdgeInsets.only(top: 16), child: Text('Aucun membre.')),
                    for (var index = 0; index < (loading ? 3 : state.members.length); index++)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: loading ? const PulsingPlaceholder(width: 24, height: 24) : const Icon(Icons.person_rounded),
                        title: loading
                            ? const Align(alignment: Alignment.centerLeft, child: PulsingPlaceholder(width: 180, height: 20))
                            : Text(state.members[index].userName),
                        subtitle: !loading && state.members[index].id == state.group.owner ? const Text('Propriétaire') : null,
                      ),
                    const SizedBox(height: 24),
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      color: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minVerticalPadding: 4,
                        title: const Text('Inviter des proches'),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (state.group.link?.isNotEmpty ?? false)
                                    ? 'Copiez ce lien et envoyez-le aux personnes que vous souhaitez inviter dans le groupe.'
                                    : 'Aucun lien d’invitation disponible pour ce groupe.',
                              ),
                              if (state.group.link?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 6),
                                Text(state.group.link!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                              ],
                            ],
                          ),
                        ),
                        trailing: Icon(Icons.copy_rounded, color: Theme.of(context).colorScheme.primary),
                        enabled: !deleting && (state.group.link?.isNotEmpty ?? false),
                        onTap: deleting || !(state.group.link?.isNotEmpty ?? false) ? null : () => _copyInvitation(context, state.group.link!),
                      ),
                    ),
                    if (state.canLeave) ...[
                      const SizedBox(height: 24),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minVerticalPadding: 4,
                        title: Text(state.status == GroupStatus.leaving ? 'Départ…' : 'Quitter le groupe'),
                        subtitle: const Text('Vous ne ferez plus partie de ce groupe et perdrez l’accès à ses recettes privées.'),
                        trailing: const Icon(Icons.logout_rounded),
                        textColor: Theme.of(context).colorScheme.error,
                        iconColor: Theme.of(context).colorScheme.error,
                        enabled: !loading && !deleting,
                        onTap: loading || deleting ? null : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Quitter le groupe ?'),
                              content: const Text('Vous pourrez le rejoindre à nouveau avec une invitation.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quitter')),
                              ],
                            ),
                          );
                          if (!context.mounted || confirmed != true) return;
                          await context.read<GroupCubit>().leaveGroup();
                        },
                      ),
                    ],
                    if (state.canDelete) ...[
                      const SizedBox(height: 24),
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minVerticalPadding: 4,
                          textColor: Theme.of(context).colorScheme.error,
                          iconColor: Theme.of(context).colorScheme.error,
                          enabled: !loading && !deleting,
                          onTap: loading || deleting
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Supprimer le groupe ?'),
                                      content: const Text('Cette suppression est définitive.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
                                      ],
                                    ),
                                  );
                                  if (!context.mounted || confirmed != true) return;
                                  await context.read<GroupCubit>().deleteGroup();
                                },
                          trailing: const Icon(Icons.delete_rounded),
                          title: Text(deleting ? 'Suppression…' : 'Supprimer le groupe'),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Supprime définitivement ce groupe. Cette action ne peut pas être annulée.'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
