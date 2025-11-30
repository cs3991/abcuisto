import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'filters/filter_cubit.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 65,
      // leading: IconButton(onPressed: () {}, icon: Icon(Icons.filter_list_rounded)),
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher une recette',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          constraints: BoxConstraints(maxHeight: 50),
          isDense: false,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainer,
          suffixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.outline),
        ),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        onChanged: (t) => context.read<FilterCubit>().updateSearchPattern(t),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: IconButton(icon: Icon(Icons.person_rounded), onPressed: () {}),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
