import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/abcuisto_repository.dart';
import '../../models/recipe.dart';
import '../../pulsing_placeholder.dart';
import 'group_cubit.dart';

class GroupDetailsPage extends StatelessWidget {
  final RecipeGroup group;

  const GroupDetailsPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupCubit(context.read<AbcuistoRepository>(), group)..loadGroup(),
      child: Scaffold(
        appBar: AppBar(title: Text(group.name ?? 'Groupe')),
        body: BlocBuilder<GroupCubit, GroupState>(
          builder: (context, state) {
            final loading = state.status == GroupStatus.loading;
            return RefreshIndicator(
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
                    TextButton(onPressed: context.read<GroupCubit>().loadGroup, child: const Text('Réessayer')),
                  ],
                  if (state.status == GroupStatus.success && state.members.isEmpty)
                    const Padding(padding: EdgeInsets.only(top: 16), child: Text('Aucun membre.')),
                  for (var index = 0; index < (loading ? 3 : state.members.length); index++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: loading
                          ? const PulsingPlaceholder(width: 24, height: 24)
                          : const Icon(Icons.person_rounded),
                      title: loading
                          ? const Align(
                              alignment: Alignment.centerLeft,
                              child: PulsingPlaceholder(width: 180, height: 20),
                            )
                          : Text(state.members[index].userName),
                      subtitle: !loading && state.members[index].id == state.group.owner
                          ? const Text('Propriétaire')
                          : null,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
