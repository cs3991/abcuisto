import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/abcuisto_repository.dart';
import '../../models/recipe.dart';
import '../../models/group_member.dart';
import '../../pulsing_placeholder.dart';
import 'group_cubit.dart';

enum GroupDetailsResult { deleted, left, transferred }

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

  Future<void> _shareInvitation(BuildContext context, RecipeGroup group) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(ShareParams(
        text: 'Rejoins le groupe ${group.name ?? "ABCuisto"} sur ABCuisto : ${group.link}',
        subject: 'Invitation au groupe ${group.name ?? "ABCuisto"}',
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de partager l’invitation. Vous pouvez copier le lien.')));
    }
  }

  Future<void> _chooseNewOwner(BuildContext context, GroupState state) async {
    final candidates = state.members.where((member) => member.id != state.group.owner).toList();
    final member = await showDialog<GroupMember>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le nouveau propriétaire'),
        content: SizedBox(
          width: double.maxFinite,
          child: candidates.isEmpty
              ? const Text('Invitez un autre membre pour pouvoir transférer la propriété.')
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final candidate in candidates)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(candidate.userName),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.pop(context, candidate),
                      ),
                  ],
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))],
      ),
    );
    if (!context.mounted || member == null) return;
    await _confirmTransfer(context, member);
  }

  Future<void> _confirmTransfer(BuildContext context, GroupMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transférer la propriété ?'),
        content: Text('${member.userName} deviendra propriétaire du groupe. Vous resterez membre et perdrez vos droits de propriétaire.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Transférer')),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    await context.read<GroupCubit>().transferOwnership(member);
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
            if (state.status == GroupStatus.transferred) Navigator.of(context).pop(GroupDetailsResult.transferred);
            if (state.status == GroupStatus.left) Navigator.of(context).pop(GroupDetailsResult.left);
          },
          builder: (context, state) {
            final loading = state.status == GroupStatus.loading;
            final deleting = state.status == GroupStatus.deleting || state.status == GroupStatus.leaving || state.status == GroupStatus.transferring;
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
                    ListTile(
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
                    if (state.group.link?.isNotEmpty ?? false)
                      Builder(
                        builder: (context) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minVerticalPadding: 4,
                          title: const Text('Partager l’invitation'),
                          subtitle: const Text('Envoyez le lien avec l’application de votre choix.'),
                          trailing: Icon(Icons.share_rounded, color: Theme.of(context).colorScheme.primary),
                          enabled: !deleting,
                          onTap: deleting ? null : () => _shareInvitation(context, state.group),
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
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minVerticalPadding: 4,
                        textColor: Theme.of(context).colorScheme.error,
                        iconColor: Theme.of(context).colorScheme.error,
                        title: Text(state.status == GroupStatus.transferring ? 'Transfert en cours…' : 'Transférer la propriété'),
                        subtitle: const Text('Confiez la gestion du groupe à un autre membre. Vous resterez membre du groupe.'),
                        trailing: const Icon(Icons.manage_accounts_rounded),
                        enabled: !loading && !deleting,
                        onTap: loading || deleting ? null : () => _chooseNewOwner(context, state),
                      ),
                      ListTile(
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
                        title: Text(state.status == GroupStatus.deleting ? 'Suppression…' : 'Supprimer le groupe'),
                        subtitle: const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Supprime définitivement ce groupe. Cette action ne peut pas être annulée.'),
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
