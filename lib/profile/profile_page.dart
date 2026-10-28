import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../login/authentication_cubit.dart';
import '../models/abcuisto_repository.dart';
import '../models/recipe.dart';
import '../recipe/filters/filter_cubit.dart';
import 'profile_cubit.dart';
import 'groups/create_group_dialog.dart';
import 'groups/group_details_page.dart';
import '../pulsing_placeholder.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _openGroup(BuildContext context, RecipeGroup group) async {
    final deleted = await Navigator.push<bool>(context, MaterialPageRoute(
      builder: (context) => GroupDetailsPage(group: group),
    ));
    if (!context.mounted || deleted != true) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Groupe supprimé.')));
    context.read<FilterCubit>().update();
    await context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(context.read<AbcuistoRepository>())..loadProfile(),
      child: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationLoggedOut) {
            context.read<FilterCubit>().update();
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Mon profil')),
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final user = state.user;
              final loading = state.status == ProfileStatus.loading;
              final groups = user?.groups.where((group) => !group.isPublic).toList() ?? [];
              return RefreshIndicator(
                onRefresh: context.read<ProfileCubit>().loadProfile,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (state.errorMessage != null) ...[
                      Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      TextButton(
                        onPressed: context.read<ProfileCubit>().loadProfile,
                        child: const Text('Réessayer'),
                      ),
                    ],
                    if (loading || user != null) ...[
                      Center(
                        child: loading
                            ? const PulsingPlaceholder(width: 72, height: 72)
                            : const Icon(Icons.account_circle_rounded, size: 72),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: loading
                            ? const PulsingPlaceholder(width: 180, height: 28)
                            : Text(user!.userName ?? user.email ?? 'Mon profil', style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      if (loading || user?.email != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: loading
                              ? const PulsingPlaceholder(width: 240, height: 16)
                              : Text(user!.email!),
                        ),
                      if (loading || (user?.bio?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 12),
                        loading
                            ? const PulsingPlaceholder(width: double.infinity, height: 16)
                            : Text(user!.bio!),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(child: Text('Mes groupes', style: Theme.of(context).textTheme.titleLarge)),
                          IconButton(
                            tooltip: 'Créer un groupe',
                            icon: const Icon(Icons.group_add_rounded),
                            onPressed: loading ? null : () async {
                              final created = await showCreateGroupDialog(context);
                              if (!context.mounted || created != true) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Groupe créé.')));
                              context.read<FilterCubit>().update();
                              await context.read<ProfileCubit>().loadProfile();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!loading && groups.isEmpty) const Text('Vous ne faites partie d’aucun groupe.'),
                      for (var index = 0; index < (loading ? 3 : groups.length); index++)
                        ListTile(
                          onTap: loading || groups[index].id == null ? null : () => _openGroup(context, groups[index]),
                          trailing: loading ? null : const Icon(Icons.chevron_right_rounded),
                          contentPadding: EdgeInsets.zero,
                          leading: loading
                              ? const PulsingPlaceholder(width: 24, height: 24)
                              : const Icon(Icons.group_rounded),
                          title: loading
                              ? const Align(
                                  alignment: Alignment.centerLeft,
                                  child: PulsingPlaceholder(width: 180, height: 20),
                                )
                              : Text(groups[index].name ?? 'Groupe'),
                          subtitle: !loading && groups[index].owner == user?.id ? const Text('Propriétaire') : null,
                        ),
                    ],
                    const SizedBox(height: 32),
                    BlocBuilder<AuthenticationCubit, AuthenticationState>(
                      builder: (context, authState) => OutlinedButton.icon(
                        onPressed: authState is AuthenticationLoggedIn
                            ? () => context.read<AuthenticationCubit>().logOut()
                            : null,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Se déconnecter'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
